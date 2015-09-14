create or replace trigger trg_UComprobantes
	after update of cmp_fecha_anulacion
	on Comprobantes
	for each row
declare
	gcmVar varchar2(10);
	cliProVar varchar2(2);
	PRAGMA AUTONOMOUS_TRANSACTION;
	cmpCanceladoVar number;
begin
	select gcm_codigo into gcmVar from tipos_comprobantes tc where tc.tcm_codigo = :old.tcm_codigo;
	case
		when :old.pro_codigo is null and :old.cli_codigo is null then
			cliProVar := null;
		when :old.pro_codigo is not null then
			cliProVar := 'P';
		when :old.cli_codigo is not null then
			cliProVar := 'C';
	end case;
	case
		when gcmVar = 'M' then
			update TareasComprobantes set compras_con = DECODE(pkg_tracking.FNC_VER_COMP_TAREA_ORD_count(numero,'M') - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = :old.cmp_numero);
		when gcmVar = 'F' then
			update TareasComprobantes set facturas_con = DECODE(pkg_tracking.FNC_VER_COMP_TAREA_ORD_count(numero,'F') - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = :old.cmp_numero);
		when gcmVar = 'RC' then
			select cmp_numero_cancelado into cmpCanceladoVar from aplicaciones_comprobantes 
				where cmp_numero_cancelador = :old.cmp_numero;
			update	TareasComprobantes set Recibos_con = DECODE(pkg_tracking.FNC_VER_COMP_TAREA_ORD_count(numero,'RC') - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = cmpCanceladoVar);
		else
			null;
	end case;
	case
		when gcmVar = 'M' and cliProVar = 'C' then
			update TareasComprobantes set compras = DECODE(pkg_tracking.fnc_verifica_comp_tarea_count(numero,'M','C') - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = :old.cmp_numero);
		when gcmVar = 'RCP' and cliProVar = 'C' then		
			update TareasComprobantes t set recepcion = (select case
																					when cant_recepcion - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_recepcion - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero),
				cant_recepcion = (select cant_recepcion - 1 from TareasComprobantes where numero = t.numero)
				where numero in (select trs_id from tareas_detalles_comprobantes  where cmp_numero = :old.cmp_numero);
			-- update TareasComprobantes set recepcion = DECODE(pkg_tracking.fnc_verifica_comp_tarea_count(numero,'RCP','C') - 1,0,
				-- '<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/Fndokay1.gif" alt="">') 
				-- where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = :old.cmp_numero);
		when gcmVar = 'F' and cliProVar = 'C' then
			update TareasComprobantes set facturas = DECODE(pkg_tracking.fnc_verifica_comp_tarea_count(numero,'F','C') - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = :old.cmp_numero);
		when (gcmVar = 'F' and cliProVar = 'P') or gcmVar = 'GF' then
			update TareasComprobantes set gastos = DECODE(0,pkg_tracking.fnc_verifica_comp_tarea_count(numero,'GF') - 1,
				'<img src="/i/FNDCANCE.gif" alt="">',
				pkg_tracking.fnc_verifica_comp_tarea_count(numero,'F','P') - 1,
				'<img src="/i/FNDCANCE.gif" alt="">',
				'<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = :old.cmp_numero);
		when gcmVar = 'RC' and cliProVar = 'C'  then
			select cmp_numero_cancelado into cmpCanceladoVar from aplicaciones_comprobantes 
				where cmp_numero_cancelador = :old.cmp_numero;
			update TareasComprobantes set recibos = DECODE(pkg_tracking.fnc_verifica_comp_tarea_count(numero,'RC','C') - 1,0,
				'<img src="/i/FNDCANCE.gif" alt="">','<img src="/i/Fndokay1.gif" alt="">') 
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = cmpCanceladoVar);
		else
			null;
	end case;
	commit;
end trg_UComprobantes;
			  