# Stockflow

## Configuración local con XAMPP

1. Copia este proyecto dentro de `htdocs`.
2. Inicia **Apache** y **MySQL** desde el panel de XAMPP.
3. Entra a `http://localhost/phpmyadmin`.
4. Importa el archivo `base_datos.sql`.
5. Abre `http://localhost/inventario_avance1/acceso.php`.

La conexión usa por defecto `root` sin contraseña y la base de datos `stockflow`. Si tu instalación de XAMPP tiene otra configuración, ajusta las constantes de `conexion.php`.

Cuenta inicial:

- Correo: `admin@example.com`
- Contraseña: `admin123`
