package config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionS {
	
	//URL, usuario y contraseña
	private static final String url = "jdbc:mysql://localhost:3306/proy2_seguridad";
	private static final String user =  "root";
	private static final String password = "";
	
	
	private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
	
	private Connection connection;
	
	public static Connection getConexion() throws SQLException{
		
		return DriverManager.getConnection(url, user, password);
	}
	
}
