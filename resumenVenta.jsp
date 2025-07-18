<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
	String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
	String dbUser = "owner_ferreteria";
	String dbPass = "1234567";

    String tablaSeleccionada = request.getParameter("tabla");
    if (tablaSeleccionada == null || tablaSeleccionada.isEmpty()) {
        tablaSeleccionada = "inventario";
    }

    String tituloTabla = "";
    switch (tablaSeleccionada) {
        case "inventario": tituloTabla = "Lista de Productos"; break;
        case "ventas": tituloTabla = "Historial de Ventas"; break;
        case "clientes": tituloTabla = "Lista de Clientes"; break;
        case "categorias": tituloTabla = "Categorías de Productos"; break;
        case "proveedores": tituloTabla = "Lista de Proveedores"; break;
        default: tituloTabla = "Lista de Productos"; tablaSeleccionada = "inventario";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario de Productos</title>
    <link rel="stylesheet" href="css/tabla.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
<header>
  <div class="header-banner">
    <div class="header-logo-container">
      <div class="header-Logo">
        <img src="img/Logo.png" alt="logo" />
      </div>
      <h1 class="site-name">Ferreteria Don Lu</h1>
    </div>
    <div class="group-icons">
      <a href="https://www.google.com/"><i class="fa-solid fa-magnifying-glass icons"></i></a>
      <i class="fa-brands fa-facebook icons"></i>
      <i class="fa-brands fa-instagram icons"></i>
      <i class="fa-brands fa-youtube icons"></i>
      <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
    </div>
  </div>
  <nav class="main-nav">
    <ul>
	      <li><a href="main_gerente.jsp">Inicio</a></li>
	      <li><a href="registro_empleado.jsp">Registrar empleado</a></li>
	      <li><a href="resumenVenta.jsp">Reporte de ventas</a></li>
	      <li><a href="auditoria.jsp">Reporte de auditoria</a></li>
    </ul>
  </nav>
</header>
<div class="container">
  <section class="table-section">
    <div class="table-header">
      <h2><%= tituloTabla %></h2>
      <section class="metrics-flex">
<%
  int totalTransacciones = 0;
  double totalVentas = 0.0;
  String productoMasVendido = "No disponible";
  try {
    Class.forName("oracle.jdbc.OracleDriver");
    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

    // Total de transacciones
    PreparedStatement ps1 = conn.prepareStatement("SELECT COUNT(*) FROM Venta");
    ResultSet rs1 = ps1.executeQuery();
    if (rs1.next()) totalTransacciones = rs1.getInt(1);
    rs1.close(); ps1.close();

    // Total de ventas
    PreparedStatement ps2 = conn.prepareStatement("SELECT SUM(ven_monto) FROM Venta");
    ResultSet rs2 = ps2.executeQuery();
    if (rs2.next()) totalVentas = rs2.getDouble(1);
    rs2.close(); ps2.close();

    // Producto más vendido usando la función FN_PRODUCTO_MAS_VENDIDO
    PreparedStatement ps3 = conn.prepareStatement("SELECT FN_PRODUCTO_MAS_VENDIDO FROM dual");
    ResultSet rs3 = ps3.executeQuery();
    if (rs3.next()) productoMasVendido = rs3.getString(1);
    rs3.close(); ps3.close();

    conn.close();
  } catch (Exception e) {
    out.println("<p class='text-red'>Error al cargar indicadores: " + e.getMessage() + "</p>");
  }
%>
        <div class="notification flex-1">
          <div class="notification-content">
            <div class="notification-title">Transacciones</div>
            <div class="notification-text">Cantidad total: <strong><%= totalTransacciones %></strong></div>
          </div>
        </div>
        <div class="notification flex-1">
          <div class="notification-content">
            <div class="notification-title">Ventas Totales</div>
            <div class="notification-text">Monto acumulado: <strong>$<%= String.format("%.2f", totalVentas) %></strong></div>
          </div>
        </div>
        <div class="notification flex-1">
          <div class="notification-content">
            <div class="notification-title">Producto Más Vendido</div>
            <div class="notification-text">Nombre: <strong><%= productoMasVendido %></strong></div>
          </div>
        </div>
      </section>
    </div>
    <div class="table-container">
      <table class="modern-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>Producto</th>
            <th>Categoría</th>
            <th>Stock Disponible</th>
          </tr>
        </thead>
        <tbody>
<%
  try {
    Class.forName("oracle.jdbc.OracleDriver");
    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
    if (tablaSeleccionada.equals("inventario")) {
      String sql = "SELECT * FROM VISTA_INV_DETALLADO_CAJA";
      PreparedStatement ps = conn.prepareStatement(sql);
      ResultSet rs = ps.executeQuery();
      while (rs.next()) {
        int id = rs.getInt("inv_id");
        String nombre = rs.getString("pro_nombre");
        String categoria = rs.getString("cat_nombre");
        int stock = rs.getInt("inv_cantidad_disp");
%>
          <tr>
            <td class="id-cell"><%= id %></td>
            <td class="product-cell">
              <div class="product-info">
                <span class="product-name"><%= nombre %></span>
              </div>
            </td>
            <td class="product-cell"><%= categoria %></td>
            <td class="quantity-cell"><%= stock %></td>
          </tr>
<%
      }
      rs.close(); ps.close();
    }
    conn.close();
  } catch (Exception e) {
    out.println("<tr><td colspan='4' class='text-red'>Error al cargar datos: " + e.getMessage() + "</td></tr>");
  }
%>
        </tbody>
      </table>
    </div>
  </section>
</div>
<footer>
  <div class="copyright">
    <p>&copy; Ferreteria Don Lu. Todos los derechos reservados.</p>
    <div class="div-logout">
      <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
    </div>
    <nav>
	        <a href="main_gerente.jsp">Inicio</a> |
	        <a href="registro_empleado.jsp">Registrar empleado</a> |
	        <a href="resumenVenta.jsp">Reporte de ventas</a> |
	        <a href="auditoria.jsp">Reporte de auditoria</a> 
    </nav>
  </div>
</footer>
</body>
</html>


