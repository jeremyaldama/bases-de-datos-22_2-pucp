SET SERVEROUTPUT ON
/
--P1
/*Procedimiento que permite recalcular los subtotales de un producto y su
  cantidad de ce_pedido_detalle con el precio del producto de ce_producto*/
CREATE OR REPLACE PROCEDURE sp_recalcular_pedido_detalle
IS
    v_id_pedido_detalle CE_PEDIDO_DETALLE.ID_PEDIDO_DETALLE%TYPE;
    v_id_producto       CE_PEDIDO_DETALLE.ID_PRODUCTO%TYPE;
    v_numero_unidades   CE_PEDIDO_DETALLE.NUMERO_UNIDADES%TYPE;
    v_producto_precio   CE_PRODUCTO.PRECIO%TYPE;
    v_nuevo_subtotal    CE_PEDIDO_DETALLE.SUBTOTAL%TYPE;    
    CURSOR c1 IS
        SELECT a.id_pedido_detalle, a.id_producto, a.numero_unidades,
                b.precio
        FROM ce_pedido_detalle a, ce_producto b
        WHERE a.id_producto=b.id_producto;
BEGIN
    OPEN c1;
    
    LOOP
        FETCH c1 INTO v_id_pedido_detalle, v_id_producto, v_numero_unidades,
                      v_producto_precio;
        EXIT WHEN c1%notfound;
        
        v_nuevo_subtotal:= v_producto_precio * v_numero_unidades;
        
        UPDATE ce_pedido_detalle
        SET subtotal = v_nuevo_subtotal
        WHERE id_pedido_detalle = v_id_pedido_detalle;
        
        dbms_output.put_line('ID_PEDIDO_DETALLE: ' || v_id_pedido_detalle ||
                              ' Subtotal: ' || v_nuevo_subtotal);
        
    END LOOP;
    
    CLOSE c1;
END;
/
EXEC sp_recalcular_pedido_detalle;
/
--P2
/*Procedimiento que elimina los pedidos de ce_pedido que no se encuentran
  en la tabla ce_pedido_detalle*/
CREATE OR REPLACE PROCEDURE sp_depurar_pedidos
IS
    CURSOR c1 IS
        SELECT id_pedido, codigo
        FROM ce_pedido
        WHERE id_pedido NOT IN (SELECT id_pedido
                                  FROM ce_pedido_detalle);
    v_id_pedido         CE_PEDIDO.ID_PEDIDO%TYPE;
    v_codigo_pedido     CE_PEDIDO.CODIGO%TYPE;
BEGIN
    OPEN c1;
    
    LOOP
        FETCH c1 INTO v_id_pedido, v_codigo_pedido;
        EXIT WHEN c1%notfound;
        
        UPDATE CE_PEDIDO
        SET estado = 'E'
        WHERE id_pedido = v_id_pedido;
        
        dbms_output.put_line('ID_PEDIDO: ' || v_id_pedido || ' CODIGO: ' ||
                              v_codigo_pedido);
    END LOOP;
    
    CLOSE c1;
END;
/
--P3
/*Subprograma que recalcula los subtotales de la tabla ce_pedido
  con las sumas de los subtotales del detalle del pedido en ce_pedido_detale*/
SELECT a.id_pedido, sum(a.subtotal)
FROM ce_pedido_detalle a, ce_pedido b
WHERE a.id_pedido=b.id_pedido
GROUP BY a.id_pedido, a.id_producto;
/
SELECT *
FROM ce_pedido_detalle
/
SELECT NVL(SUM(subtotal), 0)
FROM ce_pedido_detalle
WHERE id_pedido=5
/
INSERT INTO CE_PEDIDO_DETALLE VALUES(3,5,12,2,350,'A');
/
SELECT *
FROM ce_pedido
/
CREATE OR REPLACE PROCEDURE sp_recalcular_pedido
IS
    CURSOR c1 IS
        SELECT id_pedido, codigo
        FROM ce_pedido;
    v_id_pedido         CE_PEDIDO.ID_PEDIDO%TYPE;
    v_codigo            CE_PEDIDO.CODIGO%TYPE;
    v_nuevo_subtotal    CE_PEDIDO.SUBTOTAL%TYPE;
    v_monto_igv         CE_PEDIDO.MONTO_IGV%TYPE;
    v_monto_total       CE_PEDIDO.MONTO_TOTAL%TYPE;
BEGIN
    OPEN C1;
    
    LOOP
        FETCH c1 INTO v_id_pedido, v_codigo;
        EXIT WHEN c1%notfound;
        
        SELECT NVL(SUM(subtotal), 0)
        INTO v_nuevo_subtotal
        FROM ce_pedido_detalle
        WHERE id_pedido = v_id_pedido;
        
        v_monto_igv := v_nuevo_subtotal*0.18;
        v_monto_total := v_nuevo_subtotal + v_monto_igv;
        
        UPDATE ce_pedido
        SET
            subtotal = v_nuevo_subtotal,
            monto_igv = v_monto_igv,
            monto_total = v_monto_total
        WHERE id_pedido = v_id_pedido;
        
        dbms_output.put_line('ID_PEDIDO: ' || v_id_pedido ||
                             ' CODIGO: ' || v_codigo ||
                             ' SUBTOTAL: ' || rpad(v_nuevo_subtotal, 8) ||
                             ' MONTO_IGV: ' || rpad(v_monto_igv, 7) ||
                             ' MONTO_TOTAL: ' || v_monto_total);
    END LOOP;
    
    CLOSE c1;
END;
/
EXEC sp_recalcular_pedido;
/
--P4
/*Trigger que al inserar un nuevo registro en ce_pedido_detalle
  incrementa el monto del subtotal y recalcula monto_igv y
  monto_total del pedido en ce_pedido*/
CREATE OR REPLACE TRIGGER t_modificar_monto_igv_total
AFTER INSERT ON ce_pedido_detalle
FOR EACH ROW
BEGIN
    UPDATE ce_pedido
    SET
        subtotal = subtotal + :new.subtotal,
        monto_igv = monto_igv + :new.subtotal * 0.18,
        monto_total = monto_total + (:new.subtotal + monto_igv)
    WHERE id_pedido = :new.id_pedido;
END;
/
SELECT * FROM ce_pedido WHERE id_pedido = 1;
/
INSERT INTO ce_pedido_detalle VALUES (4,1,4,1,2500,'A');
/
SELECT * FROM ce_pedido WHERE id_pedido=1;
/
--P5
/*Trigger que actualiza el subtotal de ce_pedido_detalle 
  cuando se actualiza el precio de un producto*/
CREATE OR REPLACE TRIGGER actualizar_subtotal
AFTER UPDATE ON ce_producto
FOR EACH ROW
BEGIN
    UPDATE ce_pedido_detalle
    SET subtotal = :new.precio*numero_unidades
    WHERE id_producto = :new.id_producto;
END;
/
SELECT * FROM ce_pedido_detalle
/
SELECT id_pedido_detalle, numero_unidades, subtotal
FROM ce_pedido_detalle 
WHERE id_producto = 4;
/
SELECT *
FROM ce_producto
WHERE id_producto = 4;
/
UPDATE ce_producto
SET PRECIO = 22000
WHERE ID_PRODUCTO = 4;

    