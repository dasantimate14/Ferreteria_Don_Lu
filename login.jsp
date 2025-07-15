<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Login</title>
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
	                <h2>Ferreteria Don Lu</h2>
	                
	                <form>
	                    <div class="form-group">
	                        <label for="username">Usuario *</label>
	                        <input type="text" id="username" name="username" placeholder="Ingrese el usuario" required>
	                    </div>
	                    
	                    <div class="form-group">
	                        <label for="password">Contraseña *</label>
	                        <input type="password" id="password" name="password" placeholder="Ingrese la contraseña" required>
	                    </div>
	                    
	                    
	                    <button type="submit" class="login-btn">LOGIN</button>
	                    
	                </form>
	                
	            </div>
	        </div>
	    </div>
    </main>
</html>