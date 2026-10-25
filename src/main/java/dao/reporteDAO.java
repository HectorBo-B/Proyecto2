package dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import config.Conexion;
import model.empleado;
import model.reporteAsistencia;

public class reporteDAO
{
    private static final String COLUMNAS =
            "ID_PERSONAL, CEDULA, NOMBRE, APELLIDO, CODIGO_MARCACION, TURNO, ESTADO, FECHA_REGISTRO";

    private static final LocalTime INICIO_MANANA = LocalTime.of(6, 0);
    private static final LocalTime FIN_MANANA = LocalTime.of(12, 0);
    private static final LocalTime INICIO_TARDE = LocalTime.of(12, 0);
    private static final LocalTime FIN_TARDE = LocalTime.of(17, 20);

    private empleado leer(ResultSet rs) throws SQLException
    {
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

    public List<empleado> buscar(String texto) throws SQLException
    {
        boolean filtra = texto != null && !texto.isEmpty();
        String sql = "SELECT " + COLUMNAS + " FROM personal";

        if (filtra)
        {
            sql += " WHERE CEDULA LIKE ? OR CAST(CODIGO_MARCACION AS CHAR) LIKE ?"
                    + " OR CONCAT(NOMBRE, ' ', APELLIDO) LIKE ? OR CONCAT(APELLIDO, ' ', NOMBRE) LIKE ?";
        }
        sql += " ORDER BY NOMBRE, APELLIDO";

        List<empleado> lista = new ArrayList<>();

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql))
        {
            if (filtra)
            {
                String patron = "%" + texto.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%";

                for (int i = 1; i <= 4; i++)
                {
                    ps.setString(i, patron);
                }
            }

            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    lista.add(leer(rs));
                }
            }
        }
        return lista;
    }

    public empleado obtener(int id) throws SQLException
    {
        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement("SELECT " + COLUMNAS + " FROM personal WHERE ID_PERSONAL = ?"))
        {
            ps.setInt(1, id);

            try (ResultSet rs = ps.executeQuery())
            {
                return rs.next() ? leer(rs) : null;
            }
        }
    }

    private LocalTime[] horario(String turno)
    {
        return "T".equals(turno)
                ? new LocalTime[] {INICIO_TARDE, FIN_TARDE}
                : new LocalTime[] {INICIO_MANANA, FIN_MANANA};
    }

    private Map<LocalDate, List<LocalTime>> marcaciones(int codigo, LocalDate desde, LocalDate hasta) throws SQLException
    {
        String sql = "SELECT FECHA, HORA FROM registros_asistencia "
                + "WHERE CODIGO_MARCACION = ? AND FECHA BETWEEN ? AND ? ORDER BY FECHA, HORA";

        Map<LocalDate, List<LocalTime>> marcas = new TreeMap<>();

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql))
        {
            ps.setInt(1, codigo);
            ps.setDate(2, Date.valueOf(desde));
            ps.setDate(3, Date.valueOf(hasta));

            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    marcas.computeIfAbsent(rs.getDate("FECHA").toLocalDate(), clave -> new ArrayList<>())
                            .add(rs.getTime("HORA").toLocalTime());
                }
            }
        }
        return marcas;
    }

    private Map<LocalDate, String[]> observaciones(int idPersonal, LocalDate desde, LocalDate hasta) throws SQLException
    {
        String sql = "SELECT FECHA, OBSERVACION, JUSTIFICADA FROM observaciones_asistencia "
                + "WHERE ID_PERSONAL = ? AND FECHA BETWEEN ? AND ?";

        Map<LocalDate, String[]> notas = new TreeMap<>();

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql))
        {
            ps.setInt(1, idPersonal);
            ps.setDate(2, Date.valueOf(desde));
            ps.setDate(3, Date.valueOf(hasta));

            try (ResultSet rs = ps.executeQuery())
            {
                while (rs.next())
                {
                    notas.put(rs.getDate("FECHA").toLocalDate(),
                            new String[] {rs.getString("OBSERVACION"), String.valueOf(rs.getInt("JUSTIFICADA"))});
                }
            }
        }
        return notas;
    }

    public reporteAsistencia generar(empleado emp, LocalDate desde, LocalDate hasta) throws SQLException
    {
        LocalTime[] horario = horario(emp.getTurno());
        Map<LocalDate, List<LocalTime>> marcas = marcaciones(emp.getCodM(), desde, hasta);
        Map<LocalDate, String[]> notas = observaciones(emp.getEmpleadoID(), desde, hasta);
        reporteAsistencia reporte = new reporteAsistencia(emp, desde, hasta);
        LocalDate hoy = LocalDate.now();

        for (LocalDate fecha = desde; !fecha.isAfter(hasta); fecha = fecha.plusDays(1))
        {
            reporteAsistencia.dia registro = new reporteAsistencia.dia(fecha);
            List<LocalTime> horas = marcas.get(fecha);

            if (horas != null)
            {
                LocalTime primera = horas.get(0);

                if (horas.size() > 1)
                {
                    registro.setEntrada(primera);
                    registro.setSalida(horas.get(horas.size() - 1));
                }
                else if (primera.isBefore(horario[1]))
                {
                    registro.setEntrada(primera);
                }
                else
                {
                    registro.setSalida(primera);
                }
            }

            if (!registro.isFinDeSemana())
            {
                boolean incompleto = registro.getEntrada() == null || registro.getSalida() == null;

                if (incompleto && fecha.isBefore(hoy))
                {
                    registro.setAusente(true);
                }
                else if (registro.getEntrada() != null && registro.getEntrada().isAfter(horario[0]))
                {
                    registro.setTardanzaSegundos(Duration.between(horario[0], registro.getEntrada()).getSeconds());
                }
            }

            String[] nota = notas.get(fecha);

            if (nota != null)
            {
                registro.setObservacion(nota[0]);
                registro.setJustificada("1".equals(nota[1]));
            }

            reporte.agregar(registro);
        }
        return reporte;
    }

    public int guardarObservaciones(int idPersonal, List<LocalDate> fechas, String texto, boolean justificada) throws SQLException
    {
        String sql = texto.isEmpty()
                ? "DELETE FROM observaciones_asistencia WHERE ID_PERSONAL = ? AND FECHA = ?"
                : "INSERT INTO observaciones_asistencia (ID_PERSONAL, FECHA, OBSERVACION, JUSTIFICADA) VALUES (?, ?, ?, ?) "
                + "ON DUPLICATE KEY UPDATE OBSERVACION = VALUES(OBSERVACION), JUSTIFICADA = VALUES(JUSTIFICADA)";

        try (Connection con = Conexion.getConexion())
        {
            con.setAutoCommit(false);

            try (PreparedStatement ps = con.prepareStatement(sql))
            {
                for (LocalDate fecha : fechas)
                {
                    ps.setInt(1, idPersonal);
                    ps.setDate(2, Date.valueOf(fecha));

                    if (!texto.isEmpty())
                    {
                        ps.setString(3, texto);
                        ps.setInt(4, justificada ? 1 : 0);
                    }
                    ps.addBatch();
                }
                ps.executeBatch();
                con.commit();
            }
            catch (SQLException e)
            {
                con.rollback();
                throw e;
            }
        }
        return fechas.size();
    }
}