create or replace trigger trg_IDEvaluaciones
	after insert or delete
	on Evaluaciones_Tareas
	for each row
declare
	PRAGMA AUTONOMOUS_TRANSACTION;
begin 
	case
		when inserting then
			update TareasComprobantes set evaluaciones = '<img src="/i/Fndokay1.gif" alt="">' where numero = :new.trs_id;
		when deleting then
			update TareasComprobantes set evaluaciones = DECODE(pkg_tracking.fnc_verifica_eval_tarea_count(numero) - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">','<img src="/i/Fndokay1.gif" alt="">')
				where numero = :old.trs_id;
	end case;
	commit;
end trg_IDEvaluaciones;