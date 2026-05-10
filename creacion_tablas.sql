-- (Seguridad y Autorización)
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    nombre_role VARCHAR(50) UNIQUE NOT NULL --'Admin', 'Cajero', 'Cliente'
);


CREATE TABLE clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    cui VARCHAR(13) UNIQUE NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL, -- Para autenticación
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Cuentas (Integridad Referencial)
CREATE TABLE cuentas (
    cuenta_id SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES clientes(cliente_id) ON DELETE CASCADE,
    tipo_cuenta VARCHAR(20) CHECK (tipo_cuenta IN ('Ahorro', 'Monetaria')),
    saldo DECIMAL(15, 2) DEFAULT 0.00 CHECK (saldo >= 0), -- Integridad de datos
    moneda VARCHAR(3) DEFAULT 'GTQ',
    estado BOOLEAN DEFAULT TRUE
);

--Tipos de Transacción (Catálogo)
CREATE TABLE tipos_transaccion (
    tipo_id SERIAL PRIMARY KEY,
    nombre_operacion VARCHAR(50) NOT NULL --'Deposito', 'Retiro', 'Transferencia'
);

--Transacciones (El nucleo del sistema)
CREATE TABLE transacciones (
    transaccion_id SERIAL PRIMARY KEY,
    cuenta_origen_id INT REFERENCES cuentas(cuenta_id),
    cuenta_destino_id INT REFERENCES cuentas(cuenta_id), -- NULL si es retiro/depósito
    tipo_id INT REFERENCES tipos_transaccion(tipo_id),
    monto DECIMAL(15, 2) NOT NULL CHECK (monto > 0),
    fecha_transaccion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    descripcion TEXT
);

--Auditoría (Para Triggers de Seguridad)
CREATE TABLE bitacora_auditoria (
    auditoria_id SERIAL PRIMARY KEY,
    tabla_afectada VARCHAR(50),
    operacion VARCHAR(10), -- 'INSERT', 'UPDATE', 'DELETE'
    usuario_db TEXT DEFAULT current_user,
    dato_anterior JSONB,
    dato_nuevo JSONB,
    fecha_evento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);