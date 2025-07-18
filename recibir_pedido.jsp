<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Recibir Pedido</title>
</head>
<body>
<%
	String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
	String dbUser = "owner_ferreteria";
	String dbPass = "1234567";

  int pedidoId   = Integer.parseInt(request.getParameter("pedido_id"));
  int provId     = Integer.parseInt(request.getParameter("proveedor_id"));
  int invId      = Integer.parseInt(request.getParameter("inventario_id"));
  int cantRec    = Integer.parseInt(request.getParameter("cantidad_recibida"));

  Connection conn          = null;
  CallableStatement csReg  = null;
  CallableStatement csProc = null;
  String productName       = "";
  String providerName      = "";

  try {
    Class.forName("oracle.jdbc.OracleDriver");
    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

    // 1) Registrar la recepción
    csReg = conn.prepareCall("{ call SP_REGISTRAR_RECEPCION_PEDIDO(?,?,?) }");
    csReg.setInt(1, invId);
    csReg.setInt(2, pedidoId);
    csReg.setInt(3, cantRec);
    csReg.execute();

    // 2) Procesar recepciones del día para este pedido
    csProc = conn.prepareCall("{ call SP_PROCESAR_RECEPCIONES_PEDIDO(?,?) }");
    csProc.setInt(1, pedidoId);
    csProc.setInt(2, provId);
    csProc.execute();

    // 3) Obtener nombre de producto
    try (PreparedStatement psProd = conn.prepareStatement(
           "SELECT p.pro_nombre FROM Producto p " +
           "JOIN Inventario i ON i.inv_producto = p.pro_id " +
           "WHERE i.inv_id = ?")) {
      psProd.setInt(1, invId);
      try (ResultSet rs = psProd.executeQuery()) {
        if (rs.next()) productName = rs.getString("pro_nombre");
      }
    }

    // 4) Obtener nombre de proveedor
    try (PreparedStatement psProv = conn.prepareStatement(
           "SELECT prv_nombre FROM Proveedor WHERE prv_id = ?")) {
      psProv.setInt(1, provId);
      try (ResultSet rs = psProv.executeQuery()) {
        if (rs.next()) providerName = rs.getString("prv_nombre");
      }
    }

    // 5) Mostrar alerta y redirigir
%>
    <script>
      alert("Se registraron <%= cantRec %> unidades de “<%= productName %>” del proveedor “<%= providerName %>”.");
      window.location = "enc_inventario.jsp";
    </script>
<%
    return;
  }
  catch(Exception e) {
%>
    <div class="error-section">
      <h3>Error al procesar recepción:</h3>
      <p><%= e.getMessage() %></p>
      <p><a href="enc_inventario.jsp">Volver al inventario</a></p>
    </div>
<%
  }
  finally {
    try { if (csReg  != null) csReg.close();  } catch (Exception ignore) {}
    try { if (csProc != null) csProc.close(); } catch (Exception ignore) {}
    try { if (conn   != null) conn.close();  } catch (Exception ignore) {}
  }
%>
</body>
</html>


