<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String mensaje = "";
String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
String dbUser = "owner_ferreteria";
String dbPass = "1234567";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    try {
        Class.forName("oracle.jdbc.OracleDriver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        if (request.getParameter("registrar") != null) {
            CallableStatement cs = conn.prepareCall("{call SP_REGISTRAR_EMPLEADO(?, ?, ?, ?, ?, ?, ?, ?, ?)}");
            cs.setString(1, request.getParameter("emp_nombre"));
            
            
            cs.setString(2, request.getParameter("emp_apellido_paterno"));
            cs.setString(3, request.getParameter("emp_apellido_materno"));
            cs.setString(4, request.getParameter("emp_cedula"));
            cs.setString(5, request.getParameter("emp_email"));
            cs.setDouble(6, Double.parseDouble(request.getParameter("emp_salario")));
            cs.setString(7, request.getParameter("emp_puesto"));
            cs.setString(8, request.getParameter("emp_direccion"));
            cs.setString(9, request.getParameter("emp_password"));
            cs.execute();
            mensaje = "✓ Empleado registrado exitosamente.";
            cs.close();

        } else if (request.getParameter("actualizar") != null) {
            CallableStatement cs = conn.prepareCall("{call SP_ACTUALIZAR_EMPLEADO(?, ?, ?)}");
            cs.setInt(1, Integer.parseInt(request.getParameter("emp_id")));
            cs.setDouble(2, Double.parseDouble(request.getParameter("emp_salario")));
            cs.setString(3, request.getParameter("emp_puesto"));
            cs.execute();
            mensaje = "✓ Empleado actualizado correctamente.";
            cs.close();

        } else if (request.getParameter("eliminar") != null) {
            String idStr = request.getParameter("emp_id");
            String cedula = request.getParameter("emp_cedula");

            if (idStr != null && !idStr.trim().isEmpty()) {
                CallableStatement cs = conn.prepareCall("{call SP_ELIMINAR_EMPLEADO(?)}");
                cs.setInt(1, Integer.parseInt(idStr));
                cs.execute();
                mensaje = "✓ Empleado eliminado por ID correctamente.";
                cs.close();

            } else if (cedula != null && !cedula.trim().isEmpty()) {
                CallableStatement cs = conn.prepareCall("{call SP_ELIMINAR_EMPLEADO_CEDULA(?)}");
                cs.setString(1, cedula);
                cs.execute();
                mensaje = "✓ Empleado eliminado por cédula correctamente.";
                cs.close();

            } else {
                mensaje = "✗ Debe proporcionar el ID o la cédula para eliminar un empleado.";
            }
        }

        conn.close();
    } catch (SQLException sqle) {
        mensaje = "✗ Error SQL: " + sqle.getMessage();
    } catch (Exception e) {
        mensaje = "✗ Error general: " + e.getMessage();
    }
}
%>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Gestión de Empleados</title>
    <link rel="stylesheet" href="css/styles.css" />
    <link rel="stylesheet" href="css/tabla.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
</head>
<body>
<header>
    <div class="header-banner">
        <div class="header-logo-container">
            <div class="header-Logo"><img src="img/Logo.png" alt="logo" /></div>
            <h1 class="site-name">Ferretería Don Lu</h1>
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
	      <li><a href="main_gerente.jsp">Inicio</a></li>
	      <li><a href="registro_empleado.jsp">Registrar empleado</a></li>
	      <li><a href="resumenVenta.jsp">Reporte de ventas</a></li>
	      <li><a href="auditoria.jsp">Reporte de auditoria</a></li>
	    </ul>
    </nav>
</header>

<main class="container">
	<!-- Tabla de empleados -->
	<section class="tabla-empleados-section">
            <h2 class="text-center">Lista de Empleados</h2>
	    <div class="table-container">
	    <table class="modern-table">
	        <thead>
	            <tr>
	                <th>ID</th>
	                <th>Nombre</th>
	                <th>Apellido Paterno</th>
	                <th>Apellido Materno</th>
	                <th>Cédula</th>
	                <th>Email</th>
	                <th>Puesto</th>
	                <th>Salario</th>
	                <th>Dirección</th>
	            </tr>
	        </thead>
	        <tbody>
	        <%
	            Connection conn = null;
	            Statement stmt = null;
	            ResultSet rs = null;
	            try {
	                Class.forName("oracle.jdbc.OracleDriver");
	                conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
	                stmt = conn.createStatement();
	                rs = stmt.executeQuery("SELECT emp_id, emp_nombre, emp_apellido_paterno, emp_apellido_materno, emp_cedula, emp_email, emp_puesto, emp_salario, emp_direccion FROM Empleado ORDER BY emp_id");
	                while (rs.next()) {
	        %>
	            <tr>
	                <td><%= rs.getInt("emp_id") %></td>
	                <td><%= rs.getString("emp_nombre") %></td>
	                <td><%= rs.getString("emp_apellido_paterno") %></td>
	                <td><%= rs.getString("emp_apellido_materno") %></td>
	                <td><%= rs.getString("emp_cedula") %></td>
	                <td><%= rs.getString("emp_email") %></td>
	                <td><%= rs.getString("emp_puesto") %></td>
	                <td><%= rs.getDouble("emp_salario") %></td>
	                <td><%= rs.getString("emp_direccion") %></td>
	            </tr>
	        <%
	                }
	            } catch (Exception e) {
	        %>
	            <tr>
                        <td colspan="9" class="text-red">Error al cargar empleados: <%= e.getMessage() %></td>
	            </tr>
	        <%
	            } finally {
	                try { if (rs != null) rs.close(); } catch (Exception ex) {}
	                try { if (stmt != null) stmt.close(); } catch (Exception ex) {}
	                try { if (conn != null) conn.close(); } catch (Exception ex) {}
	            }
	        %>
	        </tbody>
	    </table>
	    </div>
	</section>
	<br><br>
	
    <div class="upd-content">

        <!-- Eliminar Empleado -->
        <div class="form-section">
            <h2>Eliminar Empleado (por ID o Cédula)</h2>
            <form method="post" action="registro_empleado.jsp" class="product-form">
                <div class="form-group">
                    <label for="emp_id">ID del empleado:</label>
                    <input type="number" id="emp_id" name="emp_id" class="form-input" />
                </div>
                <div class="form-group">
                    <label for="emp_cedula">Cédula sin guiones:</label>
                    <input type="text" id="emp_cedula" name="emp_cedula" class="form-input" pattern="^[0-9]{6,20}$" title="Solo números sin guiones" />
                </div>
                <div class="form-actions">
                    <button type="submit" name="eliminar" class="upd-btn">Eliminar</button>
                </div>
            </form>
        </div>

        <!-- Actualizar Empleado -->
        <div class="form-section">
            <h2>Actualizar Empleado</h2>
            <form method="post" action="registro_empleado.jsp" class="product-form">
                <div class="form-group">
                    <label for="emp_id">ID del empleado *</label>
                    <input type="number" id="emp_id" name="emp_id" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_salario">Salario *</label>
                    <input type="number" id="emp_salario" step="0.01" min="0.01" name="emp_salario" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_puesto">Puesto *</label>
                    <input type="text" id="emp_puesto" name="emp_puesto" class="form-input" required />
                </div>
                <div class="form-actions">
                    <button type="submit" name="actualizar" class="upd-btn">Actualizar</button>
                </div>
            </form>
        </div>

        <!-- Registrar Empleado -->
        <section class="form-section">
            <h2 class="section-title">Registrar Empleado</h2>
            <form method="post" action="registro_empleado.jsp" class="form">
                <div class="form-group">
                    <label for="emp_nombre">Nombre:</label>
                    <input type="text" id="emp_nombre" name="emp_nombre" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_apellido_paterno">Apellido Paterno:</label>
                    <input type="text" id="emp_apellido_paterno" name="emp_apellido_paterno" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_apellido_materno">Apellido Materno:</label>
                    <input type="text" id="emp_apellido_materno" name="emp_apellido_materno" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_cedula">Cédula (sin guiones):</label>
                    <input type="text" id="emp_cedula" name="emp_cedula" class="form-input" required pattern="^[0-9]{6,20}$" title="Ingrese solo números sin guiones" />
                </div>
                <div class="form-group">
                    <label for="emp_puesto">Puesto:</label>
                    <input type="text" id="emp_puesto" name="emp_puesto" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_salario">Salario:</label>
                    <input type="number" id="emp_salario" name="emp_salario" step="0.01" min="0.01" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_direccion">Dirección:</label>
                    <input type="text" id="emp_direccion" name="emp_direccion" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_email">Email:</label>
                    <input type="email" id="emp_email" name="emp_email" class="form-input" required />
                </div>
                <div class="form-group">
                    <label for="emp_password">Contraseña:</label>
                    <input type="password" id="emp_password" name="emp_password" class="form-input" required />
                </div>
                <div class="form-actions">
                    <button type="submit" name="registrar" class="upd-btn">Registrar</button>
                </div>
            </form>
        </section>

        <p class="mt-20 <%= mensaje.startsWith("✓") ? "text-green" : "text-red" %>">
            <%= mensaje %>
        </p>
    </div>
</main>


<footer>
    <div class="copyright">
        <p>&copy; Ferretería Don Lu. Todos los derechos reservados.</p>
        <div class="div-logout">
            <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
        </div>
        <nav>
	        <a href="main_gerente.jsp">Inicio</a> |
	        <a href="registro_empleado.jsp">Registrar empleado</a> |
	        <a href="resumenVenta.jsp">Reporte de ventas</a> |
	        <a href="auditoria.jsp">Reporte de auditoria</a> 
        </nav>
    </div>
</footer>
</body>
</html>
