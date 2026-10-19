package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.List; 
import java.util.ArrayList;
import java.sql.ResultSet;


import config.Conexion;
import model.empleado;

public class empleadoDAO {

	//Inserta a un empleado en la base de datos (en progreso)
	public boolean crearEmpleado(empleado emp) {
		
		String sql = "Insert into personal "
				+ "(ID_PERSONAL, CEDULA, NOMBRE, APELLIDO, "
				+ "CODIGO_MARCACION, TURNO, ESTADO, FECHA_REGISTRO) "
				+ "values(?, ?, ?, ?, ?, ?, ?, ?)";
		
		try{
			
			Connection con = Conexion.getConexion();
			PreparedStatement prepST = con.prepareStatement(sql);
					
					prepST.setInt(1, emp.getEmpleadoID());
					
					prepST.setString(2, emp.getCedula());
					System.out.println("Cédula en el objeto: " + emp.getCedula());
					
					prepST.setString(3, emp.getNombre());
					prepST.setString(4, emp.getApellido());
					prepST.setInt(5, emp.getCodM());
					prepST.setString(6, emp.getTurno());
					prepST.setInt(7, emp.getEstado());   
					prepST.setDate(8, emp.getFechaReg());

					int filas = prepST.executeUpdate();
					return filas > 0;
				
			
			
		}catch (Exception e2) {
			e2.printStackTrace();
			return false;
		}
	}
	
	//Busca y devuelve los datos de todos los empleados, se utiliza para la lista que aparece en la pestaña de "empleados"
	public List<empleado> buscarEmpleados() {
		
		List<empleado> lista = new ArrayList<>();
		
		String sql = "select (CODIGO_MARCACION, NOMBRE, ESTADO) from personal"; 
		
		try {
			Connection con = Conexion.getConexion();
			PreparedStatement prepST = con.prepareStatement(sql);
			ResultSet rs = prepST.executeQuery();
			
			while (rs.next()) {
				empleado emp = new empleado();
				
				emp.setCodM(rs.getInt("CODIGO_MARCACION"));
				emp.setNombre(rs.getString("NOMBRE"));
			}
			
			
			
			
		} catch (Exception e) {
			e.printStackTrace();
		}
		return lista;
	}
}
