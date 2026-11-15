package model;

import java.util.Locale;
import java.util.regex.Pattern;

//Mismas reglas que webapp/js/validaciones.js, para que también se cumplan si se salta el navegador
public final class validaciones
{
    private static final Pattern NOMBRE = Pattern.compile("\\p{L}+");
    private static final Pattern APELLIDO = Pattern.compile("\\p{L}+( \\p{L}+)*");
    private static final Pattern CEDULA = Pattern.compile("[0-9]+(-[0-9]+){0,3}");
    private static final Pattern USUARIO = Pattern.compile("[A-Za-z0-9._-]+");
    private static final Pattern CORREO = Pattern.compile("[A-Za-z0-9]+@[A-Za-z0-9]+\\.[A-Za-z]{2,}");

    private validaciones()
    {

    }

    //Mayúscula al inicio y después de cada espacio; el resto en minúscula
    public static String capitalizar(String texto)
    {
        StringBuilder resultado = new StringBuilder();
        boolean inicio = true;

        for (char c : texto.toLowerCase(Locale.ROOT).toCharArray())
        {
            resultado.append(inicio && Character.isLetter(c) ? Character.toUpperCase(c) : c);
            inicio = Character.isWhitespace(c);
        }
        return resultado.toString();
    }

    public static String nombre(String valor)
    {
        String texto = limpio(valor);

        if (texto.isEmpty())
        {
            throw new IllegalArgumentException("El nombre es obligatorio.");
        }
        if (texto.length() < 3 || texto.length() > 15 || !NOMBRE.matcher(texto).matches())
        {
            throw new IllegalArgumentException("El nombre debe tener de 3 a 15 letras, sin espacios ni símbolos.");
        }
        return capitalizar(texto);
    }

    public static String apellido(String valor)
    {
        String texto = limpio(valor);

        if (texto.isEmpty())
        {
            throw new IllegalArgumentException("El apellido es obligatorio.");
        }
        if (texto.length() < 3 || texto.length() > 15 || !APELLIDO.matcher(texto).matches())
        {
            throw new IllegalArgumentException("El apellido debe tener de 3 a 15 caracteres: solo letras y un solo espacio entre palabras.");
        }
        return capitalizar(texto);
    }

    public static String cedula(String valor)
    {
        String texto = limpio(valor);

        if (texto.isEmpty())
        {
            throw new IllegalArgumentException("La cédula es obligatoria.");
        }
        if (texto.length() > 13 || !CEDULA.matcher(texto).matches())
        {
            throw new IllegalArgumentException("La cédula solo admite números y hasta 3 guiones (máximo 13 caracteres).");
        }
        return texto;
    }

    public static String usuario(String valor)
    {
        String texto = limpio(valor);

        if (texto.isEmpty())
        {
            throw new IllegalArgumentException("El usuario es obligatorio.");
        }
        if (texto.length() < 3 || texto.length() > 30 || !USUARIO.matcher(texto).matches())
        {
            throw new IllegalArgumentException("El usuario debe tener de 3 a 30 caracteres: letras, números, punto, guion o guion bajo, sin espacios.");
        }
        return texto;
    }

    public static String correo(String valor)
    {
        String texto = limpio(valor);

        if (texto.isEmpty())
        {
            throw new IllegalArgumentException("El correo es obligatorio.");
        }
        if (texto.length() > 30 || !CORREO.matcher(texto).matches())
        {
            throw new IllegalArgumentException("El correo no es válido: solo letras y números, un solo @ y un solo punto (máximo 30 caracteres).");
        }
        return texto;
    }

    //La contraseña admite cualquier carácter y no se recorta. Al editar puede venir vacía (se conserva la actual)
    public static String clave(String valor, boolean obligatoria)
    {
        String clave = valor == null ? "" : valor;

        if (clave.isEmpty() && !obligatoria)
        {
            return "";
        }
        if (clave.length() < 8 || clave.length() > 30)
        {
            throw new IllegalArgumentException("La contraseña debe tener entre 8 y 30 caracteres.");
        }
        return clave;
    }

    //Búsquedas: solo letras, números y hasta 3 guiones
    public static String busqueda(String valor)
    {
        StringBuilder resultado = new StringBuilder();
        int guiones = 0;

        if (valor == null)
        {
            return "";
        }
        for (char c : valor.toCharArray())
        {
            if (Character.isLetterOrDigit(c))
            {
                resultado.append(c);
            }
            else if (c == '-' && guiones < 3)
            {
                resultado.append(c);
                guiones++;
            }
        }
        return resultado.toString();
    }

    private static String limpio(String valor)
    {
        return valor == null ? "" : valor.trim();
    }
}