(function ()
{
    'use strict';

    var EXTENSIONES_PERMITIDAS = ['dat', 'txt'];
    var CLAVE_MENU = 'asistencia-menu-oculto';
    var TEXTO_ARCHIVO_VACIO = 'Formatos permitidos: .dat, .txt';
    var SUFIJO_DEMO = ' (vista de demostración).';
    var consultaMovil = window.matchMedia('(max-width: 960px)');
    var permisosPorRol = {};
    var rolActual = '';

    function leerPreferenciaMenu()
    {
        try
        {
            return window.localStorage.getItem(CLAVE_MENU) === '1';
        }
        catch (error)
        {
            return false;
        }
    }

    function guardarPreferenciaMenu(oculto)
    {
        try
        {
            window.localStorage.setItem(CLAVE_MENU, oculto ? '1' : '0');
        }
        catch (error)
        {
            return;
        }
    }

    function mostrarNotificacion(mensaje)
    {
        var notificacion = document.createElement('div');
        notificacion.className = 'toast';
        notificacion.setAttribute('role', 'status');
        notificacion.textContent = mensaje;
        document.body.appendChild(notificacion);
        window.setTimeout(function ()
        {
            notificacion.classList.add('visible');
        }, 20);
        window.setTimeout(function ()
        {
            notificacion.classList.remove('visible');
            window.setTimeout(function ()
            {
                notificacion.remove();
            }, 300);
        }, 2800);
    }

    function cerrarMenu()
    {
        var lateral = document.getElementById('sidebar');
        if (lateral)
        {
            lateral.classList.remove('abierto');
        }
        document.body.classList.remove('menu-abierto');
    }

    function aplicarPreferenciaMenu()
    {
        if (consultaMovil.matches)
        {
            document.body.classList.remove('menu-oculto');
            cerrarMenu();
            return;
        }
        document.body.classList.toggle('menu-oculto', leerPreferenciaMenu());
    }

    function dosDigitos(numero)
    {
        return String(numero).padStart(2, '0');
    }

    function ahoraFormateado()
    {
        var ahora = new Date();
        return dosDigitos(ahora.getDate()) + '/' + dosDigitos(ahora.getMonth() + 1) + '/' + ahora.getFullYear() + ' ' + dosDigitos(ahora.getHours()) + ':' + dosDigitos(ahora.getMinutes());
    }

    function formatearFecha(valor)
    {
        var partes = /^(\d{4})-(\d{2})-(\d{2})$/.exec(valor);
        return partes ? partes[3] + '/' + partes[2] + '/' + partes[1] : valor;
    }

    function claveCampo(campo)
    {
        return campo.name.toLowerCase();
    }

    function filasDe(tabla)
    {
        return Array.prototype.slice.call(tabla.querySelectorAll('tbody tr:not(.fila-vacia)'));
    }

    function leerMapa(tabla, atributo)
    {
        var mapa = {};
        var definicion = tabla.getAttribute(atributo);
        if (!definicion)
        {
            return null;
        }
        definicion.split(';').forEach(function (par)
        {
            var partes = par.split('|');
            mapa[partes[0]] = partes.slice(1);
        });
        return mapa;
    }

    function etiquetaFila(tabla, fila)
    {
        var claves = (tabla.getAttribute('data-etiqueta') || '').split(' ');
        return claves.map(function (clave)
        {
            return fila.dataset[clave] || '';
        }).join(' ').trim();
    }

    function renderizarFila(tabla, fila, claves)
    {
        fila.querySelectorAll('td[data-col]').forEach(function (celda)
        {
            var columnas = celda.getAttribute('data-col').split(' ');
            var afectada = !claves || columnas.some(function (columna)
            {
                return claves.indexOf(columna) !== -1;
            });
            if (!afectada)
            {
                return;
            }

            var insignias = columnas.length === 1 ? leerMapa(tabla, 'data-badge-' + columnas[0]) : null;
            var valor = fila.dataset[columnas[0]] || '';
            if (insignias && insignias[valor])
            {
                var etiqueta = document.createElement('span');
                etiqueta.className = 'badge ' + insignias[valor][0];
                etiqueta.textContent = insignias[valor][1];
                celda.textContent = '';
                celda.appendChild(etiqueta);
                return;
            }

            var textos = columnas.map(function (columna)
            {
                var mapa = leerMapa(tabla, 'data-mapa-' + columna);
                var crudo = fila.dataset[columna] || '';
                return mapa && mapa[crudo] ? mapa[crudo][0] : formatearFecha(crudo);
            });
            (celda.querySelector('strong') || celda).textContent = textos.join(' ');
        });
    }

    function actualizarBotonEstado(fila)
    {
        var boton = fila.querySelector('[data-accion="estado"]');
        if (!boton)
        {
            return;
        }
        var activo = fila.dataset.estado === '1';
        var icono = boton.querySelector('i');
        boton.title = activo ? 'Desactivar' : 'Activar';
        boton.classList.toggle('danger', activo);
        if (icono)
        {
            icono.classList.toggle('fa-user-slash', activo);
            icono.classList.toggle('fa-user-check', !activo);
        }
    }

    function asignarValoresAutomaticos(tabla, fila, filas)
    {
        var campoId = tabla.getAttribute('data-auto-id');
        var campoFecha = tabla.getAttribute('data-auto-fecha');
        var iniciales = tabla.getAttribute('data-iniciales');
        var mayor = 0;

        if (campoId)
        {
            filas.forEach(function (otra)
            {
                mayor = Math.max(mayor, parseInt(otra.dataset[campoId], 10) || 0);
            });
            fila.dataset[campoId] = String(mayor + 1);
        }
        if (campoFecha)
        {
            fila.dataset[campoFecha] = ahoraFormateado();
        }
        if (iniciales)
        {
            iniciales.split(';').forEach(function (par)
            {
                var partes = par.split('=');
                fila.dataset[partes[0]] = partes[1];
            });
        }
    }

    function abrirDialogo(dialogo, fila, titulo)
    {
        var formulario = dialogo.querySelector('form');
        var encabezado = dialogo.querySelector('[data-titulo-dialogo]');
        var editando = fila !== null;

        dialogo.filaEdicion = fila;

        if (formulario)
        {
            formulario.reset();
            Array.prototype.forEach.call(formulario.elements, function (campo)
            {
                if (!campo.name)
                {
                    return;
                }
                campo.classList.remove('invalid');
                if (campo.type === 'hidden')
                {
                    if (campo.getAttribute('data-valor-inicial') === null)
                    {
                        campo.setAttribute('data-valor-inicial', campo.defaultValue);
                    }
                    campo.value = campo.getAttribute('data-valor-inicial');
                }
                if (editando && campo.type !== 'password' && fila.dataset[claveCampo(campo)] !== undefined)
                {
                    campo.value = fila.dataset[claveCampo(campo)];
                }
                if (campo.hasAttribute('data-bloquear-edicion'))
                {
                    campo.disabled = editando;
                }
            });
        }

        dialogo.querySelectorAll('[data-txt]').forEach(function (elemento)
        {
            elemento.textContent = editando ? (fila.dataset[elemento.getAttribute('data-txt')] || '-') : '-';
        });
        dialogo.querySelectorAll('[data-solo-edicion]').forEach(function (elemento)
        {
            elemento.hidden = !editando;
        });
        dialogo.querySelectorAll('[data-solo-creacion]').forEach(function (elemento)
        {
            elemento.hidden = editando;
        });
        dialogo.querySelectorAll('[data-requerido-creacion]').forEach(function (elemento)
        {
            elemento.required = !editando;
        });

        if (dialogo.id === 'dlgPersonal' && formulario)
        {
            formulario.querySelector('#accion').value = editando ? 'editar' : 'crear';
            cargarCodigos(dialogo, fila, formulario.querySelector('#turno').value);
        }

        if (titulo && encabezado)
        {
            encabezado.textContent = titulo;
        }
        if (typeof dialogo.showModal === 'function')
        {
            dialogo.showModal();
        }
    }

    function leerCodigos()
    {
        return Array.prototype.map.call(document.querySelectorAll('#datosCodigos span'), function (marca)
        {
            return {
                codigo: parseInt(marca.getAttribute('data-codigo'), 10),
                turno: marca.getAttribute('data-turno'),
                dueno: parseInt(marca.getAttribute('data-dueno'), 10) || 0
            };
        });
    }

    function cargarCodigos(dialogo, fila, turno)
    {
        var selector = dialogo.querySelector('#codMarc');
        var idEmpleado = fila ? parseInt(fila.dataset.idemp, 10) : 0;
        var disponibles = [];

        selector.innerHTML = '';
        selector.required = false;

        if (!turno)
        {
            selector.appendChild(new Option('Seleccione un turno', ''));
            selector.disabled = true;
            return;
        }

        leerCodigos().forEach(function (codigo)
        {
            if (codigo.turno === turno && (codigo.dueno === 0 || codigo.dueno === idEmpleado))
            {
                disponibles.push(codigo.codigo);
            }
        });
        disponibles.sort(function (a, b) { return a - b; });

        if (disponibles.length === 0)
        {
            selector.appendChild(new Option('No hay códigos disponibles en este turno', ''));
            selector.disabled = true;
            return;
        }

        selector.appendChild(new Option('Seleccione un código', ''));
        disponibles.forEach(function (numero)
        {
            selector.appendChild(new Option(String(numero), String(numero)));
        });
        selector.disabled = false;
        selector.required = true;

        if (fila && disponibles.indexOf(parseInt(fila.dataset.codmarc, 10)) !== -1)
        {
            selector.value = fila.dataset.codmarc;
        }
    }

	//Envía una acción (estado, eliminar) al servidor sin abrir ningún formulario
	function enviarAccion(url, accion, id)
	{
	    var formulario = document.createElement('form');

	    formulario.method = 'post';
	    formulario.action = url;
	    [['accion', accion], ['idEMP', id]].forEach(function (par)
	    {
	        var campo = document.createElement('input');
	        campo.type = 'hidden';
	        campo.name = par[0];
	        campo.value = par[1];
	        formulario.appendChild(campo);
	    });
	    document.body.appendChild(formulario);
	    formulario.submit();
	}

    function guardarFila(tabla, dialogo, formulario)
    {
        var fila = dialogo.filaEdicion;
        var filas = filasDe(tabla);
        var claves = [];
        var repetido = null;
        var nueva = fila === null;
        var campos = Array.prototype.filter.call(formulario.elements, function (campo)
        {
            return campo.name && campo.type !== 'password' && campo.type !== 'submit' && campo.type !== 'button';
        });

        campos.forEach(function (campo)
        {
            var valor = campo.value.trim().toLowerCase();
            if (repetido || campo.disabled || !campo.hasAttribute('data-unico'))
            {
                return;
            }
            filas.forEach(function (otra)
            {
                if (otra !== fila && (otra.dataset[claveCampo(campo)] || '').toLowerCase() === valor)
                {
                    repetido = campo;
                }
            });
        });

        if (repetido)
        {
            var rotulo = formulario.querySelector('label[for="' + repetido.id + '"]');
            repetido.classList.add('invalid');
            repetido.focus();
            mostrarNotificacion('Ya existe otro registro con el mismo valor en «' + (rotulo ? rotulo.textContent.replace('*', '').trim() : repetido.name) + '».');
            return false;
        }

        if (nueva)
        {
            if (filas.length === 0)
            {
                mostrarNotificacion('La tabla necesita al menos una fila de ejemplo para crear registros.');
                return false;
            }
            fila = filas[0].cloneNode(true);
            Object.keys(fila.dataset).forEach(function (clave)
            {
                delete fila.dataset[clave];
            });
            fila.hidden = false;
        }

        campos.forEach(function (campo)
        {
            fila.dataset[claveCampo(campo)] = campo.value.trim();
            claves.push(claveCampo(campo));
        });

        if (nueva)
        {
            asignarValoresAutomaticos(tabla, fila, filas);
            tabla.tBodies[0].insertBefore(fila, tabla.querySelector('tbody .fila-vacia'));
            renderizarFila(tabla, fila, null);
            fila.classList.add('fila-nueva');
            window.setTimeout(function ()
            {
                fila.classList.remove('fila-nueva');
            }, 2200);
        }
        else
        {
            renderizarFila(tabla, fila, claves);
        }

        actualizarBotonEstado(fila);
        filtrarTabla(tabla);
        mostrarNotificacion((nueva ? 'Registro creado' : 'Registro actualizado') + SUFIJO_DEMO);
        return true;
    }

    function filtrarTabla(tabla)
    {
        var consulta = '';
        var visibles = 0;
        var cuadro = document.querySelector('[data-buscar="' + tabla.id + '"]');
        var selectores = document.querySelectorAll('select[data-filtro-select="' + tabla.id + '"]');
        var pestanas = document.querySelectorAll('[data-filtro-de="' + tabla.id + '"].active');
        var contador = document.querySelector('[data-contador="' + tabla.id + '"]');
        var filaVacia = tabla.querySelector('tbody .fila-vacia');

        if (cuadro)
        {
            consulta = cuadro.value.trim().toLowerCase();
        }

        filasDe(tabla).forEach(function (fila)
        {
            var coincide = !consulta || fila.textContent.toLowerCase().indexOf(consulta) !== -1;

            selectores.forEach(function (selector)
            {
                var valor = selector.value;
                var campo = selector.getAttribute('data-campo');
                if (coincide && valor && fila.getAttribute('data-' + campo) !== valor)
                {
                    coincide = false;
                }
            });

            pestanas.forEach(function (pestana)
            {
                var valor = pestana.getAttribute('data-filtro');
                var campo = pestana.getAttribute('data-campo') || 'estado';
                if (coincide && valor && fila.getAttribute('data-' + campo) !== valor)
                {
                    coincide = false;
                }
            });

            fila.hidden = !coincide;
            if (coincide)
            {
                visibles++;
            }
        });

        if (!filaVacia)
        {
            var celda = document.createElement('td');
            filaVacia = document.createElement('tr');
            filaVacia.className = 'fila-vacia';
            celda.className = 'table-empty';
            celda.colSpan = tabla.querySelectorAll('thead th').length;
            celda.textContent = 'No se encontraron resultados.';
            filaVacia.appendChild(celda);
            tabla.tBodies[0].appendChild(filaVacia);
        }
        filaVacia.hidden = visibles > 0;

        if (contador)
        {
            contador.textContent = visibles + ' resultado(s)';
        }
    }

    function mostrarNombreArchivo(archivo, etiqueta, zona)
    {
        if (!etiqueta)
        {
            return;
        }
        if (archivo)
        {
            etiqueta.textContent = archivo.name;
            if (zona)
            {
                zona.classList.add('has-file');
            }
            return;
        }
        etiqueta.textContent = TEXTO_ARCHIVO_VACIO;
        if (zona)
        {
            zona.classList.remove('has-file');
        }
    }

    function extensionValida(archivo)
    {
        var partes = archivo.name.toLowerCase().split('.');
        return partes.length > 1 && EXTENSIONES_PERMITIDAS.indexOf(partes[partes.length - 1]) !== -1;
    }

    function iniciarImportacion()
    {
        var entrada = document.getElementById('archivo');
        var etiqueta = document.getElementById('nombreArchivo');
        var zona = document.querySelector('.dropzone');
        var formulario = entrada ? entrada.closest('form') : null;
        if (!entrada)
        {
            return;
        }

        entrada.addEventListener('change', function ()
        {
            var archivo = entrada.files.length > 0 ? entrada.files[0] : null;
            if (archivo && !extensionValida(archivo))
            {
                entrada.value = '';
                mostrarNombreArchivo(null, etiqueta, zona);
                mostrarNotificacion('Formato no permitido. Use .dat o .txt');
                return;
            }
            if (archivo && archivo.size === 0)
            {
                entrada.value = '';
                mostrarNombreArchivo(null, etiqueta, zona);
                mostrarNotificacion('El archivo está vacío.');
                return;
            }
            mostrarNombreArchivo(archivo, etiqueta, zona);
        });

        if (zona)
        {
            ['dragenter', 'dragover'].forEach(function (nombre)
            {
                zona.addEventListener(nombre, function (evento)
                {
                    evento.preventDefault();
                    zona.classList.add('dragover');
                });
            });
            ['dragleave', 'drop'].forEach(function (nombre)
            {
                zona.addEventListener(nombre, function (evento)
                {
                    evento.preventDefault();
                    zona.classList.remove('dragover');
                });
            });
            zona.addEventListener('drop', function (evento)
            {
                if (evento.dataTransfer && evento.dataTransfer.files.length > 0)
                {
                    entrada.files = evento.dataTransfer.files;
                    entrada.dispatchEvent(new Event('change'));
                }
            });
        }

        if (formulario)
        {
            formulario.addEventListener('reset', function ()
            {
                mostrarNombreArchivo(null, etiqueta, zona);
            });
            formulario.addEventListener('submit', function (evento)
            {
                if (entrada.files.length === 0)
                {
                    evento.preventDefault();
                    mostrarNotificacion('Seleccione un archivo para importar.');
                }
                else if (entrada.files[0].size === 0)
                {
                    evento.preventDefault();
                    mostrarNotificacion('El archivo está vacío.');
                }
            });
        }
    }

    function iniciarGuardado()
    {
        var formulario = document.getElementById('frmGuardar');
        if (!formulario)
        {
            return;
        }

        formulario.addEventListener('submit', function (evento)
        {
            var validos = parseInt(formulario.getAttribute('data-validos'), 10) || 0;
            var hayIncidencias = formulario.getAttribute('data-incidencias') === '1';

            if (validos === 0)
            {
                evento.preventDefault();
                mostrarNotificacion('No hay registros válidos para guardar.');
                return;
            }

            if (hayIncidencias && !window.confirm('¿Está seguro de guardar solamente ' + validos + ' registro(s) válido(s)?'))
            {
                evento.preventDefault();
                return;
            }

            formulario.querySelector('button[type="submit"]').disabled = true;
        });
    }

    function iniciarRangoFechas()
    {
        var desde = document.getElementById('desde');
        var hasta = document.getElementById('hasta');
        var formulario = desde ? desde.closest('form') : null;
        if (!desde || !hasta)
        {
            return;
        }

        desde.addEventListener('change', function ()
        {
            hasta.min = desde.value;
        });

        if (formulario)
        {
            formulario.addEventListener('submit', function (evento)
            {
                if (desde.value && hasta.value && hasta.value < desde.value)
                {
                    evento.preventDefault();
                    mostrarNotificacion('La fecha final no puede ser anterior a la inicial.');
                }
            });
        }
    }

    function mostrarPermisos(tabla, rol)
    {
        rolActual = rol;
        tabla.querySelectorAll('input[type="checkbox"]').forEach(function (casilla)
        {
            casilla.checked = permisosPorRol[rol].indexOf(casilla.value) !== -1;
        });
        document.querySelectorAll('[data-permisos-rol]').forEach(function (boton)
        {
            boton.classList.toggle('active', boton.getAttribute('data-permisos-rol') === rol);
        });
        var campoRol = document.getElementById('rolPermisos');
        if (campoRol)
        {
            campoRol.value = rol;
        }
    }

    function iniciarPermisos()
    {
        var tabla = document.getElementById('tblPermisos');
        var botones = document.querySelectorAll('[data-permisos-rol]');
        if (!tabla || botones.length === 0)
        {
            return;
        }
        botones.forEach(function (boton)
        {
            var rol = boton.getAttribute('data-permisos-rol');
            var concedidos = tabla.getAttribute('data-concedidos-' + rol.toLowerCase()) || '';
            permisosPorRol[rol] = concedidos ? concedidos.split(',') : [];
        });
        mostrarPermisos(tabla, botones[0].getAttribute('data-permisos-rol'));
    }

    function iniciar()
    {
        aplicarPreferenciaMenu();
        if (consultaMovil.addEventListener)
        {
            consultaMovil.addEventListener('change', aplicarPreferenciaMenu);
        }
        window.requestAnimationFrame(function ()
        {
            window.requestAnimationFrame(function ()
            {
                document.body.classList.add('menu-anim');
            });
        });

        document.querySelectorAll('[data-contador]').forEach(function (contador)
        {
            var tabla = document.getElementById(contador.getAttribute('data-contador'));
            if (tabla)
            {
                filtrarTabla(tabla);
            }
        });

        iniciarImportacion();
        iniciarGuardado();
        iniciarRangoFechas();
        iniciarPermisos();
    }

    document.addEventListener('click', function (evento)
    {
        var lateral = document.getElementById('sidebar');
        if (!lateral)
        {
            return;
        }
        if (evento.target.closest('[data-menu]'))
        {
            if (consultaMovil.matches)
            {
                var abierto = lateral.classList.toggle('abierto');
                document.body.classList.toggle('menu-abierto', abierto);
            }
            else
            {
                var oculto = document.body.classList.toggle('menu-oculto');
                guardarPreferenciaMenu(oculto);
            }
            return;
        }
        if (lateral.classList.contains('abierto') && !evento.target.closest('#sidebar'))
        {
            cerrarMenu();
        }
    });

    document.addEventListener('keydown', function (evento)
    {
        if (evento.key === 'Escape')
        {
            cerrarMenu();
        }
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-abrir]');
        var dialogo = boton ? document.getElementById(boton.getAttribute('data-abrir')) : null;
        if (dialogo)
        {
            abrirDialogo(dialogo, null, boton.getAttribute('data-titulo'));
        }
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-accion]');
        var fila = boton ? boton.closest('tr') : null;
        var tabla = boton ? boton.closest('table') : null;
        var accion = boton ? boton.getAttribute('data-accion') : '';
        var etiqueta = '';
        var activo = false;
        var dialogo = null;

        if (!fila || !tabla)
        {
            return;
        }
        etiqueta = etiquetaFila(tabla, fila);

        if (accion === 'editar')
        {
            dialogo = document.getElementById(tabla.getAttribute('data-crud'));
            if (dialogo)
            {
                abrirDialogo(dialogo, fila, tabla.getAttribute('data-titulo-editar'));
            }
            return;
        }

		if (accion === 'estado')
		{
		    activo = fila.dataset.estado === '1';
		    if (!window.confirm('¿' + (activo ? 'Desactivar' : 'Activar') + ' «' + etiqueta + '»?'))
		    {
		        return;
		    }
		    if (tabla.hasAttribute('data-servidor'))
		    {
		        enviarAccion(tabla.getAttribute('data-servidor'), 'estado', fila.dataset.idemp);
		        return;
		    }
		    fila.dataset.estado = activo ? '0' : '1';
		    renderizarFila(tabla, fila, ['estado']);
		    actualizarBotonEstado(fila);
		    filtrarTabla(tabla);
		    mostrarNotificacion((activo ? 'Registro desactivado' : 'Registro activado') + SUFIJO_DEMO);
		    return;
		}

		if (accion === 'eliminar')
		{
		    if (!window.confirm('¿Eliminar «' + etiqueta + '»? Esta acción no se puede deshacer.'))
		    {
		        return;
		    }
		    if (tabla.hasAttribute('data-servidor'))
		    {
		        enviarAccion(tabla.getAttribute('data-servidor'), 'eliminar', fila.dataset.idemp);
		        return;
		    }
		    fila.remove();
		    filtrarTabla(tabla);
		    mostrarNotificacion('Registro eliminado' + SUFIJO_DEMO);
		}
    });

    document.addEventListener('change', function (evento)
    {
        var dialogo = document.getElementById('dlgPersonal');

        if (evento.target.id === 'turno' && dialogo && dialogo.contains(evento.target))
        {
            cargarCodigos(dialogo, dialogo.filaEdicion, evento.target.value);
        }
    });

    document.addEventListener('click', function (evento)
    {
        var cierre = evento.target.closest('[data-cerrar]');
        if (cierre)
        {
            cierre.closest('dialog').close();
            return;
        }
        if (evento.target.tagName === 'DIALOG')
        {
            var area = evento.target.getBoundingClientRect();
            if (evento.clientX < area.left || evento.clientX > area.right || evento.clientY < area.top || evento.clientY > area.bottom)
            {
                evento.target.close();
            }
        }
    });

    document.addEventListener('input', function (evento)
    {
        if (evento.target.matches('[data-buscar]'))
        {
            filtrarTabla(document.getElementById(evento.target.getAttribute('data-buscar')));
        }
        if (evento.target.classList.contains('invalid'))
        {
            evento.target.classList.remove('invalid');
        }
    });

    document.addEventListener('change', function (evento)
    {
        if (evento.target.matches('select[data-filtro-select]'))
        {
            filtrarTabla(document.getElementById(evento.target.getAttribute('data-filtro-select')));
        }
        if (evento.target.matches('#tblPermisos input[type="checkbox"]'))
        {
            permisosPorRol[rolActual] = Array.prototype.filter.call(evento.target.closest('table').querySelectorAll('input[type="checkbox"]'), function (casilla)
            {
                return casilla.checked;
            }).map(function (casilla)
            {
                return casilla.value;
            });
        }
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-filtro-de]');
        var tabla = boton ? boton.getAttribute('data-filtro-de') : '';
        var campo = boton ? boton.getAttribute('data-campo') : '';
        if (!boton)
        {
            return;
        }
        document.querySelectorAll('[data-filtro-de="' + tabla + '"]').forEach(function (pestana)
        {
            if (pestana.getAttribute('data-campo') === campo)
            {
                pestana.classList.remove('active');
            }
        });
        boton.classList.add('active');
        filtrarTabla(document.getElementById(tabla));
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-limpiar]');
        var tabla = boton ? boton.getAttribute('data-limpiar') : '';
        var cuadro = boton ? document.querySelector('[data-buscar="' + tabla + '"]') : null;
        if (!boton)
        {
            return;
        }
        if (cuadro)
        {
            cuadro.value = '';
        }
        document.querySelectorAll('select[data-filtro-select="' + tabla + '"]').forEach(function (selector)
        {
            selector.value = '';
        });
        document.querySelectorAll('[data-filtro-de="' + tabla + '"]').forEach(function (pestana)
        {
            pestana.classList.toggle('active', pestana.getAttribute('data-filtro') === '');
        });
        filtrarTabla(document.getElementById(tabla));
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-panel]');
        var grupo = boton ? boton.getAttribute('data-grupo') : '';
        if (!boton)
        {
            return;
        }
        document.querySelectorAll('[data-grupo="' + grupo + '"]').forEach(function (elemento)
        {
            if (elemento.matches('button'))
            {
                elemento.classList.toggle('active', elemento === boton);
            }
            else
            {
                elemento.hidden = elemento.id !== boton.getAttribute('data-panel');
            }
        });
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-permisos-rol]');
        var tabla = document.getElementById('tblPermisos');
        if (boton && tabla)
        {
            mostrarPermisos(tabla, boton.getAttribute('data-permisos-rol'));
        }
    });

    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest('[data-ver-clave]');
        var campo = boton ? boton.parentElement.querySelector('input') : null;
        var icono = boton ? boton.querySelector('i') : null;
        var visible = false;
        if (!boton)
        {
            return;
        }
        visible = campo.type === 'text';
        campo.type = visible ? 'password' : 'text';
        boton.setAttribute('aria-label', visible ? 'Mostrar contraseña' : 'Ocultar contraseña');
        if (icono)
        {
            icono.classList.toggle('fa-eye', visible);
            icono.classList.toggle('fa-eye-slash', !visible);
        }
    });

    document.addEventListener('click', function (evento)
    {
        if (evento.target.closest('[data-imprimir]'))
        {
            window.print();
        }
    });

	document.addEventListener('submit', function (evento)
	{
	    var formulario = evento.target;
	    var dialogo = formulario.closest('dialog');
	    var tabla = dialogo ? document.querySelector('table[data-crud="' + dialogo.id + '"]') : null;
	    if (!formulario.hasAttribute('data-demo'))
	    {
	        return;
	    }
	    evento.preventDefault();
	    if (tabla)
	    {
	        if (!guardarFila(tabla, dialogo, formulario))
	        {
	            return;
	        }
	    }
	    else
	    {
	        mostrarNotificacion('Cambios guardados' + SUFIJO_DEMO);
	    }
	    if (dialogo)
	    {
	        dialogo.close();
	    }
	});
	
    if (document.readyState === 'loading')
    {
        document.addEventListener('DOMContentLoaded', iniciar);
    }
    else
    {
        iniciar();
    }
})();
