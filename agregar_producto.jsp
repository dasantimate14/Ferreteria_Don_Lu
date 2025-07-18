<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, java.util.List, java.util.ArrayList" %>
<%! 
    // Mantener listas en toda la página
    List<Integer> catIds      = new ArrayList<>();
    List<String>  catNames    = new ArrayList<>();
    List<Integer> provIds     = new ArrayList<>();
    List<String>  provNames   = new ArrayList<>();
%>
<!DOCTYPE html>  
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Agregar Nuevo Producto</title>
  <link rel="stylesheet" href="css/styles.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
  <script>
    function toggleNewCategory(val) {
      var txt = document.getElementById("categoria_nueva");
      if (val === "new") {
        txt.style.display = "block";
        txt.required = true;
      } else {
        txt.style.display = "none";
        txt.required = false;
      }
    }
    window.onload = function() {
      toggleNewCategory(document.getElementById("categoria_select").value);
    };
  </script>
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

	<div class="title">
	    <h1>Agregar Nuevo Producto</h1>
    	<a href="main_enc_inven.jsp" class="btn-secondary">← Volver al Inventario</a>
	</div>
  <div class="form-container">

<%
  String msg = "";
  String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
  String dbUser = "owner_ferreteria";
  String dbPass = "1234567";
  Class.forName("oracle.jdbc.OracleDriver");
  Connection conn = null;
  Statement  stmt = null;
  try {
    conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
    stmt = conn.createStatement();

    // Cargar categorías
    catIds.clear(); catNames.clear();
    try (ResultSet rsCats = stmt.executeQuery(
           "SELECT cat_id, cat_nombre FROM Categoria ORDER BY cat_nombre")) {
      while (rsCats.next()) {
        catIds.add(rsCats.getInt("cat_id"));
        catNames.add(rsCats.getString("cat_nombre"));
      }
    }

    // Cargar proveedores
    provIds.clear(); provNames.clear();
    try (ResultSet rsProv = stmt.executeQuery(
           "SELECT prv_id, prv_nombre FROM Proveedor ORDER BY prv_nombre")) {
      while (rsProv.next()) {
        provIds.add(rsProv.getInt("prv_id"));
        provNames.add(rsProv.getString("prv_nombre"));
      }
    }

    // Procesar formulario al enviar
    if ("POST".equalsIgnoreCase(request.getMethod())) {
      String nombre      = request.getParameter("nombre");
      String descripcion = request.getParameter("descripcion");
      String marca       = request.getParameter("marca");
      String precioStr   = request.getParameter("precio");
      String selCat      = request.getParameter("categoria_select");
      String nuevaCat    = request.getParameter("categoria_nueva");
      String[] selProvs  = request.getParameterValues("proveedor_ids");

      if (nombre.isEmpty() || descripcion.isEmpty() || marca.isEmpty()
          || precioStr.isEmpty() || selCat.isEmpty()
          || (selCat.equals("new") && nuevaCat.isEmpty())
          || selProvs == null || selProvs.length == 0) {
        msg = "Todos los campos y al menos un proveedor son obligatorios.";
      } else {
        try {
          double precio = Double.parseDouble(precioStr);
          conn.setAutoCommit(false);

          // 1) Categoría
          int catId;
          if (selCat.equals("new")) {
            try (CallableStatement c1 = conn.prepareCall(
                   "{call SP_REGISTRAR_CATEGORIA(?)}")) {
              c1.setString(1, nuevaCat);
              c1.execute();
            }
            try (PreparedStatement ps = conn.prepareStatement(
                   "SELECT cat_id FROM Categoria WHERE cat_nombre = ?")) {
              ps.setString(1, nuevaCat);
              try (ResultSet rs2 = ps.executeQuery()) {
                rs2.next(); catId = rs2.getInt("cat_id");
              }
            }
          } else {
            catId = Integer.parseInt(selCat);
          }

          // 2) Registrar producto
          try (CallableStatement c2 = conn.prepareCall(
                 "{call SP_REGISTRAR_PRODUCTO(?,?,?,?,?)}")) {
            c2.setString(1, nombre);
            c2.setString(2, descripcion);
            c2.setString(3, marca);
            c2.setDouble(4, precio);
            c2.setInt(5, catId);
            c2.execute();
          }

          // 3) Recuperar ID del nuevo producto
          int newProdId = -1;
          try (PreparedStatement psId = conn.prepareStatement(
                 "SELECT pro_id FROM Producto WHERE pro_nombre = ? AND pro_marca = ?")) {
            psId.setString(1, nombre);
            psId.setString(2, marca);
            try (ResultSet rsId = psId.executeQuery()) {
              if (rsId.next()) newProdId = rsId.getInt("pro_id");
            }
          }

          // 4) Asociar proveedores seleccionados
          if (newProdId > 0) {
            for (String pidStr : selProvs) {
              int prvId = Integer.parseInt(pidStr);
              try (CallableStatement c3 = conn.prepareCall(
                     "{call SP_INSERTAR_PRODUCTO_PROVEEDOR(?,?)}")) {
                c3.setInt(1, newProdId);
                c3.setInt(2, prvId);
                c3.execute();
              }
            }
          }

          conn.commit();
          msg = "Producto y asociaciones con proveedores registradas.";
        } catch (Exception e) {
          conn.rollback();
          msg = "Error: " + e.getMessage();
        }
      }
    }
  } catch (Exception e) {
    msg = "Error conexión: " + e.getMessage();
  } finally {
    if (stmt != null) stmt.close();
    if (conn  != null) conn.close();
  }
%>
    <p class="<%= msg.startsWith("Producto y asociaciones") 
                 ? "success-msg" : "error-msg" %>">
      <%= msg %>
    </p>
    <form method="post" action="agregar_producto.jsp">
      <label>Nombre:</label>
      <input type="text" name="nombre" required>

      <label>Descripción:</label>
      <textarea name="descripcion" rows="3" required></textarea>

      <label>Marca:</label>
      <input type="text" name="marca" required>

      <label>Precio Unitario:</label>
      <input type="number" name="precio" step="0.01" min="0.01" required>

      <label>Categoría:</label>
      <select id="categoria_select" name="categoria_select"
              onchange="toggleNewCategory(this.value)" required>
        <option value="">--Selecciona--</option>
        <option value="new">Nueva categoría</option>
        <% for (int i = 0; i < catIds.size(); i++) { %>
          <option value="<%= catIds.get(i) %>">
            <%= catNames.get(i) %>
          </option>
        <% } %>
      </select>
      <input type="text" id="categoria_nueva" name="categoria_nueva"
             placeholder="Escribe nueva categoría">

      <label>Proveedores (Ctrl+click para varios):</label>
      <select name="proveedor_ids" multiple size="5" required>
        <% for (int i = 0; i < provIds.size(); i++) { %>
          <option value="<%= provIds.get(i) %>">
            <%= provNames.get(i) %>
          </option>
        <% } %>
      </select>

      <button type="submit" class="btn-primary positive-btn">Guardar Producto</button>
    </form>
  </div>
  
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


