<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
                        <p>Administre usuarios, permisos por rol y revise la actividad de acceso</p>
                    </div>
                </div>

                <div class="tabs">
                    <button type="button" class="active" data-grupo="seg" data-panel="panelUsuarios">Usuarios</button>
                    <button type="button" data-grupo="seg" data-panel="panelPermisos">Permisos</button>
                    <button type="button" data-grupo="seg" data-panel="panelAuditoria">Auditoría</button>
                    <button type="button" data-grupo="seg" data-panel="panelIntentos">Intentos de login</button>
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
                            <span class="counter" data-contador="tblUsuarios">3 resultado(s)</span>
                        </div>

                        <div class="table-wrap">
                            <table class="table" id="tblUsuarios"
                                   data-crud="dlgUsuario" data-titulo-editar="Modificar usuario" data-etiqueta="usuario"
                                   data-auto-id="idusuario" data-auto-fecha="creacion" data-iniciales="intentos=0;bloqueo=-"
                                   data-badge-rol="ADMIN|badge-info|Administrador;OPERADOR|badge-info|Operador"
                                   data-badge-estado="1|badge-ok|Activo;0|badge-off|Inactivo">
                                <thead>
                                    <tr>
                                        <th>Usuario</th>
                                        <th>Nombre</th>
                                        <th>Correo</th>
                                        <th>Rol</th>
                                        <th>Estado</th>
                                        <th>Intentos fallidos</th>
                                        <th>Bloqueado hasta</th>
                                        <th class="actions">Acciones</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr data-idusuario="1" data-nombre="Administrador" data-apellido="Sistema" data-usuario="admin" data-correo="admin@asistencia.local" data-rol="ADMIN" data-estado="1" data-creacion="01/10/2026 08:00" data-intentos="0" data-bloqueo="-">
                                        <td data-col="usuario"><strong>admin</strong></td>
                                        <td data-col="nombre apellido">Administrador Sistema</td>
                                        <td data-col="correo">admin@asistencia.local</td>
                                        <td data-col="rol"><span class="badge badge-info">Administrador</span></td>
                                        <td data-col="estado"><span class="badge badge-ok">Activo</span></td>
                                        <td data-col="intentos">0</td>
                                        <td data-col="bloqueo">-</td>
                                        <td class="actions">
                                            <button type="button" class="btn-icon" data-accion="editar" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                            <button type="button" class="btn-icon danger" data-accion="estado" title="Desactivar"><i class="fa-solid fa-user-slash"></i></button>
                                            <button type="button" class="btn-icon danger" data-accion="eliminar" title="Eliminar"><i class="fa-solid fa-trash-can"></i></button>
                                        </td>
                                    </tr>
                                    <tr data-idusuario="2" data-nombre="Carlos" data-apellido="Mendoza" data-usuario="operador1" data-correo="c.mendoza@asistencia.local" data-rol="OPERADOR" data-estado="1" data-creacion="02/10/2026 09:10" data-intentos="1" data-bloqueo="-">
                                        <td data-col="usuario"><strong>operador1</strong></td>
                                        <td data-col="nombre apellido">Carlos Mendoza</td>
                                        <td data-col="correo">c.mendoza@asistencia.local</td>
                                        <td data-col="rol"><span class="badge badge-info">Operador</span></td>
                                        <td data-col="estado"><span class="badge badge-ok">Activo</span></td>
                                        <td data-col="intentos">1</td>
                                        <td data-col="bloqueo">-</td>
                                        <td class="actions">
                                            <button type="button" class="btn-icon" data-accion="editar" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                            <button type="button" class="btn-icon danger" data-accion="estado" title="Desactivar"><i class="fa-solid fa-user-slash"></i></button>
                                            <button type="button" class="btn-icon danger" data-accion="eliminar" title="Eliminar"><i class="fa-solid fa-trash-can"></i></button>
                                        </td>
                                    </tr>
                                    <tr data-idusuario="3" data-nombre="Pedro" data-apellido="Núñez" data-usuario="operador2" data-correo="p.nunez@asistencia.local" data-rol="OPERADOR" data-estado="0" data-creacion="05/10/2026 11:40" data-intentos="5" data-bloqueo="16/10/2026 14:30">
                                        <td data-col="usuario"><strong>operador2</strong></td>
                                        <td data-col="nombre apellido">Pedro Núñez</td>
                                        <td data-col="correo">p.nunez@asistencia.local</td>
                                        <td data-col="rol"><span class="badge badge-info">Operador</span></td>
                                        <td data-col="estado"><span class="badge badge-off">Inactivo</span></td>
                                        <td data-col="intentos">5</td>
                                        <td data-col="bloqueo">16/10/2026 14:30</td>
                                        <td class="actions">
                                            <button type="button" class="btn-icon" data-accion="editar" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                            <button type="button" class="btn-icon" data-accion="estado" title="Activar"><i class="fa-solid fa-user-check"></i></button>
                                            <button type="button" class="btn-icon danger" data-accion="eliminar" title="Eliminar"><i class="fa-solid fa-trash-can"></i></button>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <section id="panelPermisos" data-grupo="seg" hidden>
                    <form action="#" method="post" data-demo>
                        <input type="hidden" id="rolPermisos" name="rol" value="ADMIN">
                        <div class="card">
                            <div class="card-head">
                                <h3>Permisos por rol</h3>
                                <div class="tabs tabs-flush">
                                    <button type="button" class="active" data-permisos-rol="ADMIN">Administrador</button>
                                    <button type="button" data-permisos-rol="OPERADOR">Operador</button>
                                </div>
                            </div>

                            <div class="table-wrap">
                                <table class="table" id="tblPermisos"
                                       data-concedidos-admin="DASHBOARD:VER,DASHBOARD:CREAR,DASHBOARD:EDITAR,DASHBOARD:ELIMINAR,PERSONAL:VER,PERSONAL:CREAR,PERSONAL:EDITAR,PERSONAL:ELIMINAR,IMPORTAR:VER,IMPORTAR:CREAR,IMPORTAR:EDITAR,IMPORTAR:ELIMINAR,CONSULTA:VER,CONSULTA:CREAR,CONSULTA:EDITAR,CONSULTA:ELIMINAR,USUARIOS:VER,USUARIOS:CREAR,USUARIOS:EDITAR,USUARIOS:ELIMINAR"
                                       data-concedidos-operador="DASHBOARD:VER,PERSONAL:VER,PERSONAL:CREAR,PERSONAL:EDITAR,IMPORTAR:VER,IMPORTAR:CREAR,CONSULTA:VER">
                                    <thead>
                                        <tr>
                                            <th>Módulo</th>
                                            <th class="check">Ver</th>
                                            <th class="check">Crear</th>
                                            <th class="check">Editar</th>
                                            <th class="check">Eliminar</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td><strong>Dashboard</strong></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="DASHBOARD:VER"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="DASHBOARD:CREAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="DASHBOARD:EDITAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="DASHBOARD:ELIMINAR"></td>
                                        </tr>
                                        <tr>
                                            <td><strong>Personal</strong></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="PERSONAL:VER"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="PERSONAL:CREAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="PERSONAL:EDITAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="PERSONAL:ELIMINAR"></td>
                                        </tr>
                                        <tr>
                                            <td><strong>Importar</strong></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="IMPORTAR:VER"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="IMPORTAR:CREAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="IMPORTAR:EDITAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="IMPORTAR:ELIMINAR"></td>
                                        </tr>
                                        <tr>
                                            <td><strong>Consulta individual</strong></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="CONSULTA:VER"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="CONSULTA:CREAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="CONSULTA:EDITAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="CONSULTA:ELIMINAR"></td>
                                        </tr>
                                        <tr>
                                            <td><strong>Usuarios y acceso</strong></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="USUARIOS:VER"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="USUARIOS:CREAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="USUARIOS:EDITAR"></td>
                                            <td class="check"><input type="checkbox" name="permiso" value="USUARIOS:ELIMINAR"></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>

                            <div class="form-actions">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa-solid fa-floppy-disk"></i> Guardar permisos
                                </button>
                            </div>
                        </div>
                    </form>
                </section>

                <section id="panelAuditoria" data-grupo="seg" hidden>
                    <div class="card">
                        <div class="card-head">
                            <h3>Auditoría de acceso</h3>
                            <span class="counter" data-contador="tblAuditoria">3 resultado(s)</span>
                        </div>

                        <div class="toolbar">
                            <div class="field">
                                <label for="buscarAuditoria">Buscar</label>
                                <input type="text" id="buscarAuditoria" class="input" placeholder="Usuario o descripción..." data-buscar="tblAuditoria">
                            </div>
                            <div class="tabs tabs-flush">
                                <button type="button" class="active" data-filtro-de="tblAuditoria" data-campo="accion" data-filtro="">Todas</button>
                                <button type="button" data-filtro-de="tblAuditoria" data-campo="accion" data-filtro="LOGIN">Login</button>
                                <button type="button" data-filtro-de="tblAuditoria" data-campo="accion" data-filtro="LOGOUT">Logout</button>
                                <button type="button" data-filtro-de="tblAuditoria" data-campo="accion" data-filtro="IMPORTACION">Importación</button>
                                <button type="button" data-filtro-de="tblAuditoria" data-campo="accion" data-filtro="CRUD">CRUD</button>
                            </div>
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
                                    <tr data-accion="LOGIN">
                                        <td>16/10/2026 08:01</td>
                                        <td><strong>admin</strong></td>
                                        <td><span class="badge badge-ok">LOGIN</span></td>
                                        <td>Inicio de sesión</td>
                                    </tr>
                                    <tr data-accion="IMPORTACION">
                                        <td>16/10/2026 08:15</td>
                                        <td><strong>admin</strong></td>
                                        <td><span class="badge badge-info">IMPORTACION</span></td>
                                        <td>Importación de marcaciones desde archivo .xlsx</td>
                                    </tr>
                                    <tr data-accion="CRUD">
                                        <td>16/10/2026 09:02</td>
                                        <td><strong>operador1</strong></td>
                                        <td><span class="badge badge-warn">CRUD</span></td>
                                        <td>Registró personal con código de marcación 30</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>

                <section id="panelIntentos" data-grupo="seg" hidden>
                    <div class="card">
                        <div class="card-head">
                            <h3>Intentos de inicio de sesión</h3>
                            <span class="counter" data-contador="tblIntentos">3 resultado(s)</span>
                        </div>

                        <div class="toolbar">
                            <div class="field">
                                <label for="buscarIntento">Buscar</label>
                                <input type="text" id="buscarIntento" class="input" placeholder="Usuario o IP de origen..." data-buscar="tblIntentos">
                            </div>
                            <div class="tabs tabs-flush">
                                <button type="button" class="active" data-filtro-de="tblIntentos" data-campo="exitoso" data-filtro="">Todos</button>
                                <button type="button" data-filtro-de="tblIntentos" data-campo="exitoso" data-filtro="1">Exitosos</button>
                                <button type="button" data-filtro-de="tblIntentos" data-campo="exitoso" data-filtro="0">Fallidos</button>
                            </div>
                        </div>

                        <div class="table-wrap">
                            <table class="table" id="tblIntentos">
                                <thead>
                                    <tr>
                                        <th>Fecha del intento</th>
                                        <th>Usuario</th>
                                        <th>IP de origen</th>
                                        <th>Resultado</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr data-exitoso="1">
                                        <td>16/10/2026 08:01</td>
                                        <td><strong>admin</strong></td>
                                        <td>192.168.1.10</td>
                                        <td><span class="badge badge-ok">Exitoso</span></td>
                                    </tr>
                                    <tr data-exitoso="0">
                                        <td>16/10/2026 13:52</td>
                                        <td><strong>operador2</strong></td>
                                        <td>192.168.1.24</td>
                                        <td><span class="badge badge-bad">Fallido</span></td>
                                    </tr>
                                    <tr data-exitoso="0">
                                        <td>16/10/2026 13:58</td>
                                        <td><strong>operador2</strong></td>
                                        <td>192.168.1.24</td>
                                        <td><span class="badge badge-bad">Fallido</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </section>
            </main>
        </div>
    </div>

    <dialog id="dlgUsuario">
        <form action="#" method="post" autocomplete="off" data-demo>
            <div class="modal-head">
                <h3 data-titulo-dialogo>Nuevo usuario</h3>
                <button type="button" class="modal-close" data-cerrar aria-label="Cerrar">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>

            <div class="modal-body">
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
                        <input type="text" id="usuario" name="usuario" class="input" maxlength="50" data-unico required>
                    </div>
                    <div class="field">
                        <label class="required" for="correo">Correo</label>
                        <input type="email" id="correo" name="correo" class="input" maxlength="100" data-unico required>
                    </div>
                    <div class="field full">
                        <label for="clave">Contraseña</label>
                        <div class="password-wrap">
                            <input type="password" id="clave" name="password" class="input" maxlength="255" data-requerido-creacion required>
                            <button type="button" class="toggle-pass" data-ver-clave aria-label="Mostrar contraseña">
                                <i class="fa-solid fa-eye"></i>
                            </button>
                        </div>
                        <span class="hint" data-solo-edicion hidden>Déjela vacía para conservar la contraseña actual.</span>
                    </div>
                    <div class="field">
                        <label class="required" for="rol">Rol</label>
                        <select id="rol" name="rol" class="input" required>
                            <option value="OPERADOR">Operador</option>
                            <option value="ADMIN">Administrador</option>
                        </select>
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
                        <div><span class="k">Intentos fallidos:</span> <span data-txt="intentos">-</span></div>
                        <div><span class="k">Bloqueado hasta:</span> <span data-txt="bloqueo">-</span></div>
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