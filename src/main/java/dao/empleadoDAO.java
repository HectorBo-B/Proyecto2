package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;



import config.Conexion;
import model.empleado;

public class empleadoDAO {

	//Inserta a un empleado en la base de datos (en progreso)
	public boolean crearEmpleado(empleado emp) {
		
		String sql = "Insert Into personal "
				+ "ID_PERSONAL, CEDULA, NOMBRE, APELLIDO, "
				+ "CODIGO_MARCACION, TURNO, ESTADO; FECHA_REGISTRO "
				+ "values(?, ?, ?, ?, ?, ?, ?, ?)";
		
		try{
			
			Connection con = Conexion.getConexion();
			PreparedStatement prepST = con.prepareStatement(sql);
			
			ResultSet rs = prepST.executeQuery();
			
				while (rs.next()) {
					
					prepST.setInt(1, emp.getEmpleadoID());
				}
			
			
		}catch (Exception e2) {
			e2.printStackTrace();
		}
		
		
		return false;
	}
	
	
}
