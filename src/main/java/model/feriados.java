package model;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.Map;
import java.util.TreeMap;

//Feriados nacionales de Panamá calculados para cualquier año (no hay que cargarlos año por año)
public final class feriados
{
    public static final String TEXTO = "Feriado";

    private feriados()
    {

    }

    //Días feriados entre dos fechas. La clave es la fecha y el valor el texto que se muestra en la observación
    public static Map<LocalDate, String> entre(LocalDate desde, LocalDate hasta)
    {
        Map<LocalDate, String> resultado = new TreeMap<>();

        for (int anio = desde.getYear(); anio <= hasta.getYear(); anio++)
        {
            for (LocalDate dia : deAnio(anio))
            {
                if (!dia.isBefore(desde) && !dia.isAfter(hasta))
                {
                    resultado.put(dia, TEXTO);
                }
            }
        }
        return resultado;
    }

    public static Iterable<LocalDate> deAnio(int anio)
    {
        Map<LocalDate, String> dias = new TreeMap<>();
        LocalDate pascua = pascua(anio);

        //fechas fijas: Año Nuevo, Mártires, Trabajador, Fiestas Patrias de noviembre, Madres, Duelo Nacional y Navidad
        agregar(dias, LocalDate.of(anio, 1, 1));
        agregar(dias, LocalDate.of(anio, 1, 9));
        agregar(dias, LocalDate.of(anio, 5, 1));
        agregar(dias, LocalDate.of(anio, 11, 3));
        agregar(dias, LocalDate.of(anio, 11, 5));
        agregar(dias, LocalDate.of(anio, 11, 10));
        agregar(dias, LocalDate.of(anio, 11, 28));
        agregar(dias, LocalDate.of(anio, 12, 8));
        agregar(dias, LocalDate.of(anio, 12, 20));
        agregar(dias, LocalDate.of(anio, 12, 25));

        //fechas que dependen de la Semana Santa: Martes de Carnaval y Viernes Santo
        agregar(dias, pascua.minusDays(47));
        agregar(dias, pascua.minusDays(2));

        return dias.keySet();
    }

    //Si el feriado cae domingo, el día libre pasa al lunes siguiente
    private static void agregar(Map<LocalDate, String> dias, LocalDate fecha)
    {
        dias.put(fecha, TEXTO);

        if (fecha.getDayOfWeek() == DayOfWeek.SUNDAY)
        {
            dias.put(fecha.plusDays(1), TEXTO);
        }
    }

    //Domingo de Pascua (calendario gregoriano)
    private static LocalDate pascua(int anio)
    {
        int a = anio % 19;
        int b = anio / 100;
        int c = anio % 100;
        int d = b / 4;
        int e = b % 4;
        int f = (b + 8) / 25;
        int g = (b - f + 1) / 3;
        int h = (19 * a + b - d - g + 15) % 30;
        int i = c / 4;
        int k = c % 4;
        int l = (32 + 2 * e + 2 * i - h - k) % 7;
        int m = (a + 11 * h + 22 * l) / 451;
        int mes = (h + l - 7 * m + 114) / 31;
        int dia = ((h + l - 7 * m + 114) % 31) + 1;

        return LocalDate.of(anio, mes, dia);
    }
}