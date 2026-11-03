package controllers;

import java.io.IOException;
import java.sql.SQLException;

import dao.dashboardDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.dashboard;

@WebServlet("/dashboardServlet")
public class dashboardServlet extends HttpServlet
{
    private static final long serialVersionUID = 1L;

    private static final String PAGINA = "/jsp/dashboard.jsp";

    private final dashboardDAO dao = new dashboardDAO();

    @Override
    protected void doGet(HttpServletRequest rq, HttpServletResponse rsp) throws ServletException, IOException
    {
        try
        {
            rq.setAttribute("resumen", dao.obtener());
        }
        catch (SQLException e)
        {
            e.printStackTrace();
            rq.setAttribute("resumen", new dashboard());
            rq.setAttribute("error", "No se pudo consultar la base de datos.");
        }

        rq.getRequestDispatcher(PAGINA).forward(rq, rsp);
    }
}