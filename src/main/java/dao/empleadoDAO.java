package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;

import config.Conexion;

public class empleadoDAO {

	//Inserta a un empleado en la base de datos (en progreso)
	public boolean crearEmpleado() {
		
		String sql = "Insert Into personal "
				+ "ID_PERSONAL, CEDULA, NOMBRE, APELLIDO, "
				+ "CODIGO_MARCACION, TURNO, ESTADO; FECHA_REGISTRO "
				+ "values(?, ?, ?, ?, ?, ?, ?, ?)";
		
		try{
			
			Connection con = Conexion.getConexion();
			PreparedStatement prepST = con.prepareStatement(sql);
			
			
		}catch (Exception e2) {
			e2.printStackTrace();
		}
		
		
		return false;
	}
}
