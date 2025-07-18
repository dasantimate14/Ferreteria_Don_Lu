<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Historial de Inventario</title>
  <link rel="stylesheet" href="css/tabla.css">
  <link rel="stylesheet" href="css/historial_inv.css">
</head>
<body>
  <header>
    <h1>Historial de Inventario</h1>
    <a href="enc_inventario.jsp" class="btn-secondary">← Volver al Inventario</a>
  </header>

<%
  String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
  String dbUser = "owner_ferreteria";
  String dbPass = "1234567";
  Class.forName("oracle.jdbc.OracleDriver");
  try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
       Statement  stmt = conn.createStatement()) {
%>

  <!-- 1) Tabla: Aumentos de Inventario -->
  <section>
    <h2>Ingresos (Aumentos)</h2>
    <table class="modern-table">
      <thead>
        <tr>
          <th>Fecha</th>
          <th>Producto</th>
          <th>Cantidad</th>
          <th>Pedido</th>
        </tr>
      </thead>
      <tbody>
      <%
        String sqlAum = 
          "SELECT * FROM V_AUMENTOS_INVENTARIO";
        ResultSet rsAum = stmt.executeQuery(sqlAum);
        while (rsAum.next()) {
          Timestamp fecha      = rsAum.getTimestamp("fecha");
          String    prod       = rsAum.getString("producto");
          int       cant       = rsAum.getInt("cantidad");
          String    refPedido  = rsAum.getString("referencia");
      %>
        <tr>
          <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm")
                      .format(fecha) %></td>
          <td><%= prod %></td>
          <td><%= cant %></td>
          <td><%= refPedido %></td>
        </tr>
      <%
        }
        rsAum.close();
      %>
      </tbody>
    </table>
  </section>

  <!-- 2) Tabla: Ventas -->
  <section>
    <h2>Salidas (Ventas)</h2>
    <table class="modern-table">
      <thead>
        <tr>
          <th>Fecha</th>
          <th>Producto</th>
          <th>Cantidad</th>
          <th>Precio Unitario</th>
          <th>Venta</th>
        </tr>
      </thead>
      <tbody>
      <%
        String sqlVen =
          "SELECT * FROM V_SALIDAS_INVENTARIO";
        ResultSet rsVen = stmt.executeQuery(sqlVen);
        while (rsVen.next()) {
          Timestamp fecha      = rsVen.getTimestamp("fecha");
          String    prod       = rsVen.getString("producto");
          int       cant       = rsVen.getInt("cantidad");
          double    precioU    = rsVen.getDouble("precio_unitario");
          String    refVenta   = rsVen.getString("referencia");
      %>
        <tr>
          <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm")
                      .format(fecha) %></td>
          <td><%= prod %></td>
          <td><%= cant %></td>
          <td>$<%= String.format("%.2f", precioU) %></td>
          <td><%= refVenta %></td>
        </tr>
      <%
        }
        rsVen.close();
      %>
      </tbody>
    </table>
  </section>

  <!-- 3) Resumen de Movimientos -->
  <section>
    <h2>Resumen de Movimientos</h2>
    <table class="modern-table">
      <thead>
        <tr>
          <th>Fecha</th>
          <th>Producto</th>
          <th>Tipo</th>
          <th>Cantidad</th>
        </tr>
      </thead>
      <tbody>
      <%
        String sqlMov =
          // ingresos
          "SELECT * FROM V_MOVIMIENTOS_INVENTARIO";
        ResultSet rsMov = stmt.executeQuery(sqlMov);
        while (rsMov.next()) {
          Timestamp fecha = rsMov.getTimestamp("fecha");
          String    prod  = rsMov.getString("producto");
          String    tipo  = rsMov.getString("tipo");
          int       cant  = rsMov.getInt("cantidad");
      %>
        <tr>
          <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm")
                      .format(fecha) %></td>
          <td><%= prod %></td>
          <td><%= tipo %></td>
          <td><%= cant %></td>
        </tr>
      <%
        }
        rsMov.close();
      %>
      </tbody>
    </table>
  </section>

<%
  } catch (Exception e) {
%>
  <section class="error-section">
    <p style="color:red;">Error al generar historial: <%= e.getMessage() %></p>
  </section>
<%
  }
%>

</body>
</html>

