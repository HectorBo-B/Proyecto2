package controllers;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.ArrayList;
import java.util.regex.Pattern;

import config.Seguridad;
import dao.auditoriaDAO;
import dao.usuarioDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.auditoria;
import model.usuario;

@WebServlet("/usuarioServlet")
public class usuarioServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private static final String PAGINA = "/jsp/usuarios.jsp";
	private static final String SESION_OK = "mensajeUsuarioOk";
	private static final String SESION_ERROR = "mensajeUsuarioError";
	private static final int LIMITE_AUDITORIA = 500;

	private static final Pattern PATRON_USUARIO = Pattern.compile("[A-Za-z0-9._-]{3,50}");
	private static final Pattern PATRON_CORREO = Pattern.compile("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$");

	private final usuarioDAO dao = new usuarioDAO();
	private final auditoriaDAO auditoriaDao = new auditoriaDAO();

	//Carga los usuarios y la auditoría desde la base de datos y muestra la página
	@Override
	protected void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {

		if (!esAdministrador(rq, rsp)) {
			return;
		}

		try {
			rq.setAttribute("usuarios", dao.listar());
			rq.setAttribute("auditoria", auditoriaDao.listar(LIMITE_AUDITORIA));

		} catch (SQLException e) {
			e.printStackTrace();
			rq.setAttribute("usuarios", new ArrayList<usuario>());
			rq.setAttribute("auditoria", new ArrayList<auditoria>());
			rq.setAttribute("error", "No se pudo consultar la base de datos.");
		}

		rq.getRequestDispatcher(PAGINA).forward(rq, rsp);
	}

	//Crear, editar, activar/desactivar o eliminar. Siempre vuelve al listado
	@Override
	protected void doPost(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {

		rq.setCharacterEncoding("UTF-8");

		if (!esAdministrador(rq, rsp)) {
			return;
		}

		String accion = rq.getParameter("accion");
		HttpSession sesion = rq.getSession();

		try {
			if ("crear".equals(accion) || "editar".equals(accion)) {
				//si llega un ID es una edición, aunque la acción no venga bien
				String idTexto = rq.getParameter("idUsuario");
				boolean editar = idTexto != null && !idTexto.trim().isEmpty();

				sesion.setAttribute(SESION_OK, guardar(rq, editar));
				auditoriaDAO.registrarSeguro(sesion, auditoria.CRUD,
						(editar ? "Editó" : "Insertó") + " un registro en Usuarios");

			} else if ("estado".equals(accion)) {
				cambiarEstado(rq);
				sesion.setAttribute(SESION_OK, "Estado actualizado correctamente.");
				auditoriaDAO.registrarSeguro(sesion, auditoria.CRUD, "Editó un registro en Usuarios");

			} else if ("eliminar".equals(accion)) {
				eliminar(rq);
				sesion.setAttribute(SESION_OK, "Usuario eliminado correctamente.");
				auditoriaDAO.registrarSeguro(sesion, auditoria.CRUD, "Eliminó un registro en Usuarios");
			}

		} catch (IllegalArgumentException e) {
			sesion.setAttribute(SESION_ERROR, e.getMessage());

		} catch (SQLIntegrityConstraintViolationException e) {
			e.printStackTrace();
			sesion.setAttribute(SESION_ERROR, "El usuario o el correo ya están registrados, o el registro está en uso.");

		} catch (SQLException e) {
			e.printStackTrace();
			sesion.setAttribute(SESION_ERROR, "No se pudo completar la operación en la base de datos.");
		}

		rsp.sendRedirect(rq.getContextPath() + "/usuarioServlet");
	}

	//Valida los datos y registra o modifica al usuario. Devuelve el mensaje de éxito
	private String guardar(HttpServletRequest rq, boolean editar) throws SQLException {

		int id = editar ? numero(rq.getParameter("idUsuario"), "El usuario no es válido.") : 0;

		String nombre = texto(rq.getParameter("nombre"), 100, "El nombre");
		String apellido = texto(rq.getParameter("apellido"), 100, "El apellido");
		String login = texto(rq.getParameter("usuario"), 50, "El usuario");
		String correo = texto(rq.getParameter("correo"), 100, "El correo");
		String clave = rq.getParameter("password") == null ? "" : rq.getParameter("password");
		int estado = "0".equals(rq.getParameter("estado")) ? 0 : 1;

		if (!PATRON_USUARIO.matcher(login).matches()) {
			throw new IllegalArgumentException(
					"El usuario debe tener de 3 a 50 caracteres: letras, números, punto, guion o guion bajo.");
		}
		if (!PATRON_CORREO.matcher(correo).matches()) {
			throw new IllegalArgumentException("El correo no es válido.");
		}
		if (dao.existeUsuario(login, id)) {
			throw new IllegalArgumentException("Ya existe un usuario con el nombre «" + login + "».");
		}
		if (dao.existeCorreo(correo, id)) {
			throw new IllegalArgumentException("Ya existe un usuario con el correo " + correo + ".");
		}
		if ((!editar || !clave.isEmpty()) && clave.length() < 8) {
			throw new IllegalArgumentException("La contraseña debe tener al menos 8 caracteres.");
		}
		if (clave.length() > 100) {
			throw new IllegalArgumentException("La contraseña no puede superar 100 caracteres.");
		}

		usuario u = new usuario();
		u.setId(id);
		u.setNombre(nombre);
		u.setApellido(apellido);
		u.setUsuario(login);
		u.setCorreo(correo);
		u.setEstado(estado);

		if (editar) {
			usuario existente = dao.buscarPorId(id);

			if (existente == null) {
				throw new IllegalArgumentException("El usuario no existe.");
			}
			if (existente.esAdmin() && estado == 0) {
				throw new IllegalArgumentException("El administrador no puede desactivarse.");
			}

			dao.actualizar(u, clave.isEmpty() ? null : Seguridad.cifrar(clave));

			//si el administrador se editó a sí mismo, se actualizan los datos de su sesión
			usuario actual = actual(rq);

			if (actual != null && actual.getId() == id) {
				rq.getSession().setAttribute(usuario.SESION, dao.buscarPorId(id));
			}
			return "Usuario actualizado correctamente.";
		}

		//los usuarios nuevos siempre son OPERADOR: solo puede existir un administrador
		dao.crear(u, Seguridad.cifrar(clave));
		return "Usuario registrado correctamente.";
	}

	private void cambiarEstado(HttpServletRequest rq) throws SQLException {

		usuario u = dao.buscarPorId(numero(rq.getParameter("idUsuario"), "El usuario no es válido."));

		if (u == null) {
			throw new IllegalArgumentException("El usuario no existe.");
		}
		if (u.esAdmin()) {
			throw new IllegalArgumentException("El administrador no puede desactivarse.");
		}

		dao.alternarEstado(u.getId());
	}

	private void eliminar(HttpServletRequest rq) throws SQLException {

		usuario u = dao.buscarPorId(numero(rq.getParameter("idUsuario"), "El usuario no es válido."));

		if (u == null) {
			throw new IllegalArgumentException("El usuario no existe.");
		}
		if (u.esAdmin()) {
			throw new IllegalArgumentException("El administrador no se puede eliminar.");
		}
		if (dao.tieneActividad(u.getId())) {
			throw new IllegalArgumentException("No se puede eliminar a «" + u.getUsuario()
					+ "» porque tiene actividad registrada en la auditoría. Desactívalo en su lugar.");
		}

		dao.eliminar(u.getId());
	}

	//Solo el administrador puede usar este servlet
	private boolean esAdministrador(HttpServletRequest rq, HttpServletResponse rsp) throws IOException {

		usuario actual = actual(rq);

		if (actual == null) {
			rsp.sendRedirect(rq.getContextPath() + "/jsp/login.jsp");
			return false;
		}
		if (!actual.esAdmin()) {
			rsp.sendRedirect(rq.getContextPath() + "/jsp/dashboard.jsp");
			return false;
		}
		return true;
	}

	private usuario actual(HttpServletRequest rq) {
		HttpSession sesion = rq.getSession(false);
		return sesion == null ? null : (usuario) sesion.getAttribute(usuario.SESION);
	}

	//Texto obligatorio con largo máximo
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
}