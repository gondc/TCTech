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
				cell_id_b = :new.dta_cell_id_b, site_b = :new.dta_site_b, f_valorizada = :new.dta_valorizada, facturable = 
				DECODE(:new.dta_facturable,'S','Si','No'),
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
			if :new.dta_site_a <> :old.dta_site_a or (:new.dta_site_a is not null and :old.dta_site_a is null) or
				 (:new.dta_site_a is null and :old.dta_site_a is not null) then
				update TareasComprobantes set site_a = :new.dta_site_a where numero = :old.trs_id;
			end if;
			if :new.dta_cell_id_b <> :old.dta_cell_id_b or (:new.dta_cell_id_b is not null and :old.dta_cell_id_b is null) or
				 (:new.dta_cell_id_b is null and :old.dta_cell_id_b is not null) then
				update TareasComprobantes set cell_id_b = :new.dta_cell_id_b where numero = :old.trs_id;				
			end if;
			if :new.dta_site_b <> :old.dta_site_b  or (:new.dta_site_b is not null and :old.dta_site_b is null) or
				 (:new.dta_site_b is null and :old.dta_site_b is not null) then
				update TareasComprobantes set site_b = :new.dta_site_b where numero = :old.trs_id;
			end if;
			if :new.dta_valorizada <> :old.dta_valorizada or (:new.dta_valorizada is not null and :old.dta_valorizada is null) or
				 (:new.dta_valorizada is null and :old.dta_valorizada is not null) then
				update TareasComprobantes set f_valorizada = :new.dta_valorizada where numero = :old.trs_id;
			end if;
			if :new.dta_facturable <> :old.dta_facturable or (:new.dta_facturable is not null and :old.dta_facturable is null) or
				 (:new.dta_facturable is null and :old.dta_facturable is not null) then
				update TareasComprobantes set facturable = DECODE(:new.dta_facturable,'S','Si','No')  where numero = :old.trs_id;
			end if;
			if :new.dta_importe <> :old.dta_importe or (:new.dta_importe is not null and :old.dta_importe is null) or
				 (:new.dta_importe is null and :old.dta_importe is not null)  then
				update TareasComprobantes set importe = :new.dta_importe where numero = :old.trs_id;
			end if;
			if :new.dta_importe_proveedor <> :old.dta_importe_proveedor or (:new.dta_importe_proveedor is not null 
				and :old.dta_importe_proveedor is null) or (:new.dta_importe_proveedor is null and :old.dta_importe_proveedor is not null)
				then
				update TareasComprobantes set importe_proveedor = :new.dta_importe_proveedor where numero = :old.trs_id;
			end if;
			if :new.dta_link <> :old.dta_link or (:new.dta_link is not null and :old.dta_link is null) or 
				(:new.dta_link is null and :old.dta_link is not null) then
				update TareasComprobantes set link = :new.dta_link where numero = :old.trs_id;
			end if;
			if :new.zon_id <> :old.zon_id or (:new.zon_id is not null and :old.zon_id is null) or 
				(:new.zon_id is null and :old.zon_id is not null) then
				select zon_descripcion into zonaVar from zonas where zon_id = :new.zon_id;
				update TareasComprobantes set zona = zonaVar where numero = :old.trs_id;
			end if;	
			if :new.dta_who_order <> :old.dta_who_order or (:new.dta_who_order is not null and :old.dta_who_order is null) or 
				(:new.dta_who_order is null and :old.dta_who_order is not null) then
				update TareasComprobantes set who_order = :new.dta_who_order where numero = :old.trs_id;
			end if;
			if :new.dta_rollout_manager <> :old.dta_rollout_manager or (:new.dta_rollout_manager is not null and 
				:old.dta_rollout_manager is null) or (:new.dta_rollout_manager is null and :old.dta_rollout_manager is not null) then
				update TareasComprobantes set rollout_manager = :new.dta_rollout_manager where numero = :old.trs_id;
			end if;
			if :new.coc_numero <> :old.coc_numero or (:old.coc_numero is null and :new.coc_numero is not null) or
				(:new.coc_numero is null and :old.coc_numero is not null) then
				if :new.coc_numero is not null then
					SELECT COC_NOMBRE||'-'||COC_APELLIDO into clientRespVar
						FROM   contactos_clientes coc WHERE  :new.coc_numero = coc.coc_numero;
				end if;
				update TareasComprobantes set client_responsable = clientRespVar where numero = :old.trs_id;
			end if;
			if :new.dta_tr <> :old.dta_tr or (:new.dta_tr is not null and 
				:old.dta_tr is null) or (:new.dta_tr is null and :old.dta_tr is not null) then
				update TareasComprobantes set tr = :new.dta_tr where numero = :old.trs_id;
			end if;
			if :new.dta_avi <> :old.dta_avi or (:new.dta_avi is not null and :old.dta_avi is null) or (:new.dta_avi is null and 
				:old.dta_avi is not null) then
				update TareasComprobantes set avi = :new.dta_avi where numero = :old.trs_id;
			end if;
			if :new.dta_comments <> :old.dta_comments or (:new.dta_comments is not null and :old.dta_comments is null) or 
				(:new.dta_comments is null and :old.dta_comments is not null) then
				update TareasComprobantes set comentario = :new.dta_comments where numero = :old.trs_id;
			end if;
	end case;
end trg_IUDetalleTareas;
	