SET SERVEROUTPUT ON
/
--P1
/*Piden recalcular los subtotales de la tabla sp_detallle_compra, utilizando
  el precio de la tabla sp_insumo*/
CREATE OR REPLACE PROCEDURE sp_recalcular_detalle_compra
IS
    CURSOR c1 IS
        SELECT id_compra, id_insumo, subtotal, cantidad
        FROM sp_detalle_compra
        ORDER BY 1 ASC;
    
    n_subtotal  sp_detalle_compra.subtotal%type;
    v_precio    sp_insumo.precio%type;
    
BEGIN
    FOR v_compra IN c1 LOOP
        
        SELECT precio
        INTO v_precio
        FROM sp_insumo
        WHERE id_insumo=v_compra.id_insumo;
        
        n_subtotal:=v_compra.cantidad*v_precio;
        
        UPDATE sp_detalle_compra
        SET subtotal=n_subtotal
        WHERE id_compra=v_compra.id_compra;
        
        dbms_output.put_line('ID_COMPRA: ' || v_compra.id_compra ||
                            ' Subtotal: ' || n_subtotal);
    END LOOP;
END;
/
EXEC sp_recalcular_detalle_compra;
/
--P2
/*Piden eliminar las órdenes de producción que no cuenten con un detalle*/
CREATE OR REPLACE PROCEDURE sp_depurar_ordenes_prd
IS
    CURSOR c1 IS
        SELECT id_orden
        FROM sp_orden_produccion
        ORDER BY 1 ASC;
    n_compras   NUMBER;
BEGIN
    FOR v_orden IN c1 LOOP
        
        SELECT COUNT(id_compra)
        INTO n_compras
        FROM sp_detalle_producto
        WHERE id_orden=v_orden.id_orden;
        
        IF (n_compras=0) THEN
            UPDATE sp_orden_produccion
            SET estado = 'E'
            WHERE id_orden=v_orden.id_orden;
            dbms_output.put_line('ID_ORDEN: ' || v_orden.id_orden ||
                                ' ELIMINADO');
        END IF;
    END LOOP;
END;
/
EXEC sp_depurar_ordenes_prd;
/
--P3
/*Piden recalcular subtotal, monto_igv y monto_total de sp_orden_compra*/
CREATE OR REPLACE PROCEDURE sp_recalcular_orden_compra
IS
    CURSOR c1 IS
        SELECT id_orden
        FROM sp_orden_compra
        ORDER BY 1 ASC;
    v_subtotal      sp_detalle_compra.subtotal%type;
    v_monto_igv     sp_orden_compra.monto_igv%type;
    v_monto_total   sp_orden_compra.monto_total%type;
BEGIN
    
    FOR v_orden IN c1 LOOP
        
        SELECT SUM(subtotal)
        INTO v_subtotal
        FROM sp_detalle_compra
        WHERE id_orden=v_orden.id_orden;
        
        v_monto_igv:=v_subtotal*0.18;
        v_monto_total:=v_subtotal + v_monto_igv;
        
        UPDATE sp_orden_compra
        SET subtotal = v_subtotal,
            monto_igv = v_monto_igv,
            monto_total = v_monto_total
        WHERE id_orden=v_orden.id_orden;
        
        dbms_output.put_line('ID_ORDEN: ' || v_orden.id_orden ||
                            ' SUBTOTAL: ' || v_subtotal ||
                            ' MONTO_IGV: ' || v_monto_igv ||
                            ' MONTO_TOTAL: ' || v_monto_total);
    END LOOP;
END;
/
EXEC sp_recalcular_orden_compra;
/
--P4
/*Piden realizar un trigger que al agregar un registro en sp_detalle_compra,
  incremente el subtotal y recalculo el monto_igv y monto_total de
  sp_orden_compra*/
/
CREATE OR REPLACE TRIGGER incrementar_subtotal_orden
AFTER INSERT ON sp_detalle_compra
FOR EACH ROW
BEGIN
    UPDATE sp_orden_compra
    SET subtotal = subtotal + :new.subtotal,
        monto_igv = monto_igv + (:new.subtotal*0.18),
        monto_total = monto_total + (:new.subtotal + :new.subtotal*0.18)
    WHERE id_orden = :new.id_orden;
END;
/
INSERT INTO SP_DETALLE_COMPRA 
    (ID_COMPRA, ID_ORDEN, ID_INSUMO, CANTIDAD, SUBTOTAL)
VALUES(12, 1, 5, 270.0, 675);
/
SELECT * FROM SP_ORDEN_COMPRA WHERE ID_ORDEN = 1;
/
--P5
/*Piden realizar un trigger que actualice el subtotal de sp_detalle_compra
  cuando se actualice el precio de un insumo*/
CREATE OR REPLACE TRIGGER actualizar_subtotal_detalle
AFTER UPDATE OF precio ON sp_insumo
FOR EACH ROW
BEGIN
    UPDATE sp_detalle_compra
    SET subtotal = :new.precio * cantidad
    WHERE id_insumo = :new.id_insumo;
END;
/
UPDATE SP_INSUMO SET PRECIO = 1.13 WHERE ID_INSUMO=1;
/
SELECT ID_COMPRA, SUBTOTAL FROM SP_DETALLE_COMPRA WHERE ID_INSUMO = 1
ORDER BY 1;
/



