<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<%
    // Inicializar lista de productos en sesión si no existe
    List<Map<String, Object>> productos = (List<Map<String, Object>>) session.getAttribute("productos");
    if (productos == null) {
        productos = new ArrayList<>();
        session.setAttribute("productos", productos);
    }
    
    // Procesar formulario si se envió
    String action = request.getParameter("action");
    if ("add".equals(action)) {
        String nombre = request.getParameter("productName");
        String precioStr = request.getParameter("productPrice");
        String cantidadStr = request.getParameter("productQuantity");
        String categoria = request.getParameter("productCategory");
        
        if (nombre != null && 
            precioStr != null && cantidadStr != null) {
            try {
                double precio = Double.parseDouble(precioStr);
                int cantidad = Integer.parseInt(cantidadStr);
                
                Map<String, Object> producto = new HashMap<>();
                producto.put("nombre", nombre.trim());
                producto.put("precio", precio);
                producto.put("cantidad", cantidad);
                producto.put("categoria", categoria);
                producto.put("id", System.currentTimeMillis()); // ID único simple
                
                productos.add(producto);
            } catch (NumberFormatException e) {
                // Manejar error de formato
            }
        }
    } else if ("delete".equals(action)) {
        String idStr = request.getParameter("id");
        if (idStr != null) {
            try {
                long id = Long.parseLong(idStr);
                productos.removeIf(p -> ((Long)p.get("id")).equals(id));
            } catch (NumberFormatException e) {
                // Manejar error
            }
        }
    } else if ("clear".equals(action)) {
        productos.clear();   
    }
    
    // Calcular totales
    double subtotal = 0;
    for (Map<String, Object> producto : productos) {
        double precio = (Double) producto.get("precio");
        int cantidad = (Integer) producto.get("cantidad");
        subtotal += precio * cantidad;
    }
    double itbms = subtotal * 0.16;
    double total = subtotal + itbms;
    
    if ("pagar".equals(action)) {
        String cliIdStr = request.getParameter("clientId");
        if (cliIdStr != null && !productos.isEmpty()) {
            try {
                long cliId = Long.parseLong(cliIdStr);
                long venId = System.currentTimeMillis(); // usar como ID simple
                String url = "jdbc:oracle:thin:@localhost:1521:xe"; // Ajusta según tu conexión
                String usuario = "tu_usuario";
                String clave = "tu_clave";

                Class.forName("oracle.jdbc.driver.OracleDriver");
                try (Connection conn = DriverManager.getConnection(url, usuario, clave)) {
                    String sql = "INSERT INTO Venta (ven_id, ven_cliente, ven_emp, ven_subtotal, ven_monto) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement stmt = conn.prepareStatement(sql);
                    stmt.setLong(1, venId);
                    stmt.setLong(2, cliId);
                    stmt.setInt(3, 1); // ID de empleado (puedes obtenerlo desde sesión o quemado)
                    stmt.setDouble(4, subtotal);
                    stmt.setDouble(5, total);
                    stmt.executeUpdate();

                    // Insertar detalle de cada producto
                    for (Map<String, Object> p : productos) {
                        long invId = 1; // Deberías mapear esto con el inventario real
                        String sqlDetalle = "INSERT INTO Detalle_venta (dev_venta, dev_inventario, dev_precio_u, dev_prod_vend, status) VALUES (?, ?, ?, ?, ?)";
                        PreparedStatement stmtDet = conn.prepareStatement(sqlDetalle);
                        stmtDet.setLong(1, venId);
                        stmtDet.setLong(2, invId); // ID real de inventario
                        stmtDet.setDouble(3, (Double)p.get("precio"));
                        stmtDet.setInt(4, (Integer)p.get("cantidad"));
                        stmtDet.setString(5, "P");
                        stmtDet.executeUpdate();
                    }

                    productos.clear(); // Limpia productos después del pago
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error al procesar pago: " + e.getMessage() + "</p>");
            }
        }
    }
    
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registrar venta</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/pos.css">
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
          <li><a href="home.html">Inicio</a></li>
          <li><a href="internacionales.html">Internacionales</a></li>
          <li><a href="deportivas.html">Deportivas</a></li>
          <li><a href="contactanos.html">Contactanos</a></li>
        </ul>
      </nav>
    </header>
    
    <div class="pos-container">
        <div class="pos-content">
            <!-- Formulario para agregar productos -->
            <div class="product-form-section">
                <h2>Agregar Producto</h2>
                <form method="post" action="POS.jsp" class="product-form">
                    <input type="hidden" name="action" value="add">
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="productName">Nombre del Producto *</label>
                            <input type="text" id="productName" name="productName" 
                                   placeholder="Ej: Coca Cola" required>
                        </div>
                        <div class="form-group">
                            <label for="productPrice">Precio Unitario *</label>
                            <input type="number" id="productPrice" name="productPrice" 
                                  	min="0" placeholder="0.00" required>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="productQuantity">Cantidad *</label>
                            <input type="number" id="productQuantity" name="productQuantity" 
                                   min="1" value="1" required>
                        </div>
                        <div class="form-group">
                            <label for="productCategory">Categoría</label>
                            <select id="productCategory" name="productCategory">
                                <option value="bebidas">Bebidas</option>
                                <option value="comida">Comida</option>
                                <option value="snacks">Snacks</option>
                                <option value="otros">Otros</option>
                            </select>
                        </div>
                    </div>
                    
                    <button type="submit" class="add-btn">
                        <span>+</span> Agregar Producto
                    </button>
                </form>
            </div>


            <!-- Lista de productos -->
            <div class="products-section">
                <div class="section-header">
                    <h2>Productos en Venta (<%= productos.size() %>)</h2>
                    <% if (!productos.isEmpty()) { %>
                        <form method="post" action="POS.jsp" style="display: inline;">
                            <input type="hidden" name="action" value="clear">
                            <button type="submit" class="clear-btn">
                                Limpiar Todo
                            </button>
                        </form>
                    <% } %>
                </div>
                
                <div class="products-list">
                    <% if (productos.isEmpty()) { %>
                        <div class="empty-state">
                            <p>No hay productos agregados</p>
                            <span>Agrega productos usando el formulario</span>
                        </div>
                    <% } else { %>
                        <% for (Map<String, Object> producto : productos) { %>
                            <div class="product-item">
                                <div class="product-info">
                                    <div class="product-name"><%= producto.get("nombre") %></div>
                                    <div class="product-details">
                                        Cantidad: <%= producto.get("cantidad") %> × 
                                        $<%= String.format("%.2f", (Double)producto.get("precio")) %>
                                        <span class="product-category"><%= producto.get("categoria") %></span>
                                    </div>
                                </div>
                                <div class="product-price">
                                    $<%= String.format("%.2f", (Double)producto.get("precio") * (Integer)producto.get("cantidad")) %>
                                </div>
                                <div class="product-actions">
                                    <form method="post" action="POS.jsp" style="display: inline;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= producto.get("id") %>">
                                        <button type="submit" class="delete-btn">
                                            Eliminar
                                        </button>
                                    </form>
                                </div>
                            </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
            
                        
            <div class="form-group">
			    <label for="clientId">ID del Cliente *</label>
			    <input type="number" id="clientId" name="clientId" min="1" required>
			</div>
        </div>

        <!-- Resumen de venta -->
        <div class="sale-summary">
            <div class="summary-content">
                <div class="summary-details">
                    <div class="summary-item">
                        <span>Subtotal:</span>
                        <span>$<%= String.format("%.2f", subtotal) %></span>
                    </div>
                    <div class="summary-item">
                        <span>ITBMS (7%):</span>
                        <span>$<%= String.format("%.2f", itbms) %></span>
                    </div>
                    <div class="summary-item total">
                        <span>Total:</span>
                        <span>$<%= String.format("%.2f", total) %></span>
                    </div>
                </div>
                <div class="summary-actions">
					<% if (!productos.isEmpty()) { %>
					    <!-- CAMBIO: Botón Procesar Pago con formulario -->
					    <form method="post" action="POS.jsp">
					        <input type="hidden" name="action" value="pagar">
					        <input type="hidden" name="clientId" value="<%= request.getParameter("clientId") %>">
					        <button type="submit" class="payment-btn">
					            Procesar Pago
					        </button>
					    </form>
					<% } else { %>
					    <button class="payment-btn" disabled>
					        Procesar Pago
					    </button>
					<% } %>
                </div>
            </div>
        </div>
    </div>
    
        <!-- Seccion del Footer -->
    <footer>
      <div class="copyright">
        <p>&copy; Ferreteria Don Lu. Todos los derechos reservados.</p>
      <div class="div-logout">
        	<a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
      </div>
       <nav>
	        <a href="index.html">Inicio</a> |
	        <a href="registro-profesores.jsp">Registro de Profesores</a> |
	        <a href="registro-estudiantes.jsp">Registro de Estudiantes</a> |
	        <a href="calendario.html">Calendario</a> |
	        <a href="soporte.html">Soporte</a> 
       </nav>
      </div>
    </footer>

    <script>
        function procesarPago(total) {
            if (confirm('Total a pagar: $' + total.toFixed(2) + '\n\n¿Procesar el pago?')) {
                alert('¡Pago procesado exitosamente!\n\nTotal: $' + total.toFixed(2));
                // Aquí podrías redirigir a una página de confirmación
                 window.location.href = 'HOME.html';
            }
        }
    </script>
</body>
</html>