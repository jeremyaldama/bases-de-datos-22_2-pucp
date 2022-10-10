-------------------------------------------------------------------------
--P1 (2pts)
/*
Between: trabaja en intervalos cerrados (<= y >=)
*/
SELECT b.nombre "PRODUCTO", c.razon_social "PROVEEDOR", a.porcentaje
FROM ce_descuento a,ce_producto b, ce_proveedor c
WHERE a.id_producto=b.id_producto 
and c.id_proveedor=b.id_proveedor
and trunc(sysdate) between a.fecha_inicio and a.fecha_fin
order by 3 desc;
--P2 (2pts)
/*
AVG: funcion para hallar el promedio de numeros en una columna
*/
select AVG(a.monto_total)"Monto Promedio"
from ce_pedido a, ce_medio_pago b
where b.id_medio_pago=a.id_medio_pago
and b.nombre = 'VISA';
--P3 (2pts)
select (a.apellido_paterno||' '||a.apellido_materno||', '||a.nombres)"CLIENTE"
from ce_cliente a, ce_tipo_documento b, ce_pedido c
where c.id_cliente = a.id_cliente
and b.id_tipo_documento = a.id_tipo_documento
and b.nombre='DNI'
and extract(year from c.fecha_entrega)=2021;--to_char(c.fecha_entrega,'YY')='21';
--P4 (3pts)
select a.apellido_paterno "CLIENTE", a.fecha_nacimiento
from ce_cliente a,ce_pedido b, ce_pedido_detalle c, ce_producto d,ce_proveedor e
where b.id_cliente = a.id_cliente
and c.id_pedido = b.id_pedido
and d.id_producto = c.id_producto
and e.id_proveedor = d.id_proveedor
and e.razon_social='SANSUNG SAC';
--P5 (3pts)
/*1. Eliminar datos de FK: CE_DIRECCION*/
delete
from ce_direccion y
where y.id_cliente not in (select a.id_cliente 
                            from ce_cliente a,ce_pedido b 
                            where a.id_cliente = b.id_cliente);
/*2.Eliminar clientes*/
delete
from ce_cliente z
where z.id_cliente not in (select a.id_cliente 
                            from ce_cliente a,ce_pedido b 
                            where a.id_cliente = b.id_cliente);

select * from ce_cliente;
--P6 (2pts)
select a.nombre, a.precio, b.razon_social
from ce_producto a, ce_proveedor b, ce_categoria_producto c
where b.id_proveedor = a.id_proveedor
and c.id_categoria = a.id_categoria
and c.nombre='TELEVISORES'
order by 2 desc;
--P7
select *
from ce_producto a, ce_marca_producto b
where b.id_marca = a.id_marca
and b.nombre = 'MOTOROLLA';

update ce_producto Z
set z.stock= z.stock + 5
where z.id_producto in (select a.id_producto
                        from ce_producto a, ce_marca_producto b
                        where b.id_marca = a.id_marca
                        and b.nombre = 'MOTOROLLA');
--P8
select *
from (select b.pais_origen
        from ce_producto a, ce_marca_producto b
        where b.id_marca = a.id_marca
        order by a.precio asc)
where rownum=1;
------------------------------------------------------------------------
-- NVL (Exprecion1, Expresiono2)
-- ¿hay datos en la columna? Expresion1, si no, expresion 2
--1
select a.id_cliente,
(a.apellido_paterno||' '||a.apellido_materno||' '||a.nombres) "NOMBRES"
,a.tipo_documento
,a.numero_documento
,(select count(c.id_transferencia) 
from pp_cuenta_bancaria b,pp_transferencia c 
where b.id_cuenta=c.cuenta_origen and a.id_cliente=b.id_cliente)"CANTIDAD"
from pp_cliente a
order by 1;
select * from pp_cliente;
--2
select 'El cliente '||oriCli.apellido_paterno||' '||oriCli.apellido_materno||', '||oriCli.nombres||' con id '
||oricli.id_cliente||' hizo una transferencia con id de transferencia '||x.id_transferencia||' el dia '||
to_char(x.fecha_transaccion,'dd-mm-yyyy')||' por el monto de '||x.monto_transferido||' al cliente '||
destcli.apellido_paterno||' '||destcli.apellido_materno||', '||destcli.nombres||' con id cliente '||destcli.id_cliente
from pp_cliente oriCli, pp_cuenta_bancaria oriCB, pp_transferencia x, pp_cliente destCli, pp_cuenta_bancaria destCB
where oricli.id_cliente = oricb.id_cliente 
and destCli.id_cliente = destCB.id_cliente 
and x.cuenta_origen= oriCB.id_cuenta
and x.cuenta_destino = destcb.id_cuenta
order by x.fecha_transaccion desc;
--10 9 7 1 5 6
select * from pp_transferencia where id_transferencia in (1,5,6,7,9,10);
--3
select a.id_cliente, 
(a.apellido_paterno||' '||a.apellido_materno||', '||a.nombres)"NOMBRES",
c.numero_tarjeta,
c.fecha_vencimiento,
c.ubicacion,
c.compras_internet,
b.numero_cuenta, 
d.nombre
from pp_cliente a, 
pp_cuenta_bancaria b, 
pp_tarjeta_bancaria c, 
pp_clasificacion_cuenta d
where b.id_cliente = a.id_cliente 
and c.id_cuenta = b.id_cuenta 
and b.id_clasificacion=d.id_clasificacion
and c.ubicacion='A'
order by a.id_cliente;
--4
select to_char(sum(monto_transferido),'fm999,999.00')"Total de transferencias",to_char(avg(monto_transferido),'fm999,999.00')"Promedio de transferencias" 
from pp_transferencia
where to_char(fecha_transaccion,'YYYY/MM')>'2021/06';
--5
select to_char(fecha_transaccion,'fmMonth" de "yyyy','nls_date_language = Spanish')"Mes -Anho",
to_char(sum(monto_transferido),'fm999,999.00')"Monto"
from pp_transferencia
group by to_char(fecha_transaccion,'fmMonth" de "yyyy','nls_date_language = Spanish')
having sum(monto_transferido)>700
order by 1 asc;
--7
--UPPER: se usa para convertir una minuscula a mayuscula
--substr(nombreColumna,orden,cantCaracteres)
--decode(expresion1,expresion2,resultadoExpresion2)
select upper(substr(c.nombres,1,1)||c.apellido_paterno||substr(c.apellido_materno,-1,1))"CODIGO"
,c.telefono_contacto "Telefono", a.numero_tarjeta"Numero de tarjeta",
decode((a.fecha_vencimiento - trunc(sysdate)),0,'HOY', 'EN '||to_char(a.fecha_vencimiento-trunc(sysdate)||' dias '))"VENCE"
from pp_tarjeta_bancaria a,pp_cuenta_bancaria b, pp_cliente c 
where b.id_cuenta = a.id_cuenta and c.id_cliente = b.id_cliente;
--9
--11/09/2021
--sysdate: fecha del sistema actual
select numero_tarjeta,trunc(months_between(sysdate,fecha_emision))"MESES ACTIVO"
from pp_tarjeta_bancaria
where fecha_emision>=trunc(sysdate);
-----------------------------------------------------------------------------------------
--P1
--group by: agrupa las columnas que no tengan funcion de columna
--having: restringe funciones de columnas
select c.nombre "DEPARTEMENTO", b.nombre "PROVINCIA", count(a.id_distrito) "CANTIDAD_DISTRITOS"
from ge_distrito a,ge_provincia b, ge_departamento c
where b.id_provincia = a.id_provincia and c.id_departamento = b.id_departamento
group by c.nombre,b.nombre
having count(a.id_distrito)>=12
order by 3 desc, 2 asc;
--P2
select a.nombre "NOMBRE"
, count(b.id_archivo) "CANTIDAD"
, trunc(avg(b.tamano)/1024,2) "PROMEDIO_KB"
, trunc(max(b.tamano)/1024,2) "ARCHIVO_MAXIMO_KB"
from ge_evento a, ge_archivo b
where b.id_evento = a.id_evento
and exists (select * 
            from ge_persona c, ge_persona_evento d
            where c.id_persona = d.id_persona
            and a.id_evento=d.id_evento
            and d.asistencia <> 'N')
group by a.nombre
order by 2 desc, 3 desc;
select * from ge_evento a,ge_persona_evento b
where b.id_evento = a.id_evento;
--P3
select c.nro_documento, c.apellidos || ' ' ||    c.nombres "APELLIDOS Y NOMBRES", a.nombre, b.asistencia
from ge_evento a , ge_persona_evento b, ge_persona c
where b.id_evento = a.id_evento and c.id_persona = b.id_persona
and c.nombres in (select x.nombres
                    from ge_persona x, ge_evento y
                    where x.id_persona = y.id_responsable
                    and y.cargo_responsable = 'Director');
--P4
select a.nombre, a.tema, b.nombre
from ge_evento a, ge_departamento b,ge_provincia c, ge_distrito d
where c.id_departamento = b.id_departamento
and (a.aforo > (select avg(x.aforo)
                from ge_evento x)
or a.aforo >(select y.aforo
             from ge_evento y
             where y.nombre = 'Seminario I+D'))
and d.id_provincia = c.id_provincia 
and a.ubigeo = d.id_distrito
order by a.id_evento;
--P5
select rownum, x.nombre, x.tema, x.distrito, x.aforo
from (select a.nombre, a.tema, c.nombre as distrito, a.aforo
        from ge_evento a, ge_provincia b, ge_distrito c
        where a.ubigeo = c.id_distrito 
        and b.id_provincia = c.id_provincia
        and b.nombre <> 'Huaraz'
        order by 4 desc) x
where rownum<=2;
--P6
select d.nombre "DEPARTAMENTO",a.nombre "EVENTO"
from ge_evento a, ge_distrito b, ge_provincia c, ge_departamento d
where c.id_provincia = b.id_provincia 
and d.id_departamento = c.id_departamento
and a.ubigeo = b.id_distrito
and exists (select *
            from ge_archivo x
            where x.id_evento = a.id_evento
            and x.tamano>=150*1024)
order by 1,2;
--P7
select a.nombre, count(*) "ASISTENTES"
from ge_evento a, ge_tipo_evento b, ge_categoria_evento c, ge_persona_evento d
where b.id_tipo_evento = a.id_tipo_evento 
and c.id_categoria_evento = b.id_categoria_evento
and d.id_evento = a.id_evento
and c.nombre_categoria = 'Seminarios'
and d.asistencia = 'A'
group by a.nombre
order by 2 desc, 1 asc; 