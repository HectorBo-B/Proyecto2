package model;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class marcacion implements Serializable {

	private static final long serialVersionUID = 1L;

	//Estados posibles de una marcacion despues de validarla
	public static final String CORRECTO = "CORRECTO";
	public static final String DUPLICADO = "DUPLICADO";
	public static final String RECHAZADO = "RECHAZADO";
	public static final String ERROR = "ERROR";

	private static final DateTimeFormatter FORMATO_TEXTO = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

	//Datos tal como vienen en el archivo
	private int numeroLinea;
	private String linea;

	//Datos interpretados (paso 4)
	private int codigo;
	private LocalDateTime fechaHora;
	private int verificacion;
	private int entradaSalida;
	private int codigoTrabajo;
	private int reservado;

	//Datos asociados (pasos 8 y 9)
	private int idPersonal;
	private String empleado;
	private String turno;

	//Resultado de la validacion
	private String estado;
	private String motivo;

	public marcacion() {

	}

	public marcacion(int numeroLinea, String linea) {
		this.numeroLinea = numeroLinea;
		this.linea = linea;
	}

	//Numero de linea dentro del archivo
	public int getNumeroLinea() {return numeroLinea;}
	public void setNumeroLinea(int numeroLinea) {this.numeroLinea = numeroLinea;}

	//Texto original de la linea
	public String getLinea() {return linea;}
	public void setLinea(String linea) {this.linea = linea;}

	//Codigo de marcacion del reloj
	public int getCodigo() {return codigo;}
	public void setCodigo(int codigo) {this.codigo = codigo;}

	//Fecha y hora de la marcacion
	public LocalDateTime getFechaHora() {return fechaHora;}
	public void setFechaHora(LocalDateTime fechaHora) {this.fechaHora = fechaHora;}

	public String getFechaHoraTexto() {
		return fechaHora == null ? "" : fechaHora.format(FORMATO_TEXTO);
	}

	//Columnas 3 a 6 del archivo
	public int getVerificacion() {return verificacion;}
	public void setVerificacion(int verificacion) {this.verificacion = verificacion;}

	public int getEntradaSalida() {return entradaSalida;}
	public void setEntradaSalida(int entradaSalida) {this.entradaSalida = entradaSalida;}

	public int getCodigoTrabajo() {return codigoTrabajo;}
	public void setCodigoTrabajo(int codigoTrabajo) {this.codigoTrabajo = codigoTrabajo;}

	public int getReservado() {return reservado;}
	public void setReservado(int reservado) {this.reservado = reservado;}

	//Empleado asociado
	public int getIdPersonal() {return idPersonal;}
	public void setIdPersonal(int idPersonal) {this.idPersonal = idPersonal;}

	public String getEmpleado() {return empleado;}
	public void setEmpleado(String empleado) {this.empleado = empleado;}

	//Turno (M o T)
	public String getTurno() {return turno;}
	public void setTurno(String turno) {this.turno = turno;}

	public String getTurnoNombre() {
		if (turno == null || turno.isEmpty()) {return "-";}
		if (turno.equals("M")) {return "Mañana";}
		if (turno.equals("T")) {return "Tarde";}
		return turno;
	}
	
	//Resumen para las tablas: solo codigo, fecha y hora (primeras columnas del archivo)
	public String getRegistroResumen() {

		if (linea == null) {return "";}

		String[] campos = linea.split("\t", -1);
		StringBuilder resumen = new StringBuilder(campos[0].trim());

		if (campos.length > 1) {
			//la segunda columna trae fecha y hora juntas: 2026-09-01 06:04:25
			String[] fechaHora = campos[1].trim().split("\\s+");

			for (int i = 0; i < Math.min(fechaHora.length, 2); i++) {
				resumen.append(" | ").append(fechaHora[i]);
			}
		}

		return resumen.toString();
	}

	//Estado y motivo
	public String getEstado() {return estado;}
	public void setEstado(String estado) {this.estado = estado;}

	public String getMotivo() {return motivo;}
	public void setMotivo(String motivo) {this.motivo = motivo;}

	//Marca la marcacion con un estado y el motivo que lo origino
	public void marcar(String estado, String motivo) {
		this.estado = estado;
		this.motivo = motivo;
	}
}
