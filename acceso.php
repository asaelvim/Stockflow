<?php

require_once __DIR__ . "/config.php";

if (usuarioAutenticado()) {
    redirigir("index.html");
}

$errores = [];
$correo = $_COOKIE["stockflow_correo"] ?? "";

if ($_SERVER["REQUEST_METHOD"] === "POST") {
    $correo = trim($_POST["correo"] ?? "");
    $contrasena = $_POST["contrasena"] ?? "";
    $recordarCorreo = isset($_POST["recordar_correo"]);

    if (!filter_var($correo, FILTER_VALIDATE_EMAIL)) {
        $errores[] = "Escribe un correo electrónico válido.";
    }

    if ($contrasena === "") {
        $errores[] = "Escribe tu contraseña.";
    }

    $usuarioEncontrado = null;
    if (count($errores) === 0) {
        try {
            $conexion = obtenerConexion();
            $consulta = $conexion->prepare(
                "SELECT id, codigo, nombre, correo, contrasena, rol
                 FROM usuarios
                 WHERE correo = :correo AND estado = 'activo'
                 LIMIT 1"
            );
            $consulta->execute(["correo" => $correo]);
            $usuarioEncontrado = $consulta->fetch();
        } catch (PDOException $error) {
            $errores[] = "No se pudo conectar con la base de datos. Verifica que MySQL esté iniciado en XAMPP.";
        }
    }

    if (
        count($errores) === 0
        && (!$usuarioEncontrado || !password_verify($contrasena, $usuarioEncontrado["contrasena"]))
    ) {
        $errores[] = "El correo o la contraseña no son correctos.";
    }

    if (count($errores) === 0) {
        session_regenerate_id(true);
        $_SESSION["usuario"] = [
            "id" => $usuarioEncontrado["codigo"],
            "nombre" => $usuarioEncontrado["nombre"],
            "correo" => $usuarioEncontrado["correo"],
            "rol" => $usuarioEncontrado["rol"],
            "inicio" => date("c"),
        ];

        if ($recordarCorreo) {
            setcookie("stockflow_correo", $correo, [
                "expires" => time() + (60 * 60 * 24 * 30),
                "path" => "/",
                "httponly" => true,
                "samesite" => "Lax",
            ]);
        } else {
            setcookie("stockflow_correo", "", [
                "expires" => time() - 3600,
                "path" => "/",
                "httponly" => true,
                "samesite" => "Lax",
            ]);
        }

        redirigir("index.html");
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Acceso · Stockflow</title>
  <link rel="stylesheet" href="estilos.css">
</head>
<body>
  <a class="saltar" href="#contenido">Saltar al contenido</a>
  <main class="acceso" id="contenido">
    <section class="presentacion" aria-labelledby="presentacion-titulo">
      <a class="marca" href="index.html">Stockflow<span aria-hidden="true">.</span></a>
      <p class="ceja">Gestión de inventario</p>
      <h1 id="presentacion-titulo">Cada producto.<br>Cada movimiento.<br>En un solo lugar.</h1>
      <p>Consulta existencias, organiza tus almacenes y mantén un historial claro de las entradas y salidas.</p>
      <p class="aviso"><strong>Cuenta de demostración:</strong> admin@example.com / admin123</p>
    </section>
    <section class="panel panel-acceso" aria-labelledby="acceso-titulo">
      <h2 id="acceso-titulo">Accede a tu cuenta</h2>
      <p class="ayuda">Los campos marcados con * son obligatorios.</p>
      <?php if (count($errores) > 0): ?>
        <div class="aviso" role="alert">
          <strong>No se pudo iniciar sesión.</strong>
          <ul>
            <?php foreach ($errores as $error): ?>
              <li><?= escapar($error) ?></li>
            <?php endforeach; ?>
          </ul>
        </div>
      <?php endif; ?>
      <form method="POST" action="acceso.php">
        <label for="correo">Correo electrónico *</label>
        <input id="correo" name="correo" type="email" autocomplete="username" value="<?= escapar($correo) ?>" required>
        <label for="contrasena">Contraseña *</label>
        <input id="contrasena" name="contrasena" type="password" autocomplete="current-password" required>
        <label><input type="checkbox" name="recordar_correo" value="1"> Recordar mi correo</label>
        <div class="acciones">
          <button type="submit">Iniciar sesión</button>
          <a class="boton secundario" href="index.html">Volver a la maqueta</a>
        </div>
      </form>
    </section>
  </main>
  <footer>Stockflow · Acceso PHP · <?= escapar($_SERVER["SERVER_NAME"] ?? "servidor local") ?></footer>
</body>
</html>
