<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.net.URLEncoder" %>

<!DOCTYPE html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Inventario de Productos</title>
    <link rel="stylesheet" href="css/styles.css" />
    <link rel="stylesheet" href="css/tabla.css" />
    <link rel="stylesheet" href="css/enc_inventario.css" />
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
          <li><a href="main_enc_inven.jsp">Inicio</a></li>
          <li><a href="enc_inventario.jsp">Inventario</a></li>
          <li><a href="solicitud_reabastecimiento.jsp">Solicitar reabastecimiento</a></li>
          <li><a href="agregar_proveedor.jsp">Agregar proveedor</a></li>
        </ul>
      </nav>
    </header>

    <div class="container">
      <section class="table-section">
        <div class="table-header">
          <h2>Lista de Productos</h2>
        </div>

        <div class="container">
        <!-- Panel de Resumen -->
        <section class="dashboard-summary">
            <div class="summary-cards">
                <%
                String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
                String dbUser = "owner_ferreteria";
                String dbPass = "1234567";

                try {
                    Class.forName("oracle.jdbc.OracleDriver");
                    Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
                    Statement stmt = conn.createStatement();

                    ResultSet rsStats = stmt.executeQuery(
                    		"SELECT * FROM V_INVENTARIO_RESUMEN"
                    );

                    if (rsStats.next()) {
                        int totalProductos = rsStats.getInt("total_productos");
                        int totalStock = rsStats.getInt("total_stock");
                        int productosAgotados = rsStats.getInt("productos_agotados");
                        int productosCriticos = rsStats.getInt("productos_criticos");
                %>
                <div class="summary-card">
                    <div class="card-icon">
                        <i class="fa-solid fa-boxes-stacked"></i>
                    </div>
                    <div class="card-content">
                        <h3><%= totalProductos %></h3>
                        <p>Total Productos</p>
                    </div>
                </div>

                <div class="summary-card">
                    <div class="card-icon">
                        <i class="fa-solid fa-warehouse"></i>
                    </div>
                    <div class="card-content">
                        <h3><%= totalStock %></h3>
                        <p>Stock Total</p>
                    </div>
                </div>

                <div class="summary-card alert">
                    <div class="card-icon">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <div class="card-content">
                        <h3><%= productosAgotados %></h3>
                        <p>Productos Agotados</p>
                    </div>
                </div>

                <div class="summary-card warning">
                    <div class="card-icon">
                        <i class="fa-solid fa-exclamation"></i>
                    </div>
                    <div class="card-content">
                        <h3><%= productosCriticos %></h3>
                        <p>Stock Crítico</p>
                    </div>
                </div>
                <%
                    }
                    rsStats.close();
                %>
            </div>
        </section>

        <!-- Productos con Stock Crítico -->
        <section class="critical-stock-section">
            <div class="section-header">
                <h2><i class="fa-solid fa-exclamation-triangle"></i> Productos con Stock Crítico</h2>
            </div>
            <div class="table-container">
                <table class="modern-table">
                    <thead>
                        <tr>
                            <th>Producto</th>
                            <th>Stock Actual</th>
                            <th>Estado</th>
                            <th>Acción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        ResultSet rsCritical = stmt.executeQuery(
                        		"SELECT * FROM V_PRODUCTOS_CRITICOS"
                        );

                        while (rsCritical.next()) {
                            int invId = rsCritical.getInt("inv_id");
                            int productoId = rsCritical.getInt("inv_producto");
                            int cantidadDisp = rsCritical.getInt("inv_cantidad_disp");
                            String nombreProducto = rsCritical.getString("pro_nombre");

                            String estadoClass = cantidadDisp == 0 ? "agotado" : "critico";
                            String estadoText = cantidadDisp == 0 ? "AGOTADO" : "CRÍTICO";
                        %>
                        <tr>
                            <td>
                                <div class="product-info">
                                    <span class="product-name"><%= nombreProducto %></span>
                                    <span class="product-code">ID: <%= productoId %></span>
                                </div>
                            </td>
                            <td>
                                <span class="quantity-badge <%= estadoClass %>"><%= cantidadDisp %></span>
                            </td>
                            <td>
                                <span class="status-badge <%= estadoClass %>"><%= estadoText %></span>
                            </td>
                            <td>
                                <a href="solicitud_reabastecimiento.jsp?producto=<%= productoId %>" class="btn-action">
                                    <i class="fa-solid fa-cart-plus"></i> Pedir
                                </a>
                            </td>
                        </tr>
                        <%
                        }
                        rsCritical.close();
                        %>
                    </tbody>
                </table>
            </div>
        </section>
        <br><br>


		<!-- Pedidos Pendientes -->
		<section class="not-delivered-section">
		  <div class="section-header">
		    <h2><i class="fa-solid fa-clock"></i> Productos Pendientes</h2>
		  </div>
		  <div class="table-container">
		    <table class="modern-table">
		      <thead>
		        <tr>
		          <th>ID Pedido</th>
		          <th>Proveedor</th>
		          <th>Producto</th>
		          <th>Cantidad Pendiente</th>
		          <th>Fecha Pedido</th>
		          <th>Acción</th>
		        </tr>
		      </thead>
		      <tbody>
		        <%
		          ResultSet rsPend = stmt.executeQuery("SELECT * FROM V_PEDIDOS_PENDIENTES");
		          while (rsPend.next()) {
		            int    idPedido        = rsPend.getInt("PED_ID");
		            int    proveedorId     = rsPend.getInt("PRV_ID");
		            int    invId           = rsPend.getInt("INV_ID");
		            String proveedorNombre = rsPend.getString("PRV_NOMBRE");
		            String productoNombre  = rsPend.getString("PRO_NOMBRE");
		            int    cantidadPend    = rsPend.getInt("CANTIDAD_PENDIENTE");
		            java.sql.Date fechaPedido = rsPend.getDate("FECHA_PEDIDO");
		            String fechaFmt = new java.text.SimpleDateFormat("dd/MM/yyyy")
		                              .format(fechaPedido);
		        %>
		        <tr>
		          <td><%= idPedido %></td>
		          <td><%= proveedorNombre %></td>
		          <td><%= productoNombre %></td>
		          <td><%= cantidadPend %></td>
		          <td><%= fechaFmt %></td>
		          <td>
                            <form action="recibir_pedido.jsp" method="post" class="d-inline">
		              <input type="hidden" name="pedido_id"       value="<%= idPedido     %>" />
		              <input type="hidden" name="proveedor_id"    value="<%= proveedorId  %>" />
		              <input type="hidden" name="inventario_id"   value="<%= invId        %>" />
		              <!-- Enviamos siempre toda la cantidad pendiente -->
		              <input type="hidden"
		                     name="cantidad_recibida"
		                     value="<%= cantidadPend %>" />
		              <button type="submit" class="btn-action">
		                <i class="fa-solid fa-truck"></i> Recibir (<%= cantidadPend %>)
		              </button>
		            </form>
		          </td>
		        </tr>
		        <%
		          }
		          rsPend.close();
		        %>
		      </tbody>
		    </table>
		  </div>
		</section>


		<br><br>
        
        
		 <!-- Entregados en la última semana -->
		<section class="delivered-week-section">
		  <div class="section-header">
		    <h2><i class="fa-solid fa-calendar-check"></i> Entregados (última semana)</h2>
		  </div>
		  <div class="table-container">
		    <table class="modern-table">
		      <thead>
		        <tr>
		          <th>ID Pedido</th>
		          <th>Proveedor</th>
		          <th>Producto</th>
		          <th>Cantidad</th>
		          <th>Fecha Entrega</th>
		        </tr>
		      </thead>
		      <tbody>
		        <%
		        ResultSet rsEntregados = stmt.executeQuery(
		        		"SELECT * FROM V_PEDIDOS_ENTREGADOS_SEMANA "
		        );
		
		        while (rsEntregados.next()) {
		            int    idPedido     = rsEntregados.getInt   ("PED_ID");
		            String proveedor    = rsEntregados.getString("PRV_NOMBRE");
		            String producto     = rsEntregados.getString("PRO_NOMBRE");
		            int    cantidad     = rsEntregados.getInt   ("CANTIDAD");
		            Date   fechaEnt     = rsEntregados.getDate  ("FECHA_ENTREGA");
		
		            String fechaFmt = new java.text.SimpleDateFormat("dd/MM/yyyy")
		                                 .format(fechaEnt);
		        %>
		        <tr>
		          <td><%= idPedido %></td>
		          <td><%= proveedor %></td>
		          <td><%= producto %></td>
		          <td><%= cantidad %></td>
		          <td><%= fechaFmt %></td>
		        </tr>
		        <%
		        }
		        rsEntregados.close();
		        %>
		      </tbody>
		    </table>
		  </div>
		</section>
		<br><br>
        
		<!-- Pedidos Completados Recientes -->
		<section class="delivered-recent-section">
		  <div class="section-header">
		    <h2><i class="fa-solid fa-check-circle"></i> Pedidos Completados</h2>
		  </div>
		  <div class="table-container">
		    <table class="modern-table">
		      <thead>
		        <tr>
		          <th>ID Pedido</th>
		          <th>Proveedor</th>
		          <th>Producto</th>
		          <th>Cantidad</th>
		          <th>Fecha Entrega</th>
		        </tr>
		      </thead>
		      <tbody>
		        <%
		        ResultSet rsCompletados = stmt.executeQuery(
		        		"SELECT * FROM V_PEDIDOS_COMPLETADOS"
		        );
		
		        while (rsCompletados.next()) {
		            int    idPedido    = rsCompletados.getInt   ("PED_ID");
		            String proveedor   = rsCompletados.getString("PRV_NOMBRE");
		            String producto    = rsCompletados.getString("PRO_NOMBRE");
		            int    cantidad    = rsCompletados.getInt   ("CANTIDAD");
		            Date   fechaEnt    = rsCompletados.getDate  ("FECHA_ENTREGA");
		            String fechaFmt    = new java.text.SimpleDateFormat("dd/MM/yyyy")
		                                    .format(fechaEnt);
		        %>
		        <tr>
		          <td><%= idPedido %></td>
		          <td><%= proveedor %></td>
		          <td><%= producto %></td>
		          <td><%= cantidad %></td>
		          <td><%= fechaFmt %></td>
		        </tr>
		        <%
		        }
		        rsCompletados.close();
		        %>
		      </tbody>
		    </table>
		  </div>
		</section>

		<br><br>


        <!-- Inventario Completo -->
        <section class="inventory-section">
            <div class="section-header">
                <h2><i class="fa-solid fa-warehouse"></i> Inventario Completo</h2>
                <div class="section-actions">
                    <a href="agregar_producto.jsp" class="btn-primary">
                        <i class="fa-solid fa-plus"></i> Agregar Producto
                    </a>
                    <a href="solicitud_reabastecimiento.jsp" class="btn-secondary">
                        <i class="fa-solid fa-download"></i> Solicitar Reabastecimiento
                    </a>
                </div>
            </div>

            <div class="table-container">
                <table class="modern-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Producto</th>
                            <th>Categoría</th>
                            <th>Stock Actual</th>
                            <th>Precio</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                        ResultSet rsInventario = stmt.executeQuery(
                        		"SELECT * FROM V_INVENTARIO_COMPLETO"
                        );

                        while (rsInventario.next()) {
                            int invId = rsInventario.getInt("inv_id");
                            int productoId = rsInventario.getInt("inv_producto");
                            int cantidadDisp = rsInventario.getInt("inv_cantidad_disp");
                            String nombreProducto = rsInventario.getString("pro_nombre");
                            double precio = rsInventario.getDouble("pro_precio_u");
                            String categoria = rsInventario.getString("cat_nombre");

                            String cantidadClass;
                            if (cantidadDisp == 0) {
                                cantidadClass = "quantity-empty";
                            } else if (cantidadDisp < 10) {
                                cantidadClass = "quantity-low";
                            } else if (cantidadDisp < 50) {
                                cantidadClass = "quantity-medium";
                            } else {
                                cantidadClass = "quantity-high";
                            }
                        %>
                        <tr>
                            <td class="id-cell"><%= invId %></td>
                            <td>
                                <div class="product-info">
                                    <span class="product-name"><%= nombreProducto %></span>
                                    <span class="product-code">ID: <%= productoId %></span>
                                </div>
                            </td>
                            <td><%= categoria != null ? categoria : "Sin categoría" %></td>
                            <td class="quantity-cell">
                                <span class="quantity-badge <%= cantidadClass %>"><%= cantidadDisp %></span>
                            </td>
                            <td class="price-cell">$<%= String.format("%.2f", precio) %></td>
                            </td>
                        </tr>
                        <%
                        }
                        rsInventario.close();
                        stmt.close();
                        conn.close();
                        %>
                    </tbody>
                </table>
            </div>
        </section>
        <br><br>

        <%
        } catch (Exception e) {
        %>
        <section class="error-section">
            <div class="error-message">
                <i class="fa-solid fa-exclamation-triangle"></i>
                <h3>Error al cargar el inventario</h3>
                <p><%= e.getMessage() %></p>
            </div>
        </section>
        <%
        }
        %>
    </div>
    
    </section>
   </div>
   
       <!-- Botón para ver el Historial del Inventario y Agregar Proveedor-->
    <div class="centered-section">
      <form action="historial_inventario.jsp" method="get">
        <button type="submit" class="btn-primary">Historial del Inventario</button>
      </form>
    </div>
      
    <!-- Seccion del Footer -->
    <footer>
      <div class="copyright">
        <p>&copy; Ferreteria Don Lu. Todos los derechos reservados.</p>
        <div class="div-logout">
          <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
        </div>
        <nav>
	        <a href="main_enc_inven.jsp">Inicio</a> |
	        <a href="enc_inventario.jsp">Inventario</a> |
	        <a href="solicitud_reabastecimiento.jsp">Solicitar reabastecimiento</a> |
	        <a href="agregar_proveedor.jsp">Agregar proveedor</a>
        </nav>
      </div>
    </footer>
  </body>
</html>
