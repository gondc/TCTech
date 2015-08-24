create or replace trigger trg_chkCantOrdXTarea
after update of Ord_Estado on Ordenativos
for each row 
when(new.Ord_Estado = 'ANULADO')
declare
	cursor c_tareas is select trs_id from detalles_ordenativos where ord_id = :new.ord_id and dor_estado in ('ANU', 'PEN');
	cantDetallesOrd number(30);
begin
	for id_tareas in c_tareas loop
		select count(*) into cantDetallesOrd from detalles_ordenativos where trs_id = id_tareas.trs_id;
		if cantDetallesOrd = 1 then
			update tareas set trs_fecha_inicio = null, trs_estado = 'EPL' where trs_id = id_tareas.trs_id;
		end if;
	end loop;
end trg_chkCantOrdXTarea;

select * from tareas where trs_id in (2636,2635,2634,2612)

select trs_id from detalles_ordenativos where ord_id = 327 and dor_estado in ('ANU', 'PEN');

select count(*) from detalles_ordenativos where trs_id = 2612;

select * from tareas where trs_id in (2636,2635,2634,2612)

delete from ordenativos where ord_id = 326
delete from detalles_ordenativos where ord_id = 326
delete from vehiculos_ordenativos where ord_id = 326
delete from vehiculos_ordenativos_personas where ord_id = 326
delete from PUNTAJES_DET_ORD_VEH_PERSONAS where ord_id = 326