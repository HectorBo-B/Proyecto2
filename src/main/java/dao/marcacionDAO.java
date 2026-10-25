package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import config.Conexion;
import model.marcacion;

public class marcacionDAO {

	private static final DateTimeFormatter FORMATO = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

	//Clave unica de una marcacion: codigo + fecha y hora
	public static String clave(int codigo, LocalDateTime fechaHora) {
		return codigo + "|" + fechaHora.format(FORMATO);
	}

	//Devuelve las claves de las marcaciones ya guardadas entre dos fechas (paso 7)
	public Set<String> clavesExistentes(LocalDate desde, LocalDate hasta) throws SQLException {

		String sql = "SELECT CODIGO_MARCACION, FECHA, HORA FROM registros_asistencia "
				+ "WHERE FECHA BETWEEN ? AND ?";

		Set<String> claves = new HashSet<>();

		try (Connection con = Conexion.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			ps.setDate(1, Date.valueOf(desde));
			ps.setDate(2, Date.valueOf(hasta));

			try (ResultSet rs = ps.executeQuery()) {
				while (rs.next()) {

					LocalDateTime fechaHora = rs.getDate("FECHA").toLocalDate()
							.atTime(rs.getTime("HORA").toLocalTime());

					claves.add(clave(rs.getInt("CODIGO_MARCACION"), fechaHora));
				}
			}
		}

		return claves;
	}

	//Guarda las marcaciones correctas (paso 10). Devuelve cuantas se insertaron
	public int guardar(List<marcacion> lista) throws SQLException {

		//la clave unica UQ_REGISTRO (codigo, fecha, hora) evita repetidos
		String sql = "INSERT IGNORE INTO registros_asistencia "
				+ "(CODIGO_MARCACION, FECHA, HORA) VALUES (?, ?, ?)";

		int insertadas = 0;

		try (Connection con = Conexion.getConexion()) {

			con.setAutoCommit(false);

			try (PreparedStatement ps = con.prepareStatement(sql)) {

				for (marcacion m : lista) {
					ps.setInt(1, m.getCodigo());
					ps.setDate(2, Date.valueOf(m.getFechaHora().toLocalDate()));
					ps.setTime(3, Time.valueOf(m.getFechaHora().toLocalTime()));
					ps.addBatch();
				}

				for (int cuenta : ps.executeBatch()) {
					if (cuenta > 0 || cuenta == Statement.SUCCESS_NO_INFO) {
						insertadas++;
					}
				}

				con.commit();

			} catch (SQLException e) {
				con.rollback();
				throw e;
			}
		}

		return insertadas;
	}
}
