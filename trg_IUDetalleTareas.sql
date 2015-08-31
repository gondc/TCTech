create or replace trigger trg_IUDetalleTareas
	after insert or update
	on detalles_tareas
	for each row
declare
	serviceTypeVar varchar2(250);
	zonaVar varchar2(250);
	clientRespVar varchar2(81) := null;	
begin
	case
		when inserting then
			select set_descripcion into serviceTypeVar from services_types where set_id = :new.set_id;
			select zon_descripcion into zonaVar from zonas where zon_id = :new.zon_id;
			if :new.coc_numero is not null then
				SELECT COC_NOMBRE||'-'||COC_APELLIDO into clientRespVar
					FROM   contactos_clientes coc WHERE  :new.coc_numero = coc.coc_numero;
			end if;
			update TareasComprobantes set service_type = serviceTypeVar, cell_id_a = :new.dta_cell_id_a, site_a = :new.dta_site_a,
				cell_id_b = :new.dta_cell_id_b, site_b = :new.dta_site_b, f_valorizada = :new.dta_valorizada, facturable = :new.dta_facturable,
				importe = :new.dta_importe, importe_proveedor = :new.dta_importe_proveedor, link = :new.dta_link, zona = zonaVar, 
				who_order = :new.dta_who_order, rollout_manager = :new.dta_rollout_manager, client_responsable = clientRespVar,
				tr = :new.dta_tr, avi = :new.dta_avi, comentario = :new.dta_comments, dta_id = :new.dta_id where numero = :new.trs_id;
		when updating then		
			if :new.set_id <> :old.set_id then
				select set_descripcion into serviceTypeVar from services_types where set_id = :new.set_id;
				update TareasComprobantes set service_type= serviceTypeVar where  numero = :old.trs_id;
			end if;			
			if :new.dta_cell_id_a <> :old.dta_cell_id_a then
				update TareasComprobantes set cell_id_a = :new.dta_cell_id_a where numero = :old.trs_id;				
			end if;
			if :new.dta_site_a <> :old.dta_site_a then
				update TareasComprobantes set site_a = :new.dta_site_a where numero = :old.trs_id;
			end if;
			if :new.dta_cell_id_b <> :old.dta_cell_id_b then
				update TareasComprobantes set cell_id_b = :new.dta_cell_id_b where numero = :old.trs_id;				
			end if;
			if :new.dta_site_b <> :old.dta_site_b then
				update TareasComprobantes set site_b = :new.dta_site_b where numero = :old.trs_id;
			end if;
			if :new.dta_valorizada <> :old.dta_valorizada then
				update TareasComprobantes set f_valorizada = :new.dta_valorizada where numero = :old.trs_id;
			end if;
			if :new.dta_facturable <> :old.dta_facturable then
				update TareasComprobantes set facturable = :new.dta_facturable  where numero = :old.trs_id;
			end if;
			if :new.dta_importe <> :old.dta_importe then
				update TareasComprobantes set importe = :new.dta_importe where numero = :old.trs_id;
			end if;
			if :new.dta_importe_proveedor <> :old.dta_importe_proveedor then
				update TareasComprobantes set importe_proveedor = :new.dta_importe_proveedor where numero = :old.trs_id;
			end if;
			if :new.dta_link <> :old.dta_link then
				update TareasComprobantes set link = :new.dta_link where numero = :old.trs_id;
			end if;
			if :new.zon_id <> :old.zon_id then
				select zon_descripcion into zonaVar from zonas where zon_id = :new.zon_id;
				update TareasComprobantes set zona = zonaVar where numero = :old.trs_id;
			end if;	
			if :new.dta_who_order <> :old.dta_who_order then
				update TareasComprobantes set who_order = :new.dta_who_order where numero = :old.trs_id;
			end if;
			if :new.dta_rollout_manager <> :old.dta_rollout_manager then
				update TareasComprobantes set rollout_manager = :new.dta_rollout_manager where numero = :old.trs_id;
			end if;
			if :new.coc_numero <> :old.coc_numero then
				if :new.coc_numero is not null then
					SELECT COC_NOMBRE||'-'||COC_APELLIDO into clientRespVar
						FROM   contactos_clientes coc WHERE  :new.coc_numero = coc.coc_numero;
				end if;
				update TareasComprobantes set client_responsable = clientRespVar where numero = :old.trs_id;
			end if;
			if :new.dta_tr <> :old.dta_tr then
				update TareasComprobantes set tr = :new.dta_tr where numero = :old.trs_id;
			end if;
			if :new.dta_avi <> :old.dta_avi then
				update TareasComprobantes set avi = :new.dta_avi where numero = :old.trs_id;
			end if;
			if :new.dta_comments <> :old.dta_comments then
				update TareasComprobantes set comentario = :new.dta_comments where numero = :old.trs_id;
			end if;
	end case;
end trg_IUDetalleTareas;
	