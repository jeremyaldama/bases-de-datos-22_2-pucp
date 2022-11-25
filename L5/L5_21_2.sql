--P1
/*Funcion que devuelve la cantidad de transferencias que ha realizado
  un cliente
*/
CREATE OR REPLACE FUNCTION sp_contar_transferencias(v_id_cliente NUMBER)
RETURN NUMBER
AS
    v_contador NUMBER;
BEGIN
    SELECT COUNT(c.id_transferencia)
    INTO v_contador
    FROM pp_cliente a, pp_cuenta_bancaria b, pp_transferencia c
    WHERE a.id_cliente=b.id_cliente and b.id_cuenta=c.cuenta_origen
          and a.id_cliente=v_id_cliente;
    RETURN v_contador;
EXCEPTION
    WHEN no_data_found THEN
        RETURN -1;
END;
/
SELECT sp_contar_transferencias(1) "CANTIDAD TRANSFERENCIAS" FROM DUAL;
/
--P2
/*Piden imprimir las transferencias que ha realizado un cliente*/
CREATE OR REPLACE PROCEDURE sp_reporte_transferencias(v_id_cliente NUMBER)
IS
    CURSOR c1 IS
        SELECT c.id_transferencia, c.monto_transferido, b.numero_cuenta,
            d.numero_tarjeta,
            b_des.numero_cuenta, c.fecha_transaccion, NVL(to_char(c.fecha_confirmacion, 'dd/mm/yyyy'), '---'),
            c.mensaje, c.estado
        FROM pp_cliente a, pp_cuenta_bancaria b, pp_transferencia c, 
             pp_cuenta_bancaria b_des, pp_tarjeta_bancaria d
        WHERE a.id_cliente=v_id_cliente AND a.id_cliente=b.id_cliente AND
            c.cuenta_origen=b.id_cuenta AND b_des.id_cuenta=c.cuenta_destino
            AND d.id_cuenta=b.id_cuenta;
    v_id_transferencia    PP_TRANSFERENCIA.ID_TRANSFERENCIA%TYPE;
    v_monto_transferido   PP_TRANSFERENCIA.MONTO_TRANSFERIDO%TYPE;
    v_cuenta_origen       PP_TRANSFERENCIA.cuenta_origen%TYPE;
    v_numero_tarjeta      PP_TARJETA_BANCARIA.numero_tarjeta%TYPE;
    v_cuenta_destino      PP_TRANSFERENCIA.cuenta_destino%TYPE;
    v_fecha_transaccion   VARCHAR2 (100);
    v_fecha_confirmacion  VARCHAR2 (100);
    v_mensaje             PP_TRANSFERENCIA.mensaje%TYPE;
    v_estado              PP_TRANSFERENCIA.estado%TYPE;
BEGIN
    OPEN c1;
    
    LOOP
        FETCH c1 INTO v_id_transferencia,
                      v_monto_transferido,
                      v_cuenta_origen,
                      v_numero_tarjeta,
                      v_cuenta_destino,   
                      v_fecha_transaccion, 
                      v_fecha_confirmacion,
                      v_mensaje,
                      v_estado;
        EXIT WHEN c1%notfound;
        dbms_output.put_line(rpad('Codigo de transferencia', 20) || ': ' || 
                             v_id_transferencia);
                             
        dbms_output.put_line(rpad('Monto transferido', 20) || ': ' || 
                             'S/ ' || v_monto_transferido);
                             
        dbms_output.put_line(rpad(' ', 5) || rpad('Cuenta origen ', 15) || ': '
                             || v_cuenta_origen || ' (Nro. Tarjeta: ' || 
                             v_numero_tarjeta || ')');
                             
        dbms_output.put_line(rpad(' ', 5) || rpad('Cuenta destino ', 15) || ': '
                             || v_cuenta_destino);
                             
                            
        dbms_output.put_line(rpad(' ', 5) || rpad('Fecha de transaccion', 15) 
                             || ': ' || v_fecha_transaccion);
        dbms_output.put_line(rpad(' ', 5) || rpad('Fecha de confirmacion', 15) 
                             || ': ' || v_fecha_confirmacion);
        dbms_output.put_line(rpad(' ', 5) || rpad('Motivo', 15) 
                             || ': ' || v_mensaje);
        dbms_output.put_line(rpad(' ', 5) || rpad('Estado', 15) 
                             || ': ' || v_estado);
                             
        dbms_output.put_line('');
    END LOOP;
    CLOSE c1;
END;
/                             
EXEC sp_reporte_transferencias(1);
--P3: parecida a la anterior
--P4
/
ALTER TABLE PP_CUENTA_BANCARIA ADD SALDO NUMBER(7, 2) NULL;
UPDATE PP_CUENTA_BANCARIA SET SALDO = 10000;
/
CREATE OR REPLACE TRIGGER tr_actualiza_saldos
AFTER INSERT ON PP_TRANSFERENCIA
FOR EACH ROW
BEGIN
    UPDATE PP_CUENTA_BANCARIA
    SET SALDO = SALDO - :NEW.MONTO_TRANSFERIDO
    WHERE ID_CUENTA = :NEW.CUENTA_ORIGEN;
    
    UPDATE PP_CUENTA_BANCARIA
    SET SALDO = SALDO + :NEW.MONTO_TRANSFERIDO
    WHERE ID_CUENTA = :NEW.CUENTA_DESTINO;
END;
/
SELECT saldo
FROM pp_cuenta_bancaria
WHERE id_cuenta=12 OR id_cuenta=13;--hay 10000
/
INSERT INTO pp_transferencia(id_transferencia, cuenta_origen, cuenta_destino,
                            monto_transferido, mensaje, fecha_transaccion,
                            estado) VALUES
                            (11, 12, 13, 1250, 'TRIGGER', SYSDATE, 'R');
/
SELECT *
FROM pp_transferencia
/
--P5
CREATE TABLE PP_ESTADO_TRANSFERENCIA
(
	ID_ESTADO_TRANSFERENCIA NUMBER NOT NULL,
	ID_TRANSFERENCIA NUMBER NOT NULL,
	DESCRIPCION VARCHAR2(100 BYTE) NOT NULL,
	FECHA_REGISTRO DATE NOT NULL,
	ESTADO_ANTERIOR CHAR(1 BYTE) NULL,
	ESTADO_ACTUAL CHAR(1 BYTE) NULL
);

ALTER TABLE PP_ESTADO_TRANSFERENCIA ADD CONSTRAINT PP_EST_TR_PK PRIMARY KEY ( ID_ESTADO_TRANSFERENCIA );
/
CREATE OR REPLACE TRIGGER tr_actualiza_estado
AFTER INSERT OR UPDATE OR DELETE ON pp_transferencia
FOR EACH ROW
DECLARE
    v_estado_transferencia  NUMBER;
BEGIN
    SELECT NVL(MAX(id_estado_transferencia), 0)
    INTO v_estado_transferencia
    FROM pp_estado_transferencia;
    
    IF inserting and :new.fecha_confirmacion IS NULL THEN
        INSERT INTO pp_estado_transferencia 
        VALUES (v_estado_transferencia+1, :new.id_transferencia, 
        'TRANSFERENCIA EN PROCESO', TRUNC(SYSDATE), NULL, 'P');
    END IF;
END;
/
INSERT INTO PP_TRANSFERENCIA (ID_TRANSFERENCIA, CUENTA_ORIGEN,
    CUENTA_DESTINO, MONTO_TRANSFERIDO, MENSAJE, FECHA_TRANSACCION,
    FECHA_CONFIRMACION, ESTADO)
    VALUES (12, 12, 13, 150, 'Compras del mes', SYSDATE, NULL, 'P');
/
SELECT * FROM PP_ESTADO_TRANSFERENCIA;
    
    