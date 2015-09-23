create or replace trigger trg_IUDTareas
	after insert or delete or update
	on tareas
	for each row
declare
	proyectoVar varchar2(30);
	conceptoVar varchar2(50);
	estadoVar varchar2(30) := null;
	tareaPadreVar varchar2(400) := null;
	etapaVar varchar2(30) := null;
	mensaje varchar2(150) := '1';
begin
	case 
		when inserting then
			select PRY_NOMBRE into proyectoVar from proyectos where pry_id = :new.pry_id;
			select cnc_descripcion into conceptoVar from conceptos where  cnc_codigo = :new.cnc_codigo;
			select est_descripcion into estadoVar from estados where est_codigo = :new.trs_estado and prc_codigo = 'TAR';
			if :new.trs_id_padre is not null then
				SELECT TRS_ID||'-'||(SELECT set_descripcion FROM   services_types s
														WHERE  s.set_id = t2.set_id)||'-'|| DTA_CELL_ID_A||'-'||DTA_CELL_ID_B into tareaPadreVar
					FROM   detalles_tareas t2  WHERE  t2.trs_id = :new.trs_id_padre;			
			end if;
			if :new.etp_id is not null then
				SELECT etp_nombre into etapaVar FROM etapas_proyectos ep WHERE  ep.etp_id = :new.etp_id AND :new.pry_id = ep.pry_id;
			end if;
			insert into TareasComprobantes (numero, proyecto, estado, f_solicitud, f_creacion, f_inicio, f_fin, usuario, titulo, tarea_padre,
				etapa, concepto, trs_id, compras, recepcion, facturas, recibos, gastos, evaluaciones, ordenativos, compras_con, 
				facturas_con, recibos_con, pry_id) values (:new.trs_id, proyectoVar, estadoVar, :new.trs_fecha_solicitud, 
				:new.trs_fecha_creacion, :new.trs_fecha_inicio, :new.trs_fecha_fin, :new.usr_codigo, :new.trs_titulo, 
				tareaPadreVar, etapaVar, conceptoVar, :new.trs_id, '<img src="/i/FNDCANCE.gif" alt="">', 
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/FNDCANCE.gif" alt="">', 
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/FNDCANCE.gif" alt="">', 
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/FNDCANCE.gif" alt="">', 
				'<img src="/i/FNDCANCE.gif" alt="">', '<img src="/i/FNDCANCE.gif" alt="">', 
				'<img src="/i/FNDCANCE.gif" alt="">', :new.pry_id);
		when deleting then
			delete from TareasComprobantes where numero = :old.trs_id;
		when updating then
			if :new.cnc_codigo <> :old.cnc_codigo then
				select cnc_descripcion into conceptoVar from conceptos where  cnc_codigo = :new.cnc_codigo;
				update TareasComprobantes set concepto = conceptoVar where numero = :old.trs_id;
			end if;
			if :new.trs_titulo <> :old.trs_titulo then				
				update TareasComprobantes set titulo = :new.trs_titulo where numero = :old.trs_id;
			end if;
			if :new.trs_estado <> :old.trs_estado then				
				select est_descripcion into estadoVar from estados where est_codigo = :new.trs_estado and prc_codigo = 'TAR';
				update TareasComprobantes set  estado = estadoVar where numero = :old.trs_id;			
			end if;
			if :new.pry_id <> :old.pry_id then
				select PRY_NOMBRE into proyectoVar from proyectos where pry_id = :new.pry_id;
				update TareasComprobantes set proyecto = proyectoVar where numero = :old.trs_id;
			end if;			
			if :new.trs_id_padre <> :old.trs_id_padre or (:old.trs_id_padre is null and :new.trs_id_padre is not null) or
			(:new.trs_id_padre is null and :old.trs_id_padre is not null) then
				if :new.trs_id_padre is not null then
					SELECT TRS_ID||'-'||(SELECT set_descripcion FROM   services_types s
															WHERE  s.set_id = t2.set_id)||'-'|| DTA_CELL_ID_A||'-'||DTA_CELL_ID_B into tareaPadreVar
						FROM   detalles_tareas t2  WHERE  t2.trs_id = :new.trs_id_padre;	
				end if;
				update TareasComprobantes set tarea_padre = tareaPadreVar where numero = :old.trs_id;
			end if;
			if :new.trs_fecha_inicio <> :old.trs_fecha_inicio then
				update TareasComprobantes set f_inicio = :new.trs_fecha_inicio where numero = :old.trs_id;
			end if;
			if :new.trs_fecha_fin <> :old.trs_fecha_fin then
				update TareasComprobantes set f_fin = :new.trs_fecha_fin where numero = :old.trs_id;
			end if;
			if :new.trs_fecha_creacion <> :old.trs_fecha_creacion  then
				update TareasComprobantes set f_creacion = :new.trs_fecha_creacion where numero = :old.trs_id;
			end if;
			if :new.trs_fecha_solicitud <> :old.trs_fecha_solicitud then
				update TareasComprobantes set f_solicitud = :new.trs_fecha_solicitud where numero = :old.trs_id;
			end if;
			if :new.usr_codigo <> :old.usr_codigo then
				update TareasComprobantes set usuario = :new.usr_codigo where numero = :old.trs_id;
			end if;
			if :new.etp_id <> :old.etp_id or (:old.etp_id is null and :new.etp_id is not null) or
			(:new.etp_id is null and :old.etp_id is not null) then			
				if :new.etp_id is not null then
					SELECT etp_nombre into etapaVar FROM etapas_proyectos ep WHERE  ep.etp_id = :new.etp_id AND :new.pry_id = ep.pry_id;
				end if;		
				update TareasComprobantes set etapa = etapaVar where numero = :old.trs_id;
			end if;			
	end case;
end trg_IUDTareas;