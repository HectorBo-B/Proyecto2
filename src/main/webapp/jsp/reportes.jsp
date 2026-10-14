<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Consulta individual - Asistencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/includes/sidebar.jsp" />

        <main class="main">
            <div class="page-header">
                <div>
                    <h1>Consulta individual</h1>
                    <p>Historial de asistencia por empleado</p>
                </div>
                <button type="button" class="btn btn-secondary">
                    <i class="fa-solid fa-print"></i> Imprimir
                </button>
            </div>

            <div class="card">
                <form action="#" method="get" class="toolbar">
                    <div class="field">
                        <label for="empleado">Empleado</label>
                        <select id="empleado" name="empleado" class="input">
                            <option value="">Seleccione un empleado</option>
                        </select>
                    </div>
                    <div class="field">
                        <label for="desde">Desde</label>
                        <input type="date" id="desde" name="desde" class="input">
                    </div>
                    <div class="field">
                        <label for="hasta">Hasta</label>
                        <input type="date" id="hasta" name="hasta" class="input">
                    </div>
                    <button type="submit" class="btn btn-primary">
                        <i class="fa-solid fa-magnifying-glass"></i> Consultar
                    </button>
                </form>
            </div>

            <div class="card">
                <div class="employee">
                    <div class="avatar">NE</div>
                    <div>
                        <h3>Nombre del empleado</h3>
                        <p>Código 0000 · Departamento · Cargo</p>
                    </div>
                </div>

                <div class="summary">
                    <div class="summary-item">
                        <span>Días asistidos</span>
                        <strong>0</strong>
                    </div>
                    <div class="summary-item">
                        <span>Tardanzas</span>
                        <strong>0</strong>
                    </div>
                    <div class="summary-item">
                        <span>Ausencias</span>
                        <strong>0</strong>
                    </div>
                    <div class="summary-item">
                        <span>Horas trabajadas</span>
                        <strong>0:00</strong>
                    </div>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Fecha</th>
                                <th>Entrada</th>
                                <th>Salida</th>
                                <th>Horas</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>00/00/0000</td>
                                <td>00:00</td>
                                <td>00:00</td>
                                <td>0:00</td>
                                <td><span class="badge badge-ok">Puntual</span></td>
                            </tr>
                            <tr>
                                <td>00/00/0000</td>
                                <td>00:00</td>
                                <td>00:00</td>
                                <td>0:00</td>
                                <td><span class="badge badge-warn">Tardanza</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
