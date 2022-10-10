--Preg A
--CANT DE LIKES RECIBIDOS
select a.idcuenta "CUENTA PROPITARIA"
, a.usuario
, b.descripcion "TIPO CUENTA"
, count(c.flaglike) "NUM LIKES"
from cuenta a,
tipocuenta b,
accion c,
video d
where c.idvideo = d.idvideo
and d.idcuenta_propietaria = a.idcuenta
and a.idtipocuenta = b.idtipocuenta
and to_char(c.fecha_like,'yyyy-mm-dd') between '2021-08-01' and '2021-09-30'
and c.flaglike = 1
group by a.idcuenta, a.usuario, b.descripcion
having count(c.flaglike)>10
order by 4 desc;
--Preg B
--ROWNUM: enumera las filas de una consulta
select rownum,tableTemp.*
from (select b.idvideo,b.titulo,count(a.flagcompartido) as Compartido ,sum(a.min_reproduccion) as Minutos_Reproduccion
        from accion a,
        video b
        where a.idvideo= b.idvideo
        --and a.flagcompartido = 1
        and exists (select *
                    from publicidad_x_video c
                    where c.idvideo = b.idvideo
                    and c.activo = 1
                    having count(c.idpublicidad)>0)
        group by b.idvideo,b.titulo
        having count(a.flagcompartido)>=3
        order by 4 desc) tableTemp
where rownum <=5;
--Preg C
--Insertar una nueva columna en una tabla
alter table publicidad
add idPublicidadAsociada number null;
--Creacion de Foreign key
alter table publicidad
add constraint FK_publicidadAsociada
foreign key (idPublicidadAsociada)
references publicidad (IDPUBLICIDAD);
--actualizacion de datos
-- NVL(exp1,exp2) si exp1 = null -> exp2
select * from publicidad;

update publicidad x
set idPublicidadAsociada = idpublicidad+2
where exists (select * from publicidad y where y.idpublicidad = x.idpublicidad+2);
--Preg D
select a1.usuario,b.titulo,a2.usuario,c.min_reproduccion,to_char(c.fecha_like,'fmDD "de" fmMonth "del" YYYY')
from cuenta a1, -- nombre de la cuenta propietaria
cuenta a2, -- cuentas que han dado like
video b,
accion c
where a1.idcuenta=b.idcuenta_propietaria
and a2.idcuenta = c.idcuenta
and c.idvideo = b.idvideo
and a1.idcuenta  <> a2.idcuenta
and c.flaglike = 1
order by 2,3;
--Preg E
/*
create view nombreVista as subconsulta;
*/
select a.usuario, f.descripcion, sum(d.precioporsegundo*d.duracionporsegundo)
from cuenta a,
video b,
publicidad_x_video c,
publicidad d,
privacidad f
where a.idcuenta=b.idcuenta_propietaria
and b.idvideo = c.idvideo
and c.idpublicidad = d.idpublicidad
and f.idprivacidad = b.idprivacidad
and not exists (select * 
                from accion e 
                where e.idcuenta =a.idcuenta 
                and flaglike = 1 and flagdislike = 1)
group by a.usuario, f.descripcion
having sum(d.precioporsegundo*d.duracionporsegundo)>2000
order by 1;
--Preg F
--POR QUE UN INDICE
--porque sirve para agilizar la busqueda de grandes cantidades de datos
--NO ES UTIL
--NO, en un futuro si
--ESTRUCTURA:
/*
create tipoIndice index NombreIndice
on nombreTabla(campos);
*/
create unique index IndicieEx1_2021_2
on video(titulo);
--VISUALIZAR INIDICE:
select * from user_ind_columns
where table_name ='VIDEO';

select * from user_objects
where object_type = 'INDEX';
