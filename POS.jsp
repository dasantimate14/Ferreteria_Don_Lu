<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
	String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
	String dbUser = "owner_ferreteria";
	String dbPass = "1234567";

    List<Map<String, Object>> disponibles = new ArrayList<>();
    try {
        Class.forName("oracle.jdbc.OracleDriver");
        try (Connection con = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
            String sql = "SELECT p.pro_nombre, p.pro_precio_u, p.pro_categoria, i.inv_id, i.inv_cantidad_disp " +
                         "FROM Producto p JOIN Inventario i ON p.pro_id = i.inv_producto";
            try (PreparedStatement ps = con.prepareStatement(sql);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("nombre", rs.getString("pro_nombre"));
                    item.put("precio", rs.getDouble("pro_precio_u"));
                    item.put("categoria", rs.getString("pro_categoria"));
                    item.put("inv_id", rs.getLong("inv_id"));
                    item.put("stock", rs.getInt("inv_cantidad_disp"));
                    disponibles.add(item);
                }
            }
        }
    } catch (Exception e) {
        out.println("<p style='color:red;'>Error al cargar inventario: " + e.getMessage() + "</p>");
    }

    List<Map<String, Object>> productos = (List<Map<String, Object>>) session.getAttribute("productos");
    if (productos == null) {
        productos = new ArrayList<>();
        session.setAttribute("productos", productos);
    }

    String action = request.getParameter("action");
    if ("add".equals(action)) {
        try {
            long invId = Long.parseLong(request.getParameter("inv_id"));
            int cantidad = Integer.parseInt(request.getParameter("productQuantity"));
            Map<String, Object> seleccionado = null;

            for (Map<String, Object> item : disponibles) {
                if (((Long) item.get("inv_id")) == invId) {
                    seleccionado = item;
                    break;
                }
            }

            if (seleccionado != null && cantidad <= (Integer) seleccionado.get("stock")) {
                Map<String, Object> producto = new HashMap<>();
                producto.put("id", System.currentTimeMillis());
                producto.put("inv_id", invId);
                producto.put("nombre", seleccionado.get("nombre"));
                producto.put("precio", seleccionado.get("precio"));
                producto.put("cantidad", cantidad);
                producto.put("categoria", seleccionado.get("categoria"));
                productos.add(producto);
            }
        } catch (Exception e) {
            out.println("<p style='color:red;'>Error al agregar producto: " + e.getMessage() + "</p>");
        }
    } else if ("delete".equals(action)) {
        try {
            long id = Long.parseLong(request.getParameter("id"));
            productos.removeIf(p -> ((Long)p.get("id")).equals(id));
        } catch (Exception ignored) {}
    } else if ("clear".equals(action)) {
        productos.clear();
    }

    double subtotal = 0;
    for (Map<String, Object> producto : productos) {
        double precio = (Double) producto.get("precio");
        int cantidad = (Integer) producto.get("cantidad");
        subtotal += precio * cantidad;
    }
    double itbms = subtotal * 0.07;
    double total = subtotal + itbms;

    if ("pagar".equals(action)) {
        String cliIdStr = request.getParameter("clientId");
        Integer empId = (Integer) session.getAttribute("emp_id");

        if (empId == null) {
            out.println("<p style='color:red;'>⚠️ No se encontró el ID del empleado en la sesión. Asegúrate de haber iniciado sesión correctamente.</p>");
        } else if (cliIdStr == null || cliIdStr.isEmpty()) {
            out.println("<p style='color:red;'>⚠️ El ID del cliente es obligatorio.</p>");
        } else if (productos.isEmpty()) {
            out.println("<p style='color:red;'>⚠️ No hay productos en la venta.</p>");
        } else {
            try {
                long cliId = Long.parseLong(cliIdStr);
                long venId = 0;

                Class.forName("oracle.jdbc.OracleDriver");
                try (Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass)) {
                    // REGISTRAR VENTA
                    try (CallableStatement cs = conn.prepareCall("{ call SP_REGISTRAR_VENTA(?, ?, ?, ?, ?) }")) {
                        cs.setLong(1, cliId);
                        cs.setInt(2, empId);
                        cs.setString(3, "Venta registrada desde POS.jsp");
                        cs.setDouble(4, subtotal);
                        cs.registerOutParameter(5, Types.NUMERIC);
                        cs.execute();
                        venId = cs.getLong(5);
                    }

                    // DETALLE DE VENTA
                    for (Map<String, Object> p : productos) {
                        try (CallableStatement csDet = conn.prepareCall("{ call SP_AGREGAR_DETALLE_VENTA(?, ?, ?) }")) {
                            csDet.setLong(1, venId);
                            csDet.setLong(2, (Long) p.get("inv_id"));
                            csDet.setInt(3, (Integer) p.get("cantidad"));
                            csDet.execute();
                        }
                    }

                    productos.clear();
                    session.setAttribute("mensaje_exito", "✅ Venta procesada exitosamente. ID Venta: " + venId);
                    response.sendRedirect("pos.jsp");
                    return;
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>❌ Error al procesar venta: " + e.getMessage() + "</p>");
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Registrar venta</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="css/pos.css">
</head>
<body>
<header>
  <div class="header-banner">
    <div class="header-logo-container">
      <div class="header-Logo">
        <img src="img/Logo.png" alt="logo" />
      </div>
      <h1 class="site-name">Ferreteria Don Lu</h1>
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

<div class="pos-container">
    <div class="pos-content">
        <div class="product-form-section">
            <h2>Agregar Producto</h2>
            <form method="post" action="pos.jsp" class="product-form">
                <input type="hidden" name="action" value="add">
                <div class="form-row">
                    <div class="form-group">
                        <label for="inv_id">Producto *</label>
                        <select name="inv_id" id="inv_id" required>
                            <option value="" disabled selected>Selecciona un producto</option>
                            <% for (Map<String, Object> item : disponibles) { %>
                                <option value="<%= item.get("inv_id") %>">
                                    <%= item.get("nombre") %> - $<%= item.get("precio") %> - Stock: <%= item.get("stock") %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="productQuantity">Cantidad *</label>
                        <input type="number" id="productQuantity" name="productQuantity" min="1" value="1" required>
                    </div>
                </div>
                <button type="submit" class="add-btn"><span>+</span> Agregar Producto</button>
            </form>
        </div>

        <div class="products-section">
            <div class="section-header">
                <h2>Productos en Venta (<%= productos.size() %>)</h2>
                <% if (!productos.isEmpty()) { %>
                    <form method="post" action="pos.jsp" style="display: inline;">
                        <input type="hidden" name="action" value="clear">
                        <button type="submit" class="clear-btn">Limpiar Todo</button>
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
                                <form method="post" action="pos.jsp" style="display: inline;">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<%= producto.get("id") %>">
                                    <button type="submit" class="delete-btn">Eliminar</button>
                                </form>
                            </div>
                        </div>
                    <% } %>
                <% } %>
            </div>
        </div>

      

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
		                <form method="post" action="pos.jsp">
		                    <input type="hidden" name="action" value="pagar">
		
		                    <!-- MOVIDO AQUÍ -->
		                    <div class="form-group">
		                        <label for="clientId">ID del Cliente *</label>
		                        <input type="number" id="clientId" name="clientId" min="1" required>
		                    </div>
		
		                    <button type="submit" class="payment-btn">Procesar Pago</button>
		                </form>
		            <% } else { %>
		                <button class="payment-btn" disabled>Procesar Pago</button>
		            <% } %>
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
          <a href="main_cajero.jsp">Inicio</a> |
          <a href="pos.jsp">Registrar venta</a> |
          <a href="registroCliente.jsp">Registrar clientes</a> |
          <a href="inventario.jsp">Inventario</a>
        </nav>
      </div>
    </footer>
</body>
</html>
