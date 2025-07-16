<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%> <% try {
Class.forName("oracle.jdbc.driver.OracleDriver"); Connection conn =
DriverManager.getConnection(url, usuario, clave); Statement stmt =
conn.createStatement(); String sql = "SELECT inv_id, inv_producto,
inv_cantidad_disp FROM Inventario ORDER BY inv_id"; ResultSet rs =
stmt.executeQuery(sql); conn.close(); } catch (Exception e) { mensaje = "Error
al registrar: "; } %>

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Inventario</title>
    <link rel="stylesheet" href="css/styles.css" />
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
      rel="stylesheet"
    />
  </head>
  <body>
    <header>
      <!-- Seccion del header -->
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

    <main>
      <h2>Inventario</h2>

      <!-- Seccion del inventario -->
      <section>
        <table>
          <tr>
            <th>ID</th>
            <th>ID Producto</th>
            <th>Cantidad Disponible</th>
          </tr>

          <% while (rs.next()) { int id = rs.getInt("inv_id"); int producto =
          rs.getInt("inv_producto"); int cantidad =
          rs.getInt("inv_cantidad_disp"); %>
          <tr>
            <td><%= id %></td>
            <td><%= producto %></td>
            <td><%= cantidad %></td>
          </tr>
          <% } rs.close(); stmt.close(); conn.close(); } catch (Exception e) {
          %>
          <p style="color: red; text-align: center">
            Error: <%= e.getMessage() %>
          </p>
          <% } %>
        </table>
      </section>
    </main>

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
