package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import config.ConexionS;
import model.usuario;

public class usuarioDAO {

	private static final String COLUMNAS =
			"ID_Usuario, NOMBRE, APELLIDO, Usuario, CORREO, ROL, ESTADO, FECHA_CREACION";

	//Convierte la fila actual del ResultSet en un Usuario
	private usuario leer(ResultSet rs) throws SQLException {

		usuario u = new usuario();
		u.setId(rs.getInt("ID_Usuario"));
		u.setNombre(rs.getString("NOMBRE"));
		u.setApellido(rs.getString("APELLIDO"));
		u.setUsuario(rs.getString("Usuario"));
		u.setCorreo(rs.getString("CORREO"));
		u.setRol(rs.getString("ROL"));
		u.setEstado(rs.getInt("ESTADO"));
		u.setFechaCreacion(rs.getTimestamp("FECHA_CREACION"));
		return u;
	}

	private int ejecutar(String sql, Object... parametros) throws SQLException {

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			for (int i = 0; i < parametros.length; i++) {
				ps.setObject(i + 1, parametros[i]);
			}
			return ps.executeUpdate();
		}
	}

	private Object valor(String sql, Object... parametros) throws SQLException {

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			for (int i = 0; i < parametros.length; i++) {
				ps.setObject(i + 1, parametros[i]);
			}
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getObject(1) : null;
			}
		}
	}

	//Lista todos los Usuarios (el administrador primero)
	public List<usuario> listar() throws SQLException {

		List<usuario> lista = new ArrayList<>();

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement("SELECT " + COLUMNAS
					 + " FROM Usuarios ORDER BY (ROL = 'ADMIN') DESC, ID_Usuario");
			 ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				lista.add(leer(rs));
			}
		}

		return lista;
	}

	//Busca un Usuario por su ID, o null si no existe
	public usuario buscarPorId(int id) throws SQLException {

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement("SELECT " + COLUMNAS
					 + " FROM Usuarios WHERE ID_Usuario = ?")) {

			ps.setInt(1, id);

			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? leer(rs) : null;
			}
		}
	}

	//Busca por nombre de Usuario e incluye la contraseña cifrada (solo para iniciar sesión)
	public usuario buscarParaLogin(String nombreUsuario) throws SQLException {

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement("SELECT " + COLUMNAS
					 + ", PASSWORD FROM Usuarios WHERE Usuario = ?")) {

			ps.setString(1, nombreUsuario);

			try (ResultSet rs = ps.executeQuery()) {

				if (!rs.next()) {
					return null;
				}

				usuario u = leer(rs);
				u.setClave(rs.getString("PASSWORD"));
				return u;
			}
		}
	}

	public boolean existeUsuario(String nombreUsuario, int excluirId) throws SQLException {
		return valor("SELECT 1 FROM Usuarios WHERE Usuario = ? AND ID_Usuario <> ?", nombreUsuario, excluirId) != null;
	}

	public boolean existeCorreo(String correo, int excluirId) throws SQLException {
		return valor("SELECT 1 FROM Usuarios WHERE CORREO = ? AND ID_Usuario <> ?", correo, excluirId) != null;
	}

	//Registra un Usuario nuevo con el rol OPERADOR (solo puede haber un administrador)
	public void crear(usuario u, String claveCifrada) throws SQLException {
		ejecutar("INSERT INTO Usuarios (NOMBRE, APELLIDO, Usuario, PASSWORD, CORREO, ROL, ESTADO) "
				+ "VALUES (?, ?, ?, ?, ?, 'OPERADOR', ?)",
				u.getNombre(), u.getApellido(), u.getUsuario(), claveCifrada, u.getCorreo(), u.getEstado());
	}

	//Modifica los datos del Usuario. El rol nunca se cambia. Si claveCifrada es null conserva la actual
	public void actualizar(usuario u, String claveCifrada) throws SQLException {

		if (claveCifrada == null) {
			ejecutar("UPDATE Usuarios SET NOMBRE = ?, APELLIDO = ?, Usuario = ?, CORREO = ?, ESTADO = ? "
					+ "WHERE ID_Usuario = ?",
					u.getNombre(), u.getApellido(), u.getUsuario(), u.getCorreo(), u.getEstado(), u.getId());
			return;
		}

		ejecutar("UPDATE Usuarios SET NOMBRE = ?, APELLIDO = ?, Usuario = ?, CORREO = ?, ESTADO = ?, PASSWORD = ? "
				+ "WHERE ID_Usuario = ?",
				u.getNombre(), u.getApellido(), u.getUsuario(), u.getCorreo(), u.getEstado(), claveCifrada, u.getId());
	}

	public void alternarEstado(int id) throws SQLException {
		ejecutar("UPDATE Usuarios SET ESTADO = 1 - ESTADO WHERE ID_Usuario = ?", id);
	}

	//El Usuario ya tiene registros en la auditoría (no se puede eliminar)
	public boolean tieneActividad(int id) throws SQLException {
		return valor("SELECT 1 FROM auditoria_acceso WHERE ID_Usuario = ? LIMIT 1", id) != null;
	}

	public void eliminar(int id) throws SQLException {
		ejecutar("DELETE FROM Usuarios WHERE ID_Usuario = ?", id);
	}
}