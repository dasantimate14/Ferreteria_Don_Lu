<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String tablaSeleccionada = request.getParameter("tabla");
    if (tablaSeleccionada == null || tablaSeleccionada.isEmpty()) {
        tablaSeleccionada = "auditoria"; // Por defecto muestra auditoría
    }

    String tituloTabla = "";
    switch (tablaSeleccionada) {
        case "auditoria": tituloTabla = "Registro de Auditoría"; break;
        case "inventario": tituloTabla = "Lista de Productos"; break;
        case "ventas": tituloTabla = "Historial de Ventas"; break;
        case "clientes": tituloTabla = "Lista de Clientes"; break;
        case "categorias": tituloTabla = "Categorías de Productos"; break;
        case "proveedores": tituloTabla = "Lista de Proveedores"; break;
        default: tituloTabla = "Lista de Productos"; tablaSeleccionada = "inventario";
    }

    String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUser = "owner_ferreteria";
    String dbPass = "1234567";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title><%= tituloTabla %></title>
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
      <h1 class="site-name">Ferretería Don Lu</h1>
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
      <div class="table-selector">
        <form method="GET" action="auditoria.jsp">
          <label for="tabla">Seleccionar Auditoria:</label>
          <select name="tabla" id="tabla" onchange="this.form.submit()">
            <option value="auditoria" <%= "auditoria".equals(tablaSeleccionada) ? "selected" : "" %>>Auditoría</option>
            <option value="inventario" <%= "inventario".equals(tablaSeleccionada) ? "selected" : "" %>>Inventario</option>
            <option value="ventas" <%= "ventas".equals(tablaSeleccionada) ? "selected" : "" %>>Ventas</option>
            <option value="clientes" <%= "clientes".equals(tablaSeleccionada) ? "selected" : "" %>>Clientes</option>
            <option value="categorias" <%= "categorias".equals(tablaSeleccionada) ? "selected" : "" %>>Categorías</option>
          </select>
          <noscript><input type="submit" value="Ver" class="btn-change"></noscript>
        </form>
      </div>
    </div>

    <div class="table-container">
      <% try {
          Class.forName("oracle.jdbc.OracleDriver");
          Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
          Statement stmt = conn.createStatement();
          ResultSet rs = null;

          if ("auditoria".equals(tablaSeleccionada)) {
              rs = stmt.executeQuery("SELECT * FROM V_AUDITORIA_GENERAL");
      %>
      <table class="modern-table">
        <thead><tr><th>Tabla</th><th>Usuario</th><th>Operación</th><th>Fecha</th></tr></thead>
        <tbody>
          <% while (rs.next()) { %>
          <tr>
            <td><%= rs.getString("tabla") %></td>
            <td><%= rs.getString("usuario") %></td>
            <td><%= rs.getString("operacion") %></td>
            <td><%= rs.getTimestamp("fecha_operacion") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
      <% } else if ("inventario".equals(tablaSeleccionada)) {
              rs = stmt.executeQuery("SELECT * FROM AUD_INVENTARIO"); %>
      <table class="modern-table">
        <thead><tr><th>ID</th><th>Producto</th><th>Cantidad</th><th>Monto</th><th>Operación</th><th>Usuario</th><th>Fecha</th></tr></thead>
        <tbody>
          <% while (rs.next()) { %>
          <tr>
            <td><%= rs.getInt("inv_id") %></td>
            <td><%= rs.getInt("inv_producto") %></td>
            <td><%= rs.getInt("inv_cantidad_disp") %></td>
            <td><%= rs.getDouble("monto_afectado") %></td>
            <td><%= rs.getString("operacion") %></td>
            <td><%= rs.getString("usuario") %></td>
            <td><%= rs.getTimestamp("fecha_operacion") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
      <% } else if ("ventas".equals(tablaSeleccionada)) {
              rs = stmt.executeQuery("SELECT * FROM AUD_VENTA"); %>
      <table class="modern-table">
        <thead><tr><th>ID</th><th>Cliente</th><th>Empleado</th><th>Comentario</th><th>Monto</th><th>Operación</th><th>Usuario</th><th>Fecha</th></tr></thead>
        <tbody>
          <% while (rs.next()) { %>
          <tr>
            <td><%= rs.getInt("ven_id") %></td>
            <td><%= rs.getInt("ven_cliente") %></td>
            <td><%= rs.getInt("ven_emp") %></td>
            <td><%= rs.getString("ven_comentario") %></td>
            <td><%= rs.getDouble("monto_afectado") %></td>
            <td><%= rs.getString("operacion") %></td>
            <td><%= rs.getString("usuario") %></td>
            <td><%= rs.getTimestamp("fecha_operacion") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
      <% } else if ("clientes".equals(tablaSeleccionada)) {
              rs = stmt.executeQuery("SELECT * FROM AUD_CLIENTE"); %>
      <table class="modern-table">
        <thead><tr><th>ID</th><th>Nombre</th><th>Apellido Paterno</th><th>Apellido Materno</th><th>Email</th><th>Dirección</th><th>Operación</th><th>Usuario</th><th>Fecha</th></tr></thead>
        <tbody>
          <% while (rs.next()) { %>
          <tr>
            <td><%= rs.getInt("cli_id") %></td>
            <td><%= rs.getString("cli_nombre") %></td>
            <td><%= rs.getString("cli_apellido_paterno") %></td>
            <td><%= rs.getString("cli_apellido_materno") %></td>
            <td><%= rs.getString("cli_email") %></td>
            <td><%= rs.getString("cli_direccion") %></td>
            <td><%= rs.getString("operacion") %></td>
            <td><%= rs.getString("usuario") %></td>
            <td><%= rs.getTimestamp("fecha_operacion") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
      <% } else if ("categorias".equals(tablaSeleccionada)) {
              rs = stmt.executeQuery("SELECT * FROM AUD_CATEGORIA"); %>
      <table class="modern-table">
        <thead><tr><th>ID</th><th>Nombre</th><th>Operación</th><th>Usuario</th><th>Fecha</th></tr></thead>
        <tbody>
          <% while (rs.next()) { %>
          <tr>
            <td><%= rs.getInt("cat_id") %></td>
            <td><%= rs.getString("cat_nombre") %></td>
            <td><%= rs.getString("operacion") %></td>
            <td><%= rs.getString("usuario") %></td>
            <td><%= rs.getTimestamp("fecha_operacion") %></td>
          </tr>
          <% } %>
        </tbody>
      </table>
      <% } else {
          out.println("<p>Tabla no implementada.</p>");
      }
        rs.close(); stmt.close(); conn.close();
        } catch (Exception e) {
          out.println("<p>Error: " + e.getMessage() + "</p>");
        }
      %>
    </div>
  </section>
</div>

<footer>
  <div class="copyright">
    <p>&copy; Ferretería Don Lu. Todos los derechos reservados.</p>
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
