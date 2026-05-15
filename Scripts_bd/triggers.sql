--captura cualquier cambio y lo inserta a la tabla de auditoria
CREATE OR REPLACE FUNCTION fn_auditoria_cuentas()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria (tabla_afectada, operacion, registro_id, datos_anteriores, datos_nuevos, fecha_hora)
        VALUES ('cuentas', TG_OP, OLD.id, to_jsonb(OLD), to_jsonb(NEW), CURRENT_TIMESTAMP);
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria (tabla_afectada, operacion, registro_id, datos_nuevos, fecha_hora)
        VALUES ('cuentas', TG_OP, NEW.id, to_jsonb(NEW), CURRENT_TIMESTAMP);
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria (tabla_afectada, operacion, registro_id, datos_anteriores, fecha_hora)
        VALUES ('cuentas', TG_OP, OLD.id, to_jsonb(OLD), CURRENT_TIMESTAMP);
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_auditoria_cuentas
AFTER INSERT OR UPDATE OR DELETE ON cuentas
FOR EACH ROW EXECUTE FUNCTION fn_auditoria_cuentas();


/*Funcion y trigger para la integridad de las operaciones Valida si la cuenta tiene fondos suficientes para aplicar la transaccion
se basa en el limite de sobregiro de la tabla cuentas*/

CREATE OR REPLACE FUNCTION fn_validar_saldo_insuficiente()
RETURNS TRIGGER AS $$
DECLARE
    v_saldo_actual DECIMAL(15,2);
    v_limite DECIMAL(15,2);
BEGIN
    -- Obtenemos el saldo y el límite de la cuenta origen
    SELECT saldo, limite_sobregiro INTO v_saldo_actual, v_limite 
    FROM cuentas WHERE id = NEW.cuenta_origen_id;

    -- Si el monto de la transacción supera el saldo disponible + el límite de sobregiro
    IF (v_saldo_actual + v_limite) < NEW.monto THEN
        RAISE EXCEPTION 'Saldo insuficiente en la cuenta origen para realizar la transacción.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_transaccion
BEFORE INSERT ON transacciones
FOR EACH ROW
WHEN (NEW.cuenta_origen_id IS NOT NULL) -- Solo aplica si hay una cuenta de origen (retiros/transferencias)
EXECUTE FUNCTION fn_validar_saldo_insuficiente();

/*Verificar si una cuenta esta activa para poder realizar la transaccion*/
CREATE OR REPLACE FUNCTION fn_verificar_cuenta_activa()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar cuenta origen
    IF (SELECT estado FROM cuentas WHERE id = NEW.cuenta_origen_id) != 'Activa' THEN
        RAISE EXCEPTION 'La cuenta de origen no se encuentra activa.';
    END IF;

    -- Verificar cuenta destino (si existe)
    IF NEW.cuenta_destino_id IS NOT NULL THEN
        IF (SELECT estado FROM cuentas WHERE id = NEW.cuenta_destino_id) != 'Activa' THEN
            RAISE EXCEPTION 'La cuenta de destino no se encuentra activa.';
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_verificar_estado_cuenta
BEFORE INSERT ON transacciones
FOR EACH ROW EXECUTE FUNCTION fn_verificar_cuenta_activa();