create or replace trigger trg_IDObservacionesTarea
	after insert or delete on observaciones_tareas
	for each row
declare
	PRAGMA AUTONOMOUS_TRANSACTION;	
	countVar number;
begin	
	case 
		when inserting then
			update TareasComprobantes set obs = 'S' where numero = :new.trs_id;
		when deleting then
			select count(*) into countVar from observaciones_tareas where trs_id = :old.trs_id;
			if (countVar - 1) > 0 then
				update TareasComprobantes set obs = 'S' where numero = :old.trs_id;
			else
				update TareasComprobantes set obs = 'N' where numero = :old.trs_id;
			end if;
	end case;
	commit;
end trg_IDObservacionesTarea;