<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%
    // Parámetros de conexión
    String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
    String dbUser = "owner_ferreteria";
    String dbPass = "1234567";

    // Listas para productos y proveedores
    List<String[]> productos    = new ArrayList<>();
    Map<Integer, List<String[]>> prodProvs = new HashMap<>();
    String mensaje = null;

    try {
        Class.forName("oracle.jdbc.OracleDriver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        // 1) Cargar productos
        try (PreparedStatement ps = conn.prepareStatement(
               "SELECT pro_id, pro_nombre FROM Producto ORDER BY pro_nombre");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                productos.add(new String[]{ rs.getString(1), rs.getString(2) });
            }
        }

        // 2) Cargar proveedores para cada producto
        for (String[] prod : productos) {
            int pid = Integer.parseInt(prod[0]);
            try (PreparedStatement ps = conn.prepareStatement(
                   "SELECT pr.prv_id, pr.prv_nombre " +
                   "FROM Producto_Proveedor pp " +
                   " JOIN Proveedor pr ON pp.prv_id=pr.prv_id " +
                   "WHERE pp.pro_id=? ORDER BY pr.prv_nombre")) {
                ps.setInt(1, pid);
                try (ResultSet rs = ps.executeQuery()) {
                    List<String[]> lst = new ArrayList<>();
                    while (rs.next()) {
                        lst.add(new String[]{ rs.getString(1), rs.getString(2) });
                    }
                    prodProvs.put(pid, lst);
                }
            }
        }

        // 3) Si vinimos de un POST, registrar el pedido y sus detalles
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            Connection conn2 = DriverManager.getConnection(dbURL, dbUser, dbPass);
            // Registrar cabecera del pedido
            CallableStatement cstmt = conn2.prepareCall(
                "{ call SP_REGISTRAR_PEDIDO_REAB(?, ?, ?) }");
            cstmt.setString(1, request.getParameter("descripcion"));
            cstmt.setDouble(2, Double.parseDouble(request.getParameter("sub_total")));
            cstmt.registerOutParameter(3, Types.NUMERIC);
            cstmt.execute();
            int pedidoId = cstmt.getInt(3);
            cstmt.close();

            // Detalles: arrays de parámetros
            String[] prodArr = request.getParameterValues("producto_id");
            String[] provArr = request.getParameterValues("proveedor_id");
            String[] precArr = request.getParameterValues("precio_u");
            String[] cantArr = request.getParameterValues("cantidad");

            if (prodArr != null) {
                for (int i = 0; i < prodArr.length; i++) {
                    cstmt = conn2.prepareCall(
                        "{ call SP_REGISTRAR_DET_REAB(?, ?, ?, ?, ?) }");
                    cstmt.setInt(1, pedidoId);
                    cstmt.setInt(2, Integer.parseInt(prodArr[i]));
                    cstmt.setInt(3, Integer.parseInt(provArr[i]));
                    cstmt.setDouble(4, Double.parseDouble(precArr[i]));
                    cstmt.setInt(5, Integer.parseInt(cantArr[i]));
                    cstmt.execute();
                    cstmt.close();
                }
            }
            conn2.close();
            mensaje = "✓ Pedido registrado exitosamente (ID " + pedidoId + ")";
        }

        conn.close();
    } catch (Exception e) {
        mensaje = "✗ Error: " + e.getMessage();
    }

    // Construir objeto JS de proveedores por producto
    StringBuilder proveedoresPorProductoJS = new StringBuilder("{");
    for (String[] prod : productos) {
        int pid = Integer.parseInt(prod[0]);
        proveedoresPorProductoJS.append(pid).append(":[");
        List<String[]> lst = prodProvs.get(pid);
        if (lst != null) {
            for (int j = 0; j < lst.size(); j++) {
                String[] p = lst.get(j);
                proveedoresPorProductoJS
                  .append("{id:").append(p[0])
                  .append(",nombre:'")
                  .append(p[1].replace("'", "\\'"))
                  .append("'}");
                if (j < lst.size() - 1) proveedoresPorProductoJS.append(",");
            }
        }
        proveedoresPorProductoJS.append("],");
    }
    if (!productos.isEmpty())
        proveedoresPorProductoJS.setLength(proveedoresPorProductoJS.length() - 1);
    proveedoresPorProductoJS.append("}");

    // HTML prearmado para el select de productos
    StringBuilder selectProductoHtml = new StringBuilder();
    selectProductoHtml.append(
      "<select name='producto_id' class='form-input sel-prod' " +
      "required onchange='cargarProveedores(this)'>");
    selectProductoHtml.append("<option value=''>Seleccione...</option>");
    for (String[] p : productos) {
        selectProductoHtml
          .append("<option value='").append(p[0]).append("'>")
          .append(p[1])
          .append("</option>");
    }
    selectProductoHtml.append("</select>");
    request.setAttribute("selectProductoHtml", selectProductoHtml.toString());
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Solicitud de Reabastecimiento</title>
  <link rel="stylesheet" href="css/styles.css">
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
        rel="stylesheet">
</head>
<body>
  <!-- Sección del header -->
  <header>
    <div class="header-banner">
      <div class="header-logo-container">
        <div class="header-Logo">
          <img src="img/Logo.png" alt="logo" />
        </div>
        <h1 class="site-name">Ferretería Don Lu</h1>
      </div>
      <div class="group-icons">
        <a href="https://www.google.com/">
          <i class="fa-solid fa-magnifying-glass icons"></i>
        </a>
        <i class="fa-brands fa-facebook icons"></i>
        <i class="fa-brands fa-instagram icons"></i>
        <i class="fa-brands fa-youtube icons"></i>
        <a href="login.jsp">
          <i class="fa-solid fa-right-to-bracket icon-login"></i>
        </a>
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
  <main class="container">
    <div class="form-section">
      <h2>Registrar Pedido de Reabastecimiento</h2>

      <% if (mensaje != null) { %>
        <div class="<%= mensaje.startsWith("✓") ? "mensaje-exito" : "mensaje-error" %>">
          <%= mensaje %>
        </div>
      <% } %>

      <form method="post">
        <div class="form-group">
          <label for="descripcion">Descripción:</label>
          <input id="descripcion" class="form-input"
                 type="text" name="descripcion" required>
        </div>

        <div class="form-group">
          <label for="sub_total">Subtotal:</label>
          <input id="sub_total" class="form-input"
                 type="number" name="sub_total"
                 step="0.01" readonly required>
        </div>

        <h3>Detalles del Pedido</h3>
        <div id="detalles">
          <div class="detalle">
            <div class="form-group">
              <label>Producto:</label>
              <%= request.getAttribute("selectProductoHtml") %>
            </div>
            <div class="form-group">
              <label>Proveedor:</label>
              <select name="proveedor_id"
                      class="form-input sel-prov"
                      required>
                <option value="">Seleccione producto primero</option>
              </select>
            </div>
            <div class="form-group">
              <label>Precio de Compra:</label>
              <input class="form-input" type="number"
                     name="precio_u" step="0.01" required>
            </div>
            <div class="form-group">
              <label>Cantidad:</label>
              <input class="form-input" type="number"
                     name="cantidad" required>
            </div>
            <!-- Sin botón Eliminar en el primer bloque -->
          </div>
        </div>

        <div class="form-actions">
          <button type="button"
                  class="btn btn-secondary"
                  onclick="agregarDetalle()">
            <i class="fa-solid fa-plus"></i> Agregar Otro
          </button>
          <button type="submit"
                  class="btn btn-success">
            <i class="fa-solid fa-paper-plane"></i> Enviar Pedido
          </button>
        </div>
      </form>

      <script>
        const proveedoresPorProducto = <%= proveedoresPorProductoJS %>;

        function actualizarSubtotal() {
          let total = 0;
          document.querySelectorAll('#detalles .detalle').forEach(det => {
            let p = parseFloat(det.querySelector('input[name="precio_u"]').value) || 0;
            let c = parseInt(det.querySelector('input[name="cantidad"]').value) || 0;
            total += p * c;
          });
          document.getElementById('sub_total').value =
            total > 0 ? total.toFixed(2) : '';
        }

        // Asociar cálculo al bloque inicial
        document.querySelectorAll('#detalles .detalle').forEach(det => {
          det.querySelectorAll('input').forEach(i =>
            i.addEventListener('input', actualizarSubtotal)
          );
        });

        function cargarProveedores(sel) {
          const det = sel.closest('.detalle');
          const provSel = det.querySelector('.sel-prov');
          provSel.innerHTML = '<option value="">Seleccione...</option>';
          (proveedoresPorProducto[sel.value] || [])
            .forEach(p => {
              const opt = document.createElement('option');
              opt.value = p.id; opt.textContent = p.nombre;
              provSel.appendChild(opt);
            });
        }

        function crearBotonEliminar() {
          const btn = document.createElement('button');
          btn.type = 'button';
          btn.className = 'btn btn-danger';
          btn.innerHTML = '<i class="fa-solid fa-trash"></i> Eliminar';
          btn.addEventListener('click', () => {
            btn.closest('.detalle').remove();
            actualizarSubtotal();
          });
          return btn;
        }

        function agregarDetalle() {
          const cont = document.getElementById('detalles');
          const orig = cont.querySelector('.detalle');
          const clone = orig.cloneNode(true);
          // Limpiar valores
          clone.querySelectorAll('input').forEach(i => i.value = '');
          clone.querySelectorAll('select').forEach(s => s.selectedIndex = 0);
          // Añadir botón Eliminar
          const acc = document.createElement('div');
          acc.className = 'form-actions';
          acc.appendChild(crearBotonEliminar());
          clone.appendChild(acc);
          cont.appendChild(clone);
          // Re-asociar cálculo
          clone.querySelectorAll('input').forEach(i =>
            i.addEventListener('input', actualizarSubtotal)
          );
        }
      </script>
    </div>
  </main>
  
    <!-- Sección del footer -->
  <footer>
    <div class="copyright">
      <p>&copy; Ferretería Don Lu. Todos los derechos reservados.</p>
      <div class="div-logout">
        <a href="login.jsp">
          <i class="fa-solid fa-right-to-bracket icon-login"></i>
        </a>
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



