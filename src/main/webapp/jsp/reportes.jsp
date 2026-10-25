<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.Normalizer, java.util.List, model.empleado, model.resultadoImportacion" %>
<%!
    private static String sinTildes(String texto)
    {
        return Normalizer.normalize(texto, Normalizer.Form.NFD).replaceAll("\\p{M}", "");
    }
%>
<%
    @SuppressWarnings("unchecked")
    List<empleado> empleados = (List<empleado>) request.getAttribute("empleados");

    if (empleados == null)
    {
        response.sendRedirect(request.getContextPath() + "/reporteServlet");
        return;
    }

    String texto = (String) request.getAttribute("q");
    String desde = (String) request.getAttribute("desde");
    String hasta = (String) request.getAttribute("hasta");
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reportes y Consultas - Asistencia</title>
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
                <strong class="topbar-title">Reportes y Consultas</strong>
            </header>

            <main class="main">
                <div class="page-header">
                    <div>
                        <h1>Reportes y Consultas</h1>
                        <p>Busca un empleado e imprime su historial de asistencia</p>
                    </div>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= resultadoImportacion.escapar(error) %>
                </div>
                <% } %>

                <div class="card">
                    <form id="frmBuscar" action="${pageContext.request.contextPath}/reporteServlet" method="get" class="toolbar" autocomplete="off">
                        <div class="field">
                            <label for="q">Buscar</label>
                            <input type="text" id="q" name="q" class="input" value="<%= resultadoImportacion.escapar(texto) %>" placeholder="Cédula, nombre o código de marcación..." data-buscar="tblReportes" autofocus>
                        </div>
                        <div class="field">
                            <label for="desde">Desde</label>
                            <input type="<%= desde.isEmpty() ? "text" : "date" %>" id="desde" name="desde" class="input" value="<%= desde %>" placeholder="Seleccione la fecha" data-fecha required>
                        </div>
                        <div class="field">
                            <label for="hasta">Hasta</label>
                            <input type="<%= hasta.isEmpty() ? "text" : "date" %>" id="hasta" name="hasta" class="input" value="<%= hasta %>" placeholder="Seleccione la fecha" data-fecha required>
                        </div>
                        <button type="button" class="btn btn-secondary" data-limpiar="tblReportes">
                            <i class="fa-solid fa-rotate"></i> Limpiar
                        </button>
                        <span class="counter" data-contador="tblReportes"><%= empleados.size() %> resultado(s)</span>
                    </form>
                </div>

                <div class="card">
                    <div class="card-head">
                        <h3>Empleados encontrados</h3>
                    </div>

                    <div class="table-wrap">
                        <table class="table" id="tblReportes">
                            <thead>
                                <tr>
                                    <th>Nombre</th>
                                    <th>Turno</th>
                                    <th>Estado</th>
                                    <th class="actions">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (empleado e : empleados) {
                                    boolean activo = e.getEstado() == 1;
                                    String nombreCompleto = e.getNombre() + " " + e.getApellido();
                                    String claveBusqueda = e.getCedula() + " " + e.getCodM() + " " + sinTildes(nombreCompleto)
                                            + " " + sinTildes(e.getApellido() + " " + e.getNombre());
                                %>
                                <tr>
                                    <td><strong><%= resultadoImportacion.escapar(nombreCompleto) %></strong><span hidden><%= resultadoImportacion.escapar(claveBusqueda) %></span></td>
                                    <td><%= e.getTurnoNombre() %></td>
                                    <td><span class="badge <%= activo ? "badge-ok" : "badge-off" %>"><%= activo ? "Activo" : "Inactivo" %></span></td>
                                    <td class="actions">
                                        <button type="submit" class="btn btn-secondary" form="frmBuscar" name="id" value="<%= e.getEmpleadoID() %>" title="Imprimir asistencia">
                                            <i class="fa-solid fa-list-check"></i></i> Asistencia
                                        </button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <script>
        document.getElementById('frmBuscar').addEventListener('keydown', function (evento)
        {
            if (evento.key === 'Enter' && evento.target.tagName === 'INPUT')
            {
                evento.preventDefault();
            }
        });

        document.querySelectorAll('input[data-fecha]').forEach(function (campo)
        {
            campo.addEventListener('focus', function ()
            {
                campo.type = 'date';
                if (typeof campo.showPicker === 'function')
                {
                    try
                    {
                        campo.showPicker();
                    }
                    catch (error)
                    {
                        return;
                    }
                }
            });
            campo.addEventListener('blur', function ()
            {
                if (!campo.value)
                {
                    campo.type = 'text';
                }
            });
            campo.addEventListener('invalid', function ()
            {
                campo.setCustomValidity('Seleccione la fecha');
            });
            campo.addEventListener('input', function ()
            {
                campo.setCustomValidity('');
            });
        });
    </script>
</body>
</html>
