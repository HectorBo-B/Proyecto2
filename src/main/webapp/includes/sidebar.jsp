<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<% String uri = request.getRequestURI().toLowerCase(); %>
<aside class="sidebar" id="sidebar">
    <div class="sidebar-header">
        <div class="sidebar-logo">
            <i class="fa-solid fa-clipboard-user"></i>
        </div>
        <div>
            <div class="sidebar-title">Asistencia</div>
            <div class="sidebar-subtitle">Control de personal</div>
        </div>
    </div>

    <div class="sidebar-label">Menú</div>

    <nav class="sidebar-nav">
        <a href="${pageContext.request.contextPath}/jsp/dashboard.jsp" class="sidebar-link <%= uri.contains("dashboard") ? "active" : "" %>">
            <i class="fa-solid fa-chart-pie"></i> <span>Dashboard</span>
        </a>
        <a href="${pageContext.request.contextPath}/empServlet" class="sidebar-link <%= uri.contains("empleados") || uri.contains("empservlet") ? "active" : "" %>">
            <i class="fa-solid fa-user-group"></i> <span>Personal</span>
        </a>
        <a href="${pageContext.request.contextPath}/jsp/importar.jsp" class="sidebar-link <%= uri.contains("importar") ? "active" : "" %>">
            <i class="fa-solid fa-file-arrow-up"></i> <span>Importar</span>
        </a>
        <a href="${pageContext.request.contextPath}/jsp/reportes.jsp" class="sidebar-link <%= uri.contains("reportes") ? "active" : "" %>">
            <i class="fa-solid fa-magnifying-glass-chart"></i> <span>Reportes y Consultas</span>
        </a>
        <a href="${pageContext.request.contextPath}/jsp/usuarios.jsp" class="sidebar-link <%= uri.contains("usuarios") ? "active" : "" %>">
            <i class="fa-solid fa-user-shield"></i> <span>Usuarios y acceso</span>
        </a>
    </nav>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/jsp/login.jsp" class="sidebar-link sidebar-logout">
            <i class="fa-solid fa-arrow-right-from-bracket"></i> <span>Cerrar sesión</span>
        </a>
    </div>
</aside>
