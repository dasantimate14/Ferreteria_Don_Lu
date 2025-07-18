<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.sql.*" %>
<%
String mensaje = "";
String clienteId = "";
String claseMensaje = "";

if ("POST".equalsIgnoreCase(request.getMethod())) {
    String cli_nombre = request.getParameter("cli_nombre");
    String cli_apellido_paterno = request.getParameter("cli_apellido_paterno");
    String cli_apellido_materno = request.getParameter("cli_apellido_materno");
    String cli_email = request.getParameter("cli_email");
    String cli_direccion = request.getParameter("cli_direccion");

    String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUser = "owner_ferreteria";
    String dbPass = "1234567";

    try {
        Class.forName("oracle.jdbc.OracleDriver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        CallableStatement cs = conn.prepareCall("{call SP_REGISTRAR_CLIENTE(?, ?, ?, ?, ?, ?)}");
        cs.setString(1, cli_nombre);
        cs.setString(2, cli_apellido_paterno);
        cs.setString(3, cli_apellido_materno);
        cs.setString(4, cli_email);
        cs.setString(5, cli_direccion);
        cs.registerOutParameter(6, java.sql.Types.NUMERIC);

        cs.execute();
        int nuevoId = cs.getInt(6);
        clienteId = String.valueOf(nuevoId);
        mensaje = "✓ Cliente registrado exitosamente.";
        claseMensaje = "mensaje-exito";

        conn.close();
    } catch (Exception e) {
        String error = e.getMessage();
        if (error != null && error.contains("ORA-00001") && error.contains("CLI_EMAIL")) {
            mensaje = "✗ Ya existe un cliente registrado con este correo electrónico.";
        } else {
            mensaje = "✗ Error al registrar: " + error;
        }
        claseMensaje = "mensaje-error";
    }
}
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8" />
    <title>Registrar Cliente</title>
    <link rel="stylesheet" href="css/formulario.css" />
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet" />
    <style>
        .mensaje-exito {
            background-color: #e0ffe0;
            border: 2px solid #2ecc71;
            color: #2ecc71;
            padding: 10px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 15px;
            border-radius: 8px;
        }
        .mensaje-error {
            background-color: #ffe0e0;
            border: 2px solid #e74c3c;
            color: #e74c3c;
            padding: 10px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 15px;
            border-radius: 8px;
        }
        .cliente-id {
            font-size: 1.3em;
            color: #2980b9;
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <!-- Header -->
    <header>
        <div class="header-banner">
            <div class="header-logo-container">
                <div class="header-Logo">
                    <img src="img/Logo.png" alt="logo" />
                </div>
                <h1 class="site-name">Ferretería Don Lu</h1>
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
                <li><a href="pos.jsp">Registrar venta</a></li>
                <li><a href="registroCliente.jsp">Registrar clientes</a></li>
                <li><a href="inventario.jsp">Inventario</a></li>
            </ul>
        </nav>
    </header>

    <!-- Formulario -->
    <div class="container">
        <section class="form-section">
            <h2>Registrar cliente</h2>

            <% if (!mensaje.isEmpty()) { %>
                <div class="<%= claseMensaje %>"><%= mensaje %>
                    <% if (!clienteId.isEmpty()) { %>
                        <div class="cliente-id">Número de cliente generado: <strong><%= clienteId %></strong></div>
                    <% } %>
                </div>
            <% } %>

            <form method="post" action="registroCliente.jsp" class="form">
                <div class="form-group">
                    <label for="cli_nombre" class="form-label">Nombre *</label>
                    <input type="text" id="cli_nombre" name="cli_nombre" class="form-input" maxlength="100" required />
                </div>
                <div class="form-group">
                    <label for="cli_apellido_paterno" class="form-label">Apellido Paterno *</label>
                    <input type="text" id="cli_apellido_paterno" name="cli_apellido_paterno" class="form-input" maxlength="100" required />
                </div>
                <div class="form-group">
                    <label for="cli_apellido_materno" class="form-label">Apellido Materno</label>
                    <input type="text" id="cli_apellido_materno" name="cli_apellido_materno" class="form-input" maxlength="100" />
                </div>
                <div class="form-group">
                    <label for="cli_email" class="form-label">Email *</label>
                    <input type="email" id="cli_email" name="cli_email" class="form-input" maxlength="150" required />
                </div>
                <div class="form-group">
                    <label for="cli_direccion" class="form-label">Dirección *</label>
                    <input type="text" id="cli_direccion" name="cli_direccion" class="form-input" maxlength="300" required />
                </div>
                <div class="form-actions">
                    <button type="submit" class="submit-btn">Registrar</button>
                </div>
            </form>
        </section>
    </div>
    <!-- Tabla de Clientes Actuales -->
<style>
.tabla-clientes-section {
    margin: 48px auto 30px auto;
    max-width: 1050px;
    background: #fff;
    border-radius: 14px;
    box-shadow: 0 2px 12px rgba(44,62,80,0.12);
    padding: 22px 15px 26px 15px;
}
.tabla-clientes-section h2 {
    color: #283e62;
    text-align: center;
    font-size: 1.4em;
    margin-bottom: 16px;
}
.table-clientes-container {
    overflow-x: auto;
}
.tabla-clientes {
    width: 100%;
    border-collapse: collapse;
    font-family: 'Segoe UI', Arial, sans-serif;
    background: #fafcff;
}
.tabla-clientes th, .tabla-clientes td {
    padding: 10px 13px;
    text-align: center;
}
.tabla-clientes th {
    background: #2286cf;
    color: #fff;
    font-weight: 600;
    font-size: 1.06em;
}
.tabla-clientes tr {
    border-bottom: 1px solid #e3e3f3;
    transition: background 0.17s;
}
.tabla-clientes tr:hover {
    background: #e4f1fb;
}
.tabla-clientes td {
    color: #223;
}
@media (max-width: 700px) {
    .tabla-clientes-section {
        padding: 10px 2vw;
    }
    .tabla-clientes th, .tabla-clientes td {
        font-size: 0.97em;
        padding: 7px 2px;
    }
}
</style>

	<section class="tabla-clientes-section">
	    <h2>Clientes Registrados</h2>
	    <div class="table-clientes-container">
	        <table class="tabla-clientes">
	            <thead>
	                <tr>
	                    <th>ID</th>
	                    <th>Nombre</th>
	                    <th>Apellido Paterno</th>
	                    <th>Apellido Materno</th>
	                    <th>Email</th>
	                    <th>Dirección</th>
	                </tr>
	            </thead>
	            <tbody>
	            <%
	            // Consulta y muestra los clientes
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
	                rs = stmt.executeQuery("SELECT cli_id, cli_nombre, cli_apellido_paterno, cli_apellido_materno, cli_email, cli_direccion FROM Cliente ORDER BY cli_id");
	                while (rs.next()) {
	            %>
	                <tr>
	                    <td><%= rs.getInt("cli_id") %></td>
	                    <td><%= rs.getString("cli_nombre") %></td>
	                    <td><%= rs.getString("cli_apellido_paterno") %></td>
	                    <td><%= rs.getString("cli_apellido_materno") %></td>
	                    <td><%= rs.getString("cli_email") %></td>
	                    <td><%= rs.getString("cli_direccion") %></td>
	                </tr>
	            <%
	                }
	            } catch (Exception e) {
	            %>
	                <tr>
	                    <td colspan="6" style="color:red;">Error al cargar clientes: <%= e.getMessage() %></td>
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

    <!-- Footer -->
    <footer>
        <div class="copyright">
            <p>&copy; Ferretería Don Lu. Todos los derechos reservados.</p>
            <div class="div-logout">
                <a href="login.jsp"><i class="fa-solid fa-right-to-bracket icon-login"></i></a>
            </div>
            <nav>
                <a href="main_cajero.jsp">Inicio</a> |
                <a href="pos.jsp">Registrar venta</a> |
                <a href="registro_cliente.jsp">Registrar clientes</a> |
                <a href="Inventario.jsp">Inventario</a>
            </nav>
        </div>
    </footer>
</body>
</html>
