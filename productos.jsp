<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String mensaje = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        // Captura los valores del formulario
        String nombre = request.getParameter("pro_nombre");
        String descripcion = request.getParameter("pro_descripcion");
        String marca = request.getParameter("pro_marca");
        String precioUnitario = request.getParameter("pro_precio_u");
        String categoria = request.getParameter("pro_categoria");

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:XE", "owner_ferreteria", "1234567");

            // Ajusta este INSERT a la estructura real de tu tabla `productos`
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO productos (pro_nombre, pro_descripcion, pro_marca, pro_precio_u, pro_categoria) VALUES (?, ?, ?, ?, ?)");

            ps.setString(1, nombre);
            ps.setString(2, descripcion);
            ps.setString(3, marca);
            ps.setString(4, precioUnitario);
            ps.setString(5, categoria);

            ps.executeUpdate();
            mensaje = "Producto registrado exitosamente.";
            conn.close();
        } catch (Exception e) {
            mensaje = "Error al registrar el producto: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Productos</title>
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
                <h2>Eliminar Productos</h2>
                <form method="post" action="productos.jsp" class="product-form">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="pro_nombre">Nombre del producto *</label>
                            <input type="text" id="pro_nombre" name="pro_nombre" 
                                   placeholder="Ej: Tornillos" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label for="pro_id">ID del producto *</label>
                            <input type="number" id="pro_id" name="pro_id" class="form-input" required>
                        </div>
                    </div>
	                <div class="form-actions">
	                    <button type="submit" class="del-btn">Eliminar</button>
	                </div>
                </form>
                <p><%= mensaje %></p>
                
                <h2>Actualizar precio</h2>
                <form method="post" action="productos.jsp" class="product-form">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="pro_id">ID del producto *</label>
                            <input type="number" id="pro_id" name="pro_id" class="form-input" required>
                        </div>
                        <div class="form-group">
                            <label for="pro_precio_u">Precio *</label>
                            <input type="number" id="pro_precio_u" name="pro_precio_u" 
                                   class="form-input" required>
                        </div>
                    </div>
                    
	                <div class="form-actions">
	                    <button type="submit" class="upd-btn">Actualizar</button>
	                </div>
                </form>
                <p><%= mensaje %></p>
                
            </div>
                
		        <section class="form-section">
		            <h2 class="section-title">Registrar prodcuto</h2>
		            <form method="post" action="productos.jsp" class="form">
		                <div class="form-group">
		                    <label for="pro_nombre">Nombre:</label>
		                    <input type="text" id="pro_nombre" name="pro_nombre" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="pro_descripcion">Descripcion:</label>
		                    <input type="text" id="pro_descripcion" name="pro_descripcion" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="pro_marca">Marca:</label>
		                    <input type="text" id="pro_marca" name="pro_marca" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="pro_precio_u">Precio Unitario:</label>
		                    <input type="number" id="pro_precio_u" name="pro_precio_u" class="form-input" required>
		                </div>
		                <div class="form-group">
		                    <label for="pro_categoria">Categoria:</label>
		                    <input type="text" id="pro_categoria" name="pro_categoria" class="form-input" required>
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