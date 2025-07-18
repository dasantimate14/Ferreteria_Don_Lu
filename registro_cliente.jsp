<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String mensaje = "";
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String cli_nombre = request.getParameter("cli_nombre");
        String cli_apellido_paterno = request.getParameter("cli_apellido_paterno");
        String cli_apellido_materno = request.getParameter("cli_apellido_materno");
        String cli_email = request.getParameter("cli_email");
        String cli_direccion = request.getParameter("cli_direccion");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:XE", "owner_ferreteria", "1234567");

            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO clientes (nombre, apellido_paterno, apellido_materno, email, direccion) VALUES (?, ?, ?, ?, ?)");
            ps.setString(1, cli_nombre);
            ps.setString(2, cli_apellido_paterno);
            ps.setString(3, cli_apellido_materno);
            ps.setString(4, cli_email);
            ps.setString(5, cli_direccion);
            ps.executeUpdate();

            mensaje = "Cliente registrado exitosamente.";
            conn.close();
        } catch (Exception e) {
            mensaje = "Error al registrar: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Registrar Cliente</title>
    <link rel="stylesheet" href="css/formulario.css">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
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
          <a href="https://www.google.com/"><i class="fa-solid fa-magnifying-glass icons"></i></a>
          <i class="fa-brands fa-facebook icons"></i>
          <i class="fa-brands fa-instagram icons"></i>
          <i class="fa-brands fa-youtube icons"></i>
          <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
	    </div>
      </div>
      <nav class="main-nav">
	    <ul>
	      <li><a href="main_cajero.jsp">Inicio</a></li>
	      <li><a href="POS.jsp">Registrar venta</a></li>
	      <li><a href="registro_cliente.jsp">Registrar clientes</a></li>
	      <li><a href="Inventario.jsp">Inventario</a> </li>
	    </ul>
      </nav>
    </header>

<div class="container">
  <section class="form-section">
    <h2>Registrar cliente</h2>

    <% if (!mensaje.isEmpty()) { %>
      <p style="color: green; text-align:center;"><%= mensaje %></p>
    <% } %>

    <form method="post" action="register-client.jsp" class="form">
      <div class="form-group">
        <label for="cli_nombre" class="form-label">Nombre *</label>
        <input type="text" id="cli_nombre" name="cli_nombre" class="form-input" maxlength="100" required>
      </div>
      <div class="form-group">
        <label for="cli_apellido_paterno" class="form-label">Apellido Paterno *</label>
        <input type="text" id="cli_apellido_paterno" name="cli_apellido_paterno" class="form-input" maxlength="100" required>
      </div>
      <div class="form-group">
        <label for="cli_apellido_materno" class="form-label">Apellido Materno</label>
        <input type="text" id="cli_apellido_materno" name="cli_apellido_materno" class="form-input" maxlength="100">
      </div>
      <div class="form-group">
        <label for="cli_email" class="form-label">Email *</label>
        <input type="email" id="cli_email" name="cli_email" class="form-input" maxlength="150">
      </div>
      <div class="form-group">
        <label for="cli_direccion" class="form-label">Direccion *</label>
        <input id="cli_direccion" name="cli_direccion" class="form-input">
      </div>
      <div class="form-actions">
        <button type="submit" class="upd-btn">Registrar</button>
      </div>
    </form>
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
	        <a href="POS.jsp">Registrar venta</a> |
	        <a href="registro_cliente.jsp">Registrar clientes</a> |
	        <a href="Inventario.jsp">Inventario</a> 
       </nav>
      </div>
    </footer>
</body>
</html>