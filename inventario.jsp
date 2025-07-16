<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Inventario de Productos</title>
    <link rel="stylesheet" href="css/tabla.css" />
  </head>
  <body>
    <!-- Seccion del header -->
    <header>
      <div class="header-banner">
        <div class="header-logo-container">
          <div class="header-Logo">
            <img src="img/Logo.png" alt="logo" />
          </div>
          <h1 class="site-name">Ferreteria Don Lu</h1>
        </div>
        <div class="group-icons">
          <a href="https://www.google.com/"
            ><i class="fa-solid fa-magnifying-glass icons"></i
          ></a>
          <i class="fa-brands fa-facebook icons"></i>
          <i class="fa-brands fa-instagram icons"></i>
          <i class="fa-brands fa-youtube icons"></i>
          <a href="login.jsp"
            ><i class="fa-solid fa-right-to-bracket icon-login"></i
          ></a>
        </div>
      </div>
      <nav class="main-nav">
        <ul>
          <li><a href="main_cajero.jsp">Inicio</a></li>
          <li><a href="POS.jsp">Registrar venta</a></li>
          <li><a href="registro_cliente.jsp">Registrar clientes</a></li>
          <li><a href="Inventario.jsp">Inventario</a></li>
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
                <th>ID Producto</th>
                <th>Cantidad Disponible</th>
              </tr>
            </thead>
            <tbody>
              <% try { Class.forName("oracle.jdbc.driver.OracleDriver");
              Connection conn =
              DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521/XEPDB1",
              "system", "oracle"); Statement stmt = conn.createStatement();
              ResultSet rs = stmt.executeQuery("SELECT * FROM Inventario");
              while (rs.next()) { int id = rs.getInt("inv_id"); int producto =
              rs.getInt("inv_producto"); int cantidad =
              rs.getInt("inv_cantidad_disp"); // Definir clase CSS según
              cantidad String cantidadClass; if (cantidad == 0) { cantidadClass
              = "quantity-empty"; } else if (cantidad < 10) { cantidadClass =
              "quantity-low"; } else if (cantidad < 50) { cantidadClass =
              "quantity-medium"; } else { cantidadClass = "quantity-high"; } %>
              <tr>
                <td class="id-cell"><%= id %></td>
                <td class="product-cell">
                  <div class="product-info">
                    <span class="product-name">Producto #<%= producto %></span>
                    <span class="product-code">Código: <%= producto %></span>
                  </div>
                </td>
                <td class="quantity-cell">
                  <span class="quantity-badge <%= cantidadClass %>"
                    ><%= cantidad %></span
                  >
                </td>
              </tr>
              <% } rs.close(); stmt.close(); conn.close(); } catch (Exception e)
              { %>
              <tr>
                <td colspan="3" style="color: red; text-align: center">
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
          <a href="login.jsp"
            ><i class="fa-solid fa-right-to-bracket icon-login"></i
          ></a>
        </div>
        <nav>
          <a href="main_cajero.jsp">Inicio</a> |
          <a href="POS.jsp">Registrar venta</a> |
          <a href="registro_cliente.jsp">Registrar clientes</a> |
          <a href="Inventario.jsp">Inventario</a>
        </nav>
      </div>
    </footer>
  </body>
</html>
