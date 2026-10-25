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

@WebFilter("/*")
public class marcoFilter implements Filter
{
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException
    {
        HttpServletRequest rq = (HttpServletRequest) request;
        HttpServletResponse rsp = (HttpServletResponse) response;
        String destino = rq.getHeader("Sec-Fetch-Dest");
        String ruta = rq.getRequestURI().substring(rq.getContextPath().length());

        if ("document".equals(destino) && !ruta.isEmpty() && !"/".equals(ruta))
        {
            rsp.sendRedirect(rq.getContextPath() + "/");
            return;
        }

        chain.doFilter(request, response);
    }
}