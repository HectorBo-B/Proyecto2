<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" import="java.util.List, model.marcacion, model.resultadoImportacion" %>
<%
    @SuppressWarnings("unchecked")
    List<marcacion> lista = (List<marcacion>) request.getAttribute("listaMarcaciones");

    //en la vista de correctos se ocultan las columnas Estado y Detalle
    boolean mostrarEstado = request.getAttribute("ocultarEstado") == null;
    request.removeAttribute("ocultarEstado");
%>
<div class="table-wrap">
    <table class="table">
        <thead>
            <tr>
                <th>Línea</th>
                <th>Registro</th>
                <th>Empleado</th>
                <th>Turno</th>
                <% if (mostrarEstado) { %>
                <th>Estado</th>
                <th>Detalle</th>
                <% } %>
            </tr>
        </thead>
        <tbody>
            <% if (lista == null || lista.isEmpty()) { %>
            <tr>
                <td colspan="<%= mostrarEstado ? 6 : 4 %>" class="table-empty">No hay registros</td>
            </tr>
            <% } else { for (marcacion m : lista) {
                   String clase = "badge-ok";
                   String texto = "Correcto";
                   if (marcacion.DUPLICADO.equals(m.getEstado())) { clase = "badge-warn"; texto = "Duplicado"; }
                   else if (marcacion.RECHAZADO.equals(m.getEstado())) { clase = "badge-off"; texto = "Rechazado"; }
                   else if (marcacion.ERROR.equals(m.getEstado())) { clase = "badge-bad"; texto = "Error"; }
            %>
            <tr>
                <td><%= m.getNumeroLinea() %></td>
                <td><%= resultadoImportacion.escapar(m.getRegistroResumen()) %></td>
                <td><%= m.getEmpleado() == null ? "-" : resultadoImportacion.escapar(m.getEmpleado()) %></td>
                <td><%= resultadoImportacion.escapar(m.getTurnoNombre()) %></td>
                <% if (mostrarEstado) { %>
                <td><span class="badge <%= clase %>"><%= texto %></span></td>
                <td><%= m.getMotivo() == null || m.getMotivo().isEmpty() ? "-" : resultadoImportacion.escapar(m.getMotivo()) %></td>
                <% } %>
            </tr>
            <% } } %>
        </tbody>
    </table>
</div>