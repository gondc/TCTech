SELECT "Numero",
       "Service Type", 
       "Proyecto", 
       "Cell Id A", 
       "Site A", 
       "Cell Id B", 
       "Site B", 
       "Estado", 
       "F. Solicitud", 
       "F. Creacion", 
       "F. Inicio", 
       "F. Fin", 
       "F. Valorizada",
       "Facturable",
       "Importe",
		"Importe Proveedor",
	   (SELECT DCO_IMPORTE_SALDO FROM DETALLES_COMPROBANTES DC 
					JOIN COMPROBANTES C ON DC.CMP_NUMERO = C.CMP_NUMERO
					JOIN TAREAS_DETALLES_COMPROBANTES TDC ON TDC.DCO_NUMERO = DC.DCO_NUMERO 
					AND TDC.CMP_NUMERO = DC.CMP_NUMERO 
					WHERE TDC.TRS_ID = vw_detalles_tareas.TRS_ID AND C.TCM_CODIGO = 'OCC' AND
					vw_detalles_tareas.DTA_FACTURABLE = 'S') "Saldo OCC",
       pkg_tracking.fnc_fecha_facturacion_tarea(trs_id) "F. Fact.",
       pkg_tracking.fnc_fecha_cierre_tarea(trs_id) "F. Cierre",
       NVL((SELECT 'S' 
           FROM   observaciones_tareas o
           WHERE  vw_detalles_tareas.trs_id = o.trs_id
           AND    ROWNUM = 1), 'N') "OBS",
       "Link", 
       "Zona", 
       "Usuario", 
       "Who Order", 
       "Rollout Manager", 
       "Client Resposable", 
       TR, 
       AVI, 
       "Comentario", 
       "Titulo", 
       "Tarea Padre", 
       "Etapa", 
       "Concepto",
       trs_id,
       dta_id,
       DECODE(pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'M','C'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') as Compras,
       DECODE(pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'RCP','C'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Recepcion,
       DECODE(pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'F','C'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Facturas,
       DECODE(pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'RC','C'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Recibos,
       DECODE('S',pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'GF'),
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'F','P'),
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Gastos,    
       DECODE(pkg_tracking.fnc_verifica_evaluacion_tarea(trs_id),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Evaluaciones,
       DECODE(pkg_tracking.fnc_verifica_ordenativo_tarea(trs_id),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') "Ordenativos",
       DECODE(pkg_tracking.fnc_verifica_comp_tarea_ord(trs_id,'M'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Compras_con,
       DECODE(pkg_tracking.fnc_verifica_comp_tarea_ord(trs_id,'F'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Facturas_con,
       DECODE(pkg_tracking.fnc_verifica_comp_tarea_ord(trs_id,'RC'),'S',
              '<img src="#IMAGE_PREFIX#Fndokay1.gif" alt="">',
              '<img src="#IMAGE_PREFIX#FNDCANCE.gif" alt="">') Recibos_con,
      (SELECT cmp_numero_legal
       FROM   comprobantes cmp,
              tipos_comprobantes tcm,
              tareas_detalles_comprobantes tdc
       WHERE  cmp.cmp_numero = tdc.cmp_numero
       AND    cmp.tcm_codigo = tcm.tcm_codigo
       AND    tcm.TCM_ORIGEN = 'V'
       AND    tcm.gcm_codigo = 'M'
       AND    cmp.cli_codigo IS NOT NULL
       AND    tdc.trs_id = vw_detalles_tareas.trs_id
       AND    ROWNUM = 1)"O.C. Cliente",
      (SELECT SUBSTR(dco_descripcion_adicional,0,INSTR(dco_descripcion_adicional,'-')-1)
       FROM   comprobantes cmp,
              detalles_comprobantes dco,
              tipos_comprobantes tcm,
              tareas_detalles_comprobantes tdc
       WHERE  cmp.cmp_numero = tdc.cmp_numero
       AND    cmp.tcm_codigo = tcm.tcm_codigo
       AND    cmp.cmp_numero = dco.cmp_numero
       AND    dco.dco_numero = tdc.dco_numero
       AND    tcm.tcm_origen = 'V'
       AND    tcm.gcm_codigo = 'M'
       AND    cmp.cli_codigo IS NOT NULL
       AND    tdc.trs_id = vw_detalles_tareas.trs_id
       AND    ROWNUM = 1)"Pos.",
       (SELECT pro_razon_social
       FROM   proveedores p,
              ordenativos o,
              detalles_ordenativos do
       WHERE  vw_detalles_tareas.trs_id = do.trs_id
       AND    do.ord_id = o.ord_id
       AND    p.pro_codigo = o.pro_codigo
       AND    ROWNUM = 1) "Proveedor"
FROM   vw_detalles_tareas
WHERE  PKG_TRACKING.fnc_proyecto_asignado(pry_id,:USUARIO) = 1
AND   ((:P32_CONSULTA IN ('Sin OC','Con OC','Con OC y RCP') AND trs_id IN (SELECT t.trs_id
                                               FROM   tareas t,
                                                      detalles_tareas d
                                               WHERE  TO_CHAR(trs_fecha_fin,'YYYY') = :P32_ANO
                                               AND    t.trs_id = d.trs_id
                                               AND    dta_facturable = 'S'
                                               AND    trs_estado <> pkg_consultas.fnc_pag_valor(e_pag_tipo => 'SIS',
                                                                           e_pag_codigo => 'ESTADO_CANCELAR_TAREAS')
                                               AND    EXISTS (SELECT 1
                                                              FROM   estados
                                                              WHERE  trs_estado =  est_codigo
                                                              AND    prc_codigo = 'TAR'
                                                              AND    est_final = 'S')
                                               AND    TO_CHAR(trs_fecha_fin,'MONTH') = :P32_MES
                                               AND    pkg_tracking.fnc_verifica_comprobante_tarea(t.trs_id,'M')||pkg_tracking.fnc_verifica_comprobante_tarea(t.trs_id,'RCP') = DECODE(:P32_CONSULTA,'Sin OC','NN','Con OC','SN','Con OC y RCP','SS')))
       OR (:P32_CONSULTA IN ('Facturado 7 dias','Facturado 30 dias') 
          AND trs_id IN (SELECT tdc.trs_id
                         FROM   tareas vt,
                                comprobantes c,
                                detalles_comprobantes dc,
                                tareas_detalles_comprobantes tdc,
                                tipos_comprobantes tcm,
                                detalles_condiciones d
                         WHERE  PKG_TRACKING.fnc_proyecto_asignado(pry_id,:USUARIO) = 1
                         AND    TO_CHAR(cmp_fecha_emision,'YYYY') = :P32_ANO
                         AND    tcm.gcm_codigo = 'F'
                         AND    vt.trs_id = tdc.trs_id
                         AND    c.cmp_numero = dc.cmp_numero
                         AND    dc.cmp_numero = tdc.cmp_numero
                         AND    dc.dco_numero = tdc.dco_numero
                         AND    tcm.tcm_codigo = c.tcm_codigo
                         AND    d.cca_codigo = c.cca_codigo
                         AND    d.dcc_dias = DECODE(:P32_CONSULTA,'Facturado 7 dias',7,'Facturado 30 dias',30)
                         AND    TO_CHAR(cmp_fecha_emision,'MONTH') = :P32_MES)) OR (:P32_CONSULTA = 'CAO' AND 
						 TO_CHAR("F. Inicio",'YYYY') = :P32_ANO AND TO_CHAR("F. Inicio",'MONTH') = :P32_MES AND trs_estado = 'CAO'
						 and dta_facturable = 'S')
       OR :P32_CONSULTA IS NULL)
and "Proyecto" like '%' || :P32_PROYECTOS
ORDER BY "Numero" DESC