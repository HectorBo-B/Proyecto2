<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.empleado, model.empleado.codigoMarcacion, model.resultadoImportacion" %>
<%
    @SuppressWarnings("unchecked")
    List<empleado> empleados = (List<empleado>) request.getAttribute("empleados");

    //si se abre el JSP directamente, se pasa primero por el servlet para cargar los datos
    if (empleados == null)
    {
        response.sendRedirect(request.getContextPath() + "/empServlet");
        return;
    }

    @SuppressWarnings("unchecked")
    List<codigoMarcacion> codigos = (List<codigoMarcacion>) request.getAttribute("codigos");

    String error = (String) request.getAttribute("error");
    String mensajeOk = (String) session.getAttribute("mensajeEmpleadoOk");
    String mensajeError = (String) session.getAttribute("mensajeEmpleadoError");
    session.removeAttribute("mensajeEmpleadoOk");
    session.removeAttribute("mensajeEmpleadoError");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal - Asistencia</title>
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
                <strong class="topbar-title">Personal</strong>
            </header>

            <main class="main">
                <div class="page-header">
                    <div>
                        <h1>Personal</h1>
                        <p>Empleados y sus códigos de marcación del reloj</p>
                    </div>
                    <button type="button" class="btn btn-primary" data-abrir="dlgPersonal" data-titulo="Nuevo empleado">
                        <i class="fa-solid fa-plus"></i> Nuevo empleado
                    </button>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= resultadoImportacion.escapar(error) %>
                </div>
                <% } %>
                <% if (mensajeError != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= resultadoImportacion.escapar(mensajeError) %>
                </div>
                <% } %>
                <% if (mensajeOk != null) { %>
                <div class="alert alert-ok">
                    <i class="fa-solid fa-circle-check"></i> <%= resultadoImportacion.escapar(mensajeOk) %>
                </div>
                <% } %>

                <div class="card">
                    <div class="card-head">
                        <h3>Listado de personal</h3>
                    </div>

                    <div class="toolbar">
                        <div class="field">
                            <label for="buscar">Buscar</label>
                            <input type="text" id="buscar" class="input" placeholder="Cédula, nombre o código de marcación..." data-buscar="tblPersonal">
                        </div>
                        <div class="field">
                            <label for="filtroTurno">Turno</label>
                            <select id="filtroTurno" class="input" data-filtro-select="tblPersonal" data-campo="turno">
                                <option value="">Todos</option>
                                <option value="M">Mañana</option>
                                <option value="T">Tarde</option>
                            </select>
                        </div>
                        <div class="field">
                            <label for="filtroEstado">Estado</label>
                            <select id="filtroEstado" class="input" data-filtro-select="tblPersonal" data-campo="estado">
                                <option value="">Todos</option>
                                <option value="1">Activos</option>
                                <option value="0">Inactivos</option>
                            </select>
                        </div>
                        <button type="button" class="btn btn-secondary" data-limpiar="tblPersonal">
                            <i class="fa-solid fa-rotate"></i> Limpiar
                        </button>
                        <span class="counter" data-contador="tblPersonal"><%= empleados.size() %> resultado(s)</span>
                    </div>

                    <div class="table-wrap">
                        <table class="table" id="tblPersonal"
                               data-crud="dlgPersonal" data-titulo-editar="Modificar empleado" data-etiqueta="nombre apellido"
                               data-servidor="${pageContext.request.contextPath}/empServlet"
                               data-mapa-turno="M|Mañana;T|Tarde"
                               data-badge-estado="1|badge-ok|Activo;0|badge-off|Inactivo">
                            <thead>
                                <tr>
                                    <th>Cédula</th>
                                    <th>Nombre</th>
                                    <th>Código de marcación</th>
                                    <th>Turno</th>
                                    <th>Estado</th>
                                    <th>Fecha de registro</th>
                                    <th class="actions">Acciones</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (empleado e : empleados) { boolean activo = e.getEstado() == 1; %>
                                <tr data-idemp="<%= e.getEmpleadoID() %>" data-nombre="<%= resultadoImportacion.escapar(e.getNombre()) %>" data-apellido="<%= resultadoImportacion.escapar(e.getApellido()) %>" data-cedula="<%= resultadoImportacion.escapar(e.getCedula()) %>" data-codmarc="<%= e.getCodM() %>" data-turno="<%= resultadoImportacion.escapar(e.getTurno()) %>" data-estado="<%= e.getEstado() %>" data-fecha="<%= e.getFechaRegTexto() %>">
                                    <td data-col="cedula"><%= resultadoImportacion.escapar(e.getCedula()) %></td>
                                    <td data-col="nombre apellido"><strong><%= resultadoImportacion.escapar(e.getNombre() + " " + e.getApellido()) %></strong></td>
                                    <td data-col="codmarc"><%= e.getCodM() %></td>
                                    <td data-col="turno"><%= e.getTurnoNombre() %></td>
                                    <td data-col="estado"><span class="badge <%= activo ? "badge-ok" : "badge-off" %>"><%= activo ? "Activo" : "Inactivo" %></span></td>
                                    <td data-col="fecha"><%= e.getFechaRegTexto() %></td>
                                    <td class="actions">
                                        <button type="button" class="btn-icon" data-accion="editar" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                        <button type="button" class="btn-icon <%= activo ? "danger" : "" %>" data-accion="estado" title="<%= activo ? "Desactivar" : "Activar" %>"><i class="fa-solid <%= activo ? "fa-user-slash" : "fa-user-check" %>"></i></button>
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

    <%-- Codigos de marcacion con el turno y el empleado que los usa (0 = libre) --%>
    <div id="datosCodigos" hidden>
        <% if (codigos != null) { for (codigoMarcacion c : codigos) { %>
        <span data-codigo="<%= c.getCodigo() %>" data-turno="<%= c.getTurno() %>" data-dueno="<%= c.getIdDueno() %>"></span>
        <% } } %>
    </div>

    <dialog id="dlgPersonal">
        <form action="${pageContext.request.contextPath}/empServlet" method="post" autocomplete="off">
            <div class="modal-head">
                <h3 data-titulo-dialogo>Nuevo empleado</h3>
                <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" id="accion" name="accion" value="crear">
                <input type="hidden" id="idEMP" name="idEMP">

                <div class="form-grid">
                    <div class="field">
                        <label class="required" for="nombre">Nombre</label>
                        <input type="text" id="nombre" name="nombre" class="input" placeholder="Escriba su Nombre" maxlength="100" required>
                    </div>
                    <div class="field">
                        <label class="required" for="apellido">Apellido</label>
                        <input type="text" id="apellido" name="apellido" class="input" placeholder="Escriba su Apellido" maxlength="100" required>
                    </div>
                    <div class="field">
                        <label class="required" for="cedula">Cédula</label>
                        <input type="text" id="cedula" name="cedula" class="input" placeholder="00-0000-000" maxlength="13" required>
                    </div>
                    <div class="field">
                        <label class="required" for="turno">Turno</label>
                        <select id="turno" name="turno" class="input" required>
                            <option value="">Seleccione un turno</option>
                            <option value="M">Mañana</option>
                            <option value="T">Tarde</option>
                        </select>
                    </div>
                    <div class="field full">
                        <label class="required" for="codMarc">Código de marcación</label>
                        <select id="codMarc" name="codMarc" class="input" disabled>
                            <option value="">Seleccione un turno</option>
                        </select>
                        <span class="hint">Se habilita al elegir el turno y muestra solo los códigos libres de ese turno.</span>
                    </div>

                    <div class="full readonly-box" data-solo-edicion hidden>
                        <div class="readonly-title"><i class="fa-solid fa-lock"></i> Datos del sistema (no editables)</div>
                        <div><span class="k">ID del personal:</span> <span data-txt="idemp">-</span></div>
                        <div><span class="k">Fecha de registro:</span> <span data-txt="fecha">-</span></div>
                    </div>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-secondary" data-cerrar>Cancelar</button>
                <button type="submit" class="btn btn-primary"><i class="fa-solid fa-floppy-disk"></i> Guardar</button>
            </div>
        </form>
    </dialog>
</body>
</html>
