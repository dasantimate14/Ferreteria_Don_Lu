<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // CAMBIO: Lógica JSP para manejar selección de tabla sin JavaScript
    String tablaSeleccionada = request.getParameter("tabla");
    if (tablaSeleccionada == null || tablaSeleccionada.isEmpty()) {
        tablaSeleccionada = "inventario"; // Tabla por defecto
    }
    
    // CAMBIO: Definir títulos y datos para cada tabla
    String tituloTabla = "";
    switch (tablaSeleccionada) {
        case "inventario":
            tituloTabla = "Lista de Productos";
            break;
        case "ventas":
            tituloTabla = "Historial de Ventas";
            break;
        case "clientes":
            tituloTabla = "Lista de Clientes";
            break;
        case "categorias":
            tituloTabla = "Categorías de Productos";
            break;
        case "proveedores":
            tituloTabla = "Lista de Proveedores";
            break;
        default:
            tituloTabla = "Lista de Productos";
            tablaSeleccionada = "inventario";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inventario de Productos</title>
    <link rel="stylesheet" href="css/tabla.css">
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
        <section class="table-section">
            <div class="table-header">
                <h2><%= tituloTabla %></h2>
                 <section style="display: flex; gap: 20px; justify-content: space-between; margin-top: 30px; margin ">
				  <div class="notification" style="flex: 1;">
				    <div class="notification-content">
				      <div class="notification-title">Transacciones</div>
				      <div class="notification-text">Cantidad total: <strong>152</strong></div>
				    </div>
				  </div>
				
				  <div class="notification" style="flex: 1;">
				    <div class="notification-content">
				      <div class="notification-title">Ventas Totales</div>
				      <div class="notification-text">Monto acumulado: <strong>$12,450.00</strong></div>
				    </div>
				  </div>
				
				  <div class="notification" style="flex: 1;">
				    <div class="notification-content">
				      <div class="notification-title">Producto Más Vendido</div>
				      <div class="notification-text">Nombre: <strong>Agua embotellada 600ml</strong></div>
				    </div>
				  </div>
				</section>                
            </div>

            <div class="table-container">
                <!-- CAMBIO: Tabla de Inventario -->
				<table class="modern-table">
				    <thead>
				        <tr>
				            <th>ID</th>
				            <th>Cliente</th>
				            <th>Empleado</th>
				            <th>Comentario</th>
				            <th>Fecha</th>
				            <th>Subtotal</th>
				            <th>Monto Total</th>
				        </tr>
				    </thead>
				    <tbody>
				        <tr>
				            <td class="id-cell">#VEN001</td>
				            <td class="product-cell">
				                <div class="product-info">
				                    <span class="product-name">Cliente 123</span>
				                    <span class="product-code">Juan Pérez</span>
				                </div>
				            </td>
				            <td class="product-cell">
				                <div class="product-info">
				                    <span class="product-name">Empleado 12</span>
				                    <span class="product-code">María López</span>
				                </div>
				            </td>
				            <td class="quantity-cell">Entrega a domicilio urgente</td>
				            <td class="quantity-cell">2025-07-14</td>
				            <td class="quantity-cell">$120.00</td>
				            <td class="quantity-cell">$127.20</td>
				        </tr>
				        <tr>
				            <td class="id-cell">#VEN002</td>
				            <td class="product-cell">
				                <div class="product-info">
				                    <span class="product-name">Cliente 456</span>
				                    <span class="product-code">Ana Torres</span>
				                </div>
				            </td>
				            <td class="product-cell">
				                <div class="product-info">
				                    <span class="product-name">Empleado 34</span>
				                    <span class="product-code">Luis Gómez</span>
				                </div>
				            </td>
				            <td class="quantity-cell">Compra al por mayor</td>
				            <td class="quantity-cell">2025-07-13</td>
				            <td class="quantity-cell">$340.50</td>
				            <td class="quantity-cell">$357.53</td>
				        </tr>
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
	        <a href="POS.jsp">Registrar venta</a> |
	        <a href="registro_cliente.jsp">Registrar clientes</a> |
	        <a href="Inventario.jsp">Inventario</a> 
       </nav>
      </div>
    </footer>
</body>
</html>