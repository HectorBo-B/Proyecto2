package controllers;

import java.io.IOException;
import java.sql.SQLException;

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

@WebServlet("/loginServlet")
public class loginServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	private static final String LOGIN = "/jsp/login.jsp";
	private static final String INICIO = "/jsp/dashboard.jsp";

	private final usuarioDAO dao = new usuarioDAO();

	@Override
	protected void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {
		rsp.sendRedirect(rq.getContextPath() + LOGIN);
	}

	@Override
	protected void doPost(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {

		rq.setCharacterEncoding("UTF-8");

		String nombre = rq.getParameter("usuario") == null ? "" : rq.getParameter("usuario").trim();
		String clave = rq.getParameter("password") == null ? "" : rq.getParameter("password");

		if (nombre.isEmpty() || clave.isEmpty()) {
			mostrarError(rq, rsp, "Ingresa tu usuario y contraseña.");
			return;
		}

		try {
			usuario u = dao.buscarParaLogin(nombre);

			if (u == null || !Seguridad.verificar(clave, u.getClave())) {
				mostrarError(rq, rsp, "Usuario o contraseña incorrectos.");
				return;
			}
			if (u.getEstado() != 1) {
				mostrarError(rq, rsp, "Tu usuario está inactivo. Comunícate con el administrador.");
				return;
			}

			u.setClave(null);

			//sesión nueva para evitar la fijación de sesión
			HttpSession anterior = rq.getSession(false);

			if (anterior != null) {
				anterior.invalidate();
			}

			HttpSession sesion = rq.getSession(true);
			sesion.setAttribute(usuario.SESION, u);

			auditoriaDAO.registrarSeguro(sesion, auditoria.LOGIN, "Inició sesión");

			rsp.sendRedirect(rq.getContextPath() + INICIO);

		} catch (SQLException e) {
			e.printStackTrace();
			mostrarError(rq, rsp, "No se pudo consultar la base de datos.");
		}
	}

	private void mostrarError(HttpServletRequest rq, HttpServletResponse rsp, String mensaje)
			throws ServletException, IOException {

		rq.setAttribute("error", mensaje);
		rq.getRequestDispatcher(LOGIN).forward(rq, rsp);
	}
}