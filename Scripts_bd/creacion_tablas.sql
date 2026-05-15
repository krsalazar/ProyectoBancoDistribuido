-- 1. Catálogos y Entidades Independientes
CREATE TABLE sucursales (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT,
    telefono VARCHAR(20),
    ciudad VARCHAR(100),
    codigo_postal VARCHAR(10),
    fecha_apertura DATE,
    activa BOOLEAN DEFAULT TRUE
);

CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    permisos_json JSONB -- Para manejo flexible de permisos
);

CREATE TABLE tipos_cuenta (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL, -- Ej: 'Ahorro', 'Monetaria'
    tasa_interes DECIMAL(5, 4),
    saldo_minimo DECIMAL(15, 2),
    permite_sobregiro BOOLEAN DEFAULT FALSE
);

CREATE TABLE tipos_transaccion (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(10) UNIQUE NOT NULL, -- Ej: 'TRANS_INT'
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    requiere_autoriz BOOLEAN DEFAULT FALSE
);

-- 2. Usuarios del Sistema (Cajeros/Admins)
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    rol_id INT REFERENCES roles(id),
    sucursal_id INT REFERENCES sucursales(id),
    activo BOOLEAN DEFAULT TRUE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ultimo_acceso TIMESTAMP
);

-- 3. Clientes y Cuentas
CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    numero_cliente VARCHAR(20) UNIQUE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    tipo_documento VARCHAR(20),
    numero_doc VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(150),
    telefono VARCHAR(20),
    direccion TEXT,
    ciudad VARCHAR(100),
    fecha_nac DATE,
    fecha_reg TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activo BOOLEAN DEFAULT TRUE
);

CREATE TABLE cuentas (
    id SERIAL PRIMARY KEY,
    numero_cuenta VARCHAR(20) UNIQUE NOT NULL,
    cliente_id INT REFERENCES clientes(id),
    tipo_cuenta_id INT REFERENCES tipos_cuenta(id),
    sucursal_id INT REFERENCES sucursales(id),
    saldo DECIMAL(15, 2) DEFAULT 0.00,
    fecha_apertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'Activa',
    limite_sobregiro DECIMAL(15, 2) DEFAULT 0.00
);

-- 4. Operaciones y Control
CREATE TABLE transacciones (
    id SERIAL PRIMARY KEY,
    cuenta_origen_id INT REFERENCES cuentas(id),
    cuenta_destino_id INT REFERENCES cuentas(id),
    tipo_transaccion_id INT REFERENCES tipos_transaccion(id),
    monto DECIMAL(15, 2) NOT NULL,
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT,
    usuario_id INT REFERENCES usuarios(id), -- El cajero o usuario que operó
    referencia VARCHAR(50),
    estado VARCHAR(20),
    ip_origen VARCHAR(45)
);

CREATE TABLE auditoria (
    id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(50),
    operacion VARCHAR(10),
    registro_id INT,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    usuario_id INT REFERENCES usuarios(id),
    fecha_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45)
);