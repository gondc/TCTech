create or replace trigger trg_IUDCheckOrdenativos
	after insert or delete or update of trs_id
	on DETALLES_ORDENATIVOS
	for each row
declare
	PRAGMA AUTONOMOUS_TRANSACTION;
	prov varchar2(100);
begin
	case
		when inserting then
			update TareasComprobantes set ordenativos = '<img src="/i/Fndokay1.gif" alt="">' where numero = :new.trs_id;				
		when updating ('trs_id') then
			update TareasComprobantes set ordenativos =  DECODE(pkg_tracking.FNC_VERIFICA_ORD_TAREA_count(trs_id) - 1, 0,
             '<img src="/i/FNDCANCE.gif" alt="">' , 
			 '<img src="/i/Fndokay1.gif" alt="">')  where numero = :new.trs_id;
		when deleting then
			update TareasComprobantes set ordenativos = DECODE(pkg_tracking.FNC_VERIFICA_ORD_TAREA_count(trs_id) - 1, 0,
             '<img src="/i/FNDCANCE.gif" alt="">' , 
			 '<img src="/i/Fndokay1.gif" alt="">')  where numero = :old.trs_id;
	end case;
	commit;
end trg_IUDCheckOrdenativos;	
