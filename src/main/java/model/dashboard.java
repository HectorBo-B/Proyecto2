package model;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class dashboard
{
    private static final DateTimeFormatter FECHA_TEXTO = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter FECHA_HORA_TEXTO = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
    private static final DateTimeFormatter HORA_TEXTO = DateTimeFormatter.ofPattern("HH:mm:ss");

    private int empleados, ausencias, tardanzas;
    private long registros, segundosTardanza;
    private Timestamp ultimoProceso;
    private String ultimoArchivo = "";
    private LocalDate desde, hasta;
    private final List<registro> ultimos = new ArrayList<>();

    public dashboard()
    {

    }

    public void sumar(int ausenciasNuevas, int tardanzasNuevas, long segundos)
    {
        ausencias += ausenciasNuevas;
        tardanzas += tardanzasNuevas;
        segundosTardanza += segundos;
    }

    public void agregar(registro nuevo)
    {
        ultimos.add(nuevo);
    }

    public int getEmpleados() {return empleados;}
    public void setEmpleados(int empleados) {this.empleados = empleados;}

    public long getRegistros() {return registros;}
    public void setRegistros(long registros) {this.registros = registros;}

    public int getAusencias() {return ausencias;}

    public int getTardanzas() {return tardanzas;}

    public long getSegundosTardanza() {return segundosTardanza;}

    public String getTiempoTardanzaTexto()
    {
        return reporteAsistencia.duracion(segundosTardanza);
    }

    public Timestamp getUltimoProceso() {return ultimoProceso;}
    public void setUltimoProceso(Timestamp ultimoProceso) {this.ultimoProceso = ultimoProceso;}

    public String getUltimoArchivo() {return ultimoArchivo;}
    public void setUltimoArchivo(String ultimoArchivo) {this.ultimoArchivo = ultimoArchivo == null ? "" : ultimoArchivo;}

    public String getUltimoProcesoTexto()
    {
        return ultimoProceso == null ? "Sin importaciones" : ultimoProceso.toLocalDateTime().format(FECHA_HORA_TEXTO);
    }

    public LocalDate getDesde() {return desde;}
    public void setDesde(LocalDate desde) {this.desde = desde;}

    public LocalDate getHasta() {return hasta;}
    public void setHasta(LocalDate hasta) {this.hasta = hasta;}

    public String getRangoTexto()
    {
        return desde == null ? "Sin registros" : desde.format(FECHA_TEXTO) + " - " + hasta.format(FECHA_TEXTO);
    }

    public List<registro> getUltimos() {return ultimos;}

    public static class registro
    {
        private final String nombre, turno;
        private final int codigo;
        private final LocalDate fecha;
        private final LocalTime hora;

        public registro(String nombre, int codigo, String turno, LocalDate fecha, LocalTime hora)
        {
            this.nombre = nombre == null ? "" : nombre;
            this.codigo = codigo;
            this.turno = turno == null ? "" : turno;
            this.fecha = fecha;
            this.hora = hora;
        }

        public String getNombre()
        {
            return nombre.isEmpty() ? "Sin empleado asociado" : nombre;
        }

        public int getCodigo() {return codigo;}

        public String getTurnoNombre()
        {
            if (turno.equals("M"))
            {
                return "Mañana";
            }
            if (turno.equals("T"))
            {
                return "Tarde";
            }
            return "-";
        }

        public String getFechaTexto()
        {
            return fecha.format(FECHA_TEXTO);
        }

        public String getHoraTexto()
        {
            return hora.format(HORA_TEXTO);
        }
    }
}