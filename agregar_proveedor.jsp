<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Agregar Proveedor</title>
    <link rel="stylesheet" href="css/agregar_proveedor.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
      form { max-width:500px; margin:auto; }
      label { display:block; margin-top:1em; }
      input, textarea { width:100%; }
      .mensaje { text-align:center; margin-top:2em; font-weight:bold; }
      .ejemplo { color: #444; font-size: 0.95em; margin-top: 0.15em; }
    </style>
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
    
    <h2 style="text-align:center;">Registrar Nuevo Proveedor</h2>

    <form method="post" autocomplete="off">
        <label>Nombre del Proveedor:</label>
        <input type="text" name="nombre" maxlength="100" required>
        
        <label>Nombre de Contacto:</label>
        <input type="text" name="nombre_contacto" maxlength="100">

        <label>Email:
          <span class="ejemplo">(Ejemplo: nombre@email.com)</span>
        </label>
        <input type="email" name="email" maxlength="150" required pattern="^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$">

        <label>Teléfono:
          <span class="ejemplo">(Formato internacional, ejemplo: +1234567891)</span>
        </label>
        <input type="text" name="telefono" maxlength="20" pattern="\+[0-9]{11,15}" title="Debe tener el formato +12331562244" required>

        <label>Dirección:</label>
        <textarea name="direccion" maxlength="300"></textarea>

        <br>
        <button type="submit" class="btn-primary">Registrar Proveedor</button>
    </form>

    <%
    String mensaje = null;
    if ("post".equalsIgnoreCase(request.getMethod())) {
    	String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
    	String dbUser = "owner_ferreteria";
    	String dbPass = "1234567";
        Connection conn = null;
        CallableStatement cstmt = null;
        // Validación de teléfono en backend (también en frontend)
        String telefono = request.getParameter("telefono");
        String telefonoRegex = "\\+[0-9]{11,15}";
        if (telefono == null || !telefono.matches(telefonoRegex)) {
            mensaje = "Error: El teléfono debe tener el formato +12331562244";
        } else {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
            conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

            cstmt = conn.prepareCall("{ call SP_REGISTRAR_PROVEEDOR(?, ?, ?, ?, ?) }");
            cstmt.setString(1, request.getParameter("nombre"));
            cstmt.setString(2, request.getParameter("nombre_contacto"));
            cstmt.setString(3, request.getParameter("email"));
            cstmt.setString(4, telefono);
            cstmt.setString(5, request.getParameter("direccion"));
            cstmt.execute();

            mensaje = "Proveedor registrado exitosamente.";
        } catch (Exception e) {
            mensaje = "Error al registrar proveedor: " + e.getMessage();
        } finally {
            try { if (cstmt != null) cstmt.close(); } catch(Exception e){}
            try { if (conn != null) conn.close(); } catch(Exception e){}
        }
        }
    }
    if (mensaje != null) {
    %>
      <div class="mensaje" style="color:<%=mensaje.startsWith("Error")?"red":"green"%>;">
        <%= mensaje %>
      </div>
    <%
    }
    %>
    <!-- Tabla de Proveedores Actuales -->
	<style>
	.tabla-proveedores-section {
	    margin: 48px auto 18px auto;
	    max-width: 1100px;
	    background: #fff;
	    border-radius: 14px;
	    box-shadow: 0 2px 14px rgba(80,100,160,0.10);
	    padding: 25px 15px;
	}
	.tabla-proveedores-section h2 {
	    color: #2d4379;
	    text-align: center;
	    font-size: 1.5em;
	    margin-bottom: 20px;
	}
	.table-proveedores-container {
	    overflow-x: auto;
	}
	.tabla-proveedores {
	    width: 100%;
	    border-collapse: collapse;
	    font-family: 'Segoe UI', Arial, sans-serif;
	    background: #f9fafd;
	}
	.tabla-proveedores th, .tabla-proveedores td {
	    padding: 10px 14px;
	    text-align: center;
	}
	.tabla-proveedores th {
	    background: #165ea8;
	    color: #fff;
	    font-weight: 600;
	    font-size: 1.07em;
	}
	.tabla-proveedores tr {
	    border-bottom: 1px solid #e2e2ee;
	    transition: background 0.16s;
	}
	.tabla-proveedores tr:hover {
	    background: #e7f1fb;
	}
	.tabla-proveedores td {
	    color: #1b1b1b;
	}
	@media (max-width: 700px) {
	    .tabla-proveedores-section {
	        padding: 10px 2vw;
	    }
	    .tabla-proveedores th, .tabla-proveedores td {
	        font-size: 0.98em;
	        padding: 6px 2px;
	    }
	}
	</style>
	
	<section class="tabla-proveedores-section">
	    <h2>Proveedores Actuales</h2>
	    <div class="table-proveedores-container">
	        <table class="tabla-proveedores">
	            <thead>
	                <tr>
	                    <th>ID</th>
	                    <th>Nombre</th>
	                    <th>Persona de Contacto</th>
	                    <th>Email</th>
	                    <th>Teléfono</th>
	                    <th>Dirección</th>
	                </tr>
	            </thead>
	            <tbody>
	            <%
	            // Consulta y muestra proveedores
	            String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
	            String dbUser = "owner_ferreteria";
	            String dbPass = "1234567";
	            Connection conn = null;
	            Statement stmt = null;
	            ResultSet rs = null;
	            try {
	                Class.forName("oracle.jdbc.OracleDriver");
	                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
	                stmt = conn.createStatement();
	                rs = stmt.executeQuery("SELECT prv_id, prv_nombre, prv_nombre_contacto, prv_email, prv_telefono, prv_direccion FROM Proveedor ORDER BY prv_id");
	                while (rs.next()) {
	            %>
	                <tr>
	                    <td><%= rs.getInt("prv_id") %></td>
	                    <td><%= rs.getString("prv_nombre") %></td>
	                    <td><%= rs.getString("prv_nombre_contacto") %></td>
	                    <td><%= rs.getString("prv_email") %></td>
	                    <td><%= rs.getString("prv_telefono") %></td>
	                    <td><%= rs.getString("prv_direccion") %></td>
	                </tr>
	            <%
	                }
	            } catch (Exception e) {
	            %>
	                <tr>
	                    <td colspan="6" style="color:red;">Error al cargar proveedores: <%= e.getMessage() %></td>
	                </tr>
	            <%
	            } finally {
	                try { if (rs != null) rs.close(); } catch(Exception e){}
	                try { if (stmt != null) stmt.close(); } catch(Exception e){}
	                try { if (conn != null) conn.close(); } catch(Exception e){}
	            }
	            %>
	            </tbody>
	        </table>
	    </div>
	</section>
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

