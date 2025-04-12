CREATE DATABASE IF NOT EXISTS resolut_banco;
USE resolut_banco;

CREATE TABLE segmento (
    id_segmento INT PRIMARY KEY,
    nombre_segmento VARCHAR(50),
    limite_segmento DECIMAL(12,2)
);

CREATE TABLE clientes (
    id_cliente INT PRIMARY KEY,
    cuil VARCHAR(20),
    nombre_cliente VARCHAR(100),
    domicilio VARCHAR(150),
    cod_postal VARCHAR(10),
    mail VARCHAR(100),
    telefono VARCHAR(20),
    fecha_alta DATE,
    id_segmento INT,
    nro_cuenta VARCHAR(20),
    desc_actividad VARCHAR(150),
    perfil_ingresos DECIMAL(12,2),
    FOREIGN KEY (id_segmento) REFERENCES segmento(id_segmento)
);

CREATE TABLE operatoria (
    id_txn INT PRIMARY KEY,
    cuil VARCHAR(20),
    nombre VARCHAR(100),
    nro_cuenta VARCHAR(20),
    tipo VARCHAR(10),
    fecha DATE,
    descripcion VARCHAR(200),
    importe DECIMAL(12,2),
    contraparte VARCHAR(20)
);
