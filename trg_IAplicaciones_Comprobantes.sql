create or replace trigger trg_IAplicaciones_Comprobantes
	after insert
	on Aplicaciones_Comprobantes
	for each row
declare
	gcmVar varchar2(10);
	cliProVar varchar2(2);
begin
	select gcm_codigo into gcmVar from tipos_comprobantes tc where tc.tcm_codigo = (select tcm_codigo 
		from comprobantes where cmp_numero = :new.cmp_numero_cancelador);
	select case
					when pro_codigo is null and cli_codigo is null then
						null
					when pro_codigo is not null then
						'P'
					when cli_codigo is not null then
						'C'
				end into cliProVar
		from comprobantes where cmp_numero = :new.cmp_numero_cancelador;
	if gcmVar = 'RC' and cliProVar = 'C' then
		update TareasComprobantes set recibos = '<img src="/i/Fndokay1.gif" alt="">' where numero in (select trs_id
			from tareas_detalles_comprobantes where cmp_numero = :new.cmp_numero_cancelado);
	elsif gcmVar = 'RC' and cliProVar = 'P' then
		update	TareasComprobantes set Recibos_con = '<img src="/i/Fndokay1.gif" alt="">'
			where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = :new.cmp_numero_cancelado);
	end if;
end trg_IAplicaciones_Comprobantes;