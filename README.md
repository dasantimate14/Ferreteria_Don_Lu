# Ferretería Don Lu

Este proyecto es una aplicación web básica construida con **JSP** (Java Server Pages), HTML y CSS. Su propósito es administrar un sistema de ventas e inventario para una ferretería ficticia. A continuación se describen los archivos más importantes y cómo funciona cada uno.

## Archivos HTML

### `HOME.html`
Página principal del sitio público. Contiene encabezado con menús y enlaces a redes sociales. El contenido principal es estático, con artículos informativos de muestra. El diseño se define en `css/styles.css`. No realiza consultas a base de datos.

### `Sobre_Nosotros.html`
Página estática que describe la empresa. Comparte la misma estructura de encabezado y pie de página que `HOME.html`.

## Archivos JSP
Los JSP combinan código HTML con scriptlets Java para realizar consultas en una base de datos Oracle y generar contenido dinámico.

### `login.jsp`
Maneja el inicio de sesión. Recibe `username` y `password` mediante `POST` y consulta la tabla **Empleado** para validar las credenciales:
```java
Class.forName("oracle.jdbc.OracleDriver");
con = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:XE", "owner_ferreteria", "1234567");
PreparedStatement ps = con.prepareStatement(
    "SELECT emp_id, emp_nombre, emp_puesto FROM Empleado WHERE emp_email = ? AND emp_contrasena = ?"
);
```
Si encuentra un registro, guarda en sesión el id, nombre y puesto. Luego redirige a la página principal según el rol (cajero, inventario o gerente). En caso contrario muestra un mensaje de error.

### `POS.jsp`
Módulo de punto de venta. Al cargarse consulta el inventario disponible y guarda los productos en una lista de mapas Java. Los productos agregados a la venta se almacenan en la sesión (`session.getAttribute("productos")`). Los bloques `while` recorren estas listas para mostrar las opciones y los productos agregados.

Cuando se envía la acción `pagar` se ejecutan dos procedimientos almacenados: `SP_REGISTRAR_VENTA` para registrar la venta y `SP_AGREGAR_DETALLE_VENTA` para cada producto. Después de procesar la venta se limpia la lista en sesión.

### `inventario.jsp`
Muestra la vista de inventario para el cajero. Dentro de un ciclo `while (rs.next())` se recorren los registros obtenidos de `VISTA_INV_DETALLADO_CAJA` para pintar cada fila de la tabla. Según la cantidad disponible se asigna una clase CSS que colorea la etiqueta de stock.

### `registroCliente.jsp`
Permite registrar nuevos clientes y mostrar los existentes. Los datos se envían a un procedimiento `SP_REGISTRAR_CLIENTE` y el id generado se muestra en pantalla. Otro `while (rs.next())` recorre los clientes existentes para crear las filas de la tabla.

### `registro_empleado.jsp`
Página para gestionar empleados. Incluye tres operaciones:
- Registrar nuevo empleado (`SP_REGISTRAR_EMPLEADO`).
- Actualizar salario y puesto (`SP_ACTUALIZAR_EMPLEADO`).
- Eliminar empleado por id o por cédula (`SP_ELIMINAR_EMPLEADO` o `SP_ELIMINAR_EMPLEADO_CEDULA`).

Los datos de cada empleado se muestran recorriendo el `ResultSet` con un `while`.

### `main_cajero.jsp`, `main_enc_inven.jsp`, `main_gerente.jsp`
Son paneles de inicio para cada rol. Solo contienen HTML estático con enlaces a las secciones correspondientes.

### `enc_inventario.jsp`
Panel completo para el encargado de inventario. Ejecuta varias consultas:
- `V_INVENTARIO_RESUMEN` para obtener métricas generales.
- `V_PRODUCTOS_CRITICOS`, `V_PEDIDOS_PENDIENTES`, `V_PEDIDOS_ENTREGADOS_SEMANA` y `V_PEDIDOS_COMPLETADOS` para llenar distintas tablas.

Cada consulta se procesa con un `while (rs.next())` que arma las filas de las tablas. También se generan enlaces para registrar recepción de pedidos.

### `agregar_producto.jsp`
Formulario para agregar productos nuevos. Primero carga listas de categorías y proveedores, luego si se envía el formulario llama a:
- `SP_REGISTRAR_CATEGORIA` si el usuario creó una nueva categoría.
- `SP_REGISTRAR_PRODUCTO` para guardar el producto.
- `SP_INSERTAR_PRODUCTO_PROVEEDOR` para asociar proveedores.

Se usan bloques `for` para recorrer las listas y crear las opciones de los `select`.

### `agregar_proveedor.jsp`
Permite registrar proveedores y listar los existentes. Usa `SP_REGISTRAR_PROVEEDOR` para guardar la información. Un `while` muestra todos los proveedores consultando la tabla **Proveedor**.

### `solicitud_reabastecimiento.jsp`
Genera pedidos de reabastecimiento. Carga productos y proveedores, almacena todo en estructuras `List` y `Map`. Al enviar el formulario registra el pedido con `SP_REGISTRAR_PEDIDO_REAB` y cada detalle con `SP_REGISTRAR_DET_REAB`. Utiliza JavaScript para clonar campos dinámicamente y calcular el subtotal en el navegador.

### `historial_inventario.jsp`
Muestra historial de movimientos de inventario. Tres consultas (`V_AUMENTOS_INVENTARIO`, `V_SALIDAS_INVENTARIO`, `V_MOVIMIENTOS_INVENTARIO`) alimentan sus respectivas tablas.

### `auditoria.jsp`
Reporte de auditoría configurable. Dependiendo de la tabla seleccionada ejecuta una consulta distinta (por ejemplo `V_AUDITORIA_GENERAL`, `AUD_INVENTARIO`, `AUD_VENTA`, etc.). Luego se recorre el `ResultSet` para generar la tabla de resultados.

### `resumenVenta.jsp`
Página de reportes de ventas. Calcula métricas generales (total de transacciones, monto acumulado y producto más vendido) y luego muestra el inventario con un `while` sobre `VISTA_INV_DETALLADO_CAJA`.

### `recibir_pedido.jsp`
Se invoca al recibir un pedido. Llama a `SP_REGISTRAR_RECEPCION_PEDIDO` y luego `SP_PROCESAR_RECEPCIONES_PEDIDO`. Obtiene el nombre del producto y proveedor para mostrar una alerta y redirigir al inventario.

## Estructura de CSS
Los estilos principales se encuentran en `css/styles.css`, `css/pos.css`, `css/tabla.css`, `css/enc_inventario.css` y `css/historial_inv.css`. Estos archivos definen las reglas de diseño que afectan a los componentes HTML:

- **Layout general**: bordes, márgenes y tipografía global.
- **Encabezado y navegación**: colores, tamaños de fuente e iconos. Los enlaces activos cambian de color mediante las clases CSS.
- **Tablas** (`tabla.css`): definen estilos responsivos para tablas usadas en reportes e inventarios.
- **Formularios**: clases para campos, botones y mensajes de éxito o error.
- **POS y paneles** (`pos.css`, `enc_inventario.css`, `historial_inv.css`): contienen grid y flexbox para acomodar formularios y listas, además de colores para indicar estados (por ejemplo `quantity-low`, `quantity-high`).

Cada JSP y HTML enlaza las hojas de estilo con `<link rel="stylesheet" href="...">` para aplicar el formato. Muchas tablas cambian colores de las celdas dependiendo de las clases asignadas en los bucles de Java.

## Conexión a la base de datos
Todos los JSP que acceden a la base de datos utilizan el driver Oracle:
```java
Class.forName("oracle.jdbc.OracleDriver");
Connection conn = DriverManager.getConnection(
    "jdbc:oracle:thin:@localhost:1521:XE",
    "owner_ferreteria",
    "1234567"
);
```
Las consultas se realizan principalmente con `PreparedStatement` o `CallableStatement` (para procedimientos almacenados). Después de usarlos se cierran explícitamente en bloques `finally`.

## Cómo ejecutar
Este proyecto está pensado para desplegarse en un contenedor que soporte JSP (por ejemplo Apache Tomcat). Coloque los archivos en la carpeta adecuada del servidor, configure la conexión a la base de datos en cada JSP si cambia las credenciales y acceda mediante el navegador.

