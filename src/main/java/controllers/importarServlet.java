package controllers;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import dao.empleadoDAO;
import dao.marcacionDAO;
import dao.auditoriaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import model.empleado;
import model.marcacion;
import model.resultadoImportacion;

//Importa marcaciones desde un archivo .dat/.txt: valida, muestra el resumen y guarda al confirmar
@WebServlet("/ImportarServlet")
@MultipartConfig(
    //tamaño máximo del archivo: 5 MB
    maxFileSize = 5 * 1024 * 1024,
    maxRequestSize = 6 * 1024 * 1024
)
public class importarServlet extends HttpServlet
{

	private static final long serialVersionUID = 1L;

	private static final String PAGINA = "/jsp/importar.jsp";
	//el resultado queda en la sesión hasta que el usuario confirme o cancele
	private static final String SESION_RESULTADO = "resultadoImportacion";
	private static final String SESION_MENSAJE = "mensajeImportacion";

	//formato del archivo: 2026-09-01 06:04:25
	private static final DateTimeFormatter FORMATO_FECHA =
			DateTimeFormatter.ofPattern("uuuu-MM-dd HH:mm:ss").withResolverStyle(ResolverStyle.STRICT);

	//columnas que debe tener cada línea del archivo
	private static final int COLUMNAS = 6;

	private final empleadoDAO empDAO = new empleadoDAO();
	private final marcacionDAO marcDAO = new marcacionDAO();

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        response.sendRedirect(request.getContextPath() + PAGINA);
    }

	//Según la acción: guardar, cancelar o procesar el archivo (por defecto)
	@Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        request.setCharacterEncoding("UTF-8");

        String accion = request.getParameter("accion");

        if ("guardar".equals(accion))
        {
            guardar(request, response);
        }
        else if ("cancelar".equals(accion))
        {
            cancelar(request, response);
        }
        else
        {
            procesar(request, response);
        }
    }
	

	private static final DateTimeFormatter FORMATO_HORA = DateTimeFormatter.ofPattern("HH:mm:ss");

	//marcacion de referencia: linea 0 = ya estaba en la base de datos
	private static class Referencia
	{
	    final LocalDateTime hora;
	    final int linea;

	    Referencia(LocalDateTime hora, int linea)
	    {
	        this.hora = hora;
	        this.linea = linea;
	    }
	}
	
	//---------------------------------------------------------------
	// IMPORTAR: pasos 1 al 9
	//---------------------------------------------------------------
	private void procesar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        Part archivo = request.getPart("archivo");
        String nombre = archivo == null ? null : archivo.getSubmittedFileName();

        if (nombre == null || nombre.trim().isEmpty())
        {
            error(request, response, "Selecciona un archivo.");
            return;
        }

        //paso 1: extension permitida
        String minuscula = nombre.toLowerCase();

        if (!(minuscula.endsWith(".txt") || minuscula.endsWith(".dat")))
        {
            error(request, response, "Solo se permiten archivos TXT o DAT.");
            return;
        }

        //paso 2: archivo no vacio
        if (archivo.getSize() == 0)
        {
            error(request, response, "El archivo está vacío.");
            return;
        }

        //paso 3: leer cada registro
        List<marcacion> registros = leer(archivo);

        if (registros.isEmpty())
        {
            error(request, response, "El archivo no contiene registros.");
            return;
        }

        try
        {
            //pasos 4 y 5: interpretar y validar la estructura
            List<marcacion> candidatas = new ArrayList<>();

            for (marcacion m : registros)
            {
                String problema = interpretar(m);

                if (problema != null)
                {
                    m.marcar(marcacion.ERROR, problema);
                }
                else
                {
                    candidatas.add(m);
                }
            }

            //pasos 8 y 9: asociar con el empleado y determinar el turno
            Map<Integer, empleado> empleados = empDAO.mapaPorCodigoMarcacion();
            List<marcacion> asociadas = new ArrayList<>();

            for (marcacion m : candidatas)
            {
                empleado emp = empleados.get(m.getCodigo());

                if (emp == null)
                {
                    m.marcar(marcacion.RECHAZADO,
                        "El código " + m.getCodigo() + " no está asociado a ningún empleado.");
                }
                else if (emp.getEstado() != 1)
                {
                    m.marcar(marcacion.RECHAZADO, "El empleado asociado está inactivo.");
                }
                else if (emp.getTurno() == null || emp.getTurno().trim().isEmpty())
                {
                    m.marcar(marcacion.RECHAZADO, "El empleado no tiene un turno asignado.");
                }
                else
                {
                    m.setIdPersonal(emp.getEmpleadoID());
                    m.setEmpleado(emp.getNombre() + " " + emp.getApellido());
                    m.setTurno(emp.getTurno().trim().toUpperCase());
                    asociadas.add(m);
                }
            }

            //paso 7: duplicados dentro del archivo y contra la base de datos
            marcarDuplicados(asociadas);

            //se arma el resumen respetando el orden original del archivo
            resultadoImportacion resultado = new resultadoImportacion(nombre);

            for (marcacion m : registros)
            {
                if (m.getEstado() == null)
                {
                    m.marcar(marcacion.CORRECTO, "");
                }
                resultado.agregar(m);
            }

            request.getSession().setAttribute(SESION_RESULTADO, resultado);
            request.setAttribute("resultado", resultado);
            request.getRequestDispatcher(PAGINA).forward(request, response);
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            error(request, response, "No se pudo consultar la base de datos. Intenta de nuevo.");
        }
    }

	//paso 3: lee las lineas del archivo, ignorando las que estan en blanco
	private List<marcacion> leer(Part archivo) throws IOException
    {
        List<marcacion> registros = new ArrayList<>();

        try (BufferedReader lector = new BufferedReader(
                new InputStreamReader(archivo.getInputStream(), StandardCharsets.UTF_8)))
        {
            String linea;
            int numero = 0;

            while ((linea = lector.readLine()) != null)
            {
                numero++;

                //quita el BOM si el archivo lo trae
                if (numero == 1 && linea.startsWith("\uFEFF"))
                {
                    linea = linea.substring(1);
                }

                if (linea.trim().isEmpty())
                {
                    continue;
                }

                registros.add(new marcacion(numero, linea));
            }
        }

        return registros;
    }

	//pasos 4 y 5: interpreta la linea y valida su estructura.
	//Devuelve null si es correcta o el motivo del error
	private String interpretar(marcacion m)
    {
        String[] campos = m.getLinea().split("\t", -1);

        if (campos.length != COLUMNAS)
        {
            return "Se esperaban " + COLUMNAS + " columnas separadas por tabulación y se encontraron "
                    + campos.length + ".";
        }

        for (int i = 0; i < campos.length; i++)
        {
            campos[i] = campos[i].trim();
        }

        //columna 1: codigo de marcacion
        if (!campos[0].matches("\\d{1,9}") || Integer.parseInt(campos[0]) <= 0)
        {
            return "El código de marcación «" + campos[0] + "» no es un número válido.";
        }

        //columna 2: fecha y hora
        LocalDateTime fechaHora;

        try
        {
            fechaHora = LocalDateTime.parse(campos[1], FORMATO_FECHA);
        }
        catch (DateTimeParseException e)
        {
            return "La fecha y hora «" + campos[1] + "» no tiene el formato aaaa-mm-dd hh:mm:ss.";
        }

        //columnas 3 a 6: numericas
        int[] numeros = new int[4];

        for (int i = 0; i < 4; i++)
        {
            String valor = campos[i + 2];

            if (!valor.matches("\\d{1,9}"))
            {
                return "La columna " + (i + 3) + " debe ser numérica y trae «" + valor + "».";
            }
            numeros[i] = Integer.parseInt(valor);
        }

        m.setCodigo(Integer.parseInt(campos[0]));
        m.setFechaHora(fechaHora);
        m.setVerificacion(numeros[0]);
        m.setEntradaSalida(numeros[1]);
        m.setCodigoTrabajo(numeros[2]);
        m.setReservado(numeros[3]);

        return null;
    }

	//paso 7: la primera aparicion se conserva y las repetidas se marcan como duplicadas
	//paso 7: marcaciones repetidas por error (mismo empleado, mismo dia, muy seguidas).
	//Las identicas (ya en la BD o repetidas en el archivo) se omiten sin mostrarse como duplicadas
	private void marcarDuplicados(List<marcacion> lista) throws SQLException
	{
	    if (lista.isEmpty())
	    {
	        return;
	    }

	    LocalDateTime desde = lista.get(0).getFechaHora();
	    LocalDateTime hasta = desde;

	    for (marcacion m : lista)
	    {
	        if (m.getFechaHora().isBefore(desde)) {desde = m.getFechaHora();}
	        if (m.getFechaHora().isAfter(hasta)) {hasta = m.getFechaHora();}
	    }

	    Map<Integer, List<LocalDateTime>> enBaseDeDatos =
	            marcDAO.marcacionesExistentes(desde.toLocalDate(), hasta.toLocalDate());

	    //se procesa en orden cronologico por empleado: la primera marcacion se conserva
	    List<marcacion> ordenadas = new ArrayList<>(lista);
	    ordenadas.sort(Comparator.comparingInt(marcacion::getCodigo)
	            .thenComparing(marcacion::getFechaHora)
	            .thenComparingInt(marcacion::getNumeroLinea));

	    Map<Integer, List<Referencia>> referencias = new HashMap<>();

	    for (marcacion m : ordenadas)
	    {
	        List<Referencia> refs = referencias.get(m.getCodigo());

	        if (refs == null)
	        {
	            refs = new ArrayList<>();

	            List<LocalDateTime> guardadas = enBaseDeDatos.get(m.getCodigo());

	            if (guardadas != null)
	            {
	                for (LocalDateTime hora : guardadas)
	                {
	                    refs.add(new Referencia(hora, 0));
	                }
	            }
	            referencias.put(m.getCodigo(), refs);
	        }

	        LocalDateTime hora = m.getFechaHora();
	        Referencia cercana = null;
	        long menor = Long.MAX_VALUE;

	        for (Referencia r : refs)
	        {
	            if (!r.hora.toLocalDate().equals(hora.toLocalDate()))
	            {
	                continue;
	            }

	            long diferencia = Math.abs(Duration.between(r.hora, hora).getSeconds());

	            if (diferencia < menor)
	            {
	                menor = diferencia;
	                cercana = r;
	            }
	        }

	        String origen = cercana == null ? "" : (cercana.linea == 0
	                ? "ya registrada en la base de datos"
	                : "línea " + cercana.linea + " del archivo");

	        if (cercana != null && menor == 0)
	        {
	            m.marcar(marcacion.OMITIDO, "Idéntica a una marcación existente (" + origen + ").");
	        }
	        else if (cercana != null && menor <= marcacionDAO.VENTANA_DUPLICADO_SEGUNDOS)
	        {
	        	m.marcar(marcacion.DUPLICADO,
	        		    "Marcó " + menor + " segundo(s) " + (cercana.hora.isBefore(hora) ? "después" : "antes")
	        		    + " de la marcación de las " + cercana.hora.format(FORMATO_HORA) + " (" + origen + "). "
	        		    + "Se guarda, pero el reporte toma la primera.");
	        }
	        else
	        {
	            refs.add(new Referencia(hora, m.getNumeroLinea()));
	        }
	    }
	}

	//---------------------------------------------------------------
	// GUARDAR: paso 10
	//---------------------------------------------------------------
	private void guardar(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException
    {
        HttpSession sesion = request.getSession();
        resultadoImportacion resultado = (resultadoImportacion) sesion.getAttribute(SESION_RESULTADO);

        if (resultado == null)
        {
            error(request, response, "No hay una importación pendiente. Vuelve a cargar el archivo.");
            return;
        }

        List<marcacion> guardables = resultado.getGuardables();

        if (guardables.isEmpty())
        {
            error(request, response, "No hay registros válidos para guardar.");
            return;
        }

        try
        {
            auditoriaDAO.registrarSeguro(sesion, "IMPORTACION", "Importó el archivo " + resultado.getNombreArchivo());
            int guardadas = marcDAO.guardar(guardables);

            sesion.removeAttribute(SESION_RESULTADO);
            sesion.setAttribute(SESION_MENSAJE, "Se guardaron " + guardadas + " marcación(es) correctamente.");
            response.sendRedirect(request.getContextPath() + PAGINA);
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            error(request, response, "No se pudieron guardar los registros. No se guardó ninguno.");
        }
    }

	//---------------------------------------------------------------
	// CANCELAR
	//---------------------------------------------------------------
	private void cancelar(HttpServletRequest request, HttpServletResponse response)
            throws IOException
    {
        request.getSession().removeAttribute(SESION_RESULTADO);
        response.sendRedirect(request.getContextPath() + PAGINA);
    }

	//devuelve a la pagina con un mensaje de error
	private void error(HttpServletRequest request, HttpServletResponse response, String mensaje)
            throws ServletException, IOException
    {
        request.setAttribute("error", mensaje);
        request.getRequestDispatcher(PAGINA).forward(request, response);
    }
}
