/* EX2 20.1
*/
--P2 A
CREATE OR REPLACE PROCEDURE p2_a
IS
BEGIN 
    UPDATE ex2_stock a
    SET a.cantidad = (SELECT SUM(b.cantidad* (CASE SUBSTR(b.tipoperacion,1,1)
                                                 WHEN 'I' THEN 1 ELSE -1 END))
                      FROM ex2_kardex b
                      WHERE a.codproducto=b.codproducto AND
                        a.codalmacen = b.codalmacen AND
                        SUBSTR(b.tipoperacion, 1, 1) in ('S', 'I'));
END;
/
SELECT *
FROM EX2_STOCK
/
EXEC p2_a;
/
CREATE OR REPLACE TRIGGER t_verificar_receta
AFTER UPDATE OF unidad ON ex2_producto
FOR EACH ROW
DECLARE
    verificador_c CHAR(3);
    verificador_m NUMBER;
BEGIN
    SELECT unidad
    INTO verificador_c
    FROM ex2_detalle_receta
    WHERE unidad = :new.unidad;
    
    SELECT codproducto
    INTO verificadorm
    FROM ex2_producto
    WHERE codproducto = :new.codproducto;
EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('La undiad de medida debe acutalizarse primero en el detalle de receta.');
END;
/
SELECT *
FROM ex2_detalle_receta
/
SELECT *
FROM ex2_producto
/

