<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Inventario de Productos</title>
    <link rel="stylesheet" href="css/tabla.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  </head>
  
  <body>
    <!-- Sección del header -->
    <header>
      <div class="header-banner">
        <div class="header-logo-container">
          <div class="header-Logo">
            <img src="img/Logo.png" alt="logo" />
          </div>
          <h1 class="site-name">Ferretería Don Lu</h1>
        </div>
        <div class="group-icons">
          <a href="#"><i class="fa-solid fa-magnifying-glass icons"></i></a>
          <i class="fa-brands fa-facebook icons"></i>
          <i class="fa-brands fa-instagram icons"></i>
          <i class="fa-brands fa-youtube icons"></i>
          <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
        </div>
      </div>
	  <nav class="main-nav">
	    <ul>
	      <li><a href="main_cajero.jsp">Inicio</a></li>
	      <li><a href="pos.jsp">Registrar venta</a></li>
	      <li><a href="registroCliente.jsp">Registrar clientes</a></li>
	      <li><a href="inventario.jsp">Inventario</a> </li>
	    </ul>
	  </nav>
    </header>

    <div class="container">
      <section class="table-section">
        <div class="table-header">
          <h2>Lista de Productos</h2>
        </div>

        <div class="table-container">
          <table class="modern-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Producto</th>
                <th>Categoría</th>
                <th>Cantidad Disponible</th>
              </tr>
            </thead>
            <tbody>
              <%
                try {
                    Class.forName("oracle.jdbc.OracleDriver");

                    String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
                    String dbUser = "owner_ferreteria";
                    String dbPass = "1234567"; 

                    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                    String sql = "SELECT * FROM VISTA_INV_DETALLADO_CAJA";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        int id = rs.getInt("inv_id");
                        String producto = rs.getString("pro_nombre");
                        String categoria = rs.getString("cat_nombre");
                        int cantidad = rs.getInt("inv_cantidad_disp");

                        String cantidadClass;
                        if (cantidad == 0) {
                            cantidadClass = "quantity-empty";
                        } else if (cantidad < 10) {
                            cantidadClass = "quantity-low";
                        } else if (cantidad < 50) {
                            cantidadClass = "quantity-medium";
                        } else {
                            cantidadClass = "quantity-high";
                        }
              %>
              <tr>
                <td class="id-cell"><%= id %></td>
                <td class="product-cell"><%= producto %></td>
                <td class="category-cell"><%= categoria %></td>
                <td class="quantity-cell">
                  <span class="quantity-badge <%= cantidadClass %>"><%= cantidad %></span>
                </td>
              </tr>
              <%
                    }
                    rs.close();
                    ps.close();
                    conn.close();
                } catch (Exception e) {
              %>
              <tr>
                <td colspan="4" class="text-red text-center">
                  Error: <%= e.getMessage() %>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
      </section>
    </div>

	<!-- Seccion del Footer -->
    <footer>
      <div class="copyright">
        <p>&copy; Ferreteria Don Lu. Todos los derechos reservados.</p>
      <div class="div-logout">
        	<a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
      </div>
        <nav>
          <a href="main_cajero.jsp">Inicio</a> |
          <a href="pos.jsp">Registrar venta</a> |
          <a href="registroCliente.jsp">Registrar clientes</a> |
          <a href="inventario.jsp">Inventario</a>
        </nav>
      </div>
    </footer>
  </body>
</html>
