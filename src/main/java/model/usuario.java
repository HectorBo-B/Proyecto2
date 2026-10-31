package model;

import java.io.Serializable;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class usuario implements Serializable {

	private static final long serialVersionUID = 1L;

	//Nombre con el que se guarda el Usuario dentro de la sesión
	public static final String SESION = "UsuarioSesion";

	public static final String ADMIN = "ADMIN";
	public static final String OPERADOR = "OPERADOR";

	private int id_Usuario;
	private String nombre;
	private String apellido;
	private String Usuario;
	private String correo;
	private String rol;
	private int estado;
	private Timestamp fecha_creacion;
	private transient String clave;	//solo se usa al iniciar sesión, nunca se muestra

	public usuario() {

	}

	public int getId() {return id_Usuario;}
	public void setId(int id_Usuario) {this.id_Usuario = id_Usuario;}

	public String getNombre() {return nombre;}
	public void setNombre(String nombre) {this.nombre = nombre;}

	public String getApellido() {return apellido;}
	public void setApellido(String apellido) {this.apellido = apellido;}

	public String getUsuario() {return Usuario;}
	public void setUsuario(String Usuario) {this.Usuario = Usuario;}

	public String getCorreo() {return correo;}
	public void setCorreo(String correo) {this.correo = correo;}

	public String getRol() {return rol;}
	public void setRol(String rol) {this.rol = rol;}

	//Estado (1 activo, 0 inactivo)
	public int getEstado() {return estado;}
	public void setEstado(int estado) {this.estado = estado;}

	public Timestamp getFechaCreacion() {return fecha_creacion;}
	public void setFechaCreacion(Timestamp fecha_creacion) {this.fecha_creacion = fecha_creacion;}

	public String getClave() {return clave;}
	public void setClave(String clave) {this.clave = clave;}

	public boolean esAdmin() {
		return ADMIN.equals(rol);
	}

	public String getNombreCompleto() {
		return nombre + " " + apellido;
	}

	public String getRolNombre() {
		return esAdmin() ? "Administrador" : "Operador";
	}

	//Fecha como se muestra en la tabla: 10/10/2026 08:15
	public String getFechaCreacionTexto() {
		return fecha_creacion == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(fecha_creacion);
	}
}