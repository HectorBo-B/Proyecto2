document.addEventListener('DOMContentLoaded', function ()
{
    var archivo = document.getElementById('archivo');
    var nombreArchivo = document.getElementById('nombreArchivo');

    if (archivo && nombreArchivo)
    {
        archivo.addEventListener('change', function ()
        {
            nombreArchivo.textContent = archivo.files.length > 0 ? archivo.files[0].name : 'Formatos permitidos: .xls, .xlsx, .csv';
        });
    }
});
