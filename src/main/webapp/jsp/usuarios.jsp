<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, model.usuario, model.auditoria, model.resultadoImportacion" %>
<%!
    private static String esc(String texto)
    {
        return resultadoImportacion.escapar(texto);
    }
%>
<%
    usuario actual = (usuario) session.getAttribute(usuario.SESION);

    //esta página es solo para el administrador
    if (actual == null)
    {
        response.sendRedirect(request.getContextPath() + "/jsp/login.jsp");
        return;
    }
    if (!actual.esAdmin())
    {
        response.sendRedirect(request.getContextPath() + "/jsp/dashboard.jsp");
        return;
    }

    @SuppressWarnings("unchecked")
    List<usuario> usuarios = (List<usuario>) request.getAttribute("usuarios");

    //si se abre el JSP directamente, se pasa primero por el servlet para cargar los datos
    if (usuarios == null)
    {
        response.sendRedirect(request.getContextPath() + "/usuarioServlet");
        return;
    }

    @SuppressWarnings("unchecked")
    List<auditoria> registros = (List<auditoria>) request.getAttribute("auditoria");

    String error = (String) request.getAttribute("error");
    String mensajeOk = (String) session.getAttribute("mensajeUsuarioOk");
    String mensajeError = (String) session.getAttribute("mensajeUsuarioError");
    session.removeAttribute("mensajeUsuarioOk");
    session.removeAttribute("mensajeUsuarioError");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Usuarios y acceso - Asistencia</title>
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
                <strong class="topbar-title">Usuarios y Accesos</strong>
            </header>

            <main class="main">
                <div class="page-header">
                    <div>
                        <h1>Usuarios y acceso</h1>
                        <p>Administre los usuarios del sistema y revise la actividad de acceso</p>
                    </div>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= esc(error) %>
                </div>
                <% } %>
                <% if (mensajeError != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= esc(mensajeError) %>
                </div>
                <% } %>
                <% if (mensajeOk != null) { %>
                <div class="alert alert-ok">
                    <i class="fa-solid fa-circle-check"></i> <%= esc(mensajeOk) %>
                </div>
                <% } %>

                <div class="tabs">
                    <button type="button" class="active" data-grupo="seg" data-panel="panelUsuarios">Usuarios</button>
                    <button type="button" data-grupo="seg" data-panel="panelAuditoria">Auditoría</button>
                </div>

                <section id="panelUsuarios" data-grupo="seg">
                    <div class="card">
                        <div class="card-head">
                            <h3>Usuarios del sistema</h3>
                            <button type="button" class="btn btn-primary" data-abrir="dlgUsuario" data-titulo="Nuevo usuario">
                                <i class="fa-solid fa-plus"></i> Nuevo usuario
                            </button>
                        </div>

                        <div class="toolbar">
                            <div class="field">
                                <label for="buscarUsuario">Buscar</label>
                                <input type="text" id="buscarUsuario" class="input" placeholder="Usuario, nombre o correo..." data-buscar="tblUsuarios">
                            </div>
                            <div class="field">
                                <label for="filtroRol">Rol</label>
                                <select id="filtroRol" class="input" data-filtro-select="tblUsuarios" data-campo="rol">
                                    <option value="">Todos</option>
                                    <option value="ADMIN">Administrador</option>
                                    <option value="OPERADOR">Operador</option>
                                </select>
                            </div>
                            <div class="field">
                                <label for="filtroEstadoUsuario">Estado</label>
                                <select id="filtroEstadoUsuario" class="input" data-filtro-select="tblUsuarios" data-campo="estado">
                                    <option value="">Todos</option>
                                    <option value="1">Activos</option>
                                    <option value="0">Inactivos</option>
                                </select>
                            </div>
                            <button type="button" class="btn btn-secondary" data-limpiar="tblUsuarios">
                                <i class="fa-solid fa-rotate"></i> Limpiar
                            </button>
                            <span class="counter" data-contador="tblUsuarios"><%= usuarios.size() %> resultado(s)</span>
                        </div>

                        <div class="table-wrap">
                            <table class="table" id="tblUsuarios"
                                   data-crud="dlgUsuario" data-titulo-editar="Modificar usuario" data-etiqueta="usuario"
                                   data-servidor="${pageContext.request.contextPath}/usuarioServlet"
                                   data-param-id="idUsuario" data-fila-id="idusuario"
                                   data-badge-rol="ADMIN|badge-info|Administrador;OPERADOR|badge-info|Operador"
                                   data-badge-estado="1|badge-ok|Activo;0|badge-off|Inactivo">
                                <thead>
                                    <tr>
                                        <th>Usuario</th>
                                        <th>Nombre</th>
                                        <th>Correo</th>
                                        <th>Rol</th>
                                        <th>Estado</th>
                                        <th class="actions">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (usuario u : usuarios) { boolean activo = u.getEstado() == 1; boolean admin = u.esAdmin(); %>
                                    <tr data-idusuario="<%= u.getId() %>" data-nombre="<%= esc(u.getNombre()) %>" data-apellido="<%= esc(u.getApellido()) %>" data-usuario="<%= esc(u.getUsuario()) %>" data-correo="<%= esc(u.getCorreo()) %>" data-rol="<%= esc(u.getRol()) %>" data-estado="<%= u.getEstado() %>" data-creacion="<%= u.getFechaCreacionTexto() %>">
                                        <td data-col="usuario"><strong><%= esc(u.getUsuario()) %></strong></td>
                                        <td data-col="nombre apellido"><%= esc(u.getNombreCompleto()) %></td>
                                        <td data-col="correo"><%= esc(u.getCorreo()) %></td>
                                        <td data-col="rol"><span class="badge badge-info"><%= u.getRolNombre() %></span></td>
                                        <td data-col="estado"><span class="badge <%= activo ? "badge-ok" : "badge-off" %>"><%= activo ? "Activo" : "Inactivo" %></span></td>
                                        <td class="actions">
                                            <button type="button" class="btn-icon" data-accion="editar" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                            <% if (!admin) { %>
                                            <button type="button" class="btn-icon <%= activo ? "danger" : "" %>" data-accion="estado" title="<%= activo ? "Desactivar" : "Activar" %>"><i class="fa-solid <%= activo ? "fa-user-slash" : "fa-user-check" %>"></i></button>
                                            <button type="button" class="btn-icon danger" data-accion="eliminar" title="Eliminar"><i class="fa-solid fa-trash-can"></i></button>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <section id="panelAuditoria" data-grupo="seg" hidden>
                    <div class="card">
                        <div class="card-head">
                            <h3>Auditoría de acceso</h3>
                            <span class="counter" data-contador="tblAuditoria"><%= registros == null ? 0 : registros.size() %> resultado(s)</span>
                        </div>

                        <div class="toolbar">
                            <div class="field">
                                <label for="buscarAuditoria">Buscar</label>
                                <input type="text" id="buscarAuditoria" class="input" placeholder="Usuario o descripción..." data-buscar="tblAuditoria">
                            </div>
                            <div class="field">
                                <label for="filtroAccion">Acción</label>
                                <select id="filtroAccion" class="input" data-filtro-select="tblAuditoria" data-campo="accion">
                                    <option value="">Todas</option>
                                    <option value="LOGIN">Login</option>
                                    <option value="LOGOUT">Logout</option>
                                    <option value="IMPORTACION">Importación</option>
                                    <option value="CRUD">CRUD</option>
                                </select>
                            </div>
                            <button type="button" class="btn btn-secondary" data-limpiar="tblAuditoria">
                                <i class="fa-solid fa-rotate"></i> Limpiar
                            </button>
                        </div>

                        <div class="table-wrap">
                            <table class="table" id="tblAuditoria">
                                <thead>
                                    <tr>
                                        <th>Fecha</th>
                                        <th>Usuario</th>
                                        <th>Acción</th>
                                        <th>Descripción</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% if (registros != null) { for (auditoria a : registros) { %>
                                    <tr data-accion="<%= esc(a.getAccion()) %>">
                                        <td><%= a.getFechaTexto() %></td>
                                        <td><strong><%= esc(a.getUsuario()) %></strong></td>
                                        <td><span class="badge <%= a.getBadge() %>"><%= a.getAccionTexto() %></span></td>
                                        <td><%= esc(a.getDescripcion()) %></td>
                                    </tr>
                                    <% } } %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    </div>

    <dialog id="dlgUsuario">
        <form action="${pageContext.request.contextPath}/usuarioServlet" method="post" autocomplete="off">
            <div class="modal-head">
                <h3 data-titulo-dialogo>Nuevo usuario</h3>
                <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" id="accionUsuario" name="accion" value="crear">
                <input type="hidden" id="idUsuario" name="idUsuario">

                <div class="form-grid">
                    <div class="field">
                        <label class="required" for="nombreUsuario">Nombre</label>
                        <input type="text" id="nombreUsuario" name="nombre" class="input" maxlength="100" required>
                    </div>
                    <div class="field">
                        <label class="required" for="apellidoUsuario">Apellido</label>
                        <input type="text" id="apellidoUsuario" name="apellido" class="input" maxlength="100" required>
                    </div>
                    <div class="field">
                        <label class="required" for="usuario">Usuario</label>
                        <input type="text" id="usuario" name="usuario" class="input" maxlength="50" required>
                    </div>
                    <div class="field">
                        <label class="required" for="correo">Correo</label>
                        <input type="email" id="correo" name="correo" class="input" maxlength="100" required>
                    </div>
                    <div class="field full">
                        <label for="clave">Contraseña</label>
                        <div class="password-wrap">
                            <input type="password" id="clave" name="password" class="input" minlength="8" maxlength="100" data-requerido-creacion required>
                            <button type="button" class="toggle-pass" data-ver-clave aria-label="Mostrar contraseña">
                                <i class="fa-solid fa-eye"></i>
                            </button>
                        </div>
                        <span class="hint" data-solo-edicion hidden>Déjela vacía para conservar la contraseña actual.</span>
                    </div>
                    <div class="field">
                        <label for="rol">Rol</label>
                        <select id="rol" name="rol" class="input" disabled>
                            <option value="OPERADOR">Operador</option>
                            <option value="ADMIN">Administrador</option>
                        </select>
                        <span class="hint">Solo puede existir un administrador; los usuarios nuevos son operadores.</span>
                    </div>
                    <div class="field">
                        <label class="required" for="estadoUsuario">Estado</label>
                        <select id="estadoUsuario" name="estado" class="input" required>
                            <option value="1">Activo</option>
                            <option value="0">Inactivo</option>
                        </select>
                    </div>

                    <div class="full readonly-box" data-solo-edicion hidden>
                        <div class="readonly-title"><i class="fa-solid fa-lock"></i> Datos del sistema (no editables)</div>
                        <div><span class="k">ID del usuario:</span> <span data-txt="idusuario">-</span></div>
                        <div><span class="k">Fecha de creación:</span> <span data-txt="creacion">-</span></div>
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