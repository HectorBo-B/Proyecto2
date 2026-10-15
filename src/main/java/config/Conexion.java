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
	
	private Connection connection;
	
}
