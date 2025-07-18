<%@ page import="java.sql.*" %>
<%@ page import="javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String mensajeError = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            Class.forName("oracle.jdbc.OracleDriver");
            con = DriverManager.getConnection(
                "jdbc:oracle:thin:@localhost:1521:XE",  // Cambia si usas otro service name
                "owner_ferreteria",                                     // Usuario Oracle real
                "1234567"                             // Contraseña real
            );

            String sql = "SELECT emp_id, emp_nombre, emp_puesto FROM Empleado WHERE emp_email = ? AND emp_contrasena = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            rs = ps.executeQuery();

            if (rs.next()) {
                // Guardar datos en sesión
                HttpSession sesion = request.getSession();
                sesion.setAttribute("emp_id", rs.getInt("emp_id"));
                sesion.setAttribute("emp_nombre", rs.getString("emp_nombre"));
                sesion.setAttribute("emp_puesto", rs.getString("emp_puesto"));

                // Obtener y validar puesto
                String puesto = rs.getString("emp_puesto").toUpperCase();

                switch (puesto) {
                    case "CAJERO":
                        response.sendRedirect("pos.jsp");
                        break;
                    case "INVENTARIO":
                        response.sendRedirect("main_enc_inven.jsp");
                        break;
                    case "GERENTE":
                        response.sendRedirect("gerente.jsp");
                        break;
                    default:
                        response.sendRedirect("login.jsp?error=rol_desconocido");
                        break;
                }
                return;
            } else {
                mensajeError = "❌ Usuario o contraseña incorrectos.";
            }

        } catch (Exception e) {
            mensajeError = "❌ Error al conectar: " + e.getMessage();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (ps != null) ps.close(); } catch (Exception ignored) {}
            try { if (con != null) con.close(); } catch (Exception ignored) {}
        }
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Login | Ferretería Don Lu</title>
    <link rel="stylesheet" href="css/styles.css">
</head>
<body>
<main class="main-login">
    <div class="login-container">
        <div class="login-left">
            <div class="illustration">
                <img src="img/Logo.png" alt="Logo">
            </div>
        </div>

        <div class="login-right">
            <div class="login-form">
                <h2>Ferretería Don Lu</h2>

                <% if (!mensajeError.isEmpty()) { %>
                    <p style="color:red;"><%= mensajeError %></p>
                <% } %>

                <form method="POST">
                    <div class="form-group">
                        <label for="username">Usuario (Email) *</label>
                        <input type="text" id="username" name="username" placeholder="ejemplo@correo.com" required>
                    </div>

                    <div class="form-group">
                        <label for="password">Contraseña *</label>
                        <input type="password" id="password" name="password" placeholder="Ingrese su contraseña" required>
                    </div>

                    <button type="submit" class="login-btn">Iniciar Sesión</button>
                </form>
            </div>
        </div>
    </div>
</main>
</body>
</html>
