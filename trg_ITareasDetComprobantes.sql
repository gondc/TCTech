create or replace trigger trg_ITareasDetComprobantes
	after insert
	on tareas_detalles_comprobantes
	for each row
declare
	gcmVar varchar2(10);
	cliProVar  varchar2(2);
	-- PRAGMA AUTONOMOUS_TRANSACTION;
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
			update TareasComprobantes set compras = '<img src="/i/Fndokay1.gif" alt="">', cant_compras = (select cant_compras + 1
				from TareasComprobantes where numero = :new.trs_id), oc_cliente = (SELECT cmp_numero_legal
				FROM   comprobantes cmp,  tipos_comprobantes tcm WHERE  cmp.cmp_numero = :new.cmp_numero
			    AND    cmp.tcm_codigo = tcm.tcm_codigo
			    AND    tcm.TCM_ORIGEN = 'V' AND    ROWNUM = 1), 
				pos = (SELECT SUBSTR(dco_descripcion_adicional,0,INSTR(dco_descripcion_adicional,'-')-1) FROM   comprobantes cmp,
				detalles_comprobantes dco, tipos_comprobantes tcm WHERE  cmp.cmp_numero = :new.cmp_numero
			    AND    cmp.tcm_codigo = tcm.tcm_codigo
			    AND    cmp.cmp_numero = dco.cmp_numero
			    AND    dco.dco_numero = :new.dco_numero
			    AND    tcm.tcm_origen = 'V' AND    ROWNUM = 1) where numero = :new.trs_id;
		when gcmVar = 'RCP' and cliProVar = 'C' then
			update TareasComprobantes set recepcion = '<img src="/i/Fndokay1.gif" alt="">', cant_recepcion = (select cant_recepcion + 1
				from TareasComprobantes where numero = :new.trs_id) where numero = :new.trs_id;
		when gcmVar = 'F' and cliProVar = 'C' then
			update TareasComprobantes set facturas = '<img src="/i/Fndokay1.gif" alt="">', cant_facturas = (select cant_facturas + 1
				from TareasComprobantes where numero = :new.trs_id) where numero = :new.trs_id;
		when (gcmVar = 'F' and cliProVar = 'P') or gcmVar = 'GF' then
			update TareasComprobantes set gastos = '<img src="/i/Fndokay1.gif" alt="">', cant_gastos = (select cant_gastos + 1
				from TareasComprobantes where numero = :new.trs_id) where numero = :new.trs_id;
		else
			null;
	end case;
	if gcmVar = 'F' then
		update TareasComprobantes set f_fact = (select CMP_FECHA_EMISION from comprobantes 
			where cmp_numero = :new.cmp_numero) where numero = :new.trs_id;
	end if;
	update TareasComprobantes set saldo_occ = (SELECT DCO_IMPORTE_SALDO FROM DETALLES_COMPROBANTES DC 
		join comprobantes c on c.cmp_numero = dc.cmp_numero where :new.DCO_NUMERO = DC.DCO_NUMERO
		and dc.cmp_numero = :new.cmp_numero AND C.TCM_CODIGO = 'OCC') where numero = :new.trs_id
		and facturable = 'Si';
	-- commit;
end trg_ITareasDetComprobantes;
