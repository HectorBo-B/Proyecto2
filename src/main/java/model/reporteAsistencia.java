package model;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

public class reporteAsistencia
{
    private static final DateTimeFormatter FECHA_TEXTO = DateTimeFormatter.ofPattern("dd-MM-yyyy");
    private static final DateTimeFormatter HORA_TEXTO = DateTimeFormatter.ofPattern("HH:mm:ss");
    private static final String[] DIAS = {"Lun.", "Mar.", "Mie.", "Jue.", "Vie.", "Sáb.", "Dom."};

    private empleado persona;
    private LocalDate desde;
    private LocalDate hasta;
    private final List<dia> dias = new ArrayList<>();
    private int ausencias, tardanzas, justificadas;
    private long segundosTardanza;

    public reporteAsistencia()
    {

    }

    public reporteAsistencia(empleado persona, LocalDate desde, LocalDate hasta)
    {
        this.persona = persona;
        this.desde = desde;
        this.hasta = hasta;
    }

    public static String duracion(long segundos)
    {
        return String.format("%02d:%02d:%02d", segundos / 3600, (segundos % 3600) / 60, segundos % 60);
    }

    public void agregar(dia registro)
    {
        dias.add(registro);

        if (registro.isAusente())
        {
            ausencias++;
        }
        if (registro.getTardanzaSegundos() > 0)
        {
            tardanzas++;
            segundosTardanza += registro.getTardanzaSegundos();
            if (registro.isJustificada())
            {
                justificadas++;
            }
        }
    }

    public empleado getEmpleado() {return persona;}

    public LocalDate getDesde() {return desde;}

    public LocalDate getHasta() {return hasta;}

    public String getDesdeTexto() {return desde.format(FECHA_TEXTO);}

    public String getHastaTexto() {return hasta.format(FECHA_TEXTO);}

    public List<dia> getDias() {return dias;}

    public int getAusencias() {return ausencias;}

    public int getTardanzas() {return tardanzas;}

    public int getJustificadas() {return justificadas;}

    public int getInjustificadas() {return tardanzas - justificadas;}

    public long getSegundosTardanza() {return segundosTardanza;}

    public String getTiempoTardanzaTexto() {return duracion(segundosTardanza);}

    public static class dia
    {
        private final LocalDate fecha;
        private LocalTime entrada;
        private LocalTime salida;
        private boolean ausente, justificada;
        private long tardanzaSegundos;
        private String observacion = "";

        public dia(LocalDate fecha)
        {
            this.fecha = fecha;
        }

        public LocalDate getFecha() {return fecha;}

        public LocalTime getEntrada() {return entrada;}
        public void setEntrada(LocalTime entrada) {this.entrada = entrada;}

        public LocalTime getSalida() {return salida;}
        public void setSalida(LocalTime salida) {this.salida = salida;}

        public boolean isAusente() {return ausente;}
        public void setAusente(boolean ausente) {this.ausente = ausente;}

        public boolean isJustificada() {return justificada;}
        public void setJustificada(boolean justificada) {this.justificada = justificada;}

        public long getTardanzaSegundos() {return tardanzaSegundos;}
        public void setTardanzaSegundos(long tardanzaSegundos) {this.tardanzaSegundos = tardanzaSegundos;}

        public String getObservacion() {return observacion;}
        public void setObservacion(String observacion) {this.observacion = observacion == null ? "" : observacion;}

        public boolean isFinDeSemana()
        {
            return fecha.getDayOfWeek().getValue() > 5;
        }

        public String getNombreDia()
        {
            return DIAS[fecha.getDayOfWeek().getValue() - 1];
        }

        public String getFechaTexto()
        {
            return fecha.format(FECHA_TEXTO);
        }

        public String getFechaIso()
        {
            return fecha.toString();
        }

        public String getEntradaTexto()
        {
            return entrada == null ? "" : entrada.format(HORA_TEXTO);
        }

        public String getSalidaTexto()
        {
            return salida == null ? "" : salida.format(HORA_TEXTO);
        }
    }
}