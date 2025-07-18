<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String mensaje = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Captura los valores del formulario
        String nombre = request.getParameter("prv_nombre");
        String nombreContacto = request.getParameter("prv_nombre_contacto");
        String email = request.getParameter("prv_email");
        String telefono = request.getParameter("prv_telefono");
        String direccion = request.getParameter("prv_direccion");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:XE", "owner_ferreteria", "1234567");

            // Ajusta este INSERT a la estructura real de tu tabla `proveedores`
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO proveedores (prv_nombre, prv_nombre_contacto, prv_email, prv_telefono, prv_direccion) VALUES (?, ?, ?, ?, ?)");

            ps.setString(1, nombre);
            ps.setString(2, nombreContacto);
            ps.setString(3, email);
            ps.setString(4, telefono);
            ps.setString(5, direccion);

            ps.executeUpdate();
            mensaje = "Proveedor registrado exitosamente.";
            conn.close();
        } catch (Exception e) {
            mensaje = "Error al registrar el proveedor: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de proveedor</title>
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
    
    <main class="container">
            <div class="upd-content">
            <!-- Formulario para actualizar empleados -->
            <div class="form-section">
                <h2>Eliminar Proveedor</h2>
                <form method="post" action="proveedor.jsp" class="product-form">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="prv_nombre">Nombre del proveedor *</label>
                            <input type="text" id="prv_nombre" name="prv_nombre" 
                                   placeholder="Ej: Coches" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label for="prv_id">ID del proveedor *</label>
                            <input type="number" id="prv_id" name="prv_id" class="form-input" required>
                        </div>
                    </div>
                    
                    
	                <div class="form-actions">
	                    <button type="submit" class="del-btn">Eliminar</button>
	                </div>
                </form>
                <p><%= mensaje %></p>
                
            </div>
                
		        <section class="form-section">
		            <h2 class="section-title">Registrar proveedor</h2>
		            <form method="post" action="proveedor.jsp" class="form">
		                <div class="form-group">
		                    <label for="prv_nombre">Nombre:</label>
		                    <input type="text" id="prv_nombre" name="prv_nombre" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="prv_nombre_contacto">Nombre del contacto:</label>
		                    <input type="text" id="prv_nombre_contacto" name="prv_nombre_contacto" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="prv_email">Email:</label>
		                    <input type="text" id="prv_email" name="prv_email" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="prv_telefono">Telefono:</label>
		                    <input type="number" id="prv_telefono" name="prv_telefono" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="prv_direccion">Dirección:</label>
		                    <input type="text" id="prv_direccion" name="prv_direccion" class="form-input" required>
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