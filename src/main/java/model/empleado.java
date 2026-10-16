package model;

public class empleado {

	private int id_empleado;
	private String cedula;
	private String nombre;
	private String apellido;
	private int cod_marcacion;
	private String turno;
	private int estado;
	private String fecha_registro;
	
	public empleado(int id_empleado, String cedula, String nombre, String apellido, 
					int cod_marcacion, String turno, int estado, String fecha_registro) {}
	
	
	//ID Empleado
	
	//Devuelve el ID del empleado
	public int getEmpleadoID() {return id_empleado;}
	
	//Crea el ID del empleado
	public void setEmpleadoID(int id_empleado){
		this.id_empleado = id_empleado;
	}
	
	//Cedula Empleado
	public String getCedula() {return cedula;}
	
	public void setCedula(String cedula) {
		this.cedula = cedula;
	}
	
	//Nombre y Apellido
	public String getNombre() {return nombre;}
	public void setNombre(String nombre) {
		this.nombre = nombre;
	}
	
	public String getApellido() {return apellido;}
	public void setApellido(String apellido) {
		this.apellido = apellido;
	}
	
	//Codigo de marcación
	public int getCodM() {return cod_marcacion;}
	public void setCodM(int cod_marcacion) {
		this.cod_marcacion = cod_marcacion;
	}
	
	//Turno
	public String getTurno( ) {return turno;}
	public void setTurno(String turno) {
		this.turno = turno;
	}
	
	//Estado
	public int getEstado() {return estado;}
	public void setEstado(int estado) {
		this.estado = estado;
	}
	
	public String getFechaReg() {return fecha_registro;}
	public void setFechaReg(String fechaRegistro) {
		this.fecha_registro = fechaRegistro;
	}
}
