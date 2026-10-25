<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.resultadoImportacion" %>
<%
    String error = (String) request.getAttribute("error");
    resultadoImportacion resultado = (resultadoImportacion) request.getAttribute("resultado");

    //mensaje que deja el servlet despues de guardar
    String mensajeOk = (String) session.getAttribute("mensajeImportacion");
    if (mensajeOk != null)
    {
        session.removeAttribute("mensajeImportacion");
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Importar - Asistencia</title>
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
                <strong class="topbar-title">Importar</strong>
            </header>

            <main class="main">
                <div class="page-header">
                    <div>
                        <h1>Importar</h1>
                        <p>Carga de marcaciones desde un archivo</p>
                    </div>
                </div>

                <% if (error != null) { %>
                <div class="alert alert-error">
                    <i class="fa-solid fa-circle-exclamation"></i> <%= resultadoImportacion.escapar(error) %>
                </div>
                <% } %>

                <% if (mensajeOk != null) { %>
                <div class="alert alert-ok">
                    <i class=""></i> <%= resultadoImportacion.escapar(mensajeOk) %>
                </div>
                <% } %>

                <div class="card">
                    <h3>Seleccionar archivo</h3>
                    <form action="${pageContext.request.contextPath}/ImportarServlet?accion=procesar" method="post" enctype="multipart/form-data">
                        <label class="dropzone" for="archivo">
                            <i class="fa-solid fa-cloud-arrow-up"></i>
                            <strong>Haga clic o arrastre un archivo aquí</strong>
                            <span id="nombreArchivo">Formatos permitidos: .dat, .txt</span>
                            <input type="file" id="archivo" name="archivo" accept=".dat,.txt">
                        </label>

                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-file-import"></i> Importar
                            </button>
                            <button type="reset" class="btn btn-secondary">
                                <i class="fa-solid fa-xmark"></i> Cancelar
                            </button>
                        </div>
                    </form>
                </div>

                <% if (resultado != null) { %>
                <div class="card">
                    <div class="card-head">
                        <h3>Resumen del proceso - <%= resultadoImportacion.escapar(resultado.getNombreArchivo()) %></h3>
                    </div>

                    <div class="stats stats-2">
                    <div class="stat">
                        <div class="stat-icon teal"><i class="fa-solid fa-file-lines"></i></div>
                        <div>
                            <span class="stat-label">Registros procesados</span>
                            <span class="stat-value"><%= resultado.getProcesados().size() %></span>
                            <span class="stat-sub">leídos del archivo</span>
                        </div>
                    </div>
                    <div class="stat">
                        <div class="stat-icon green"><i class="fa-solid fa-circle-check"></i></div>
                        <div>
                            <span class="stat-label">Registros correctos</span>
                            <span class="stat-value"><%= resultado.getCorrectos().size() %></span>
                            <span class="stat-sub">listos para guardar</span>
                        </div>
                        <button type="button" class="btn-icon stat-ver" data-abrir="dlgCorrectos" title="Ver registros" aria-label="Ver registros correctos" <%= resultado.getCorrectos().size() == 0 ? "disabled" : "" %>>
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                    </div>

                    <div class="stats stats-3">
                    <div class="stat">
                        <div class="stat-icon amber"><i class="fa-solid fa-clone"></i></div>
                        <div>
                            <span class="stat-label">Registros duplicados</span>
                            <span class="stat-value"><%= resultado.getDuplicados().size() %></span>
                            <span class="stat-sub">no se guardarán</span>
                        </div>
                        <button type="button" class="btn-icon stat-ver" data-abrir="dlgDuplicados" title="Ver registros" aria-label="Ver registros duplicados" <%= resultado.getDuplicados().size() == 0 ? "disabled" : "" %>>
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                    <div class="stat">
                        <div class="stat-icon gray"><i class="fa-solid fa-ban"></i></div>
                        <div>
                            <span class="stat-label">Registros rechazados</span>
                            <span class="stat-value"><%= resultado.getRechazados().size() %></span>
                            <span class="stat-sub">sin empleado o turno</span>
                        </div>
                        <button type="button" class="btn-icon stat-ver" data-abrir="dlgRechazados" title="Ver registros" aria-label="Ver registros rechazados" <%= resultado.getRechazados().size() == 0 ? "disabled" : "" %>>
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                    <div class="stat">
                        <div class="stat-icon red"><i class="fa-solid fa-triangle-exclamation"></i></div>
                        <div>
                            <span class="stat-label">Registros con errores</span>
                            <span class="stat-value"><%= resultado.getErrores().size() %></span>
                            <span class="stat-sub">estructura inválida</span>
                        </div>
                        <button type="button" class="btn-icon stat-ver" data-abrir="dlgErrores" title="Ver registros" aria-label="Ver registros con errores" <%= resultado.getErrores().size() == 0 ? "disabled" : "" %>>
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                    </div>

                    <div class="form-actions">
                        <form action="${pageContext.request.contextPath}/ImportarServlet?accion=cancelar" method="post">
                            <button type="submit" class="btn btn-secondary">
                                <i class="fa-solid fa-xmark"></i> Cancelar
                            </button>
                        </form>
                        <form id="frmGuardar" action="${pageContext.request.contextPath}/ImportarServlet?accion=guardar" method="post"
                              data-validos="<%= resultado.getCorrectos().size() %>"
                              data-incidencias="<%= resultado.hayIncidencias() ? 1 : 0 %>">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa-solid fa-floppy-disk"></i> Guardar
                            </button>
                        </form>
                    </div>
                </div>
                <% } %>
            </main>
        </div>
    </div>

    <% if (resultado != null) { %>
    <dialog id="dlgCorrectos" class="dialog-ancho">
        <div class="modal-head">
            <h3>Registros correctos (<%= resultado.getCorrectos().size() %>)</h3>
            <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <% request.setAttribute("listaMarcaciones", resultado.getCorrectos()); %>
            <% request.setAttribute("ocultarEstado", true); %>
            <jsp:include page="/includes/tabla-marcaciones.jsp" />
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" data-cerrar>Cerrar</button>
        </div>
    </dialog>
    <dialog id="dlgDuplicados" class="dialog-ancho">
        <div class="modal-head">
            <h3>Registros duplicados (<%= resultado.getDuplicados().size() %>)</h3>
            <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <% request.setAttribute("listaMarcaciones", resultado.getDuplicados()); %>
            <jsp:include page="/includes/tabla-marcaciones.jsp" />
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" data-cerrar>Cerrar</button>
        </div>
    </dialog>
    <dialog id="dlgRechazados" class="dialog-ancho">
        <div class="modal-head">
            <h3>Registros rechazados (<%= resultado.getRechazados().size() %>)</h3>
            <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <% request.setAttribute("listaMarcaciones", resultado.getRechazados()); %>
            <jsp:include page="/includes/tabla-marcaciones.jsp" />
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" data-cerrar>Cerrar</button>
        </div>
    </dialog>
    <dialog id="dlgErrores" class="dialog-ancho">
        <div class="modal-head">
            <h3>Registros con errores (<%= resultado.getErrores().size() %>)</h3>
            <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>
        <div class="modal-body">
            <% request.setAttribute("listaMarcaciones", resultado.getErrores()); %>
            <jsp:include page="/includes/tabla-marcaciones.jsp" />
        </div>
        <div class="modal-foot">
            <button type="button" class="btn btn-secondary" data-cerrar>Cerrar</button>
        </div>
    </dialog>
    <% } %>
</body>
</html>
