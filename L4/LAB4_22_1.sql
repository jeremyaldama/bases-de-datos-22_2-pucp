--P1
create or replace procedure CalcularCantidadPedidosRegistrados(v_numero_documento varchar2,
                                                    v_fecha_inicio timestamp, 
                                                    v_fecha_fin timestamp)
is 
    v_cantidad number;
begin
    select count(*)
    into v_cantidad
    from ce_pedido a, ce_cliente b
    where b.id_cliente=a.id_cliente and
            b.numero_documento = v_numero_documento and
        a.fecha_registro>=v_fecha_inicio and
        a.fecha_registro<=v_fecha_fin;
    dbms_output.put_line('Hay ' || v_cantidad || ' pedidos para el cliente ' 
        || v_numero_documento || ' en el rango de ' || to_char(v_fecha_inicio, 'dd-MON-YY') || ' al ' ||
        to_char(v_fecha_fin, 'dd-MON-YY'));
end;
/
set serveroutput on;
execute CalcularCantidadPedidosRegistrados('42525748', '15-MAR-22', '15-JUN-22');
/
--P2
create or replace procedure MostrarInformacionDeProveedorDelProducto(v_nombre_producto varchar2)
is
    v_razon_social varchar2 (100 byte);
    v_ruc varchar2 (11 byte);
    v_numero_telefono varchar2 (15 byte);
    v_correo_electronico varchar2 (50 byte);
begin
    select b.razon_social, b.ruc, b.numero_telefono, b.correo_electronico
    into v_razon_social, v_ruc,v_numero_telefono, v_correo_electronico
    from ce_producto a, ce_proveedor b
    where a.id_proveedor=b.id_proveedor and
        a.nombre=v_nombre_producto;
    dbms_output.put_line('Articulo: ' || v_nombre_producto);
    dbms_output.put_line('---------------------------------');
    dbms_output.put_line('Proveedor: ' || v_razon_social || ' (' || v_ruc || ')');
    dbms_output.put_line('Teléfono: ' || v_numero_telefono);
    dbms_output.put_line('Correo electrónico: ' || v_correo_electronico);
end;
/
set serveroutput on;
execute MostrarInformacionDeProveedorDelProducto('CELULAR GALAXY Z FOLD2');
/
--P3
create or replace procedure ListarStockProductosDelProveedor(v_ruc varchar2)
is
    v_nombre_producto varchar2 (50 byte);
    v_stock number;
    cursor c1 is
        select a.nombre, a.stock
        from ce_producto a, ce_proveedor b
        where a.id_proveedor=b.id_proveedor and b.ruc = v_ruc;
begin
    dbms_output.put_line('Proveedor: '||v_ruc);
    dbms_output.put_line('--------------------------------------------------------');
    dbms_output.put_line(rpad('Articulo', 40) || '|' || lpad('Stock', 15));
    dbms_output.put_line('--------------------------------------------------------');
    open c1;
        loop
            fetch c1 into v_nombre_producto, v_stock;
            exit when c1%notfound;
            dbms_output.put_line(rpad(v_nombre_producto, 40)|| rpad('|',11) || v_stock);
        end loop;
    close c1;
end;
/
set serveroutput on
execute ListarStockProductosDelProveedor('20201329255');
/
--P5
create or replace procedure CalcularCantidadUnidadesCompradas(v_numero_documento varchar2,
    v_producto_nombre varchar2)
is
    v_unidades_compradas number;
begin
    select c.numero_unidades
    into v_unidades_compradas
    from ce_cliente a, ce_pedido b, ce_pedido_detalle c, ce_producto d
    where a.id_cliente=b.id_cliente and b.id_pedido=c.id_pedido and
        c.id_producto=d.id_producto and d.nombre=v_producto_nombre and
        a.numero_documento=v_numero_documento;
    dbms_output.put_line('El cliente '||v_numero_documento|| ' ha comprado '||v_unidades_compradas
        || ' unidades de '||v_producto_nombre);
end;
/
set serveroutput on
execute CalcularCantidadUnidadesCompradas('42525748','CELULAR SAMSUNG GALAXY S20');
/
select *
    from ce_cliente a, ce_pedido b, ce_pedido_detalle c, ce_producto d
    where a.id_cliente=b.id_cliente and b.id_pedido=c.id_pedido and
        c.id_producto=d.id_producto and d.nombre='CELULAR SAMSUNG GALAXY S20' and
        a.numero_documento='42525748';
/
--P7
create or replace procedure MarcaConMasUnidadesVendidas(v_fecha_inicio timestamp,
                                            v_fecha_fin timestamp)
is
    v_marca_nombre varchar2 (50 byte);
begin
    select y.Nombre
    into v_marca_nombre
    from (
    select a.nombre as Nombre, sum(c.numero_unidades) as Cantidad
    from ce_marca_producto a, ce_producto b, ce_pedido_detalle c, ce_pedido d
    where b.id_marca=a.id_marca and c.id_producto=b.id_producto and c.id_pedido=d.id_pedido
        and (d.fecha_registro>=v_fecha_inicio and d.fecha_registro<=v_fecha_fin)
    group by a.nombre
    order by 2 desc) y
    where rownum = 1;
    dbms_output.put_line('La marca con más unidades vendidad entre ' ||
                    to_char(v_fecha_inicio, 'DD-fmMON-YY') || ' y '|| to_char(v_fecha_fin, 'DD-MON-YY') ||
                    ' es ' || v_marca_nombre);
 end;   
 /
 set serveroutput on
 execute MarcaConMasUnidadesVendidas('01-01-22', '31-10-22');
 /
 