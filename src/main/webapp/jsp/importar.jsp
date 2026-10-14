<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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

        <main class="main">
            <div class="page-header">
                <div>
                    <h1>Importar</h1>
                    <p>Carga de marcaciones desde un archivo</p>
                </div>
            </div>

            <div class="card">
                <h3>Seleccionar archivo</h3>
                <form action="#" method="post" enctype="multipart/form-data">
                    <label class="dropzone" for="archivo">
                        <i class="fa-solid fa-cloud-arrow-up"></i>
                        <strong>Haga clic para seleccionar un archivo</strong>
                        <span id="nombreArchivo">Formatos permitidos: .xls, .xlsx, .csv</span>
                        <input type="file" id="archivo" name="archivo" accept=".xls,.xlsx,.csv">
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

            <div class="card">
                <h3>Vista previa</h3>
                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Fecha</th>
                                <th>Hora</th>
                                <th>Tipo</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td colspan="4" class="table-empty">Aún no se ha cargado ningún archivo</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</body>
</html>
