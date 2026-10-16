<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Personal - Asistencia</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    
    <style>
    .modal{
    display: none;
	position: fixed; /* Stay in place */
	z-index: 1;  /*Sit on top*/ 
	left: 40%;
	top: 30%;
	width: 30%;
	overflow: auto; 
	background-color: rgba(240,240,240,1); /* Black w/ opacity */
	border: solid 1px grey;
    }
    
    .modal-content{
    padding: 4px;
    }
    
    
    </style>
    
</head>
<body>
    <div class="app">
        <jsp:include page="/includes/sidebar.jsp" />

        <main class="main">
            <div class="page-header">
                <div>
                    <h1>Personal</h1>
                    <p>Listado de empleados registrados</p>
                </div>
                
                <!-- Botón para añadir un empleado (Abre un modal) -->
                <button id = "btnEmp" type="button" class="btn btn-primary" data-bs-dismiss="modal">
                    <i class="fa-solid fa-plus"></i> Nuevo empleado
                </button>
                
                <!-- Modal de crear empleado -->
                <div id = "modNewEmp" class = "modal">
                
                	<div class = "modal-content">
	                	<span class ="close">&times;</span>
	                	<form>
	                	
	                	<input type ="text" placeholder="ID">
	                	<input type ="text" placeholder="Martín">
	                	<input type ="text" placeholder="Alexis">
	                	<input type ="text" placeholder="8-4512-533">
	                	
	                	</form>
                	</div>
                </div>
                <!-- Fin del modal -->
                
            </div>

            <div class="card">
                <div class="toolbar">
                    <div class="field">
                        <label for="buscar">Buscar</label>
                        <input type="text" id="buscar" class="input" placeholder="Nombre o código...">
                    </div>
                    <div class="field">
                        <label for="departamento">Departamento</label>
                        <select id="departamento" class="input">
                            <option value="">Todos</option>
                        </select>
                    </div>
                    <button type="button" class="btn btn-secondary">
                        <i class="fa-solid fa-rotate"></i> Limpiar
                    </button>
                </div>

                <div class="table-wrap">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Código</th>
                                <th>Nombre</th>
                                <th>Departamento</th>
                                <th>Cargo</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>0001</td>
                                <td>Nombre del empleado</td>
                                <td>Departamento</td>
                                <td>Cargo</td>
                                <td><span class="badge badge-ok">Activo</span></td>
                                <td>
                                    <button type="button" class="btn-icon" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                    <button type="button" class="btn-icon" title="Desactivar"><i class="fa-solid fa-trash-can"></i></button>
                                </td>
                            </tr>
                            <tr>
                                <td>0002</td>
                                <td>Nombre del empleado</td>
                                <td>Departamento</td>
                                <td>Cargo</td>
                                <td><span class="badge badge-off">Inactivo</span></td>
                                <td>
                                    <button type="button" class="btn-icon" title="Editar"><i class="fa-solid fa-pen"></i></button>
                                    <button type="button" class="btn-icon" title="Activar"><i class="fa-solid fa-trash-can"></i></button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
    
    <script>
    
    var modal = document.getElementById("modNewEmp");
	var btn = document.getElementById("btnEmp");
	var span = document.getElementsByClassName("close")[0];
	
	btn.onclick = function(){
		modal.style.display = "block";
	}
	
	span.onclick = function() {
		  modal.style.display = "none";
		}
    
	window.onclick = function(){
		  if (event.target == modal) {
			    modal.style.display = "none";
			  }
	}
    //Abre un modal para "crear" empleados
    function abrirModal(){
    	
        //Elementos para el modal de crear empleados
        
    }
    </script>
    
</body>
</html>
