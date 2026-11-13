<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Collections, java.util.List, model.empleado, model.reporteAsistencia, model.resultadoImportacion" %>
<%
    @SuppressWarnings("unchecked")
    List<reporteAsistencia> hojas = (List<reporteAsistencia>) request.getAttribute("reportes");
    reporteAsistencia unica = (reporteAsistencia) request.getAttribute("reporte");
    boolean varias = hojas != null;

    if (!varias && unica == null)
    {
        response.sendRedirect(request.getContextPath() + "/reporteServlet");
        return;
    }

    if (!varias)
    {
        hojas = Collections.singletonList(unica);
    }

    String desde = (String) request.getAttribute("desde");
    String hasta = (String) request.getAttribute("hasta");
    String titulo = varias
            ? "Asistencia de todo el personal"
            : "Asistencia - " + resultadoImportacion.escapar(unica.getEmpleado().getNombre() + " " + unica.getEmpleado().getApellido());
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= titulo %></title>
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
            position: sticky;
            top: 0;
            z-index: 5;
            max-width: 860px;
            margin: 0 auto;
            padding: 10px 8px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            background: #e5e7eb;
        }
        .barra-reporte select
        {
            width: auto;
            min-width: 240px;
        }
        @media (min-width: 1400px)
        {
            .barra-reporte
            {
                position: fixed;
                top: 16px;
                left: 16px;
                width: 220px;
                max-width: none;
                margin: 0;
                padding: 0;
                flex-direction: column;
                align-items: stretch;
                background: transparent;
            }
            .barra-reporte .btn,
            .barra-reporte select
            {
                width: 100%;
                min-width: 0;
            }
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
            table-layout: fixed;
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
        .hoja td, .hoja th
        {
            white-space: nowrap;
        }
        .hoja td.c-obs, .hoja th.c-obs
        {
            white-space: normal;
            word-break: break-word;
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
            .hoja + .hoja
            {
                break-before: page;
                page-break-before: always;
            }
        }
    </style>
</head>
<body class="vista-reporte">
    <div class="barra-reporte no-print">
        <a class="btn btn-secondary" href="${pageContext.request.contextPath}/reporteServlet?desde=<%= desde %>&amp;hasta=<%= hasta %>">
            <i class="fa-solid fa-arrow-left"></i> Volver al listado
        </a>
        <button type="button" class="btn btn-primary" data-imprimir>
            <i class="fa-solid fa-print"></i> <%= varias ? "Imprimir todas" : "Imprimir" %>
        </button>
        <% if (varias && !hojas.isEmpty()) { %>
        <select id="irEmpleado" class="input" aria-label="Ir a la hoja de un empleado">
            <option value="">Ir a un empleado (<%= hojas.size() %> hojas)</option>
            <% for (reporteAsistencia r : hojas) {
                empleado e = r.getEmpleado(); %>
            <option value="emp-<%= e.getEmpleadoID() %>"><%= resultadoImportacion.escapar(e.getNombre() + " " + e.getApellido()) %></option>
            <% } %>
        </select>
        <% } %>
    </div>

    <% if (hojas.isEmpty()) { %>
    <div class="hoja">
        <p class="rango">No hay personal registrado.</p>
    </div>
    <% } %>

    <% for (reporteAsistencia reporte : hojas) {
        empleado emp = reporte.getEmpleado(); %>
    <div class="hoja" id="emp-<%= emp.getEmpleadoID() %>">
        <h1>Empresa XYZ</h1>
        <p class="rango">Asistencia Desde <%= reporte.getDesdeTexto() %> Hasta <%= reporte.getHastaTexto() %></p>

        <div class="datos">
            <p>Nombre: <%= resultadoImportacion.escapar(emp.getNombre() + " " + emp.getApellido()) %></p>
            <p>Código de Marcación: <%= emp.getCodM() %></p>
        </div>

        <table class="tbl-asistencia">
            <colgroup>
                <col style="width: 92px">
                <col style="width: 56px">
                <col style="width: 84px">
                <col style="width: 40px">
                <col style="width: 100px">
                <col>
            </colgroup>
            <thead>
                <tr>
                    <th colspan="2">Fecha</th>
                    <th>Entrada</th>
                    <th></th>
                    <th>Salida</th>
                    <th class="c-obs">Observación</th>
                </tr>
            </thead>
            <tbody>
                <% for (reporteAsistencia.dia d : reporte.getDias()) { %>
                <tr>
                    <td><%= d.getFechaTexto() %></td>
                    <td><%= d.getNombreDiaMarcado() %></td>
                    <td><%= d.getEntradaTexto() %></td>
                    <td><%= d.getMarcaTardanza() %></td>
                    <td><%= d.getSalidaTexto() %></td>
                    <td class="c-obs"><%= resultadoImportacion.escapar(d.getObservacion()) %></td>
                </tr>
                <% } %>
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="6"></td>
                </tr>
            </tfoot>
        </table>

        <div class="totales">
            <p class="titulo">Totales</p>
            <p>Ausencias: <%= reporte.getAusencias() %></p>
            <p>Tardanzas: <%= reporte.getTardanzas() %></p>
            <p>Tiempo total de tardanzas: <%= reporte.getTiempoTardanzaTexto() %></p>
        </div>
    </div>
    <% } %>

    <script>
        (function ()
        {
            var lista = document.getElementById('irEmpleado');

            if (!lista)
            {
                return;
            }
            lista.addEventListener('change', function ()
            {
                var hoja = lista.value ? document.getElementById(lista.value) : null;

                if (hoja)
                {
                    hoja.scrollIntoView({behavior: 'smooth', block: 'start'});
                }
                lista.value = '';
            });
        })();
    </script>
</body>
</html>