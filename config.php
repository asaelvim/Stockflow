<?php

session_start();

require_once __DIR__ . "/conexion.php";

function escapar($valor)
{
    return htmlspecialchars((string) $valor, ENT_QUOTES, "UTF-8");
}

function redirigir($ruta)
{
    header("Location: " . $ruta);
    exit;
}

function usuarioAutenticado()
{
    return $_SESSION["usuario"] ?? null;
}
