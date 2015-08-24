DECLARE 
  v_count NUMBER(10) := 0;
  dom NUMBER(10) := -1;
BEGIN
	BEGIN
		SELECT 1 into dom FROM   vehiculos_ordenativos ov,  vehiculos v 
					WHERE  ord_id = :P61_ORD_ID AND    ov.veh_dominio = v.veh_dominio;
	exception when NO_DATA_FOUND then
		dom := 0;
	end;
  
  FOR i IN 1..APEX_APPLICATION.G_F22.COUNT LOOP
    IF APEX_APPLICATION.G_F22(i) IS NOT NULL THEN
      
      INSERT INTO detalles_ordenativos(ORD_ID,
                                       TRS_ID,
                                       DOR_ESTADO,
                                       DOR_FECHA_INICIO)
                                VALUES(:P61_ORD_ID,
                                       APEX_APPLICATION.G_F22(i),
                                       (SELECT EST_CODIGO
                                        FROM   estados
                                        WHERE  EST_INICIAL = 'S'
                                        AND    PRC_CODIGO = 'DOR'
                                        AND    ROWNUM = 1),
                                       :P61_ORD_FECHA_INICIO);
      
		
		if dom = 1 then
			  FOR j IN 1..APEX_APPLICATION.G_F23.COUNT LOOP
				IF APEX_APPLICATION.G_F23(j) IS NOT NULL THEN
				  v_count := v_count + 1;
				  INSERT INTO puntajes_det_ord_veh_personas(ord_id, 
															prs_numero,
															veh_dominio,
															trs_id,
															pop_estado,
															pop_afectacion,
															pop_pagado)
													 VALUES(:P61_ORD_ID,
															APEX_APPLICATION.G_F23(j),
															(SELECT VEH_DOMINIO
															 FROM   vehiculos_ordenativos_personas
															 WHERE  ord_id = :P61_ORD_ID
															 AND    PRS_NUMERO = APEX_APPLICATION.G_F23(j)),
															 APEX_APPLICATION.G_F22(i),
															'EN ESPERA',
															'TOTAL',
															'N');
				END IF;
			  END LOOP;
		 else
			v_count := 1;
		end if;
    END IF;                                    
  END LOOP;
  
  IF v_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20000, 'No se han seleccionado Personas o Tareas para agregar tareas');
  END IF;
END;