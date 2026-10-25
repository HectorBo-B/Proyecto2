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
	
	public static Connection getConexion() throws SQLException{
		
		//carga el driver de MySQL; si falla, el jar no esta en WEB-INF/lib
		try {
			Class.forName(DRIVER);
		} catch (ClassNotFoundException e) {
			throw new SQLException("No se encontro el driver de MySQL (" + DRIVER
					+ "). Verifica que el jar este en WEB-INF/lib.", e);
		}
		
		return DriverManager.getConnection(url, user, password);
	}
	
}
