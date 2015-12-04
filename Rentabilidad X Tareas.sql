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

-- Informe por zona
select null, z.zon_descripcion, (sum(nvl(ingreso,0))-sum(nvl(egreso,0))) from rentabilidadxtareas r join detalles_tareas t on 
	r.trs_id = t.trs_id join zonas z on z.zon_id = t.zon_id where r.fecha >=  :P93_fecha_desde and r.fecha <= :P93_fecha_hasta group by z.zon_id, z.zon_descripcion order by z.zon_descripcion
	
-- Informe por proyectos	
select null, p.pry_nombre, (sum(nvl(ingreso,0))-sum(nvl(egreso,0))) from rentabilidadxtareas r join tareas t on 
	r.trs_id = t.trs_id join proyectos p on t.pry_id = p.pry_id where r.fecha >=  :P93_fecha_desde and r.fecha <= :P93_fecha_hasta group by p.pry_id , p.pry_nombre order by p.pry_nombre

-- Informe por service types
select null, s.set_descripcion, (sum(nvl(ingreso,0))-sum(nvl(egreso,0))) from rentabilidadxtareas r join detalles_tareas t on r.trs_id = t.trs_id 
	join services_types s on s.set_id = t.set_id  where r.fecha >=  :P93_fecha_desde and r.fecha <= :P93_fecha_hasta group by s.set_id, s.set_descripcion order by s.set_id
	
-- Informe por rollout manager
select null, dt.dta_rollout_manager, (sum(nvl(ingreso,0))-sum(nvl(egreso,0))) from rentabilidadxtareas r join detalles_tareas dt on dt.trs_id = r.trs_id
	where r.fecha >=  :P93_fecha_desde and r.fecha <= :P93_fecha_hasta
	group by dt.dta_rollout_manager order by dt.dta_rollout_manager

	
	
	
	
	