<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Asistencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <script src="${pageContext.request.contextPath}/js/funciones.js" defer></script>
</head>
<body class="login-body">
    <section class="login-aside">
        <div class="login-brand">
            <span><i class="fa-solid fa-clipboard-user"></i></span>
            Asistencia
        </div>

        <div>
            <h2>Control de asistencia simple y ordenado</h2>
            <p>Administre el personal, importe marcaciones y consulte el historial de cada empleado en un solo lugar.</p>
        </div>

        <small>Sistema de control de personal</small>
    </section>

    <section class="login-main">
        <div class="login-card">
            <h1>Bienvenido</h1>
            <p>Ingrese sus credenciales para continuar</p>

            <div class="alert alert-error" role="alert" ${empty error ? 'hidden' : ''}>
                <i class="fa-solid fa-circle-exclamation"></i>
                <span>${error}</span>
            </div>

            <form action="${pageContext.request.contextPath}/jsp/dashboard.jsp" method="post" autocomplete="off">
                <div class="field">
                    <label for="usuario">Usuario</label>
                    <input type="text" id="usuario" name="usuario" class="input" placeholder="Ingrese su usuario" maxlength="50" required autofocus>
                </div>
                <div class="field">
                    <label for="password">Contraseña</label>
                    <div class="password-wrap">
                        <input type="password" id="password" name="password" class="input" placeholder="Ingrese su contraseña" maxlength="255" required>
                        <button type="button" class="toggle-pass" data-ver-clave aria-label="Mostrar contraseña">
                            <i class="fa-solid fa-eye"></i>
                        </button>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary btn-block">Ingresar</button>
            </form>
        </div>
    </section>
</body>
</html>