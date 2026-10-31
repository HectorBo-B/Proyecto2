package model;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class auditoria {

	public static final String LOGIN = "LOGIN";
	public static final String LOGOUT = "LOGOUT";
	public static final String IMPORTACION = "IMPORTACION";
	public static final String CRUD = "CRUD";

	private int id_auditoria;
	private String Usuario;
	private String accion;
	private String descripcion;
	private Timestamp fecha;

	public auditoria() {

	}

	public int getId() {return id_auditoria;}
	public void setId(int id_auditoria) {this.id_auditoria = id_auditoria;}

	public String getUsuario() {return Usuario;}
	public void setUsuario(String Usuario) {this.Usuario = Usuario;}

	public String getAccion() {return accion;}
	public void setAccion(String accion) {this.accion = accion;}

	public String getDescripcion() {return descripcion;}
	public void setDescripcion(String descripcion) {this.descripcion = descripcion;}

	public Timestamp getFecha() {return fecha;}
	public void setFecha(Timestamp fecha) {this.fecha = fecha;}

	public String getFechaTexto() {
		return fecha == null ? "" : new SimpleDateFormat("dd/MM/yyyy HH:mm").format(fecha);
	}

	//Texto de la insignia
	public String getAccionTexto() {
		if (LOGIN.equals(accion)) {return "Login";}
		if (LOGOUT.equals(accion)) {return "Logout";}
		if (IMPORTACION.equals(accion)) {return "Importación";}
		return "CRUD";
	}

	//Color de la insignia
	public String getBadge() {
		if (LOGIN.equals(accion)) {return "badge-ok";}
		if (LOGOUT.equals(accion)) {return "badge-off";}
		if (IMPORTACION.equals(accion)) {return "badge-info";}
		return "badge-warn";
	}
}