<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.empleado, model.reporteAsistencia, model.resultadoImportacion" %>
<%
    reporteAsistencia reporte = (reporteAsistencia) request.getAttribute("reporte");

    if (reporte == null)
    {
        response.sendRedirect(request.getContextPath() + "/reporteServlet");
        return;
    }

    empleado emp = reporte.getEmpleado();
    String mensajeOk = (String) session.getAttribute("mensajeReporteOk");
    String mensajeError = (String) session.getAttribute("mensajeReporteError");
    session.removeAttribute("mensajeReporteOk");
    session.removeAttribute("mensajeReporteError");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Asistencia - <%= resultadoImportacion.escapar(emp.getNombre() + " " + emp.getApellido()) %></title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="${pageContext.request.contextPath}/js/funciones.js" defer></script>
    <style>
        body.vista-reporte
        {
            background: #e5e7eb;
            display: block;
        }
        .barra-reporte
        {
            max-width: 860px;
            margin: 16px auto 0;
            padding: 0 8px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .barra-reporte .alert
        {
            flex: 1 1 100%;
            margin: 0;
        }
        .hoja
        {
            max-width: 860px;
            margin: 12px auto 32px;
            padding: 32px 40px;
            background: #fff;
            color: #000;
            font-family: Arial, Helvetica, sans-serif;
            font-size: 13px;
            line-height: 1.35;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.2);
        }
        .hoja h1
        {
            margin: 0;
            text-align: center;
            font-size: 18px;
            color: #000;
        }
        .hoja .rango
        {
            margin: 4px 0 18px;
            text-align: center;
        }
        .hoja .datos p
        {
            margin: 0 0 4px;
        }
        .hoja table
        {
            width: 100%;
            margin-top: 8px;
            border-collapse: collapse;
            border-top: 1px dashed #000;
        }
        .hoja th
        {
            padding: 8px 6px;
            text-align: left;
            font-weight: normal;
            color: #000;
            background: transparent;
            border-bottom: 1px dashed #000;
        }
        .hoja td
        {
            padding: 1px 6px;
            color: #000;
            background: transparent;
            border: 0;
            vertical-align: top;
        }
        .hoja tbody tr:first-child td
        {
            padding-top: 8px;
        }
        .hoja tbody tr:last-child td
        {
            padding-bottom: 8px;
        }
        .hoja tfoot td
        {
            padding: 0;
            border-top: 1px dashed #000;
        }
        .hoja .c-dia
        {
            width: 60px;
        }
        .hoja .c-hora
        {
            width: 110px;
        }
        .hoja .totales
        {
            margin-top: 10px;
        }
        .hoja .totales p
        {
            margin: 0 0 3px 28px;
        }
        .hoja .totales p.titulo
        {
            margin-left: 0;
        }
        .hoja .totales p.nivel2
        {
            margin-left: 56px;
        }
        dialog [hidden]
        {
            display: none !important;
        }
        .resumen-obs
        {
            margin: 0 0 12px;
            padding: 10px 12px;
            border-radius: 8px;
            background: rgba(127, 127, 127, 0.12);
            word-break: break-word;
        }
        .acciones-dias
        {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-bottom: 10px;
        }
        .acciones-dias .contador-dias
        {
            margin-left: auto;
            font-size: 13px;
            opacity: 0.8;
        }
        .lista-dias
        {
            max-height: 320px;
            overflow-y: auto;
            border: 1px solid rgba(127, 127, 127, 0.35);
            border-radius: 8px;
        }
        .dia-item
        {
            display: flex;
            align-items: baseline;
            gap: 10px;
            padding: 7px 12px;
            cursor: pointer;
            border-bottom: 1px solid rgba(127, 127, 127, 0.2);
        }
        .dia-item:last-child
        {
            border-bottom: 0;
        }
        .dia-item:hover
        {
            background: rgba(127, 127, 127, 0.1);
        }
        .dia-item .dia-fecha
        {
            min-width: 92px;
        }
        .dia-item .dia-nombre
        {
            min-width: 40px;
        }
        .dia-item .dia-notas
        {
            font-size: 12px;
            opacity: 0.7;
        }
        .aviso-dias
        {
            display: block;
            margin-top: 8px;
            color: #dc2626;
        }
        @page
        {
            size: A4;
            margin: 14mm;
        }
        @media print
        {
            body.vista-reporte
            {
                background: #fff;
            }
            .hoja
            {
                max-width: none;
                margin: 0;
                padding: 0;
                box-shadow: none;
            }
            .hoja tr
            {
                page-break-inside: avoid;
            }
        }
    </style>
</head>
<body class="vista-reporte">
    <div class="barra-reporte no-print">
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
        <button type="button" class="btn btn-primary" data-imprimir>
            <i class="fa-solid fa-print"></i> Imprimir
        </button>
        <button type="button" class="btn btn-secondary" data-abrir="dlgObservacion" data-titulo="Observaciones">
            <i class="fa-solid fa-comment-dots"></i> Observaciones
        </button>
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/reporteServlet?desde=<%= reporte.getDesde() %>&amp;hasta=<%= reporte.getHasta() %>">
            <i class="fa-solid fa-arrow-left"></i> Volver al listado
        </a>
    </div>

    <div class="hoja">
        <h1>Empresa XYZ</h1>
        <p class="rango">Asistencia Desde <%= reporte.getDesdeTexto() %> Hasta <%= reporte.getHastaTexto() %></p>

        <div class="datos">
            <p>Nombre: <%= resultadoImportacion.escapar(emp.getNombre() + " " + emp.getApellido()) %></p>
            <p>Código de Marcación: <%= emp.getCodM() %></p>
        </div>

        <table id="tblAsistencia">
            <thead>
                <tr>
                    <th colspan="2">Fecha</th>
                    <th class="c-hora">Entrada</th>
                    <th class="c-hora">Salida</th>
                    <th>Observación</th>
                </tr>
            </thead>
            <tbody>
                <% for (reporteAsistencia.dia d : reporte.getDias()) { %>
                <tr>
                    <td><%= d.getFechaTexto() %></td>
                    <td class="c-dia"><%= d.getNombreDia() %></td>
                    <td class="c-hora"><%= d.getEntradaTexto() %></td>
                    <td class="c-hora"><%= d.getSalidaTexto() %></td>
                    <td><%= resultadoImportacion.escapar(d.getObservacion()) %></td>
                </tr>
                <% } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="5"></td>
                </tr>
            </tfoot>
        </table>

        <div class="totales">
            <p class="titulo">Totales</p>
            <p>Ausencias: <%= reporte.getAusencias() %></p>
            <p>Tardanzas: <%= reporte.getTardanzas() %></p>
            <p class="nivel2">Justificadas: <%= reporte.getJustificadas() %></p>
            <p class="nivel2">Injustificadas: <%= reporte.getInjustificadas() %></p>
            <p>Tiempo total de tardanzas: <%= reporte.getTiempoTardanzaTexto() %></p>
        </div>
    </div>

    <dialog id="dlgObservacion">
        <form id="frmObservacion" action="${pageContext.request.contextPath}/reporteServlet" method="post" autocomplete="off">
            <div class="modal-head">
                <h3 data-titulo-dialogo>Observaciones</h3>
                <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="accion" value="observaciones">
                <input type="hidden" name="idEMP" value="<%= emp.getEmpleadoID() %>">
                <input type="hidden" name="desde" value="<%= reporte.getDesde() %>">
                <input type="hidden" name="hasta" value="<%= reporte.getHasta() %>">

                <div id="pasoTexto">
                    <div class="form-grid">
                        <div class="field full">
                            <label for="observacion">Observación</label>
                            <textarea id="observacion" name="observacion" class="input" rows="4" maxlength="255" placeholder="Ej: Permiso médico, cita, reunión externa..."></textarea>
                            <span class="hint">Escríbela y luego elige los días en que se aplica. Si la dejas vacía, se quitará la observación de los días que marques.</span>
                        </div>
                        <div class="field full">
                            <label for="justificada">¿Justificada?</label>
                            <select id="justificada" name="justificada" class="input">
                                <option value="0">No</option>
                                <option value="1">Sí</option>
                            </select>
                            <span class="hint">Solo se usa para contar las tardanzas justificadas en los totales; no se agrega al texto de la observación.</span>
                        </div>
                    </div>
                </div>

                <div id="pasoDias" hidden>
                    <p class="resumen-obs" id="resumenObs"></p>

                    <div class="acciones-dias">
                        <label><input type="checkbox" id="marcarTodos"> Seleccionar todos</label>
                        <button type="button" class="btn btn-secondary" id="marcarAusencias">Marcar ausencias</button>
                        <span class="contador-dias" id="contadorDias">0 día(s) seleccionado(s)</span>
                    </div>

                    <div class="lista-dias">
                        <% for (reporteAsistencia.dia d : reporte.getDias()) { %>
                        <label class="dia-item">
                            <input type="checkbox" name="fechas" value="<%= d.getFechaIso() %>" data-ausente="<%= d.isAusente() ? "1" : "0" %>">
                            <span class="dia-fecha"><%= d.getFechaTexto() %></span>
                            <span class="dia-nombre"><%= d.getNombreDia() %></span>
                            <span class="dia-notas"><%= resultadoImportacion.escapar(d.getObservacion()) %></span>
                        </label>
                        <% } %>
                    </div>

                    <span class="aviso-dias" id="avisoDias" hidden>Selecciona al menos un día.</span>
                </div>
            </div>

            <div class="modal-foot">
                <button type="button" class="btn btn-secondary" data-cerrar>Cancelar</button>
                <button type="button" class="btn btn-secondary" id="btnVolver" hidden>
                    <i class="fa-solid fa-arrow-left"></i> Volver
                </button>
                <button type="button" class="btn btn-primary" id="btnSiguiente">
                    <i class="fa-solid fa-calendar-check"></i> Seleccionar días
                </button>
                <button type="submit" class="btn btn-primary" id="btnGuardar" hidden>
                    <i class="fa-solid fa-floppy-disk"></i> Guardar
                </button>
            </div>
        </form>
    </dialog>

    <script>
        (function ()
        {
            var formulario = document.getElementById('frmObservacion');
            var pasoTexto = document.getElementById('pasoTexto'), pasoDias = document.getElementById('pasoDias');
            var observacion = document.getElementById('observacion'), justificada = document.getElementById('justificada');
            var resumen = document.getElementById('resumenObs'), contador = document.getElementById('contadorDias'), aviso = document.getElementById('avisoDias');
            var botonSiguiente = document.getElementById('btnSiguiente'), botonVolver = document.getElementById('btnVolver'), botonGuardar = document.getElementById('btnGuardar');
            var marcarTodos = document.getElementById('marcarTodos'), marcarAusencias = document.getElementById('marcarAusencias');
            var casillas = Array.prototype.slice.call(formulario.querySelectorAll('input[name="fechas"]'));

            function marcadas()
            {
                return casillas.filter(function (casilla)
                {
                    return casilla.checked;
                });
            }

            function contar()
            {
                var cantidad = marcadas().length;

                contador.textContent = cantidad + ' día(s) seleccionado(s)';
                marcarTodos.checked = cantidad > 0 && cantidad === casillas.length;
                if (cantidad > 0)
                {
                    aviso.hidden = true;
                }
            }

            function mostrar(paso)
            {
                var texto = observacion.value.trim();

                pasoTexto.hidden = paso !== 1;
                pasoDias.hidden = paso !== 2;
                botonSiguiente.hidden = paso !== 1;
                botonVolver.hidden = paso !== 2;
                botonGuardar.hidden = paso !== 2;

                if (paso === 2)
                {
                    resumen.textContent = texto
                        ? 'Observación: ' + texto + (justificada.value === '1' ? ' (marcada como justificada)' : '')
                        : 'Se quitará la observación de los días que marques.';
                }
            }

            formulario.addEventListener('reset', function ()
            {
                window.setTimeout(function ()
                {
                    mostrar(1);
                    contar();
                    aviso.hidden = true;
                }, 0);
            });

            botonSiguiente.addEventListener('click', function ()
            {
                mostrar(2);
            });

            botonVolver.addEventListener('click', function ()
            {
                mostrar(1);
            });

            marcarTodos.addEventListener('change', function ()
            {
                casillas.forEach(function (casilla)
                {
                    casilla.checked = marcarTodos.checked;
                });
                contar();
            });

            marcarAusencias.addEventListener('click', function ()
            {
                casillas.forEach(function (casilla)
                {
                    casilla.checked = casilla.getAttribute('data-ausente') === '1';
                });
                contar();
            });

            casillas.forEach(function (casilla)
            {
                casilla.addEventListener('change', contar);
            });

            formulario.addEventListener('submit', function (evento)
            {
                if (pasoDias.hidden)
                {
                    evento.preventDefault();
                    mostrar(2);
                    return;
                }
                if (marcadas().length === 0)
                {
                    evento.preventDefault();
                    aviso.hidden = false;
                }
            });
        })();
    </script>
</body>
</html>