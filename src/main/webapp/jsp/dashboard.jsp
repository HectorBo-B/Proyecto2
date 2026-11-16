<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.dashboard, model.resultadoImportacion" %>
<%-- Si se abre sin pasar por dashboardServlet, redirige para cargar los datos --%>
<%
    dashboard resumen = (dashboard) request.getAttribute("resumen");

    if (resumen == null)
    {
        response.sendRedirect(request.getContextPath() + "/dashboardServlet");
        return;
    }

    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Asistencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="${pageContext.request.contextPath}/js/funciones.js" defer></script>
</head>
<body>
    <div class="app">
        <jsp:include page="/includes/sidebar.jsp" />

        <div class="content">
            <header class="topbar">
                <button type="button" class="menu-btn" data-menu aria-label="Mostrar u ocultar el menú" title="Mostrar u ocultar el menú">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <strong class="topbar-title">Dashboard</strong>
            </header>

            <main class="main">
                <div class="page-header">
                    <div>
                        <h1>Dashboard</h1>
                        <p>Resumen general de asistencia</p>
                    </div>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= resultadoImportacion.escapar(error) %>
                </div>
                <% } %>

                <%-- Tarjetas con los totales --%>
                <div class="stats">
                    <div class="stat">
                        <div class="stat-icon teal"><i class="fa-solid fa-users"></i></div>
                        <div>
                            <span class="stat-label">Total de empleados</span>
                            <span class="stat-value"><%= resumen.getEmpleados() %></span>
                            <span class="stat-sub">en el sistema</span>
                        </div>
                    </div>
                    <div class="stat">
                        <div class="stat-icon green"><i class="fa-solid fa-file-circle-check"></i></div>
                        <div>
                            <span class="stat-label">Registros procesados</span>
                            <span class="stat-value"><%= resumen.getRegistros() %></span>
                            <span class="stat-sub">marcaciones subidas</span>
                        </div>
                    </div>
                    <div class="stat">
                        <div class="stat-icon red"><i class="fa-solid fa-user-xmark"></i></div>
                        <div>
                            <span class="stat-label">Total de ausencias</span>
                            <span class="stat-value"><%= resumen.getAusencias() %></span>
                            <span class="stat-sub">en todos los registros</span>
                        </div>
                    </div>
                    <div class="stat">
                        <div class="stat-icon amber"><i class="fa-solid fa-clock"></i></div>
                        <div>
                            <span class="stat-label">Total de tardanzas</span>
                            <span class="stat-value"><%= resumen.getTardanzas() %></span>
                            <span class="stat-sub">acumulado: <%= resumen.getTiempoTardanzaTexto() %></span>
                        </div>
                    </div>
                </div>

                <div class="stats stats-2">
                    <div class="stat">
                        <div class="stat-icon teal"><i class="fa-solid fa-calendar-check"></i></div>
                        <div>
                            <span class="stat-label">Última fecha de procesamiento</span>
                            <span class="stat-value"><%= resumen.getUltimoProcesoTexto() %></span>
                            <span class="stat-sub"><%= resumen.getUltimoArchivo().isEmpty() ? "Aún no se ha importado ningún archivo" : "Archivo: " + resultadoImportacion.escapar(resumen.getUltimoArchivo()) %></span>
                        </div>
                    </div>
                </div>

                <%-- Tabla de últimas marcaciones --%>
                <div class="card">
                    <h3>Turnos</h3>
                    <div class="shifts">
                        <div class="shift">
                            <div class="shift-code">M</div>
                            <div>
                                <strong>Mañana</strong>
                                <span>06:00 - 12:00</span>
                            </div>
                        </div>
                        <div class="shift">
                            <div class="shift-code">T</div>
                            <div>
                                <strong>Tarde</strong>
                                <span>12:00 - 17:20</span>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </div>
</body>
</html>