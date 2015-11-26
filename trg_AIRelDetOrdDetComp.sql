create or replace trigger trg_AIRelDetOrdDetComp
	after insert
	on relaciones_det_ord_det_comp
	for each row
begin
	update rentabilidadxtareas set egreso = nvl(egreso,0) + :new.rdo_importe where trs_id = :new.trs_id and exists (select * from comprobantes where tcm_codigo in 
	('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and cmp_fecha_anulacion is null and cmp_numero = :new.cmp_numero);
exception
	when others then
		null;
end trg_AIRelDetOrdDetComp;