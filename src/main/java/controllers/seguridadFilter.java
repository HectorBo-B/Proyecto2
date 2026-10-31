package controllers;

import java.io.IOException;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.usuario;

@WebFilter("/*")
public class seguridadFilter implements Filter
{
    private static final String LOGIN = "/jsp/login.jsp";
    private static final String INICIO = "/jsp/dashboard.jsp";

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException
    {
        HttpServletRequest rq = (HttpServletRequest) request;
        HttpServletResponse rsp = (HttpServletResponse) response;

        String ruta = rq.getServletPath() + (rq.getPathInfo() == null ? "" : rq.getPathInfo());
        ruta = ruta.toLowerCase();

        if (esPublica(ruta))
        {
            chain.doFilter(request, response);
            return;
        }

        HttpSession sesion = rq.getSession(false);
        usuario actual = sesion == null ? null : (usuario) sesion.getAttribute(usuario.SESION);

        //sin sesión: al login
        if (actual == null)
        {
            rsp.sendRedirect(rq.getContextPath() + LOGIN);
            return;
        }

        //usuarios y auditoría: solo el administrador
        if (soloAdministrador(ruta) && !actual.esAdmin())
        {
            rsp.sendRedirect(rq.getContextPath() + INICIO);
            return;
        }

        //evita que el botón "atrás" muestre páginas guardadas después de cerrar sesión
        rsp.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        rsp.setHeader("Pragma", "no-cache");
        rsp.setDateHeader("Expires", 0);

        chain.doFilter(request, response);
    }

    private boolean esPublica(String ruta)
    {
        return ruta.isEmpty() || "/".equals(ruta) || "/index.jsp".equals(ruta)
                || "/jsp/login.jsp".equals(ruta)
                || "/loginservlet".equals(ruta) || "/logoutservlet".equals(ruta)
                || ruta.startsWith("/css/") || ruta.startsWith("/js/");
    }

    private boolean soloAdministrador(String ruta)
    {
        return "/jsp/usuarios.jsp".equals(ruta) || "/usuarioservlet".equals(ruta);
    }
}