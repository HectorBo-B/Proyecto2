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
    <title>Reportes y Consultas - Asistencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="${pageContext.request.contextPath}/js/funciones.js" defer></script>
    <style>
        .col-check
        {
            width: 42px;
            text-align: center;
        }
        .pie-tabla
        {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 14px;
            flex-wrap: wrap;
            padding: 14px 16px;
        }
        .pie-tabla .contador-seleccion
        {
            font-size: 13px;
            opacity: 0.8;
        }
        .aviso-rojo
        {
            color: #dc2626;
            font-size: 13px;
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
    </style>
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
                                    <th class="col-check"><input type="checkbox" id="marcarTodosEmp" aria-label="Seleccionar todos los empleados" title="Seleccionar todos"></th>
                                    <th>Cédula</th>
                                    <th>Nombre</th>
                                    <th>Código de marcación</th>
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
                                    <td class="col-check"><input type="checkbox" class="chk-emp" value="<%= e.getEmpleadoID() %>" data-nombre="<%= resultadoImportacion.escapar(nombreCompleto) %>" aria-label="Seleccionar a <%= resultadoImportacion.escapar(nombreCompleto) %>"></td>
                                    <td><%= resultadoImportacion.escapar(e.getCedula()) %></td>
                                    <td><strong><%= resultadoImportacion.escapar(nombreCompleto) %></strong><span hidden><%= resultadoImportacion.escapar(claveBusqueda) %></span></td>
                                    <td><%= e.getCodM() %></td>
                                    <td><%= e.getTurnoNombre() %></td>
                                    <td><span class="badge <%= activo ? "badge-ok" : "badge-off" %>"><%= activo ? "Activo" : "Inactivo" %></span></td>
                                    <td class="actions">
                                        <button type="submit" class="btn btn-secondary" form="frmBuscar" name="id" value="<%= e.getEmpleadoID() %>" title="Imprimir asistencia">
                                            <i class="fa-solid fa-list-check"></i> Asistencia
                                        </button>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>

                    <div class="pie-tabla">
                        <span class="aviso-rojo" id="avisoSeleccion" hidden>Seleccione al menos un empleado.</span>
                        <span class="contador-seleccion" id="contadorSeleccion">0 empleado(s) seleccionado(s)</span>
                        <button type="button" class="btn btn-primary" id="btnObservaciones">
                            <i class="fa-solid fa-comment-dots"></i> Observaciones
                        </button>
                    </div>
                </div>
            </main>
        </div>
    </div>

    <dialog id="dlgObservacion">
        <form id="frmObservacion" action="${pageContext.request.contextPath}/reporteServlet" method="post" autocomplete="off">
            <div class="modal-head">
                <h3>Observaciones</h3>
                <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="modal-body">
                <input type="hidden" name="accion" value="observaciones">
                <input type="hidden" name="desde" id="obsDesde" value="">
                <input type="hidden" name="hasta" id="obsHasta" value="">
                <div id="idsEmpleados"></div>

                <div id="pasoTexto">
                    <div class="form-grid">
                        <div class="field full">
                            <label>Empleados seleccionados</label>
                            <strong id="resumenEmpleados">-</strong>
                        </div>
                        <div class="field full">
                            <label for="tipo">Observación</label>
                            <select id="tipo" name="tipo" class="input">
                                <option value="">Seleccione una observación</option>
                                <option value="Vacaciones">Vacaciones</option>
                                <option value="Incapacidad">Incapacidad</option>
                                <option value="Capacitación">Capacitación</option>
                                <option value="Permiso">Permiso</option>
                                <option value="Misión oficial">Misión oficial</option>
                                <option value="Otro">Otro</option>
                                <option value="Quitar">Quitar observación</option>
                            </select>
                            <span class="hint">Un día con observación no se cuenta como ausencia. "Quitar observación" borra la observación de los días que marques.</span>
                        </div>
                        <div class="field full" id="campoOtro" hidden>
                            <label for="otro">Escriba la observación</label>
                            <textarea id="otro" name="otro" class="input" rows="3" maxlength="255" placeholder="Ej: Reunión externa, cita médica..."></textarea>
                        </div>
                    </div>
                    <span class="aviso-rojo" id="avisoModal" hidden></span>
                </div>

                <div id="pasoDias" hidden>
                    <p class="resumen-obs" id="resumenObs"></p>

                    <div class="acciones-dias">
                        <label><input type="checkbox" id="marcarTodos"> Seleccionar todos</label>
                        <button type="button" class="btn btn-secondary" id="marcarHabiles">Lunes a viernes</button>
                        <span class="contador-dias" id="contadorDias">0 día(s) seleccionado(s)</span>
                    </div>

                    <div class="lista-dias" id="listaDias"></div>

                    <span class="aviso-rojo" id="avisoDias" hidden>Seleccione al menos un día.</span>
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

    <script>
        (function ()
        {
            var MAXIMO_DIAS = 366;
            var DIAS = ['Dom.', 'Lun.', 'Mar.', 'Mie.', 'Jue.', 'Vie.', 'Sáb.'];
            var tabla = document.getElementById('tblReportes');
            var marcarTodosEmp = document.getElementById('marcarTodosEmp');
            var contadorSeleccion = document.getElementById('contadorSeleccion'), avisoSeleccion = document.getElementById('avisoSeleccion');
            var botonObservaciones = document.getElementById('btnObservaciones');
            var dialogo = document.getElementById('dlgObservacion'), formulario = document.getElementById('frmObservacion');
            var pasoTexto = document.getElementById('pasoTexto'), pasoDias = document.getElementById('pasoDias');
            var tipo = document.getElementById('tipo'), campoOtro = document.getElementById('campoOtro'), otro = document.getElementById('otro');
            var resumenEmpleados = document.getElementById('resumenEmpleados'), resumenObs = document.getElementById('resumenObs');
            var idsEmpleados = document.getElementById('idsEmpleados'), listaDias = document.getElementById('listaDias');
            var obsDesde = document.getElementById('obsDesde'), obsHasta = document.getElementById('obsHasta');
            var avisoModal = document.getElementById('avisoModal'), avisoDias = document.getElementById('avisoDias');
            var contadorDias = document.getElementById('contadorDias'), marcarTodos = document.getElementById('marcarTodos'), marcarHabiles = document.getElementById('marcarHabiles');
            var botonSiguiente = document.getElementById('btnSiguiente'), botonVolver = document.getElementById('btnVolver'), botonGuardar = document.getElementById('btnGuardar');

            function casillasEmpleados()
            {
                return Array.prototype.slice.call(tabla.querySelectorAll('tbody .chk-emp'));
            }

            function visibles()
            {
                return casillasEmpleados().filter(function (casilla)
                {
                    return !casilla.closest('tr').hidden;
                });
            }

            function seleccionados()
            {
                return visibles().filter(function (casilla)
                {
                    return casilla.checked;
                });
            }

            function actualizarSeleccion()
            {
                var cantidad = seleccionados().length;

                contadorSeleccion.textContent = cantidad + ' empleado(s) seleccionado(s)';
                marcarTodosEmp.checked = visibles().length > 0 && cantidad === visibles().length;
                if (cantidad > 0)
                {
                    avisoSeleccion.hidden = true;
                }
            }

            function diferir()
            {
                window.setTimeout(actualizarSeleccion, 0);
            }

            function casillasDias()
            {
                return Array.prototype.slice.call(listaDias.querySelectorAll('input[name="fechas"]'));
            }

            function diasMarcados()
            {
                return casillasDias().filter(function (casilla)
                {
                    return casilla.checked;
                });
            }

            function contarDias()
            {
                var cantidad = diasMarcados().length;

                contadorDias.textContent = cantidad + ' día(s) seleccionado(s)';
                marcarTodos.checked = cantidad > 0 && cantidad === casillasDias().length;
                if (cantidad > 0)
                {
                    avisoDias.hidden = true;
                }
            }

            function mostrar(paso)
            {
                pasoTexto.hidden = paso !== 1;
                pasoDias.hidden = paso !== 2;
                botonSiguiente.hidden = paso !== 1;
                botonVolver.hidden = paso !== 2;
                botonGuardar.hidden = paso !== 2;
            }

            function avisar(mensaje)
            {
                avisoModal.textContent = mensaje;
                avisoModal.hidden = false;
            }

            function partirFecha(valor)
            {
                var partes = valor.split('-');

                return new Date(parseInt(partes[0], 10), parseInt(partes[1], 10) - 1, parseInt(partes[2], 10));
            }

            function dosDigitos(numero)
            {
                return (numero < 10 ? '0' : '') + numero;
            }

            function textoFecha(fecha)
            {
                return dosDigitos(fecha.getDate()) + '-' + dosDigitos(fecha.getMonth() + 1) + '-' + fecha.getFullYear();
            }

            function valorFecha(fecha)
            {
                return fecha.getFullYear() + '-' + dosDigitos(fecha.getMonth() + 1) + '-' + dosDigitos(fecha.getDate());
            }

            function textoObservacion()
            {
                if (tipo.value === 'Otro')
                {
                    return otro.value.trim();
                }
                if (tipo.value === 'Quitar')
                {
                    return '';
                }
                return tipo.options[tipo.selectedIndex].text;
            }

            function construirDias(inicio, fin)
            {
                var fecha = new Date(inicio.getTime());

                listaDias.innerHTML = '';
                while (fecha <= fin)
                {
                    var fila = document.createElement('label');
                    var casilla = document.createElement('input');
                    var textoDia = document.createElement('span');
                    var nombreDia = document.createElement('span');

                    fila.className = 'dia-item';
                    casilla.type = 'checkbox';
                    casilla.name = 'fechas';
                    casilla.value = valorFecha(fecha);
                    casilla.setAttribute('data-habil', fecha.getDay() >= 1 && fecha.getDay() <= 5 ? '1' : '0');
                    casilla.addEventListener('change', contarDias);
                    textoDia.className = 'dia-fecha';
                    textoDia.textContent = textoFecha(fecha);
                    nombreDia.className = 'dia-nombre';
                    nombreDia.textContent = DIAS[fecha.getDay()];
                    fila.appendChild(casilla);
                    fila.appendChild(textoDia);
                    fila.appendChild(nombreDia);
                    listaDias.appendChild(fila);
                    fecha.setDate(fecha.getDate() + 1);
                }
            }

            function abrirModal()
            {
                var marcados = seleccionados();
                var nombres = marcados.map(function (casilla)
                {
                    return casilla.getAttribute('data-nombre');
                });

                if (marcados.length === 0)
                {
                    avisoSeleccion.hidden = false;
                    return;
                }

                formulario.reset();
                idsEmpleados.innerHTML = '';
                marcados.forEach(function (casilla)
                {
                    var oculto = document.createElement('input');

                    oculto.type = 'hidden';
                    oculto.name = 'idEMP';
                    oculto.value = casilla.value;
                    idsEmpleados.appendChild(oculto);
                });

                resumenEmpleados.textContent = nombres.length <= 3
                    ? nombres.join(', ')
                    : nombres.slice(0, 3).join(', ') + ' y ' + (nombres.length - 3) + ' más (' + nombres.length + ' en total)';
                listaDias.innerHTML = '';
                campoOtro.hidden = true;
                avisoModal.hidden = true;
                avisoDias.hidden = true;
                contarDias();
                mostrar(1);
                dialogo.showModal();
            }

            tabla.addEventListener('change', function (evento)
            {
                if (evento.target.classList.contains('chk-emp'))
                {
                    actualizarSeleccion();
                }
            });

            marcarTodosEmp.addEventListener('change', function ()
            {
                visibles().forEach(function (casilla)
                {
                    casilla.checked = marcarTodosEmp.checked;
                });
                actualizarSeleccion();
            });

            document.getElementById('q').addEventListener('input', diferir);
            document.querySelector('[data-limpiar="tblReportes"]').addEventListener('click', diferir);
            botonObservaciones.addEventListener('click', abrirModal);

            tipo.addEventListener('change', function ()
            {
                campoOtro.hidden = tipo.value !== 'Otro';
                avisoModal.hidden = true;
                if (tipo.value === 'Otro')
                {
                    otro.focus();
                }
            });

            botonSiguiente.addEventListener('click', function ()
            {
                var desde = document.getElementById('desde').value;
                var hasta = document.getElementById('hasta').value;
                var dias = 0;
                var texto = textoObservacion();

                if (!tipo.value)
                {
                    avisar('Seleccione una observación.');
                    return;
                }
                if (tipo.value === 'Otro' && !texto)
                {
                    avisar('Escriba la observación.');
                    otro.focus();
                    return;
                }
                if (!desde || !hasta)
                {
                    avisar('Seleccione las fechas Desde y Hasta en la parte superior de la pantalla.');
                    return;
                }
                if (hasta < desde)
                {
                    avisar('La fecha final no puede ser anterior a la inicial.');
                    return;
                }

                dias = Math.round((partirFecha(hasta) - partirFecha(desde)) / 86400000) + 1;
                if (dias > MAXIMO_DIAS)
                {
                    avisar('El rango no puede superar ' + MAXIMO_DIAS + ' días.');
                    return;
                }

                avisoModal.hidden = true;
                obsDesde.value = desde;
                obsHasta.value = hasta;
                construirDias(partirFecha(desde), partirFecha(hasta));
                contarDias();
                resumenObs.textContent = (tipo.value === 'Quitar'
                    ? 'Se quitará la observación de los días que marques.'
                    : 'Observación: ' + texto)
                    + ' | Rango: ' + textoFecha(partirFecha(desde)) + ' al ' + textoFecha(partirFecha(hasta));
                mostrar(2);
            });

            botonVolver.addEventListener('click', function ()
            {
                mostrar(1);
            });

            marcarTodos.addEventListener('change', function ()
            {
                casillasDias().forEach(function (casilla)
                {
                    casilla.checked = marcarTodos.checked;
                });
                contarDias();
            });

            marcarHabiles.addEventListener('click', function ()
            {
                casillasDias().forEach(function (casilla)
                {
                    casilla.checked = casilla.getAttribute('data-habil') === '1';
                });
                contarDias();
            });

            formulario.addEventListener('submit', function (evento)
            {
                if (pasoDias.hidden)
                {
                    evento.preventDefault();
                    botonSiguiente.click();
                    return;
                }
                if (diasMarcados().length === 0)
                {
                    evento.preventDefault();
                    avisoDias.hidden = false;
                }
            });

            actualizarSeleccion();
        })();
    </script>
</body>
</html>