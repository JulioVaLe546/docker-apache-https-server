<?php
// 1. La lógica va PRIMERO, antes de cualquier HTML
$mensaje_error = ''; // Variable para guardar el error si falla el login

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $usuario = $_POST['usuario'];
    $contrasena = $_POST['contrasena'];

    if ($usuario === 'julio' && $contrasena === '1234') {
        // Como no hemos enviado HTML aún, esto funcionará perfecto
        header('Location: inicio.html');
        exit();
    } else {
        // Guardamos el mensaje en la variable para mostrarlo abajo
        $mensaje_error = '<p class="error">Usuario o contraseña incorrectos.</p>';
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - Committed Organization</title>

  <style>
    :root {
      --primary: #4fb6a3;   /* Verde principal del logo */
      --primary-dark: #3a9c8b;
      --bg-light: #eef7f5;
      --text-dark: #2f3e3b;
    }

    body {
      font-family: Arial, sans-serif;
      background: linear-gradient(135deg, #2fa89a, #3fb7a6);
      background-attachment: fixed;      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
    }

    .login-box {
      background: white;
      padding: 25px 20px;
      border-radius: 10px;
      box-shadow: 0 10px 25px rgba(0, 0, 0, 0.12);
      width: 320px;
      text-align: center;
    }

    .logo {
      width: 140px;
      margin-bottom: 10px;
    }

    h2 {
      color: var(--text-dark);
      margin-bottom: 15px;
    }

    input {
      width: 90%;
      padding: 10px;
      margin: 8px 0;
      border: 1px solid #ccc;
      border-radius: 5px;
      font-size: 14px;
    }

    input:focus {
      outline: none;
      border-color: var(--primary);
      box-shadow: 0 0 5px rgba(79, 182, 163, 0.4);
    }

    button {
      width: 95%;
      padding: 10px;
      background-color: var(--primary);
      color: white;
      border: none;
      border-radius: 5px;
      font-size: 15px;
      cursor: pointer;
      margin-top: 10px;
    }

    button:hover {
      background-color: var(--primary-dark);
    }

    .error {
      color: #c0392b;
      font-size: 14px;
      margin-top: 10px;
    }
    .forgot {
      display: block;
      margin: 8px 0 15px;
      font-size: 13px;
      color: #2fa89a;
      text-decoration: none;
    }

    .forgot:hover {
      text-decoration: underline;
    }
  </style>
</head>

<body>

  <div class="login-box">

    <!-- Logo -->
    <img src="committed_organization_logo.jpeg" alt="Committed Organization" class="logo">

    <h2>Iniciar sesión</h2>

    <form method="POST" action="">
      <input type="text" name="usuario" placeholder="Usuario" required>
      <input type="password" name="contrasena" placeholder="Contraseña" required>

      <a href="#" class="forgot">¿Olvidaste tu contraseña?</a>
      <button type="submit">Ingresar</button>
    </form>


  </div>

</body>
</html>

