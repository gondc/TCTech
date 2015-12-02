CREATE OR REPLACE PROCEDURE TCTECH.sp_actualizarRentXTareas IS
	cursor comprobantes is select distinct cmp_numero from egresosbancosxproyectos;
	cmp number(15);
	cantTareas number(15);
	importe number(15,8);
BEGIN
    delete from tctech.rentabilidadxtareas;      
    insert into rentabilidadxtareas select t.trs_id,(select sum(dc.dco_importe) from tareas_detalles_comprobantes tdc join detalles_comprobantes dc on 
		tdc.cmp_numero = dc.cmp_numero and	tdc.dco_numero = dc.dco_numero join comprobantes c on c.cmp_numero = dc.cmp_numero 
		where tdc.trs_id = t.trs_id and c.tcm_codigo = 'FCA' and c.cmp_fecha_anulacion is null group by tdc.trs_id) "Ingreso", 
		(select sum(r.rdo_importe) from relaciones_det_ord_det_comp r join comprobantes c on r.cmp_numero = c.cmp_numero 
		where c.tcm_codigo in  ('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null and r.trs_id = t.trs_id group by r.trs_id) "Egreso", t.trs_fecha_fin
		from tareas t join detalles_tareas dt on t.trs_id = dt.trs_id where dt.dta_facturable = 'S'
		and t.trs_estado = 'COM' and (t.trs_id in (select tdc.trs_id from tareas_detalles_comprobantes tdc join detalles_comprobantes dc on 
		tdc.cmp_numero = dc.cmp_numero and	tdc.dco_numero = dc.dco_numero join comprobantes c on c.cmp_numero = dc.cmp_numero 
		and c.tcm_codigo = 'FCA' and c.cmp_fecha_anulacion is null) or t.trs_id in (select r.trs_id from relaciones_det_ord_det_comp r join comprobantes c on 
		r.cmp_numero = c.cmp_numero join detalles_comprobantes dc on r.cmp_numero = dc.cmp_numero and r.dco_numero = dc.dco_numero 
		where c.tcm_codigo in  ('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null));
	commit;
	update rentabilidadxtareas t set egreso = egreso + (select sum(dc.dco_importe) 
		from tareas_detalles_comprobantes r join comprobantes c on r.cmp_numero = c.cmp_numero join
		detalles_comprobantes dc on r.cmp_numero = dc.cmp_numero and r.dco_numero = dc.dco_numero where c.tcm_codigo in  
		('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null and r.trs_id = t.trs_id group by r.trs_id) where t.trs_id in (select distinct r.trs_id 
		from tareas_detalles_comprobantes r join comprobantes c on r.cmp_numero = c.cmp_numero join
		detalles_comprobantes dc on r.cmp_numero = dc.cmp_numero and r.dco_numero = dc.dco_numero where c.tcm_codigo in  
		('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null);		
	open comprobantes;
	loop
		fetch comprobantes into cmp;
		exit when comprobantes%NOTFOUND;
		select count(*) into cantTareas from comprobantes ce, rentabilidadxtareas t join tareas ta on t.trs_id = ta.trs_id 
			where ce.cmp_numero = cmp and ta.pry_id in (select pry_id from egresosbancosxproyectos where cmp_numero = cmp)
			and extract(month from t.fecha) = extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION);
		if cantTareas <>  0 then
			select cmp_importe_neto into importe from comprobantes where cmp_numero = cmp;							
			if importe <  0 then
				update rentabilidadxtareas r set egreso = nvl(egreso,0) + ((-1)*nvl((select SUM(TRUNC(cmp_importe_neto/cantTareas,2)) from comprobantes ce where
					ce.cmp_numero = cmp  
					and  extract(month from r.fecha) = extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
					EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
					EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0)) where r.trs_id in (select trs_id from tareas t where t.pry_id in
					(select pry_id from egresosbancosxproyectos where cmp_numero = cmp));
			else
				update rentabilidadxtareas r set egreso = nvl(egreso,0) + nvl((select SUM(TRUNC(cmp_importe_neto/cantTareas,2)) from comprobantes ce where
					ce.cmp_numero = cmp  
					and  extract(month from r.fecha) = extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
					EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
					EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0) where r.trs_id in (select trs_id from tareas t where t.pry_id in
					(select pry_id from egresosbancosxproyectos where cmp_numero = cmp));
			end if;
		end if;
	end loop;
	close comprobantes;
	commit;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
       NULL;
    WHEN OTHERS THEN     
       rollback;
END sp_actualizarRentXTareas;