<%@ page language="java"
         contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%
    String dbURL    = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUser   = "owner_ferreteria";
    String dbPass   = "1234567";

    // Título dinámico
    String tablaSel = request.getParameter("tabla");
    if (tablaSel == null || tablaSel.isEmpty()) tablaSel = "inventario";
    String titulo;
    switch (tablaSel) {
      case "inventario":  titulo = "Lista de Productos";       break;
      case "ventas":      titulo = "Historial de Ventas";     break;
      case "clientes":    titulo = "Lista de Clientes";       break;
      case "categorias":  titulo = "Categorías de Productos"; break;
      case "proveedores": titulo = "Lista de Proveedores";    break;
      default:
        titulo = "Lista de Productos";
        tablaSel = "inventario";
    }

    // Métricas
    int totalTx = 0;
    double totalV = 0;
    String prodTop = "No disponible";
    try {
      Class.forName("oracle.jdbc.OracleDriver");
      Connection c = DriverManager.getConnection(dbURL, dbUser, dbPass);

      try (PreparedStatement p = c.prepareStatement("SELECT COUNT(*) FROM Venta");
           ResultSet r = p.executeQuery()) {
        if (r.next()) totalTx = r.getInt(1);
      }
      try (PreparedStatement p = c.prepareStatement("SELECT SUM(ven_monto) FROM Venta");
           ResultSet r = p.executeQuery()) {
        if (r.next()) totalV = r.getDouble(1);
      }
      try (PreparedStatement p = c.prepareStatement("SELECT FN_PRODUCTO_MAS_VENDIDO FROM dual");
           ResultSet r = p.executeQuery()) {
        if (r.next()) prodTop = r.getString(1);
      }
      c.close();
    } catch (Exception e) {
      prodTop = "Error: " + e.getMessage();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Reporte de Ventas – Ferretería Don Lu</title>
  <link rel="stylesheet" href="css/styles.css">
  <link rel="stylesheet" href="css/tabla.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
        rel="stylesheet">
</head>
<body>
<header>
    <div class="header-banner">
      <div class="header-logo-container">
        <div class="header-Logo">
          <img src="img/Logo.png" alt="logo" />
        </div>
        <h1 class="site-name">Ferretería Don Lu</h1>
      </div>
      <div class="group-icons">
        <a href="#"><i class="fa-solid fa-magnifying-glass icons"></i></a>
        <i class="fa-brands fa-facebook icons"></i>
        <i class="fa-brands fa-instagram icons"></i>
        <i class="fa-brands fa-youtube icons"></i>
        <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
      </div>
    </div>
  </header>
    <nav class="main-nav">
      <ul>
        <li><a href="main_gerente.jsp">Inicio</a></li>
        <li><a href="registro_empleado.jsp">Registrar empleado</a></li>
        <li><a class="active" href="resumenVenta.jsp">Reporte de ventas</a></li>
        <li><a href="auditoria.jsp">Reporte de auditoria</a></li>
      </ul>
    </nav>

  <div class="container">
    <section class="table-section">
      <div class="table-header">
        <h2><%= titulo %></h2>
        <section class="metrics-flex">
          <div class="notification">
            <div class="notification-title">Transacciones</div>
            <div class="notification-text">
              Cantidad total: <strong><%= totalTx %></strong>
            </div>
          </div>
          <div class="notification">
            <div class="notification-title">Ventas Totales</div>
            <div class="notification-text">
              Monto acumulado: 
              <strong>$<%= String.format("%.2f", totalV) %></strong>
            </div>
          </div>
          <div class="notification">
            <div class="notification-title">Producto Más Vendido</div>
            <div class="notification-text">
              Nombre: <strong><%= prodTop %></strong>
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
              Connection c2 = DriverManager.getConnection(dbURL, dbUser, dbPass);

              String sql = "SELECT inv_id, pro_nombre, cat_nombre, inv_cantidad_disp "
                         + "FROM VISTA_INV_DETALLADO_CAJA ORDER BY inv_id";
              PreparedStatement ps = c2.prepareStatement(sql);
              ResultSet rs = ps.executeQuery();
              while (rs.next()) {
          %>
            <tr>
              <td class="id-cell"><%= rs.getInt("inv_id") %></td>
              <td class="product-cell">
                <div class="product-info">
                  <span class="product-name">
                    <%= rs.getString("pro_nombre") %>
                  </span>
                </div>
              </td>
              <td class="product-cell"><%= rs.getString("cat_nombre") %></td>
              <td class="quantity-cell">
                <%= rs.getInt("inv_cantidad_disp") %>
              </td>
            </tr>
          <%
              }
              rs.close(); ps.close(); c2.close();
            } catch (Exception e) {
          %>
            <tr>
              <td colspan="4" class="text-red">
                Error al cargar datos: <%= e.getMessage() %>
              </td>
            </tr>
          <%
            }
          %>
          </tbody>
        </table>
      </div>
    </section>
  </div>

  <!-- Footer -->
  <footer>
    <div class="copyright">
      <p>&copy; Ferretería Don Lu. Todos los derechos reservados.</p>
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


