/
--P1
create or replace function F_Contar_Clientes_Por_Region(v_nombre_region varchar2)
return number
is
    v_contador number;
begin
    select count(d.id_cliente)
    into v_contador
    from pp_region a, pp_provincia b, pp_distrito c, pp_cliente d
    where a.id_region=b.id_region and b.id_provincia=c.id_provincia and
        c.id_distrito=d.ubigeo and a.nombre=v_nombre_region;
    if (v_contador>0) then
        return v_contador;
    else 
        return -1;
    end if;
end;
/
select F_Contar_Clientes_Por_Region('Lima') from dual;
/
select count(d.id_cliente)
from pp_region a, pp_provincia b, pp_distrito c, pp_cliente d
where a.id_region=b.id_region and b.id_provincia=c.id_provincia and
        c.id_distrito=d.ubigeo and a.nombre='Lima';
/
--P2
create or replace function f_total_transferencias_cliente(v_nombre varchar2,
    v_apellido_paterno varchar2, v_apellido_materno varchar2)
return number
is
    v_total_dinero_transferido number;
begin
    select sum(c.monto_transferido)
    into v_total_dinero_transferido
    from pp_cliente a, pp_cuenta_bancaria b, pp_transferencia c
    where a.id_cliente=b.id_cliente and b.id_cuenta=c.cuenta_origen and
        a.nombres=v_nombre and a.apellido_paterno=v_apellido_paterno and
        a.apellido_materno=v_apellido_materno;
    
    if v_total_dinero_transferido>0 then
        return v_total_dinero_transferido;
    else
        return -1;
    end if;
end;
/
select f_total_transferencias_cliente('Luis Miguel', 'Zuñiga','Cuya') from dual;
/
select sum(c.monto_transferido)
    from pp_cliente a, pp_cuenta_bancaria b, pp_transferencia c
    where a.id_cliente=b.id_cliente and b.id_cuenta=c.cuenta_origen 
          and a.nombres='Sergio Miguel' and a.apellido_paterno='Zuñiga' and
         a.apellido_materno='Cuya'
/
update pp_cliente
set apellido_paterno='Zuñiga'
where id_cliente=3;
/
--P3
create or replace procedure p_mostrar_dueño_tarjeta(v_numero_tarjeta varchar2)
is
    v_nombres varchar2(50 byte);
    v_apellido_paterno varchar2 (50 byte);
    v_apellido_materno varchar2 (50 byte);
begin
    select c.nombres, c.apellido_paterno, c.apellido_materno
    into v_nombres, v_apellido_paterno, v_apellido_materno
    from pp_tarjeta_bancaria a, pp_cuenta_bancaria b, pp_cliente c
    where a.id_cuenta=b.id_cuenta and b.id_cliente=c.id_cliente and
        a.numero_tarjeta=v_numero_tarjeta;
    dbms_output.put_line('El dueño de la tarjeta es '||v_nombres||' '||v_apellido_paterno||' '||v_apellido_materno);
exception
    when NO_DATA_FOUND then
        dbms_output.put_line('No existe una tarjeta con ese numero.');
end;
/
 select c.nombres, c.apellido_paterno, c.apellido_materno
    from pp_tarjeta_bancaria a, pp_cuenta_bancaria b, pp_cliente c
    where a.id_cuenta=b.id_cuenta and b.id_cliente=c.id_cliente and
        a.numero_tarjeta='4387184165731970';
/
set serveroutput on
execute p_mostrar_dueño_tarjeta('4387184165731970');
/
--P4
create or replace procedure p_obtener_datos_transferencia(v_id_transferencia number,
    v_cliente_emisor out varchar2, v_cliente_receptor out varchar2, v_fecha out date, v_monto out number)
is
begin
    select c_origen.nombres||' '||c_origen.apellido_paterno||' '||c_origen.apellido_materno,
        c_destino.nombres||' '||c_destino.apellido_paterno||' '||c_destino.apellido_materno,
        a.fecha_transaccion, a.monto_transferido
    into v_cliente_emisor, v_cliente_receptor, v_fecha, v_monto
    from pp_transferencia a,
        pp_cuenta_bancaria b_origen, pp_cuenta_bancaria b_destino,
        pp_cliente c_origen, pp_cliente c_destino
    where a.cuenta_origen=b_origen.id_cuenta and
        a.cuenta_destino=b_destino.id_cuenta and
        b_origen.id_cliente=c_origen.id_cliente and
        b_destino.id_cliente=c_destino.id_cliente and
        a.id_transferencia=v_id_transferencia;
exception
    when NO_DATA_FOUND then
        v_cliente_emisor := NULL;
        v_cliente_receptor := NULL;
        v_fecha := NULL;
        v_monto := NULL;
end;
/
set serveroutput on
declare
    v_id_transferencia number;
    v_cliente_emisor varchar2(100);
    v_cliente_receptor varchar2(100);
    v_fecha date;
    v_monto number;
begin
    v_id_transferencia := 6;
    p_obtener_datos_transferencia(v_id_transferencia, v_cliente_emisor,
        v_cliente_receptor, v_fecha, v_monto);
    dbms_output.put_line('Cliente emisor: ' || v_cliente_emisor);
    dbms_output.put_line('Cliente receptor: ' || v_cliente_receptor);
    dbms_output.put_line('Fecha de la transferencia: '|| v_fecha);
    dbms_output.put_line('Monto de la transferencia: ' || v_monto);
end;
/
--P5
create or replace procedure p_modificar_telefono_correo(
    v_numero_documento varchar2, v_nuevo_telefono varchar2, v_nuevo_email varchar2)
is
    v_id number;
begin
    select id_cliente
    into v_id
    from pp_cliente
    where numero_documento=v_numero_documento;

    update pp_cliente
    set correo_electronico=v_nuevo_email, telefono_contacto=v_nuevo_telefono
    where numero_documento=v_numero_documento;
    dbms_output.put_line('Telefono y correo han sido modificados.');
exception
    when NO_DATA_FOUND then
        dbms_output.put_line('Numero de documento no existe.');
end;
/
set serveroutput on
exec p_modificar_telefono_correo('000000849318','999181186','jsotoc@yimeil.com');
/
set serveroutput on
exec p_modificar_telefono_correo('123456789','981234905','mlopez@yimeil.com');
/
--P6
create or replace function f_obtener_signo(vFechaNacimiento date)
return varchar2
is
    vFechaCast varchar2(20);
    vSigno varchar2(20);
begin
    vFechaCast := to_char(vFechaNacimiento,'mm/dd');
    case
        when vFechaCast between '03/21' and '04/19' then vSigno := 'Aries';
        when vFechaCast between '04/20' and '05/21' then vSigno := 'Tauro';
        when vFechaCast between '05/21' and '06/20' then vSigno := 'Geminis';
        when vFechaCast between '06/21' and '07/22' then vSigno := 'Cancer';
        when vFechaCast between '07/23' and '08/22' then vSigno := 'Leo';
        when vFechaCast between '08/23' and '09/22' then vSigno := 'Virgo';
        when vFechaCast between '09/23' and '10/22' then vSigno := 'Libra';
        when vFechaCast between '10/23' and '11/21' then vSigno := 'Escorpio';
        when vFechaCast between '11/22' and '12/21' then vSigno := 'Sagitario';
        when vFechaCast between '12/22' and '01/19' then vSigno := 'Capricornio';
        when vFechaCast between '01/20' and '02/18' then vSigno := 'Acuario';
        when vFechaCast between '02/19' and '03/20' then vSigno := 'Piscis';
    end case;
    return vSigno;
end;
/
select nombres
,apellido_paterno
,apellido_materno
,fecha_nacimiento
,f_obtener_signo(fecha_nacimiento)
from pp_cliente;
    