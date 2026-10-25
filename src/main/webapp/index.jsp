<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gestión De Asistencia</title>
    <style>
        html, body
        {
            margin: 0;
            height: 100%;
            overflow: hidden;
            background: #F4F6F8;
        }
        .marco
        {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: 0;
            background: #F4F6F8;
            visibility: hidden;
        }
        .marco.visible
        {
            visibility: visible;
        }
    </style>
</head>
<body>
    <iframe id="marcoA" name="marcoA" class="marco visible" title="Gestión De Asistencia"></iframe>
    <iframe id="marcoB" name="marcoB" class="marco" title="Gestión De Asistencia"></iframe>

    <noscript>
        <a href="${pageContext.request.contextPath}/jsp/login.jsp">Ir al inicio de sesión</a>
    </noscript>

    <script>
        (function ()
        {
            var contexto = '${pageContext.request.contextPath}';
            var inicio = contexto + '/jsp/login.jsp';
            var clave = 'asistencia-ultima-pagina';
            var marcos = [document.getElementById('marcoA'), document.getElementById('marcoB')];
            var activo = 0;
            var guardada = null;

            function pendiente()
            {
                return marcos[1 - activo];
            }

            function enBlanco(marco)
            {
                return marco.contentWindow.location.href === 'about:blank';
            }

            function preparar(marco)
            {
                var ventana = marco.contentWindow;
                var documento = marco.contentDocument;
                var original = ventana.HTMLFormElement.prototype.submit;
                var enfocable = documento.querySelector('[autofocus]');

                ventana.HTMLFormElement.prototype.submit = function ()
                {
                    this.target = pendiente().name;
                    original.call(this);
                };

                documento.addEventListener('click', function (evento)
                {
                    var enlace = evento.target.closest ? evento.target.closest('a[href]') : null;
                    var destino = enlace ? enlace.getAttribute('href') : null;

                    if (!enlace || evento.defaultPrevented || evento.button !== 0
                            || evento.ctrlKey || evento.metaKey || evento.shiftKey || enlace.target)
                    {
                        return;
                    }
                    if (!destino || destino.charAt(0) === '#' || destino.indexOf('javascript:') === 0)
                    {
                        return;
                    }

                    evento.preventDefault();
                    if (!enlace.classList.contains('active'))
                    {
                        pendiente().src = enlace.href;
                    }
                });

                documento.addEventListener('submit', function (evento)
                {
                    if (!evento.defaultPrevented)
                    {
                        evento.target.target = pendiente().name;
                    }
                });

                try
                {
                    window.sessionStorage.setItem(clave, ventana.location.pathname + ventana.location.search);
                }
                catch (error)
                {
                    guardada = null;
                }
                document.title = documento.title;
                ventana.focus();
                if (enfocable)
                {
                    enfocable.focus();
                }
            }

            function mostrar(indice)
            {
                var anterior = marcos[activo];

                marcos[indice].classList.add('visible');
                anterior.classList.remove('visible');
                activo = indice;
                preparar(marcos[indice]);

                window.setTimeout(function ()
                {
                    if (marcos[activo] !== anterior)
                    {
                        anterior.src = 'about:blank';
                    }
                }, 400);
            }

            marcos.forEach(function (marco, indice)
            {
                marco.addEventListener('load', function ()
                {
                    var fuentes = null;

                    if (enBlanco(marco))
                    {
                        return;
                    }
                    if (indice === activo)
                    {
                        preparar(marco);
                        return;
                    }

                    fuentes = marco.contentDocument.fonts;
                    if (fuentes && fuentes.ready)
                    {
                        Promise.race([fuentes.ready, new Promise(function (resolver)
                        {
                            window.setTimeout(resolver, 1200);
                        })]).then(function ()
                        {
                            if (indice !== activo)
                            {
                                mostrar(indice);
                            }
                        });
                        return;
                    }
                    mostrar(indice);
                });
            });

            try
            {
                guardada = window.sessionStorage.getItem(clave);
            }
            catch (error)
            {
                guardada = null;
            }

            if (guardada && guardada.indexOf(contexto + '/') === 0 && guardada.indexOf('//') !== 0)
            {
                marcos[0].src = guardada;
            }
            else
            {
                marcos[0].src = inicio;
            }
        })();
    </script>
</body>
</html>