
-- SCRIPT DE CREACION DE OBJETOS DEL PROYECTO FINAL
-- Proyecto SQL - Rionda

-- TABLAS PRINCIPALES

-- Tabla de segmentos
CREATE TABLE segmento (
  id_segmento INT PRIMARY KEY,
  nombre_segmento VARCHAR(50),
  limite_segmento DECIMAL(15,2)
);

-- Tabla de clientes
CREATE TABLE clientes (
  id_cliente INT PRIMARY KEY,
  cuil VARCHAR(20),
  nombre_cliente VARCHAR(100),
  domicilio VARCHAR(255),
  cod_postal VARCHAR(10),
  mail VARCHAR(100),
  telefono VARCHAR(20),
  fecha_alta DATE,
  id_segmento INT,
  nro_cuenta VARCHAR(20),
  desc_actividad VARCHAR(255),
  perfil_ingresos DECIMAL(15,2),
  FOREIGN KEY (id_segmento) REFERENCES segmento(id_segmento)
);

-- Tabla de operatoria (TABLA DE HECHOS)
CREATE TABLE operatoria (
  id_txn INT PRIMARY KEY,
  cuil VARCHAR(20),
  nombre VARCHAR(100),
  nro_cuenta VARCHAR(20),
  tipo VARCHAR(50),
  fecha DATE,
  descripcion VARCHAR(255),
  importe DECIMAL(15,2),
  contraparte VARCHAR(20)
);

-- Tabla de alertas (TRANSACCIONAL 1)
CREATE TABLE alertas (
  id_alerta INT AUTO_INCREMENT PRIMARY KEY,
  nro_cuenta VARCHAR(20),
  fecha_alerta DATETIME,
  motivo VARCHAR(255)
);

-- Tabla de tipo_operacion
CREATE TABLE tipo_operacion (
  id_tipo INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(50)
);

-- Tabla de sucursales
CREATE TABLE sucursal (
  id_sucursal INT AUTO_INCREMENT PRIMARY KEY,
  nombre_sucursal VARCHAR(100),
  provincia VARCHAR(100)
);

-- Tabla de productos
CREATE TABLE producto_bancario (
  id_producto INT AUTO_INCREMENT PRIMARY KEY,
  tipo_producto VARCHAR(50),
  descripcion TEXT
);

-- Tabla de relación cliente-producto (TRANSACCIONAL 2)
CREATE TABLE cliente_producto (
  id_cliente INT,
  id_producto INT,
  fecha_alta DATE,
  PRIMARY KEY (id_cliente, id_producto),
  FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
  FOREIGN KEY (id_producto) REFERENCES producto_bancario(id_producto)
);

-- Tabla de logs de operaciones
CREATE TABLE logs_operaciones (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  nro_cuenta VARCHAR(20),
  tipo_evento VARCHAR(100),
  fecha_evento DATETIME,
  detalle TEXT
);

-- Tabla de accesos al sistema
CREATE TABLE accesos_sistema (
  id_acceso INT AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(50),
  fecha_acceso DATETIME,
  resultado VARCHAR(20)
);

-- Tabla de auditoría de correos electrónicos
CREATE TABLE auditoria_email (
  id_email INT AUTO_INCREMENT PRIMARY KEY,
  destinatario VARCHAR(100),
  asunto VARCHAR(200),
  fecha_envio DATETIME
);

-- VISTAS

CREATE VIEW vista_clientes_segmento AS
SELECT c.nombre_cliente, c.nro_cuenta, s.nombre_segmento, s.limite_segmento
FROM clientes c
JOIN segmento s ON c.id_segmento = s.id_segmento;

CREATE VIEW vista_operaciones_altas AS
SELECT o.nombre, o.nro_cuenta, o.tipo, o.fecha, o.importe
FROM operatoria o
WHERE o.fecha >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

CREATE VIEW vista_alertas_montos AS
SELECT o.*, c.nombre_cliente
FROM operatoria o
JOIN clientes c ON o.nro_cuenta = c.nro_cuenta
WHERE o.importe > 250000;

CREATE VIEW vista_clientes_riesgo_alto AS
SELECT c.nombre_cliente, c.nro_cuenta, s.nombre_segmento, o.importe, o.descripcion
FROM operatoria o
JOIN clientes c ON o.nro_cuenta = c.nro_cuenta
JOIN segmento s ON c.id_segmento = s.id_segmento
WHERE o.importe > s.limite_segmento * 0.8;

CREATE VIEW vista_operaciones_frecuentes AS
SELECT c.nro_cuenta, COUNT(*) AS cantidad_operaciones
FROM operatoria o
JOIN clientes c ON o.nro_cuenta = c.nro_cuenta
WHERE o.fecha >= DATE_SUB(CURDATE(), INTERVAL 15 DAY)
GROUP BY c.nro_cuenta
HAVING COUNT(*) > 5;

-- FUNCIONES

DELIMITER //
CREATE FUNCTION obtener_total_operado(cuenta VARCHAR(20)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(12,2);
  SELECT SUM(importe) INTO total
  FROM operatoria
  WHERE nro_cuenta = cuenta;
  RETURN total;
END;
//

CREATE FUNCTION calcular_promedio_operaciones(cuenta VARCHAR(20)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  DECLARE promedio DECIMAL(12,2);
  SELECT AVG(importe) INTO promedio
  FROM operatoria
  WHERE nro_cuenta = cuenta;
  RETURN promedio;
END;
//
DELIMITER ;

-- STORED PROCEDURES

DELIMITER //
CREATE PROCEDURE insertar_cliente (
  IN p_cuil VARCHAR(20),
  IN p_nombre VARCHAR(100),
  IN p_mail VARCHAR(100),
  IN p_id_segmento INT,
  IN p_nro_cuenta VARCHAR(20)
)
BEGIN
  INSERT INTO clientes (cuil, nombre_cliente, mail, id_segmento, nro_cuenta)
  VALUES (p_cuil, p_nombre, p_mail, p_id_segmento, p_nro_cuenta);
END;
//

CREATE PROCEDURE listar_operaciones_por_cliente (
  IN p_cuil VARCHAR(20)
)
BEGIN
  SELECT * FROM operatoria
  WHERE cuil = p_cuil;
END;
//
DELIMITER ;

-- TRIGGERS

DELIMITER //
CREATE TRIGGER valida_importe_positivo
BEFORE INSERT ON operatoria
FOR EACH ROW
BEGIN
  IF NEW.importe <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El importe debe ser mayor a cero';
  END IF;
END;
//

CREATE TRIGGER log_operaciones_altas
AFTER INSERT ON operatoria
FOR EACH ROW
BEGIN
  IF NEW.importe > 400000 THEN
    INSERT INTO alertas (nro_cuenta, fecha_alerta, motivo)
    VALUES (NEW.nro_cuenta, NOW(), CONCAT('Importe alto: ', NEW.importe));
  END IF;
END;
//
DELIMITER ;
