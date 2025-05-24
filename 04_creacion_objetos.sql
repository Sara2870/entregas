
-- Vistas
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

-- Funciones
DELIMITER //
CREATE FUNCTION obtener_total_operado(cuenta VARCHAR(20)) RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
  DECLARE total DECIMAL(12,2);
  SELECT SUM(importe) INTO total
  FROM operatoria
  WHERE nro_cuenta = cuenta;
  RETURN total;
END //
DELIMITER ;

-- Stored Procedures
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
END //

CREATE PROCEDURE listar_operaciones_por_cliente (
  IN p_cuil VARCHAR(20)
)
BEGIN
  SELECT * FROM operatoria
  WHERE cuil = p_cuil;
END //
DELIMITER ;

-- Triggers
DELIMITER //
CREATE TRIGGER valida_importe_positivo
BEFORE INSERT ON operatoria
FOR EACH ROW
BEGIN
  IF NEW.importe <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El importe debe ser mayor a cero';
  END IF;
END //
DELIMITER ;
