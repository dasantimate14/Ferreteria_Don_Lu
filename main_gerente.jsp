<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dashboard de Gerente</title>
<link rel="stylesheet" href="css/styles.css" />
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
	      <li><a href="main_gerente.jsp">Inicio</a></li>
	      <li><a href="registro_empleado.jsp">Registrar empleado</a></li>
	      <li><a href="resumenVenta.jsp">Reporte de ventas</a></li>
	      <li><a href="auditoria.jsp">Reporte de auditoria</a></li>
	    </ul>
	  </nav>
	</header>
	
	<main class="main-notifications">
	  <h2>Notificaciones</h2>
	
	  <div class="notification">
	    <div class="notification-icon"><i class="fas fa-bell"></i></div>
	    <div class="notification-content">
	      <div class="notification-title">Nueva actualización</div>
	      <div class="notification-text">Se ha actualizado la plataforma a la versión 2.1.3 con nuevas funciones.</div>
	    </div>
	  </div>
	
	  <div class="notification">
	    <div class="notification-icon"><i class="fas fa-user-check"></i></div>
	    <div class="notification-content">
	      <div class="notification-title">Registro exitoso</div>
	      <div class="notification-text">Tu cuenta fue registrada correctamente. ¡Bienvenido!</div>
	    </div>
	  </div>
	
	  <div class="notification">
	    <div class="notification-icon"><i class="fas fa-exclamation-circle"></i></div>
	    <div class="notification-content">
	      <div class="notification-title">Atención requerida</div>
	      <div class="notification-text">Faltan datos por completar en tu perfil. Por favor, revisa tu información.</div>
	    </div>
	  </div>
	
	</main>
	
	<!-- Seccion del Footer -->
    <footer>
      <div class="copyright">
        <p>&copy; Ferreteria Don Lu. Todos los derechos reservados.</p>
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