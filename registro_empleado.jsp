<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%> <%@ page import="java.sql.*" %> <% String mensaje = "";
if ("POST".equalsIgnoreCase(request.getMethod())) { String nombre =
request.getParameter("emp_nombre"); String apellido =
request.getParameter("emp_apellido"); String puesto =
request.getParameter("emp_puesto"); String salario =
request.getParameter("emp_salario"); String direccion =
request.getParameter("emp_direccion"); String email =
request.getParameter("emp_email"); String password =
request.getParameter("emp_password"); try {
Class.forName("com.mysql.cj.jdbc.Driver"); Connection conn =
DriverManager.getConnection("jdbc:mysql://localhost:3307/programacion", "root",
""); PreparedStatement ps = conn.prepareStatement( "INSERT INTO empleados
(nombre, apellido, puesto, salario, direccion, email, password) VALUES (?, ?, ?,
?, ?, ?, ?)"); ps.setString(1, nombre); ps.setString(2, apellido);
ps.setString(3, puesto); ps.setString(4, salario); ps.setString(5, direccion);
ps.setString(6, email); ps.setString(7, password); ps.executeUpdate(); mensaje =
"Empleado registrado exitosamente."; conn.close(); } catch (Exception e) {
mensaje = "Error al registrar el empleado: " + e.getMessage(); } } %>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Gestión de Empleados</title>
    <link rel="stylesheet" href="css/formulario.css" />
    <link
      href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
      rel="stylesheet"
    />
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

    <main class="container">
      <div class="upd-content">
        <!-- Formulario para actualizar empleados -->
        <div class="form-section">
          <h2>Eliminar Empleado</h2>
          <form method="post" action="POS.jsp" class="product-form">
            <input type="hidden" name="action" value="add" />

            <div class="form-row">
              <div class="form-group">
                <label for="productName">Nombre del empleado *</label>
                <input
                  type="text"
                  id="emp_nombre"
                  name="emp_nombre"
                  placeholder="Ej: Pedro"
                  class="form-input"
                  required
                />
              </div>
              <div class="form-group">
                <label for="productPrice">ID del empleado *</label>
                <input
                  type="number"
                  id="emp_id"
                  name="emp_id"
                  class="form-input"
                  required
                />
              </div>
            </div>

            <div class="form-actions">
              <button type="submit" class="del-btn">Eliminar</button>
            </div>
          </form>
          <p><%= mensaje %></p>

          <h2>Actualizar Empleado</h2>
          <form method="post" action="POS.jsp" class="product-form">
            <input type="hidden" name="action" value="add" />

            <div class="form-row">
              <div class="form-group">
                <label for="productPrice">ID del empleado *</label>
                <input
                  type="number"
                  id="emp_id"
                  name="emp_id"
                  class="form-input"
                  required
                />
              </div>
              <div class="form-group">
                <label for="productName">Salario *</label>
                <input
                  type="number"
                  id="emp_salario"
                  name="emp_salario"
                  class="form-input"
                  required
                />
              </div>
              <div class="form-group">
                <label for="productName">Puesto *</label>
                <input
                  type="text"
                  id="emp_puesto"
                  name="emp_puesto"
                  class="form-input"
                  required
                />
              </div>
            </div>

            <div class="form-actions">
              <button type="submit" class="upd-btn">Actualizar</button>
            </div>
          </form>
          <p><%= mensaje %></p>
        </div>

        <section class="form-section">
          <h2 class="section-title">Registrar Empleado</h2>
          <form method="post" action="empleado.jsp" class="form">
            <div class="form-group">
              <label for="emp_nombre">Nombre:</label>
              <input
                type="text"
                id="emp_nombre"
                name="emp_nombre"
                class="form-input"
                required
              />
            </div>
            <div class="form-group">
              <label for="emp_apellido">Apellido:</label>
              <input
                type="text"
                id="emp_apellido"
                name="emp_apellido"
                class="form-input"
                required
              />
            </div>
            <div class="form-group">
              <label for="emp_puesto">Puesto:</label>
              <input
                type="text"
                id="emp_puesto"
                name="emp_puesto"
                class="form-input"
                required
              />
            </div>
            <div class="form-group">
              <label for="emp_salario">Salario:</label>
              <input
                type="number"
                id="emp_salario"
                name="emp_salario"
                class="form-input"
                required
              />
            </div>
            <div class="form-group">
              <label for="emp_direccion">Dirección:</label>
              <input
                type="text"
                id="emp_direccion"
                name="emp_direccion"
                class="form-input"
                required
              />
            </div>
            <div class="form-group">
              <label for="emp_email">Email:</label>
              <input
                type="email"
                id="emp_email"
                name="emp_email"
                class="form-input"
                required
              />
            </div>
            <div class="form-group">
              <label for="emp_password">Contraseña:</label>
              <input
                type="password"
                id="emp_password"
                name="emp_password"
                class="form-input"
                required
              />
            </div>
            <div class="form-actions">
              <button type="submit" class="upd-btn">Registrar</button>
            </div>
          </form>
          <p><%= mensaje %></p>
        </section>
      </div>
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
