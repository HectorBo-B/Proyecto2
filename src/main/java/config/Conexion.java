package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class Conexion {
	
	//URL, usuario y contraseña
	private static final String url = "jdbc:mysql://localhost:3306/proy2_asistencia";
	private static final String user =  "root";
	private static final String password = "";
	private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
	
	public static Connection getConexion() throws SQLException{
		try {
			Class.forName(DRIVER);
		} catch (ClassNotFoundException e) {
			throw new SQLException("No se encontró el driver de MySQL en el classpath de Tomcat", e);
		}
		return DriverManager.getConnection(url, user, password);
	}
	
	
}
