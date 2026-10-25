package model;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class resultadoImportacion implements Serializable {

	private static final long serialVersionUID = 1L;

	private String nombreArchivo;

	private final List<marcacion> procesados = new ArrayList<>();
	private final List<marcacion> correctos = new ArrayList<>();
	private final List<marcacion> duplicados = new ArrayList<>();
	private final List<marcacion> rechazados = new ArrayList<>();
	private final List<marcacion> errores = new ArrayList<>();

	public resultadoImportacion(String nombreArchivo) {
		this.nombreArchivo = nombreArchivo;
	}

	public String getNombreArchivo() {return nombreArchivo;}

	//Clasifica una marcacion segun su estado
	public void agregar(marcacion m) {

		procesados.add(m);

		if (marcacion.CORRECTO.equals(m.getEstado())) {correctos.add(m);}
		else if (marcacion.DUPLICADO.equals(m.getEstado())) {duplicados.add(m);}
		else if (marcacion.RECHAZADO.equals(m.getEstado())) {rechazados.add(m);}
		else {errores.add(m);}
	}

	public List<marcacion> getProcesados() {return procesados;}
	public List<marcacion> getCorrectos() {return correctos;}
	public List<marcacion> getDuplicados() {return duplicados;}
	public List<marcacion> getRechazados() {return rechazados;}
	public List<marcacion> getErrores() {return errores;}

	//Hay algo que no se va a guardar
	public boolean hayIncidencias() {
		return !duplicados.isEmpty() || !rechazados.isEmpty() || !errores.isEmpty();
	}

	//Escapa texto para mostrarlo en HTML
	public static String escapar(String texto) {
		if (texto == null) {return "";}
		return texto.replace("&", "&amp;")
					.replace("<", "&lt;")
					.replace(">", "&gt;")
					.replace("\"", "&quot;");
	}
}
