create or replace trigger trg_UDetallesComprobantes
	after update of dco_importe_saldo
	on Detalles_Comprobantes
	for each row
begin
	update TareasComprobantes set saldo_occ = :new.dco_importe_saldo where numero = 
		(SELECT trs_id FROM tareas_detalles_comprobantes t join comprobantes c on c.cmp_numero = t.cmp_numero
		where :old.cmp_NUMERO = c.cmp_NUMERO and t.dco_numero = :old.dco_numero
		AND C.TCM_CODIGO = 'OCC') and facturable = 'Si';
end trg_UDetallesComprobantes;