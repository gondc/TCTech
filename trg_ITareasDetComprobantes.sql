create or replace trigger trg_ITareasDetComprobantes
	after insert
	on tareas_detalles_comprobantes
	for each row
declare
	gcmVar varchar2(10);
	cliProVar  varchar2(2);
begin
	select gcm_codigo into gcmVar from tipos_comprobantes tc where tc.tcm_codigo = (select tcm_codigo 
		from comprobantes where cmp_numero = :new.cmp_numero);
	select case
					when pro_codigo is null and cli_codigo is null then
						null
					when pro_codigo is not null then
						'P'
					when cli_codigo is not null then
						'C'
				end into cliProVar
		from comprobantes where cmp_numero = :new.cmp_numero;
	case
		when gcmVar = 'M' and cliProVar = 'C' then
			update TareasComprobantes set compras = '<img src="/i/Fndokay1.gif" alt="">' where numero = :new.trs_id;
		when gcmVar = 'RCP' and cliProVar = 'C' then
			update TareasComprobantes set recepcion = '<img src="/i/Fndokay1.gif" alt="">' where numero = :new.trs_id;
		when gcmVar = 'F' and cliProVar = 'C' then
			update TareasComprobantes set facturas = '<img src="/i/Fndokay1.gif" alt="">' where numero = :new.trs_id;
		when (gcmVar = 'F' and cliProVar = 'P') or gcmVar = 'GF' then
			update TareasComprobantes set gastos = '<img src="/i/Fndokay1.gif" alt="">' where numero = :new.trs_id;
	end case;
end trg_ITareasDetComprobantes;
