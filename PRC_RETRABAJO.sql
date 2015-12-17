CREATE OR REPLACE PROCEDURE PRC_RETRABAJO(I_TRS_ID IN NUMBER, paramObs in varchar2, paramUSR in varchar2) IS

V_TRS_ID TAREAS.TRS_ID%TYPE := NULL;
V_OTA_ID OBSERVACIONES_TAREAS.OTA_ID%TYPE;

BEGIN

  SELECT TRS_ID.NEXTVAL
  INTO V_TRS_ID
  FROM DUAL;
  
  select OTA_ID.NEXTVAL into V_OTA_ID from DUAL;
                       
  INSERT INTO TAREAS (TRS_ID,
                      TRS_FECHA_CREACION,
                      TRS_TITULO,
                      TRS_ESTADO,
                      ETP_ID,
                      CNC_CODIGO,
                      TRS_ID_PADRE,
                      PRY_ID,
                      USR_CODIGO,
                      TRS_FECHA_SOLICITUD)
               SELECT V_TRS_ID,
                      SYSDATE,
                      'Retrabajo',
                      (SELECT EST_CODIGO
                       FROM   ESTADOS
                       WHERE  EST_INICIAL = 'S'
                       AND    PRC_CODIGO = 'TAR'
                       AND    ROWNUM = 1),
                      ETP_ID,
                      CNC_CODIGO,
                      TRS_ID,
                      PRY_ID,
                      USR_CODIGO,
                      TRS_FECHA_SOLICITUD
                FROM  TAREAS
                WHERE TRS_ID = I_TRS_ID;


  INSERT INTO DETALLES_TAREAS (DTA_ID,
                               DTA_LINK,
                               DTA_CELL_ID_A,
                               DTA_SITE_A,
                               DTA_CELL_ID_B,
                               DTA_SITE_B,
                               TRS_ID,
                               ZON_ID,
                               SET_ID,
                               DTA_TR,
                               DTA_AVI,
                               DTA_WHO_ORDER,
                               DTA_ROLLOUT_MANAGER,
                               COC_NUMERO,
                               DTA_IMPORTE,
                               DTA_FACTURABLE)
                        SELECT DTA_ID.NEXTVAL,
                               DTA_LINK,
                               DTA_CELL_ID_A,
                               DTA_SITE_A,
                               DTA_CELL_ID_B,
                               DTA_SITE_B,
                               V_TRS_ID,
                               ZON_ID,
                               set_id,
                               DTA_TR,
                               DTA_AVI,
                               DTA_WHO_ORDER,
                               DTA_ROLLOUT_MANAGER,
                               COC_NUMERO,
                               0,
                               'N'
                         FROM  DETALLES_TAREAS
                         WHERE TRS_ID = I_TRS_ID;
						 
	 insert into observaciones_tareas (OTA_ID, OTA_FECHA_CREACION, OTA_DESCRIPCION,TRS_ID, USR_CODIGO) values (V_OTA_ID, SYSDATE, paramObs, V_TRS_ID, paramUSR);




END;