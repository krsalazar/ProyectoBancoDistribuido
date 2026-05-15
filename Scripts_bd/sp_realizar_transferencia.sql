CREATE OR REPLACE PROCEDURE sp_realizar_transferencia(
    p_cuenta_origen_id INT,
    p_cuenta_destino_id INT,
    p_monto DECIMAL(15,2),
    p_usuario_id INT,
    p_descripcion TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_tipo_trans_id INT;
BEGIN
    -- 1. Obtener el ID del tipo de transacción 'Transferencia'
    SELECT id INTO v_tipo_trans_id FROM tipos_transaccion WHERE codigo = 'TRANSFERENCIA';--Se asume que en la tabla tipos_transacciones existe el dato TRANSFERENCIA

    -- INICIO DE LA TRANSACCIÓN (ATOMICIDAD)
  
    -- 2. Control de Concurrencia
    -- Bloqueamos ambas filas en un orden consistente para evitar Deadlocks.
    PERFORM * FROM cuentas 
    WHERE id IN (p_cuenta_origen_id, p_cuenta_destino_id) 
    ORDER BY id 
    FOR UPDATE;

    -- 3. Actualizar Saldo Cuenta Origen
    -- El Trigger 'trg_validar_transaccion' validará el saldo automáticamente.
    UPDATE cuentas 
    SET saldo = saldo - p_monto 
    WHERE id = p_cuenta_origen_id;

    -- 4. Actualizar Saldo Cuenta Destino
    UPDATE cuentas 
    SET saldo = saldo + p_monto 
    WHERE id = p_cuenta_destino_id;

    -- 5. Registrar la Transacción
    -- Este insert disparará los triggers de auditoría para dejar rastro.
    INSERT INTO transacciones (
        cuenta_origen_id, 
        cuenta_destino_id, 
        tipo_transaccion_id, 
        monto, 
        descripcion, 
        usuario_id, 
        estado
    ) VALUES (
        p_cuenta_origen_id, 
        p_cuenta_destino_id, 
        v_tipo_trans_id, 
        p_monto, 
        p_descripcion, 
        p_usuario_id, 
        'Completada'
    );

    -- Si algo falla antes de llegar aquí, se hace ROLLBACK automáticamente.
    -- Si todo tiene éxito, los cambios se confirman (COMMIT).
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        -- Captura de errores (CONSISTENCIA)
        ROLLBACK;
        RAISE EXCEPTION 'Error en la transferencia: %', SQLERRM;
END;
$$;