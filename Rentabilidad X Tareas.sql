select trs_id from rentabilidadxtareas r, comprobantes c join detalles_comprobantes dc on c.cmp_numero = dc.cmp_numero where extract(month from r.fecha) = 
	extract(month from c.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM c.CMP_FECHA_EMISION) and c.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA')

select c.cmp_numero, d.cnc_codigo from comprobantes c join detalles_comprobantes d on c.cmp_numero = d.cmp_numero where c.tcm_codigo = 'EB' and d.cnc_codigo in ('EGB', 'VIA') 
	order by c.cmp_numero
	

	
select cmp_importe_neto, TRUNC(cmp_importe_neto/(select count(*) from tareas t where extract(month from t.trs_fecha_fin) = 
	extract(month from c.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.trs_fecha_fin) = 
	EXTRACT( YEAR FROM c.CMP_FECHA_EMISION)),2) "Prorra", (select count(*) from tareas t where extract(month from t.trs_fecha_fin) = 
	extract(month from c.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.trs_fecha_fin) = 
	EXTRACT( YEAR FROM c.CMP_FECHA_EMISION)) from comprobantes c join detalles_comprobantes dc on c.cmp_numero = dc.cmp_numero where  
	c.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA')

-- insert a rentabilidadxtareas	
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
	where c.tcm_codigo in  ('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null))
	
--  update a rentabilidadxtareas con comprobantes de tareas_detalles_comprobantes
update rentabilidadxtareas t set egreso = egreso + (select sum(dc.dco_importe) 
	from tareas_detalles_comprobantes r join comprobantes c on r.cmp_numero = c.cmp_numero join
	detalles_comprobantes dc on r.cmp_numero = dc.cmp_numero and r.dco_numero = dc.dco_numero where c.tcm_codigo in  
	('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null and r.trs_id = t.trs_id group by r.trs_id) where t.trs_id in (select distinct r.trs_id 
	from tareas_detalles_comprobantes r join comprobantes c on r.cmp_numero = c.cmp_numero join
	detalles_comprobantes dc on r.cmp_numero = dc.cmp_numero and r.dco_numero = dc.dco_numero where c.tcm_codigo in  
	('FLB', 'FLC', 'FLI', 'FPA', 'FPB', 'FPC', 'GF') and c.cmp_fecha_anulacion is null)
	
	-- update en rentabilidadxtareas con prorrateo Egresos de bancos entre tareas del mes
update rentabilidadxtareas r set ingreso = ingreso + nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t
	where extract(month from t.fecha) = extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and c.cmp_fecha_anulacion is null and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0)

-- Informe por zona
select null, z.zon_descripcion, (sum(ingreso)-nvl(sum(egreso),0)),sum(ingreso),sum(egreso) from rentabilidadxtareas r join detalles_tareas t on 
	r.trs_id = t.trs_id join zonas z on z.zon_id = t.zon_id group by z.zon_id, z.zon_descripcion order by z.zon_id

-- Informe por service types
select null, s.set_descripcion, (sum(ingreso)-nvl(sum(egreso),0)),sum(ingreso),sum(egreso) from rentabilidadxtareas r join detalles_tareas t on r.trs_id = t.trs_id 
	join services_types s on s.set_id = t.set_id group by s.set_id, s.set_descripcion order by s.set_id
	
-- Informe por rollout manager
select null, dt.dta_rollout_manager, (sum(ingreso)-nvl(sum(egreso),0)), sum(ingreso),sum(egreso) from rentabilidadxtareas r join detalles_tareas dt on dt.trs_id = r.trs_id
	group by dt.dta_rollout_manager order by dt.dta_rollout_manager
	
select extract(month from c.CMP_FECHA_EMISION) "año",
	EXTRACT(year FROM c.CMP_FECHA_EMISION) "mes", r.fecha, ingreso,(select SUM(TRUNC(cmp_importe_neto/(select count(*) from tareas t join detalles_tareas d on t.trs_id = d.trs_id 
	where d.dta_facturable = 'S' and t.trs_estado = 'COM' and extract(month from t.trs_fecha_fin) = 
	extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.trs_fecha_fin) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)) "resta", (ingreso + (select SUM(TRUNC(cmp_importe_neto/(select count(*) from tareas t join detalles_tareas d on t.trs_id = d.trs_id 
	where d.dta_facturable = 'S' and t.trs_estado = 'COM' and extract(month from t.trs_fecha_fin) = 
	extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.trs_fecha_fin) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION))) "nuevo" from rentabilidadxtareas r, 
	comprobantes c join detalles_comprobantes dc 
	on c.cmp_numero = dc.cmp_numero where c.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and extract(month from r.fecha) = 
	extract(month from c.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM c.CMP_FECHA_EMISION) order by 1, 2
	
	select (select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t extract(month from t.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)) "nuevo" from rentabilidadxtareas r
	
select trs_id, r.fecha, ingreso,nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t where extract(month from t.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0) "resta", (ingreso + nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t
	where extract(month from t.fecha) = extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0)) "nuevo" from rentabilidadxtareas r order by 1
	
	

	
select r.trs_id, r.fecha, ingreso,(select count(*) from rentabilidadxtareas t where extract(month from t.fecha) = 
	extract(month from r.fecha) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM r.fecha)) "cant",(select SUM(cmp_importe_neto) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t where extract(month from t.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0) "resta", (ingreso + nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t
	where extract(month from t.fecha) = extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0)) "nuevo" from rentabilidadxtareas r join tareas t on r.trs_id = t.trs_id where t.pry_id = 12 order by 1
	
select r.trs_id, r.fecha, ingreso,egreso,(select count(*) from rentabilidadxtareas t where extract(month from t.fecha) = 
	extract(month from r.fecha) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM r.fecha)) "cant. tareas en el mes",(select SUM(cmp_importe_neto) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)) "Total EB en el mes",nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t where extract(month from t.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0) "Prorrateo", (ingreso + nvl((select SUM(TRUNC(cmp_importe_neto/(select count(*) from rentabilidadxtareas t
	where extract(month from t.fecha) = extract(month from ce.CMP_FECHA_EMISION) and EXTRACT(YEAR FROM t.fecha) =  
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION)),2)) from comprobantes ce join detalles_comprobantes dc on ce.cmp_numero = dc.cmp_numero where  
	ce.tcm_codigo = 'EB' and dc.cnc_codigo not in ('EGB', 'VIA') and  extract(month from r.fecha) = 
	extract(month from ce.CMP_FECHA_EMISION)  and EXTRACT(YEAR FROM r.fecha) = 
	EXTRACT( YEAR FROM ce.CMP_FECHA_EMISION) group by extract(year from ce.CMP_FECHA_EMISION),
	EXTRACT(month FROM ce.CMP_FECHA_EMISION)),0)) "Ingreso - Prorrateo" from rentabilidadxtareas r join tareas t on r.trs_id = t.trs_id where extract(month from r.fecha) = 1  and EXTRACT(YEAR FROM r.fecha) = 2014  and t.pry_id = 13

	
	
	
	
	