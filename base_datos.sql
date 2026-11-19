CREATE DATABASE IF NOT EXISTS stockflow
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE stockflow;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS movimiento_detalles;
DROP TABLE IF EXISTS movimientos;
DROP TABLE IF EXISTS existencias;
DROP TABLE IF EXISTS productos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS almacenes;
DROP TABLE IF EXISTS usuarios;

SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE usuarios (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    correo VARCHAR(254) NOT NULL UNIQUE,
    contrasena VARCHAR(255) NOT NULL,
    rol ENUM('administrador', 'encargado', 'consulta') NOT NULL DEFAULT 'consulta',
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE categorias (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(80) NOT NULL,
    descripcion VARCHAR(255) NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE almacenes (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    ubicacion VARCHAR(200) NOT NULL,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE = InnoDB;

CREATE TABLE productos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(120) NOT NULL,
    categoria_id INT UNSIGNED NOT NULL,
    unidad_medida ENUM('pieza', 'caja', 'paquete') NOT NULL DEFAULT 'pieza',
    descripcion VARCHAR(500) NULL,
    stock_minimo INT UNSIGNED NOT NULL DEFAULT 0,
    estado ENUM('activo', 'inactivo') NOT NULL DEFAULT 'activo',
    creado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_productos_categorias
        FOREIGN KEY (categoria_id) REFERENCES categorias(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE existencias (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    producto_id INT UNSIGNED NOT NULL,
    almacen_id INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL DEFAULT 0,
    actualizado_en TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_existencia_producto_almacen UNIQUE (producto_id, almacen_id),
    CONSTRAINT fk_existencias_productos
        FOREIGN KEY (producto_id) REFERENCES productos(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_existencias_almacenes
        FOREIGN KEY (almacen_id) REFERENCES almacenes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE movimientos (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    folio VARCHAR(30) NOT NULL UNIQUE,
    tipo ENUM('entrada', 'salida', 'traslado') NOT NULL,
    usuario_id INT UNSIGNED NOT NULL,
    almacen_origen_id INT UNSIGNED NULL,
    almacen_destino_id INT UNSIGNED NULL,
    referencia VARCHAR(80) NULL,
    motivo VARCHAR(500) NOT NULL,
    fecha TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_movimientos_usuarios
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_origen
        FOREIGN KEY (almacen_origen_id) REFERENCES almacenes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimientos_destino
        FOREIGN KEY (almacen_destino_id) REFERENCES almacenes(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE movimiento_detalles (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    movimiento_id INT UNSIGNED NOT NULL,
    producto_id INT UNSIGNED NOT NULL,
    cantidad INT UNSIGNED NOT NULL,
    CONSTRAINT fk_detalles_movimientos
        FOREIGN KEY (movimiento_id) REFERENCES movimientos(id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_detalles_productos
        FOREIGN KEY (producto_id) REFERENCES productos(id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE INDEX idx_productos_categoria ON productos(categoria_id);
CREATE INDEX idx_existencias_almacen ON existencias(almacen_id);
CREATE INDEX idx_movimientos_fecha ON movimientos(fecha);
CREATE INDEX idx_movimientos_tipo ON movimientos(tipo);
CREATE INDEX idx_detalles_producto ON movimiento_detalles(producto_id);

INSERT INTO usuarios (codigo, nombre, correo, contrasena, rol, estado)
VALUES (
    'US-001',
    'Usuario administrador',
    'admin@example.com',
    '$2y$12$MPtE2nN3aln7haZQM8Q8NevpcoIH7GW1TtIMG3nBWe9JyiYWxuKMu',
    'administrador',
    'activo'
);
