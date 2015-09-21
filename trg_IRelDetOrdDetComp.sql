create or replace trigger trg_IRelDetOrdDetComp
	after insert
	on relaciones_det_ord_det_comp
	for each row
declare
	gcmVar varchar2(10);
begin
	select gcm_codigo into gcmVar from tipos_comprobantes tc where tc.tcm_codigo = (select tcm_codigo 
		from comprobantes where cmp_numero = :new.cmp_numero);
	case
		when gcmVar = 'M' then
			update TareasComprobantes set compras_con = '<img src="/i/Fndokay1.gif" alt="">', cant_compras_con = cant_compras_con + 1
				where numero = :new.trs_id;
		when gcmVar = 'F' then
			update TareasComprobantes set facturas_con = '<img src="/i/Fndokay1.gif" alt="">', cant_facturas_con = cant_facturas_con + 1
				where numero = :new.trs_id;
	end case;
end trg_IRelDetOrdDetComp;