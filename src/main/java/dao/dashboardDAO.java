package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

import config.Conexion;
import config.ConexionS;
import model.auditoria;
import model.dashboard;
import model.empleado;
import model.reporteAsistencia;

public class dashboardDAO
{
    private static final int ULTIMOS = 10;
    private static final String PREFIJO_ARCHIVO = "Importó el archivo ";

    private final reporteDAO reportes = new reporteDAO();

    public dashboard obtener() throws SQLException
    {
        dashboard resumen = new dashboard();
        List<empleado> personal = reportes.buscar("");

        resumen.setEmpleados(personal.size());
        cargarRegistros(resumen);

        if (resumen.getDesde() != null)
        {
            for (empleado emp : personal)
            {
                reporteAsistencia reporte = reportes.generar(emp, resumen.getDesde(), resumen.getHasta());

                resumen.sumar(reporte.getAusencias(), reporte.getTardanzas(), reporte.getSegundosTardanza());
            }
            cargarUltimos(resumen);
        }

        cargarUltimoProceso(resumen);
        return resumen;
    }

    private void cargarRegistros(dashboard resumen) throws SQLException
    {
        String sql = "SELECT COUNT(*), MIN(FECHA), MAX(FECHA) FROM registros_asistencia";

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            if (rs.next())
            {
                resumen.setRegistros(rs.getLong(1));

                if (rs.getDate(2) != null)
                {
                    resumen.setDesde(rs.getDate(2).toLocalDate());
                    resumen.setHasta(rs.getDate(3).toLocalDate());
                }
            }
        }
    }

    private void cargarUltimos(dashboard resumen) throws SQLException
    {
        String sql = "SELECT r.CODIGO_MARCACION, r.FECHA, r.HORA, p.NOMBRE, p.APELLIDO, p.TURNO "
                + "FROM registros_asistencia r "
                + "LEFT JOIN personal p ON p.CODIGO_MARCACION = r.CODIGO_MARCACION "
                + "ORDER BY r.FECHA DESC, r.HORA DESC LIMIT " + ULTIMOS;

        try (Connection con = Conexion.getConexion();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery())
        {
            while (rs.next())
            {
                String nombre = rs.getString("NOMBRE") == null ? "" : rs.getString("NOMBRE") + " " + rs.getString("APELLIDO");

                resumen.agregar(new dashboard.registro(nombre, rs.getInt("CODIGO_MARCACION"), rs.getString("TURNO"),
                        rs.getDate("FECHA").toLocalDate(), rs.getTime("HORA").toLocalTime()));
            }
        }
    }

    private void cargarUltimoProceso(dashboard resumen) throws SQLException
    {
        String sql = "SELECT FECHA, DESCRIPCION FROM auditoria_acceso WHERE ACCION = ? "
                + "ORDER BY FECHA DESC, ID_AUDITORIA DESC LIMIT 1";

        try (Connection con = ConexionS.getConexion();
             PreparedStatement ps = con.prepareStatement(sql))
        {
            ps.setString(1, auditoria.IMPORTACION);

            try (ResultSet rs = ps.executeQuery())
            {
                if (rs.next())
                {
                    Timestamp fecha = rs.getTimestamp("FECHA");
                    String descripcion = rs.getString("DESCRIPCION") == null ? "" : rs.getString("DESCRIPCION");

                    resumen.setUltimoProceso(fecha);
                    resumen.setUltimoArchivo(descripcion.startsWith(PREFIJO_ARCHIVO)
                            ? descripcion.substring(PREFIJO_ARCHIVO.length()) : descripcion);
                }
            }
        }
    }
}