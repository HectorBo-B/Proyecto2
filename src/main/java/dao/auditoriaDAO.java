package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import config.ConexionS;
import jakarta.servlet.http.HttpSession;
import model.auditoria;
import model.usuario;

public class auditoriaDAO {

	//Guarda un registro de auditoría
	public void registrar(int idUsuario, String accion, String descripcion) throws SQLException {

		String texto = descripcion == null ? "" : descripcion;

		if (texto.length() > 255) {
			texto = texto.substring(0, 255);
		}

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement(
					 "INSERT INTO auditoria_acceso (ID_USUARIO, ACCION, DESCRIPCION) VALUES (?, ?, ?)")) {

			ps.setInt(1, idUsuario);
			ps.setString(2, accion);
			ps.setString(3, texto);
			ps.executeUpdate();
		}
	}

	//Registra la acción del usuario que tiene la sesión abierta.
	//Si falla, solo lo muestra en consola para no interrumpir la operación principal
	public static void registrarSeguro(HttpSession sesion, String accion, String descripcion) {

		usuario u = sesion == null ? null : (usuario) sesion.getAttribute(usuario.SESION);

		if (u == null) {
			return;
		}

		try {
			new auditoriaDAO().registrar(u.getId(), accion, descripcion);

		} catch (SQLException e) {
			e.printStackTrace();
		}
	}

	//Últimos registros de auditoría, del más reciente al más antiguo
	public List<auditoria> listar(int limite) throws SQLException {

		String sql = "SELECT a.ID_AUDITORIA, u.USUARIO, a.ACCION, a.DESCRIPCION, a.FECHA "
				+ "FROM auditoria_acceso a "
				+ "INNER JOIN usuarios u ON u.ID_USUARIO = a.ID_USUARIO "
				+ "ORDER BY a.FECHA DESC, a.ID_AUDITORIA DESC LIMIT ?";

		List<auditoria> lista = new ArrayList<>();

		try (Connection con = ConexionS.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setInt(1, limite);

			try (ResultSet rs = ps.executeQuery()) {

				while (rs.next()) {
					auditoria a = new auditoria();
					a.setId(rs.getInt(1));
					a.setUsuario(rs.getString(2));
					a.setAccion(rs.getString(3));
					a.setDescripcion(rs.getString(4));
					a.setFecha(rs.getTimestamp(5));
					lista.add(a);
				}
			}
		}

		return lista;
	}
}