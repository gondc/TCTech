create or replace trigger trg_AITareasDetComp
	after insert
	on tareas_detalles_comprobantes
	for each row
declare
	tcm varchar2(10);
begin
	select tcm_codigo into tcm from comprobantes where cmp_numero = :new.cmp_numero;
	if tcm = 'FCA' then
		update rentabilidadxtareas set ingreso = nvl(ingreso,0) + nvl((select dco_importe from detalles_comprobantes where cmp_numero = :new.cmp_numero and
			dco_numero = :new.dco_numero),0) where trs_id = :new.trs_id;
	elsif tcm in ('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') then
		update rentabilidadxtareas set egreso = nvl(egreso,0) + nvl((select dco_importe from detalles_comprobantes where cmp_numero = :new.cmp_numero and
			dco_numero = :new.dco_numero),0) where trs_id = :new.trs_id;
	end if;
end trg_AITareasDetComp;