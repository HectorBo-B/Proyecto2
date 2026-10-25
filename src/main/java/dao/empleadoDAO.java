package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import config.Conexion;
import model.empleado.codigoMarcacion;
import model.empleado;

public class empleadoDAO {

	private static final String COLUMNAS =
			"ID_PERSONAL, CEDULA, NOMBRE, APELLIDO, CODIGO_MARCACION, TURNO, ESTADO, FECHA_REGISTRO";

	//Convierte la fila actual del ResultSet en un empleado
	private empleado leer(ResultSet rs) throws SQLException {

		empleado emp = new empleado();
		emp.setEmpleadoID(rs.getInt("ID_PERSONAL"));
		emp.setCedula(rs.getString("CEDULA"));
		emp.setNombre(rs.getString("NOMBRE"));
		emp.setApellido(rs.getString("APELLIDO"));
		emp.setCodM(rs.getInt("CODIGO_MARCACION"));
		emp.setTurno(rs.getString("TURNO"));
		emp.setEstado(rs.getInt("ESTADO"));
		emp.setFechaReg(rs.getTimestamp("FECHA_REGISTRO"));
		return emp;
	}

	//Ejecuta un INSERT, UPDATE o DELETE con sus parametros
	private int ejecutar(String sql, Object... parametros) throws SQLException {

		try (Connection con = Conexion.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			for (int i = 0; i < parametros.length; i++) {
				ps.setObject(i + 1, parametros[i]);
			}
			return ps.executeUpdate();
		}
	}

	//Ejecuta un SELECT que devuelve un solo valor (null si no hay filas)
	private Object valor(String sql, Object... parametros) throws SQLException {

		try (Connection con = Conexion.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql)) {

			for (int i = 0; i < parametros.length; i++) {
				ps.setObject(i + 1, parametros[i]);
			}
			try (ResultSet rs = ps.executeQuery()) {
				return rs.next() ? rs.getObject(1) : null;
			}
		}
	}

	//Lista todos los empleados
	public List<empleado> listar() throws SQLException {

		List<empleado> lista = new ArrayList<>();

		try (Connection con = Conexion.getConexion();
			 PreparedStatement ps = con.prepareStatement("SELECT " + COLUMNAS + " FROM personal ORDER BY ID_PERSONAL");
			 ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				lista.add(leer(rs));
			}
		}

		return lista;
	}

	//Lista todos los codigos de marcacion indicando que empleado los usa
	public List<codigoMarcacion> listarCodigos() throws SQLException {

		String sql = "SELECT c.CODIGO_MARCACION, c.TURNO, p.ID_PERSONAL "
				+ "FROM codigos_marcacion c "
				+ "LEFT JOIN personal p ON p.CODIGO_MARCACION = c.CODIGO_MARCACION "
				+ "ORDER BY c.CODIGO_MARCACION";

		List<codigoMarcacion> lista = new ArrayList<>();

		try (Connection con = Conexion.getConexion();
			 PreparedStatement ps = con.prepareStatement(sql);
			 ResultSet rs = ps.executeQuery()) {

			while (rs.next()) {
				lista.add(new codigoMarcacion(rs.getInt(1), rs.getString(2), rs.getInt(3)));
			}
		}

		return lista;
	}

	//La cedula ya la usa otro empleado
	public boolean existeCedula(String cedula, int excluirId) throws SQLException {
		return valor("SELECT 1 FROM personal WHERE CEDULA = ? AND ID_PERSONAL <> ?", cedula, excluirId) != null;
	}

	//Turno de un codigo, o null si el codigo no existe
	public String turnoDeCodigo(int codigo) throws SQLException {
		Object turno = valor("SELECT TURNO FROM codigos_marcacion WHERE CODIGO_MARCACION = ?", codigo);
		return turno == null ? null : turno.toString();
	}

	//El codigo ya esta asignado a otro empleado
	public boolean codigoUsado(int codigo, int excluirId) throws SQLException {
		return valor("SELECT 1 FROM personal WHERE CODIGO_MARCACION = ? AND ID_PERSONAL <> ?", codigo, excluirId) != null;
	}

	//Primer codigo libre del turno, 0 si no queda ninguno
	public int primerCodigoDisponible(String turno) throws SQLException {

		Object codigo = valor("SELECT c.CODIGO_MARCACION FROM codigos_marcacion c "
				+ "WHERE c.TURNO = ? AND NOT EXISTS "
				+ "(SELECT 1 FROM personal p WHERE p.CODIGO_MARCACION = c.CODIGO_MARCACION) "
				+ "ORDER BY c.CODIGO_MARCACION LIMIT 1", turno);

		return codigo == null ? 0 : ((Number) codigo).intValue();
	}

	//Crea un codigo de marcacion nuevo
	public void crearCodigo(int codigo, String turno) throws SQLException {
		ejecutar("INSERT INTO codigos_marcacion (CODIGO_MARCACION, TURNO) VALUES (?, ?)", codigo, turno);
	}

	//Registra un empleado nuevo (activo). El ID y la fecha los genera la base de datos
	public void crear(empleado emp) throws SQLException {
		ejecutar("INSERT INTO personal (CEDULA, NOMBRE, APELLIDO, CODIGO_MARCACION, TURNO, ESTADO) "
				+ "VALUES (?, ?, ?, ?, ?, 1)",
				emp.getCedula(), emp.getNombre(), emp.getApellido(), emp.getCodM(), emp.getTurno());
	}

	//Modifica los datos de un empleado
	public void actualizar(empleado emp) throws SQLException {
		ejecutar("UPDATE personal SET CEDULA = ?, NOMBRE = ?, APELLIDO = ?, CODIGO_MARCACION = ?, TURNO = ? "
				+ "WHERE ID_PERSONAL = ?",
				emp.getCedula(), emp.getNombre(), emp.getApellido(), emp.getCodM(), emp.getTurno(),
				emp.getEmpleadoID());
	}

	//Activa o desactiva a un empleado
	public void alternarEstado(int id) throws SQLException {
		ejecutar("UPDATE personal SET ESTADO = 1 - ESTADO WHERE ID_PERSONAL = ?", id);
	}

	//Elimina a un empleado
	public void eliminar(int id) throws SQLException {
		ejecutar("DELETE FROM personal WHERE ID_PERSONAL = ?", id);
	}

	//Devuelve los empleados indexados por su codigo de marcacion (usado al importar)
	public Map<Integer, empleado> mapaPorCodigoMarcacion() throws SQLException {

		Map<Integer, empleado> mapa = new HashMap<>();

		for (empleado emp : listar()) {

			//si dos empleados tuvieran el mismo codigo, se conserva el primero
			if (emp.getCodM() != 0 && !mapa.containsKey(emp.getCodM())) {
				mapa.put(emp.getCodM(), emp);
			}
		}

		return mapa;
	}
}
