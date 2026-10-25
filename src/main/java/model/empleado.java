package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class empleado {

	private int id_empleado;
	private String cedula;
	private String nombre;
	private String apellido;
	private int cod_marcacion;
	private String turno;
	private int estado;
	private Timestamp fecha_registro;

	public empleado() {

	}

	public empleado(int id_empleado, String cedula, String nombre, String apellido,
					int cod_marcacion, String turno, int estado) {
		this.id_empleado = id_empleado;
		this.cedula = cedula;
		this.nombre = nombre;
		this.apellido = apellido;
		this.cod_marcacion = cod_marcacion;
		this.turno = turno;
		this.estado = estado;
	}

	//ID Empleado
	public int getEmpleadoID() {return id_empleado;}
	public void setEmpleadoID(int id_empleado) {this.id_empleado = id_empleado;}

	//Cedula Empleado
	public String getCedula() {return cedula;}
	public void setCedula(String cedula) {this.cedula = cedula;}

	//Nombre y Apellido
	public String getNombre() {return nombre;}
	public void setNombre(String nombre) {this.nombre = nombre;}

	public String getApellido() {return apellido;}
	public void setApellido(String apellido) {this.apellido = apellido;}

	//Codigo de marcación
	public int getCodM() {return cod_marcacion;}
	public void setCodM(int cod_marcacion) {this.cod_marcacion = cod_marcacion;}

	//Turno (M o T)
	public String getTurno() {return turno;}
	public void setTurno(String turno) {this.turno = turno;}

	public String getTurnoNombre() {
		if ("M".equals(turno)) {return "Mañana";}
		if ("T".equals(turno)) {return "Tarde";}
		return turno == null ? "" : turno;
	}

	//Estado (1 activo, 0 inactivo)
	public int getEstado() {return estado;}
	public void setEstado(int estado) {this.estado = estado;}

	//Fecha de registro
	public Timestamp getFechaReg() {return fecha_registro;}
	public void setFechaReg(Timestamp fecha_registro) {this.fecha_registro = fecha_registro;}

	//Fecha como se muestra en la tabla: 10/10/2026 08:15
	public String getFechaRegTexto() {
		return fecha_registro == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(fecha_registro);
	}
	
	//Codigo de marcacion del reloj con su turno y el empleado que lo usa
	public static class codigoMarcacion {

		private int codigo;
		private String turno;
		private int idDueno;	//ID del empleado que lo usa, 0 si esta libre

		public codigoMarcacion() {

		}

		public codigoMarcacion(int codigo, String turno, int idDueno) {
			this.codigo = codigo;
			this.turno = turno;
			this.idDueno = idDueno;
		}

		public int getCodigo() {return codigo;}
		public void setCodigo(int codigo) {this.codigo = codigo;}

		public String getTurno() {return turno;}
		public void setTurno(String turno) {this.turno = turno;}

		public int getIdDueno() {return idDueno;}
		public void setIdDueno(int idDueno) {this.idDueno = idDueno;}
	}
}
