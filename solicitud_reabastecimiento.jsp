<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Solicitud de Reabastecimiento</title>
    <link rel="stylesheet" href="css/styles.css">
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
<h2>Registrar Pedido de Reabastecimiento</h2>
<%
    // Conexión directa vía DriverManager
    String dbURL  = "jdbc:oracle:thin:@localhost:1521:XE";
  	String dbUser = "owner_ferreteria";
  	String dbPass = "1234567";
    List<String[]> productos = new ArrayList<>();
    Map<Integer, List<String[]>> prodProvs = new HashMap<>();
    String mensaje = null;
    try {
        Class.forName("oracle.jdbc.OracleDriver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);

        PreparedStatement ps = conn.prepareStatement("SELECT pro_id, pro_nombre FROM Producto ORDER BY pro_nombre");
        ResultSet rs = ps.executeQuery();
        while (rs.next()) productos.add(new String[]{rs.getString(1), rs.getString(2)});
        rs.close(); ps.close();

        // Para cada producto cargar proveedores válidos
        for (String[] prod : productos) {
            int pid = Integer.parseInt(prod[0]);
            ps = conn.prepareStatement(
                "SELECT pr.prv_id, pr.prv_nombre FROM Producto_Proveedor pp " +
                "JOIN Proveedor pr ON pp.prv_id = pr.prv_id WHERE pp.pro_id=? ORDER BY pr.prv_nombre");
            ps.setInt(1, pid);
            rs = ps.executeQuery();
            List<String[]> provList = new ArrayList<>();
            while (rs.next()) provList.add(new String[]{rs.getString(1), rs.getString(2)});
            prodProvs.put(pid, provList);
            rs.close(); ps.close();
        }
        conn.close();
    } catch(Exception err) {
        mensaje = "Error cargando productos/proveedores: " + err.getMessage();
    }
    // JS: producto->proveedores
    StringBuilder proveedoresPorProductoJS = new StringBuilder("{");
    for (String[] prod : productos) {
        int pid = Integer.parseInt(prod[0]);
        proveedoresPorProductoJS.append(pid).append(": [");
        List<String[]> provs = prodProvs.get(pid);
        if (provs != null) {
            for (int j = 0; j < provs.size(); j++) {
                String[] p = provs.get(j);
                proveedoresPorProductoJS.append("{id: ").append(p[0]).append(", nombre: '").append(p[1].replace("'", "\\'")).append("'}");
                if (j < provs.size() - 1) proveedoresPorProductoJS.append(",");
            }
        }
        proveedoresPorProductoJS.append("],");
    }
    if (productos.size() > 0) proveedoresPorProductoJS.setLength(proveedoresPorProductoJS.length() - 1);
    proveedoresPorProductoJS.append("}");
    // Pre-armar el HTML del select de productos para usar en JS
    StringBuilder selectProductoHtml = new StringBuilder();
    selectProductoHtml.append("<select name='producto_id' class='sel-prod' required onchange='cargarProveedores(this)'>");
    selectProductoHtml.append("<option value=''>Seleccione...</option>");
    for (String[] p : productos) {
        selectProductoHtml.append("<option value='").append(p[0]).append("'>").append(p[1]).append("</option>");
    }
    selectProductoHtml.append("</select>");
    request.setAttribute("selectProductoHtml", selectProductoHtml.toString());
%>

<form method="post">
    <label>Descripción:</label>
    <input type="text" name="descripcion" required><br>
    <label>Subtotal:</label>
<input type="number" name="sub_total" id="sub_total" step="0.01" readonly required><br>
    <h3>Agregar Detalles del Pedido</h3>
    <div id="detalles">
        <div class="detalle">
            <label>Producto:</label>
            <%= request.getAttribute("selectProductoHtml") %>
            <label>Proveedor:</label>
            <select name="proveedor_id" class="sel-prov" required>
                <option value="">Seleccione producto primero</option>
            </select>
            <label>Precio de Compra:</label>
            <input type="number" step="0.01" name="precio_u" required>
            <label>Cantidad:</label>
            <input type="number" name="cantidad" required>
        </div>
    </div>
    <button type="button" class="positive-btn" onclick="agregarDetalle()">Agregar Otro Producto</button>
    <br><br>
    <input type="submit" class="positive-btn" value="Registrar Pedido">
</form>
<script>
const proveedoresPorProducto = <%=proveedoresPorProductoJS.toString()%>;
var prodSelHtml = `<%=request.getAttribute("selectProductoHtml")%>`;

// Agrega listeners para el cálculo automático del subtotal en todos los detalles
function actualizarSubtotal() {
    let subtotal = 0;
    document.querySelectorAll('#detalles .detalle').forEach(detalle => {
        let precio = parseFloat(detalle.querySelector('input[name="precio_u"]').value) || 0;
        let cantidad = parseInt(detalle.querySelector('input[name="cantidad"]').value) || 0;
        subtotal += precio * cantidad;
    });
    document.getElementById('sub_total').value = subtotal > 0 ? subtotal.toFixed(2) : '';
}

function activarCalculoDetalle(detalle) {
    let precioInput = detalle.querySelector('input[name="precio_u"]');
    let cantidadInput = detalle.querySelector('input[name="cantidad"]');
    if (precioInput && cantidadInput) {
        precioInput.addEventListener('input', actualizarSubtotal);
        cantidadInput.addEventListener('input', actualizarSubtotal);
    }
}

// Llama al cargar la página
document.querySelectorAll('#detalles .detalle').forEach(activarCalculoDetalle);

function cargarProveedores(selProd) {
    let prodId = selProd.value;
    let detalleDiv = selProd.closest('.detalle');
    let selProv = detalleDiv.querySelector('.sel-prov');
    selProv.innerHTML = '<option value="">Seleccione...</option>';
    if (prodId && proveedoresPorProducto[prodId]) {
        for (let prov of proveedoresPorProducto[prodId]) {
            let opt = document.createElement('option');
            opt.value = prov.id;
            opt.text = prov.nombre;
            selProv.appendChild(opt);
        }
    }
}

// Agregar nuevo detalle
function agregarDetalle() {
    let detallesDiv = document.getElementById('detalles');
    let primerDetalle = detallesDiv.querySelector('.detalle');
    let nuevoDetalle = primerDetalle.cloneNode(true);

    // Limpiar los valores
    nuevoDetalle.querySelectorAll('input').forEach(input => input.value = '');
    nuevoDetalle.querySelectorAll('select').forEach(select => select.selectedIndex = 0);

    // Limpiar el select de proveedores
    let selectProv = nuevoDetalle.querySelector('.sel-prov');
    selectProv.innerHTML = '<option value="">Seleccione producto primero</option>';

    // Agregar botón eliminar si no existe
    if (!nuevoDetalle.querySelector('button[onclick*="remove"]')) {
        let btnEliminar = document.createElement('button');
        btnEliminar.type = 'button';
        btnEliminar.textContent = 'Eliminar';
        btnEliminar.style.marginLeft = "1em";
        btnEliminar.onclick = function() { 
            this.parentNode.remove(); 
            actualizarSubtotal();
        };
        nuevoDetalle.appendChild(btnEliminar);
    }

    detallesDiv.appendChild(nuevoDetalle);

    // Activar el cálculo en el nuevo detalle
    activarCalculoDetalle(nuevoDetalle);
}
</script>

<%
if (request.getMethod().equalsIgnoreCase("post")) {
    Connection conn2 = null;
    CallableStatement cstmt = null;
    try {
        Class.forName("oracle.jdbc.OracleDriver");
        conn2 = DriverManager.getConnection(dbURL, dbUser, dbPass);
        cstmt = conn2.prepareCall("{ call SP_REGISTRAR_PEDIDO_REAB(?, ?, ?) }");
        cstmt.setString(1, request.getParameter("descripcion"));
        cstmt.setDouble(2, Double.parseDouble(request.getParameter("sub_total")));
        cstmt.registerOutParameter(3, java.sql.Types.NUMERIC);
        cstmt.execute();
        int pedidoId = cstmt.getInt(3);
        cstmt.close();
        String[] prodArr = request.getParameterValues("producto_id");
        String[] provArr = request.getParameterValues("proveedor_id");
        String[] precArr = request.getParameterValues("precio_u");
        String[] cantArr = request.getParameterValues("cantidad");
        if (prodArr != null && prodArr.length > 0) {
            for (int i = 0; i < prodArr.length; i++) {
                cstmt = conn2.prepareCall("{ call SP_REGISTRAR_DET_REAB(?, ?, ?, ?, ?) }");
                cstmt.setInt(1, pedidoId);
                cstmt.setInt(2, Integer.parseInt(prodArr[i]));
                cstmt.setInt(3, Integer.parseInt(provArr[i]));
                cstmt.setDouble(4, Double.parseDouble(precArr[i]));
                cstmt.setInt(5, Integer.parseInt(cantArr[i]));
                cstmt.execute();
                cstmt.close();
            }
        }
        mensaje = "Pedido de reabastecimiento registrado exitosamente con ID " + pedidoId;
    } catch(Exception ex) {
        mensaje = "Error al registrar pedido: " + ex.getMessage();
    } finally {
        try { if (cstmt != null) cstmt.close(); } catch(Exception e){}
        try { if (conn2 != null) conn2.close(); } catch(Exception e){}
    }
}
if (mensaje != null) {
%>
    <div class="mt-20 <%= mensaje.startsWith("Error")?"mensaje-error":"mensaje-exito" %>">
        <%= mensaje %>
    </div>
<% } %>
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



