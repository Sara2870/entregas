
-- SCRIPT DE INSERCIÓN DE DATOS DEL PROYECTO FINAL
-- Proyecto SQL - Rionda

-- Inserción en tabla tipo_operacion
INSERT INTO tipo_operacion (descripcion) VALUES
('Transferencia'), ('Depósito'), ('Extracción'), ('Cheque');

-- Inserción en tabla sucursal
INSERT INTO sucursal (nombre_sucursal, provincia) VALUES
('Sucursal Centro', 'Buenos Aires'),
('Sucursal Norte', 'Córdoba'),
('Sucursal Sur', 'Mendoza');

-- Inserción en tabla producto_bancario
INSERT INTO producto_bancario (tipo_producto, descripcion) VALUES
('Cuenta Corriente', 'Cuenta en pesos con chequera'),
('Caja de Ahorro', 'Caja de ahorro en pesos'),
('Plazo Fijo', 'Depósito a término');

-- Inserción en tabla cliente_producto
INSERT INTO cliente_producto (id_cliente, id_producto, fecha_alta) VALUES
(1, 1, '2023-01-15'),
(2, 2, '2023-06-10'),
(3, 3, '2024-02-21');

-- Inserción en tabla logs_operaciones
INSERT INTO logs_operaciones (nro_cuenta, tipo_evento, fecha_evento, detalle) VALUES
('00123456789', 'Alta Operación', NOW(), 'Operación de crédito registrada'),
('00123456790', 'Baja Operación', NOW(), 'Se anuló una operación');

-- Inserción en tabla accesos_sistema
INSERT INTO accesos_sistema (usuario, fecha_acceso, resultado) VALUES
('admin', NOW(), 'OK'),
('auditor1', NOW(), 'FAIL');

-- Inserción en tabla auditoria_email
INSERT INTO auditoria_email (destinatario, asunto, fecha_envio) VALUES
('cliente1@correo.com', 'Alerta de movimiento', NOW()),
('cliente2@correo.com', 'Resumen mensual', NOW());
