package controllers;

import java.io.IOException;
import java.sql.Date;

import dao.empleadoDAO;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.empleado;
import dao.empleadoDAO;

@WebServlet("/empServlet")
public class empleadoServlet extends HttpServlet{

	//Inicializa el servlet
	public void init()throws ServletException{
		System.out.println("Server inicializado");
	}	
	
	public void doPost(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException{
		
		System.out.println("Llegó una petición");
		
		rq.setCharacterEncoding("UTF-8");
		rsp.setContentType("text/html;charset=UTF-8");
		try {
			
			String id = rq.getParameter("idEMP");
			int ID = Integer.parseInt(id);
			
			String nombre = rq.getParameter("nombre");
			String apellido = rq.getParameter("apellido");
			String cedula = rq.getParameter("cedula");
			//System.out.println("Cédula recibida del formulario: " + cedula);
			
			String cod_marcacion = rq.getParameter("codMarc");
			int cod_Marc = Integer.parseInt(cod_marcacion);
			
			String turno = rq.getParameter("turno");
			String estado = rq.getParameter("estado");
			int est = Integer.parseInt(estado);
			
			String fecha = rq.getParameter("fecha");
			
			empleado emp = new empleado(ID, cedula, nombre, apellido, cod_Marc, turno, est, fecha);
			empleadoDAO empleadoDAO = new empleadoDAO();
			
			
			//Chequeo de si la operación ha funcionado o no
			boolean ok = empleadoDAO.crearEmpleado(emp);
			if (ok) {
			    rsp.getWriter().println("Se ha completado la operación");
			    rsp.sendRedirect(rq.getContextPath() + "/jsp/empleados.jsp");
			} else {
			    rsp.getWriter().println("No se pudo guardar. Revisa la consola.");
			}
			
		} catch (NumberFormatException | NullPointerException e) {
			rsp.getWriter().println("<h1>Error: revisa los campos numéricos</h1>");
			rsp.sendRedirect(rq.getContextPath() + "/jsp/empleados.jsp");
		}
		
		
	}
	
	public void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException{
		
		System.out.println("Empezando proceso");
		
		rq.setCharacterEncoding("UTF-8");
		rsp.setContentType("text/html;charset=UTF-8");
		
		empleado emp = new empleado();
		empleadoDAO empleadoDAO = new empleadoDAO();
		
	}
	
	
}
