create or replace TRIGGER TCTECH.TRG_UPLOAD_TAREAS
INSTEAD OF INSERT
ON TCTECH.V_UPLOAD_TAREAS 
REFERENCING NEW AS NEW OLD AS OLD
FOR EACH ROW
BEGIN
  DECLARE
  v_trs_id tareas.trs_id%TYPE;
  v_cel_desc_a celdas.cel_descripcion%TYPE;
  v_cel_desc_b celdas.cel_descripcion%TYPE;
  v_coc_numero contactos_clientes.coc_numero%TYPE;
  v_etp_pry etapas_proyectos.etp_id%TYPE;
  v_ota_id observaciones_tareas.ota_id%TYPE;
  BEGIN
    SELECT trs_id.NEXTVAL 
    INTO v_trs_id
    FROM DUAL;
    
    BEGIN
      SELECT cel_descripcion
      INTO   v_cel_desc_a
      FROM   celdas
      WHERE  cel_codigo = :NEW.CELL_ID_A;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_cel_desc_a := NULL;
    END;
    
    BEGIN
      SELECT cel_descripcion
      INTO v_cel_desc_b
      FROM   celdas
      WHERE  cel_codigo = :NEW.CELL_ID_B;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_cel_desc_b := NULL;
    END;
    
	BEGIN
		select etp_id
		into v_etp_pry
		from etapas_proyectos
		where etp_nombre = :NEW.ETAPA and pry_id = :NEW.PROYECTO;
	EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_etp_pry := NULL;
    END;
	
	
    BEGIN
      SELECT coc_numero
      INTO  v_coc_numero
      FROM contactos_clientes
      WHERE coc_nombre||'-'|| coc_apellido = :NEW.CLIENT_RESPONSABLE;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        v_coc_numero := NULL;
    END;
    
    
        INSERT INTO tareas(trs_id, 
                           trs_fecha_creacion, 
                           trs_estado, 
                           cnc_codigo,  
                           pry_id,
                           usr_codigo,                            
                           trs_fecha_solicitud,
						   etp_id)
                    VALUES (v_trs_id,                           
                           SYSDATE,                             
                           pkg_general.estado_inicial('TAR'), 
                           pkg_consultas.fnc_pag_valor(e_pag_tipo => 'CMP',
                                   e_pag_codigo => 'CONCEPTO_DEFAULT_TAREAS'), 
                           :NEW.PROYECTO,
                            APEX_CUSTOM_AUTH.GET_USER,                            
                           :NEW.FECHA_SOLICITUD,
						   v_etp_pry);
        
        
        INSERT INTO detalles_tareas(dta_id, 
                                    dta_link, 
                                    dta_cell_id_a, 
                                    dta_site_a, 
                                    dta_cell_id_b, 
                                    dta_site_b, 
                                    trs_id,
                                    zon_id,                                   
                                    set_id,                                     
                                    dta_facturable,
                                    dta_rollout_manager, 
                                    coc_numero,
                                    dta_comments)                                    
                             VALUES (dta_id.NEXTVAL, 
                                    :NEW.CELL_ID_A||:NEW.CELL_ID_B,
                                    :NEW.CELL_ID_A,
                                     v_cel_desc_a,                                                             
                                    :NEW.CELL_ID_B,
                                     v_cel_desc_b,  
                                     v_trs_id, 
                                    :NEW.ZONA,                                      
                                    :NEW.SERVICE_TYPE, 
                                    :NEW.FACTURABLE,
                                    :NEW.ROLLOUT_MANAGER,
                                    v_coc_numero,                                    
                                    :NEW.COMENTARIOS);
			begin						
				if :new.observaciones is not null
				then
					select ota_id.nextval into v_ota_id from dual;
					insert into observaciones_tareas(ota_id,ota_fecha_creacion, ota_descripcion, trs_id, usr_codigo) 
						values (v_ota_id, to_char(sysdate, 'dd/mm/yyyy'), :NEW.observaciones, v_trs_id, :NEW.ROLLOUT_MANAGER);
				end if;
			end;
  EXCEPTION
    WHEN OTHERS THEN
      raise_application_error(-20000,'Error en el trigger TRG_UPLOAD_TAREAS -'||SQLERRM);                  
  END;           
END;​