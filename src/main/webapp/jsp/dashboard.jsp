<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Asistencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
</head>
<body>
    <div class="app">
        <jsp:include page="/includes/sidebar.jsp" />

        <main class="main">
            <div class="page-header">
                <div>
                    <h1>Dashboard</h1>
                    <p>Resumen general de asistencia</p>
                </div>
            </div>

            <div class="stats">
                <div class="stat">
                    <div class="stat-icon teal"><i class="fa-solid fa-users"></i></div>
                    <div>
                        <span class="stat-label">Total de personal</span>
                        <span class="stat-value">0</span>
                        <span class="stat-sub">registrados</span>
                    </div>
                </div>
                <div class="stat">
                    <div class="stat-icon green"><i class="fa-solid fa-user-check"></i></div>
                    <div>
                        <span class="stat-label">Presentes hoy</span>
                        <span class="stat-value">0</span>
                        <span class="stat-sub">asistencias</span>
                    </div>
                </div>
                <div class="stat">
                    <div class="stat-icon amber"><i class="fa-solid fa-clock"></i></div>
                    <div>
                        <span class="stat-label">Tardanzas</span>
                        <span class="stat-value">0</span>
                        <span class="stat-sub">este mes</span>
                    </div>
                </div>
                <div class="stat">
                    <div class="stat-icon red"><i class="fa-solid fa-user-xmark"></i></div>
                    <div>
                        <span class="stat-label">Ausencias</span>
                        <span class="stat-value">0</span>
                        <span class="stat-sub">este mes</span>
                    </div>
                </div>
            </div>

            <div class="card">
                <h3>Últimos registros</h3>
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Empleado</th>
                                <th>Fecha</th>
                                <th>Entrada</th>
                                <th>Salida</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>Nombre del empleado</td>
                                <td>00/00/0000</td>
                                <td>00:00</td>
                                <td>00:00</td>
                                <td><span class="badge badge-ok">Puntual</span></td>
                            </tr>
                            <tr>
                                <td>Nombre del empleado</td>
                                <td>00/00/0000</td>
                                <td>00:00</td>
                                <td>00:00</td>
                                <td><span class="badge badge-warn">Tardanza</span></td>
                            </tr>
                            <tr>
                                <td>Nombre del empleado</td>
                                <td>00/00/0000</td>
                                <td>-</td>
                                <td>-</td>
                                <td><span class="badge badge-bad">Ausente</span></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
