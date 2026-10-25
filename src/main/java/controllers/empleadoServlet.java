package controllers;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;

import dao.empleadoDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.empleado.codigoMarcacion;
import model.empleado;

@WebServlet("/empServlet")
public class empleadoServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private static final String PAGINA = "/jsp/empleados.jsp";
	private static final String SESION_OK = "mensajeEmpleadoOk";
	private static final String SESION_ERROR = "mensajeEmpleadoError";

	private final empleadoDAO dao = new empleadoDAO();

	//Carga los empleados y los codigos desde la base de datos y muestra la pagina
	@Override
	protected void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {

		try {
			rq.setAttribute("empleados", dao.listar());
			rq.setAttribute("codigos", dao.listarCodigos());

		} catch (SQLException e) {
			e.printStackTrace();
			rq.setAttribute("empleados", new ArrayList<empleado>());
			rq.setAttribute("codigos", new ArrayList<codigoMarcacion>());
			rq.setAttribute("error", "No se pudo consultar la base de datos.");
		}

		rq.getRequestDispatcher(PAGINA).forward(rq, rsp);
	}

	//Crear, editar, activar/desactivar o eliminar. Siempre vuelve al listado
	@Override
	protected void doPost(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {

		rq.setCharacterEncoding("UTF-8");

		String accion = rq.getParameter("accion");
		HttpSession sesion = rq.getSession();

		try {
			if ("crear".equals(accion) || "editar".equals(accion)) {
				sesion.setAttribute(SESION_OK, guardar(rq, "editar".equals(accion)));

			} else if ("estado".equals(accion)) {
				dao.alternarEstado(numero(rq.getParameter("idEMP"), "El empleado no es válido."));
				sesion.setAttribute(SESION_OK, "Estado actualizado correctamente.");

			}

		} catch (IllegalArgumentException e) {
			sesion.setAttribute(SESION_ERROR, e.getMessage());

		} catch (SQLIntegrityConstraintViolationException e) {
			e.printStackTrace();
			sesion.setAttribute(SESION_ERROR, "La cédula o el código de marcación ya están registrados.");

		} catch (SQLException e) {
			e.printStackTrace();
			sesion.setAttribute(SESION_ERROR, "No se pudo completar la operación en la base de datos.");
		}

		rsp.sendRedirect(rq.getContextPath() + "/empServlet");
	}

	//Valida los datos y registra o modifica al empleado. Devuelve el mensaje de exito
	private String guardar(HttpServletRequest rq, boolean editar) throws SQLException {

		int id = editar ? numero(rq.getParameter("idEMP"), "El empleado no es válido.") : 0;

		String nombre = texto(rq.getParameter("nombre"), 100, "El nombre");
		String apellido = texto(rq.getParameter("apellido"), 100, "El apellido");
		String cedula = texto(rq.getParameter("cedula"), 13, "La cédula");
		String turno = rq.getParameter("turno");
		String codigoTexto = rq.getParameter("codMarc") == null ? "" : rq.getParameter("codMarc").trim();

		if (!"M".equals(turno) && !"T".equals(turno)) {
			throw new IllegalArgumentException("Selecciona un turno válido.");
		}
		if (dao.existeCedula(cedula, id)) {
			throw new IllegalArgumentException("Ya existe un empleado con la cédula " + cedula + ".");
		}

		int codigo;

		if (codigoTexto.isEmpty()) {
			throw new IllegalArgumentException("Selecciona un código de marcación disponible.");
		}

		codigo = numero(codigoTexto, "El código de marcación no es válido.");

		if (codigo < 1) {
			throw new IllegalArgumentException("El código de marcación no es válido.");
		}

		String turnoCodigo = dao.turnoDeCodigo(codigo);

		if (turnoCodigo == null) {
			throw new IllegalArgumentException("El código " + codigo + " no existe.");
		}
		if (!turnoCodigo.equals(turno)) {
			throw new IllegalArgumentException("El código " + codigo + " pertenece al turno "
					+ nombreTurno(turnoCodigo) + ".");
		}
		if (dao.codigoUsado(codigo, id)) {
			throw new IllegalArgumentException("El código " + codigo + " ya está asignado a otro empleado.");
		}

		empleado emp = new empleado(id, cedula, nombre, apellido, codigo, turno, 1);

		if (editar) {
			dao.actualizar(emp);
			return "Empleado actualizado correctamente.";
		}

		dao.crear(emp);
		return "Empleado registrado correctamente. Código de marcación: " + codigo + ".";
	}

	//Texto obligatorio con largo maximo
	private String texto(String valor, int maximo, String campo) {

		String limpio = valor == null ? "" : valor.trim();

		if (limpio.isEmpty()) {
			throw new IllegalArgumentException(campo + " es obligatorio.");
		}
		if (limpio.length() > maximo) {
			throw new IllegalArgumentException(campo + " no puede superar " + maximo + " caracteres.");
		}
		return limpio;
	}

	private int numero(String valor, String mensaje) {

		try {
			return Integer.parseInt(valor.trim());

		} catch (NumberFormatException | NullPointerException e) {
			throw new IllegalArgumentException(mensaje);
		}
	}

	private String nombreTurno(String turno) {
		return "M".equals(turno) ? "Mañana" : "Tarde";
	}
}
