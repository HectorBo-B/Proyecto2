package controllers;

import java.io.IOException;

import dao.auditoriaDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.auditoria;

@WebServlet("/logoutServlet")
public class logoutServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
	protected void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {
		cerrar(rq, rsp);
	}

	@Override
	protected void doPost(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException {
		cerrar(rq, rsp);
	}

	private void cerrar(HttpServletRequest rq, HttpServletResponse rsp) throws IOException {

		HttpSession sesion = rq.getSession(false);

		if (sesion != null) {
			auditoriaDAO.registrarSeguro(sesion, auditoria.LOGOUT, "Cerró sesión");
			sesion.invalidate();
		}

		rsp.sendRedirect(rq.getContextPath() + "/jsp/login.jsp");
	}
}