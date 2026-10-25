package controllers;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Set;
import java.util.TreeSet;

import dao.reporteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.empleado;

@WebServlet("/reporteServlet")
public class reporteServlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    private static final String PAGINA_LISTADO = "/jsp/reportes.jsp";
    private static final String PAGINA_REPORTE = "/jsp/reporteAsistencia.jsp";
    private static final String SESION_OK = "mensajeReporteOk";
    private static final String SESION_ERROR = "mensajeReporteError";
    private static final int MAXIMO_DIAS = 366;

    private final reporteDAO dao = new reporteDAO();

    @Override
    protected void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException
    {
        rq.setCharacterEncoding("UTF-8");

        String id = rq.getParameter("id");

        if (id == null || id.trim().isEmpty())
        {
            listado(rq, rsp);
            return;
        }

        try
        {
            empleado emp = dao.obtener(numero(id));

            if (emp == null)
            {
                throw new IllegalArgumentException("El empleado no existe.");
            }

            LocalDate desde = fecha(rq.getParameter("desde"), "La fecha inicial");
            LocalDate hasta = fecha(rq.getParameter("hasta"), "La fecha final");

            if (hasta.isBefore(desde))
            {
                throw new IllegalArgumentException("La fecha final no puede ser anterior a la inicial.");
            }
            if (ChronoUnit.DAYS.between(desde, hasta) >= MAXIMO_DIAS)
            {
                throw new IllegalArgumentException("El rango no puede superar " + MAXIMO_DIAS + " días.");
            }

            rq.setAttribute("reporte", dao.generar(emp, desde, hasta));
            rq.getRequestDispatcher(PAGINA_REPORTE).forward(rq, rsp);
        }
        catch (IllegalArgumentException e)
        {
            rq.setAttribute("error", e.getMessage());
            listado(rq, rsp);
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            rq.setAttribute("error", "No se pudo generar el reporte. Verifica que exista la tabla observaciones_asistencia.");
            listado(rq, rsp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException
    {
        rq.setCharacterEncoding("UTF-8");

        HttpSession sesion = rq.getSession();
        int id;
        LocalDate desde, hasta;

        try
        {
            id = numero(rq.getParameter("idEMP"));
            desde = fecha(rq.getParameter("desde"), "La fecha inicial");
            hasta = fecha(rq.getParameter("hasta"), "La fecha final");
        }
        catch (IllegalArgumentException e)
        {
            rsp.sendRedirect(rq.getContextPath() + "/reporteServlet");
            return;
        }

        try
        {
            if ("observaciones".equals(rq.getParameter("accion")))
            {
                String texto = rq.getParameter("observacion") == null ? "" : rq.getParameter("observacion").trim();
                String[] marcadas = rq.getParameterValues("fechas");
                Set<LocalDate> fechas = new TreeSet<>();

                if (texto.length() > 255)
                {
                    throw new IllegalArgumentException("La observación no puede superar 255 caracteres.");
                }
                if (marcadas == null || marcadas.length == 0)
                {
                    throw new IllegalArgumentException("Selecciona al menos un día.");
                }

                for (String marcada : marcadas)
                {
                    LocalDate dia = fecha(marcada, "La fecha");

                    if (dia.isBefore(desde) || dia.isAfter(hasta))
                    {
                        throw new IllegalArgumentException("Hay un día fuera del rango del reporte.");
                    }
                    fechas.add(dia);
                }

                int guardados = dao.guardarObservaciones(id, new ArrayList<>(fechas), texto,
                        "1".equals(rq.getParameter("justificada")));
                sesion.setAttribute(SESION_OK, texto.isEmpty()
                        ? "Observación eliminada de " + guardados + " día(s)."
                        : "Observación guardada en " + guardados + " día(s).");
            }
        }
        catch (IllegalArgumentException e)
        {
            sesion.setAttribute(SESION_ERROR, e.getMessage());
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            sesion.setAttribute(SESION_ERROR, "No se pudo guardar la observación en la base de datos.");
        }

        rsp.sendRedirect(rq.getContextPath() + "/reporteServlet?id=" + id + "&desde=" + desde + "&hasta=" + hasta);
    }

    private void listado(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException
    {
        String texto = rq.getParameter("q") == null ? "" : rq.getParameter("q").trim();

        try
        {
            rq.setAttribute("empleados", dao.buscar(texto));
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            rq.setAttribute("empleados", new ArrayList<empleado>());
            rq.setAttribute("error", "No se pudo consultar la base de datos.");
        }

        rq.setAttribute("q", texto);
        rq.setAttribute("desde", valorFecha(rq.getParameter("desde")));
        rq.setAttribute("hasta", valorFecha(rq.getParameter("hasta")));
        rq.getRequestDispatcher(PAGINA_LISTADO).forward(rq, rsp);
    }

    private String valorFecha(String valor)
    {
        try
        {
            return LocalDate.parse(valor).toString();
        }
        catch (DateTimeParseException | NullPointerException e)
        {
            return "";
        }
    }

    private LocalDate fecha(String valor, String campo)
    {
        try
        {
            return LocalDate.parse(valor.trim());
        }
        catch (DateTimeParseException | NullPointerException e)
        {
            throw new IllegalArgumentException(campo + " no es válida.");
        }
    }

    private int numero(String valor)
    {
        try
        {
            return Integer.parseInt(valor.trim());
        }
        catch (NumberFormatException | NullPointerException e)
        {
            throw new IllegalArgumentException("El empleado no es válido.");
        }
    }
}