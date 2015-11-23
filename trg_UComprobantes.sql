create or replace trigger trg_UComprobantes
	after update of cmp_fecha_anulacion
	on Comprobantes
	for each row
declare
	gcmVar varchar2(10);
	cliProVar varchar2(2);
	-- PRAGMA AUTONOMOUS_TRANSACTION;
	eb number;
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
			update TareasComprobantes t set compras_con = (select case
																					when cant_compras_con - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_compras_con - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero), 
				cant_compras_con = (select cant_compras_con - 1 from TareasComprobantes where numero = t.numero)
				where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = :old.cmp_numero);
		when gcmVar = 'F' then
			update TareasComprobantes t set facturas_con = (select case
																					when cant_facturas_con - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_facturas_con - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero), 
				cant_facturas_con = (select cant_facturas_con - 1 from TareasComprobantes where numero = t.numero)				
				where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = :old.cmp_numero);
				-- f_fact = (SELECT MAX(CMP_FECHA_EMISION) FROM   TAREAS_DETALLES_COMPROBANTES TD, COMPROBANTES C,
								-- TIPOS_COMPROBANTES TC WHERE  TD.TRS_ID = t.numero AND  TD.CMP_NUMERO = C.CMP_NUMERO
								-- AND    C.TCM_CODIGO = TC.TCM_CODIGO  AND  TC.GCM_CODIGO = 'F' and c.cmp_fecha_anulacion is null
								-- and c.cmp_numero <> :old.cmp_NUMERO)
		when gcmVar = 'RC' then
			select cmp_numero_cancelado into cmpCanceladoVar from aplicaciones_comprobantes 
				where cmp_numero_cancelador = :old.cmp_numero;
			update	TareasComprobantes t set Recibos_con = (select case
																					when cant_recibos_con - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_recibos_con - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero), 
				cant_recibos_con = (select cant_recibos_con - 1 from TareasComprobantes where numero = t.numero)
				where numero in (select trs_id from relaciones_det_ord_det_comp where cmp_numero = cmpCanceladoVar);
		else
			null;
	end case;
	case
		when gcmVar = 'M' and cliProVar = 'C' then
			update TareasComprobantes t set compras = (select case
																					when cant_compras - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_compras - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero), 
				cant_compras = (select cant_compras - 1 from TareasComprobantes where numero = t.numero)
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
		when gcmVar = 'F' and cliProVar = 'C' then
			update TareasComprobantes t set facturas =  (select case
																					when cant_facturas - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_facturas- 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero),
				cant_facturas = (select cant_facturas - 1 from TareasComprobantes where numero = t.numero)
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = :old.cmp_numero);
			-- f_fact = (SELECT MAX(CMP_FECHA_EMISION) FROM   TAREAS_DETALLES_COMPROBANTES TD, COMPROBANTES C,
				-- TIPOS_COMPROBANTES TC WHERE  TD.TRS_ID = t.numero AND  TD.CMP_NUMERO = C.CMP_NUMERO
				-- AND    C.TCM_CODIGO = TC.TCM_CODIGO  AND  TC.GCM_CODIGO = 'F' and c.cmp_fecha_anulacion is null
				-- and c.cmp_numero <> :old.cmp_NUMERO)
		when (gcmVar = 'F' and cliProVar = 'P') or gcmVar = 'GF' then
			update TareasComprobantes t set gastos =  (select case
																					when cant_gastos - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_gastos - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero),
				cant_gastos = (select cant_gastos - 1 from TareasComprobantes where numero = t.numero)
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = :old.cmp_numero);
		when gcmVar = 'RC' and cliProVar = 'C'  then
			select cmp_numero_cancelado into cmpCanceladoVar from aplicaciones_comprobantes 
				where cmp_numero_cancelador = :old.cmp_numero;
			update TareasComprobantes t set recibos = (select case
																					when cant_recibos - 1 = 0 then 
																						'<img src="/i/FNDCANCE.gif" alt="">'
																					when cant_recibos - 1 > 0 then
																						'<img src="/i/Fndokay1.gif" alt="">'
																					end
																					from TareasComprobantes where numero = t.numero),
				cant_recibos = (select cant_recibos - 1 from TareasComprobantes where numero = t.numero)
				where numero in (select trs_id from tareas_detalles_comprobantes where cmp_numero = cmpCanceladoVar);
		else
			null;
	end case;
	if :old.tcm_codigo = 'OCC' then
		update TareasComprobantes  set saldo_occ = null  where numero in (SELECT trs_id FROM DETALLES_COMPROBANTES DC
			where :old.cmp_NUMERO = DC.cmp_NUMERO)	and facturable = 'Si';
	end if;
	begin
		select 1 into eb from egresosbancosxproyectos where cmp_NUMERO = :old.cmp_NUMERO and rownum = 1;
		update rentabilidadxtareas r set ingreso = ingreso + trunc((-1)*(:old.cmp_importe_neto)/(select count(*) from rentabilidadxtareas eb join tareas t on eb.trs_id = t.trs_id where 
			t.pry_id in (select pry_id from egresosbancosxproyectos where cmp_NUMERO = :old.cmp_NUMERO) and extract(month from eb.fecha) = 
			extract(month from :old.CMP_FECHA_EMISION) 
			and EXTRACT(YEAR FROM eb.fecha) =  EXTRACT( YEAR FROM :old.CMP_FECHA_EMISION)),2) where extract(month from r.fecha) = 
			extract(month from :old.CMP_FECHA_EMISION) 
			and EXTRACT(YEAR FROM r.fecha) =  EXTRACT( YEAR FROM :old.CMP_FECHA_EMISION);
		delete from egresosbancosxproyectos where cmp_NUMERO = :old.cmp_NUMERO;
	exception
		when no_data_found then
			null;
	end;
	-- commit;
end trg_UComprobantes;
			  