(function ()
{
    //Validación de formularios en el navegador (mismas reglas que model/validaciones.java)
    'use strict';

    var RE_NOMBRE = /^\p{L}+$/u;
    var RE_APELLIDO = /^\p{L}+( \p{L}+)*$/u;
    var RE_CEDULA = /^([A-Z0-9]{2})-([0-9]{4})-([0-9]{5})$/;
    var RE_USUARIO = /^[A-Za-z0-9._-]+$/;
    var RE_CORREO = /^[A-Za-z0-9]+@[A-Za-z0-9]+\.[A-Za-z]{2,}$/;

    /* ---------- Capitalización: mayúscula al inicio del campo y después de cada espacio ---------- */

    function capitalizar(texto)
    {
        return texto.toLowerCase().replace(/(^|\s)(\p{L})/gu, function (todo, antes, letra)
        {
            return antes + letra.toUpperCase();
        });
    }

    /* ---------- Limpieza en tiempo real (quita lo que no se permite) ---------- */

    function limitarGuiones(texto, maximo)
    {
        var cuenta = 0;

        return texto.replace(/-/g, function ()
        {
            cuenta++;
            return cuenta <= maximo ? '-' : '';
        });
    }

    function limpiarBusqueda(valor)
    {
        return limitarGuiones(valor.replace(/[^\p{L}0-9-]/gu, ''), 3);
    }

    function limpiarNombre(valor)
    {
        return capitalizar(valor.replace(/[^\p{L}]/gu, ''));
    }

    function limpiarApellido(valor)
    {
        return capitalizar(valor.replace(/\s+/g, ' ').replace(/[^\p{L} ]/gu, '').replace(/ {2,}/g, ' ').replace(/^ /, ''));
    }

    //Formato XX-0000-00000: el guion se agrega solo al completar cada grupo (no se vuelve a poner al borrar)
    function limpiarCedula(valor, insertando)
    {
        var crudo = valor.toUpperCase().replace(/[^A-Z0-9]/g, '');
        var inicio = crudo.slice(0, 2);
        var resto = crudo.slice(2).replace(/[^0-9]/g, '');
        var tomo = resto.slice(0, 4);
        var asiento = resto.slice(4, 9);
        var termina = insertando === true || /-$/.test(valor);
        var texto = inicio;

        if (inicio.length === 2 && (tomo !== '' || termina))
        {
            texto += '-' + tomo;
        }
        if (tomo.length === 4 && (asiento !== '' || termina))
        {
            texto += '-' + asiento;
        }
        return texto;
    }

    function limpiarUsuario(valor)
    {
        return valor.replace(/[^A-Za-z0-9._-]/g, '');
    }

    function limpiarCorreo(valor)
    {
        var texto = valor.replace(/[^A-Za-z0-9.@]/g, '');
        var arroba = texto.indexOf('@');
        var local = arroba === -1 ? texto : texto.slice(0, arroba);
        var dominio = arroba === -1 ? '' : texto.slice(arroba + 1);
        var punto;

        local = local.replace(/\./g, '');
        dominio = dominio.replace(/@/g, '');
        punto = dominio.indexOf('.');
        if (punto !== -1)
        {
            dominio = dominio.slice(0, punto + 1) + dominio.slice(punto + 1).replace(/\./g, '');
        }
        return arroba === -1 ? local : local + '@' + dominio;
    }

    function quitarEspacioFinal(valor)
    {
        return valor.replace(/ +$/, '');
    }

    /* ---------- Reglas de validación (devuelven '' si todo está bien) ---------- */

    var REGLAS = {
        busqueda: {
            limpiar: limpiarBusqueda
        },
        nombre: {
            max: 15,
            limpiar: limpiarNombre,
            normalizar: limpiarNombre,
            validar: function (v)
            {
                if (v.length < 3)
                {
                    return 'El nombre debe tener al menos 3 letras.';
                }
                if (!RE_NOMBRE.test(v))
                {
                    return 'El nombre solo admite letras, sin espacios.';
                }
                return v.length > 15 ? 'El nombre no puede superar 15 letras.' : '';
            }
        },
        apellido: {
            max: 15,
            limpiar: limpiarApellido,
            normalizar: function (v)
            {
                return quitarEspacioFinal(limpiarApellido(v));
            },
            validar: function (v)
            {
                if (v.length < 3)
                {
                    return 'El apellido debe tener al menos 3 caracteres.';
                }
                if (!RE_APELLIDO.test(v))
                {
                    return 'El apellido solo admite letras y un solo espacio entre palabras.';
                }
                return v.length > 15 ? 'El apellido no puede superar 15 caracteres.' : '';
            }
        },
        cedula: {
            max: 13,
            limpiar: limpiarCedula,
            validar: function (v)
            {
                var partes = RE_CEDULA.exec(v.toUpperCase());

                if (!partes)
                {
                    return 'Formato de cédula: 08-0123-00456.';
                }
                if (partes[2] === '0000')
                {
                    return 'El tomo no puede ser 0000.';
                }
                return partes[3] === '00000' ? 'El asiento no puede ser 00000.' : '';
            }
        },
        usuario: {
            max: 30,
            limpiar: limpiarUsuario,
            validar: function (v)
            {
                if (v.length < 3 || v.length > 30)
                {
                    return 'El usuario debe tener entre 3 y 30 caracteres.';
                }
                return RE_USUARIO.test(v) ? '' : 'El usuario solo admite letras, números, punto, guion y guion bajo, sin espacios.';
            }
        },
        correo: {
            max: 30,
            limpiar: limpiarCorreo,
            validar: function (v)
            {
                if (v.length > 30)
                {
                    return 'El correo no puede superar 30 caracteres.';
                }
                return RE_CORREO.test(v) ? '' : 'Escriba un correo válido ej. nombre@dominio.com';
            }
        },
        clave: {
            max: 30,
            exacto: true,
            validar: function (v)
            {
                return v.length < 8 || v.length > 30 ? 'La contraseña debe tener entre 8 y 30 caracteres.' : '';
            }
        },
        fecha: {
            vacio: 'Seleccione la fecha.',
            validar: function (v, campo)
            {
                var maximo = campo.getAttribute('data-max');

                if (maximo && v > maximo)
                {
                    return 'No se puede consultar una fecha posterior a hoy (' + maximo.split('-').reverse().join('-') + ').';
                }
                return '';
            }
        }
    };

    //Elige la regla de validación según el campo
    function reglaDe(campo)
    {
        var tipo = campo && campo.getAttribute ? campo.getAttribute('data-val') : null;

        return tipo && REGLAS[tipo] ? REGLAS[tipo] : null;
    }

    function esBusqueda(campo)
    {
        return campo.getAttribute('data-val') === 'busqueda';
    }

    /* ---------- Mensajes y estado de cada campo ---------- */

    function mensajeDe(campo)
    {
        var regla = reglaDe(campo);
        var valor = campo.value;

        if (!regla || !regla.validar)
        {
            return '';
        }
        if (valor === '')
        {
            return campo.required ? (regla.vacio || 'Este campo es obligatorio.') : '';
        }
        return regla.validar(regla.exacto ? valor : valor.trim(), campo);
    }

    function cajaError(campo)
    {
        var contenedor;

        if (!campo.cajaError)
        {
            campo.cajaError = document.createElement('span');
            campo.cajaError.className = 'campo-error';
            campo.cajaError.setAttribute('role', 'alert');
            campo.cajaError.hidden = true;
            contenedor = campo.closest('.field') || campo.parentNode;
            contenedor.appendChild(campo.cajaError);
        }
        return campo.cajaError;
    }

    //Muestra u oculta el mensaje de error del campo
    function pintar(campo, mensaje, mostrar)
    {
        var ver = mostrar && mensaje !== '';
        var caja = cajaError(campo);

        campo.setCustomValidity(mensaje);
        campo.classList.toggle('campo-invalido', ver);
        caja.textContent = ver ? mensaje : '';
        caja.hidden = !ver;
    }

    function evaluar(campo, mostrar)
    {
        pintar(campo, mensajeDe(campo), mostrar);
    }

    /* Aplica la limpieza sin mover el cursor de lugar */
    function aplicar(campo, limpiar, insertando)
    {
        var original = campo.value;
        var nuevo = limpiar(original, insertando);
        var cursor = null;
        var posicion;

        if (nuevo === original)
        {
            return;
        }
        try
        {
            cursor = campo.selectionStart;
        }
        catch (error)
        {
            cursor = null;
        }

        campo.value = nuevo;

        if (cursor !== null)
        {
            posicion = Math.min(limpiar(original.slice(0, cursor), insertando).length, nuevo.length);
            try
            {
                campo.setSelectionRange(posicion, posicion);
            }
            catch (error)
            {
                return;
            }
        }
    }

    function normalizar(campo)
    {
        var regla = reglaDe(campo);
        var nuevo;

        if (regla && regla.normalizar)
        {
            nuevo = regla.normalizar(campo.value);
            if (nuevo !== campo.value)
            {
                campo.value = nuevo;
            }
        }
    }

    //Revisa todos los campos antes de enviar el formulario
    function revisarFormulario(formulario)
    {
        Array.prototype.forEach.call(formulario.elements, function (campo)
        {
            if (reglaDe(campo) && !esBusqueda(campo))
            {
                normalizar(campo);
                evaluar(campo, false);
            }
        });
    }

    /* ---------- Eventos (un solo grupo para todas las páginas) ---------- */

    //en captura: la limpieza se hace antes que el filtro de las tablas
    document.addEventListener('input', function (evento)
    {
        var campo = evento.target;
        var regla = reglaDe(campo);

        if (!regla)
        {
            return;
        }
        if (regla.limpiar)
        {
            //al borrar no se vuelven a poner los guiones automáticos
            aplicar(campo, regla.limpiar, !evento.inputType || evento.inputType.indexOf('insert') === 0);
        }
        if (!esBusqueda(campo))
        {
            evaluar(campo, campo.getAttribute('data-tocado') === '1');
        }
    }, true);

    document.addEventListener('focusout', function (evento)
    {
        var campo = evento.target;

        if (!reglaDe(campo) || esBusqueda(campo))
        {
            return;
        }
        normalizar(campo);
        campo.setAttribute('data-tocado', '1');
        evaluar(campo, true);
    }, true);

    //antes de que el navegador valide el formulario se actualiza el estado de cada campo
    document.addEventListener('click', function (evento)
    {
        var boton = evento.target.closest ? evento.target.closest('button, input[type="submit"]') : null;

        if (boton && boton.type === 'submit' && boton.form)
        {
            revisarFormulario(boton.form);
        }
    }, true);

    document.addEventListener('invalid', function (evento)
    {
        var campo = evento.target;

        if (reglaDe(campo) && !esBusqueda(campo))
        {
            campo.setAttribute('data-tocado', '1');
            evaluar(campo, true);
        }
    }, true);

    //al abrir el formulario (nuevo o editar) se limpian los avisos anteriores
    document.addEventListener('reset', function (evento)
    {
        Array.prototype.forEach.call(evento.target.elements || [], function (campo)
        {
            if (reglaDe(campo) && !esBusqueda(campo))
            {
                campo.removeAttribute('data-tocado');
                pintar(campo, '', false);
            }
        });
    }, true);

    function iniciar()
    {
        Array.prototype.forEach.call(document.querySelectorAll('[data-val]'), function (campo)
        {
            var regla = reglaDe(campo);

            if (regla && regla.max)
            {
                campo.maxLength = regla.max;
            }
        });
    }

    if (document.readyState === 'loading')
    {
        document.addEventListener('DOMContentLoaded', iniciar);
    }
    else
    {
        iniciar();
    }

    window.validaciones = {
        capitalizar: capitalizar,
        limpiar: function (tipo, valor, insertando)
        {
            return REGLAS[tipo] && REGLAS[tipo].limpiar ? REGLAS[tipo].limpiar(valor, insertando === true) : valor;
        },
        validar: function (tipo, valor, campo)
        {
            return REGLAS[tipo] && REGLAS[tipo].validar ? REGLAS[tipo].validar(valor, campo) : '';
        }
    };
})();