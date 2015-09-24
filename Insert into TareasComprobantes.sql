insert into tctech.TareasComprobantes SELECT "Numero",
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
       (SELECT DCO_IMPORTE_SALDO FROM tctech.DETALLES_COMPROBANTES DC 
                    JOIN tctech.COMPROBANTES C ON DC.CMP_NUMERO = C.CMP_NUMERO
                    JOIN tctech.TAREAS_DETALLES_COMPROBANTES TDC ON TDC.DCO_NUMERO = DC.DCO_NUMERO 
                    AND TDC.CMP_NUMERO = DC.CMP_NUMERO 
                    WHERE TDC.TRS_ID = vw_detalles_tareas.TRS_ID AND C.TCM_CODIGO = 'OCC' AND
                    vw_detalles_tareas.DTA_FACTURABLE = 'S') "Saldo OCC",
       tctech.pkg_tracking.fnc_fecha_facturacion_tarea(trs_id) "F. Fact.",
       tctech.pkg_tracking.fnc_fecha_cierre_tarea(trs_id) "F. Cierre",
       NVL((SELECT 'S' 
           FROM   tctech.observaciones_tareas o
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
       DECODE(tctech.pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'M','C'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') as Compras,
       DECODE(tctech.pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'RCP','C'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Recepcion,
       DECODE(tctech.pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'F','C'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Facturas,
       DECODE(tctech.pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'RC','C'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Recibos,
       DECODE('S',tctech.pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'GF'),
              '<img src="/i/Fndokay1.gif" alt="">',
              tctech.pkg_tracking.fnc_verifica_comprobante_tarea(trs_id,'F','P'),
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Gastos,    
       DECODE(tctech.pkg_tracking.fnc_verifica_evaluacion_tarea(trs_id),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Evaluaciones,
       DECODE(tctech.pkg_tracking.fnc_verifica_ordenativo_tarea(trs_id),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') "Ordenativos",
       DECODE(tctech.pkg_tracking.fnc_verifica_comp_tarea_ord(trs_id,'M'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Compras_con,
       DECODE(tctech.pkg_tracking.fnc_verifica_comp_tarea_ord(trs_id,'F'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Facturas_con,
       DECODE(tctech.pkg_tracking.fnc_verifica_comp_tarea_ord(trs_id,'RC'),'S',
              '<img src="/i/Fndokay1.gif" alt="">',
              '<img src="/i/FNDCANCE.gif" alt="">') Recibos_con,
      (SELECT cmp_numero_legal
       FROM   tctech.comprobantes cmp,
              tctech.tipos_comprobantes tcm,
              tctech.tareas_detalles_comprobantes tdc
       WHERE  cmp.cmp_numero = tdc.cmp_numero
       AND    cmp.tcm_codigo = tcm.tcm_codigo
       AND    tcm.TCM_ORIGEN = 'V'
       AND    tcm.gcm_codigo = 'M'
       AND    cmp.cli_codigo IS NOT NULL
       AND    tdc.trs_id = vw_detalles_tareas.trs_id
       AND    ROWNUM = 1)"O.C. Cliente",
      (SELECT SUBSTR(dco_descripcion_adicional,0,INSTR(dco_descripcion_adicional,'-')-1)
       FROM   tctech.comprobantes cmp,
              tctech.detalles_comprobantes dco,
              tctech.tipos_comprobantes tcm,
              tctech.tareas_detalles_comprobantes tdc
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
       FROM   tctech.proveedores p,
              tctech.ordenativos o,
              tctech.detalles_ordenativos do
       WHERE  vw_detalles_tareas.trs_id = do.trs_id
       AND    do.ord_id = o.ord_id
       AND    p.pro_codigo = o.pro_codigo
       AND    ROWNUM = 1) "Proveedor",
       pry_id, tctech.pkg_tracking.FNC_VERIFICA_COMP_TAREA_count(trs_id,'RCP','C'), tctech.pkg_tracking.FNC_VER_COMP_TAREA_ORD_count(trs_id, 'M'),
    tctech.pkg_tracking.fnc_ver_comp_tarea_ord_count(trs_id,'F'), 
    tctech.pkg_tracking.fnc_ver_comp_tarea_ord_count(trs_id,'RC'), 
  tctech.pkg_tracking.FNC_VERIFICA_COMP_TAREA_count(trs_id,'M','C'),
    tctech.pkg_tracking.FNC_VERIFICA_COMP_TAREA_count(trs_id,'F','C'),
    tctech.pkg_tracking.FNC_VERIFICA_COMP_TAREA_count(trs_id,'GF') + 
    tctech.pkg_tracking.FNC_VERIFICA_COMP_TAREA_count(trs_id,'F','P'),
    tctech.pkg_tracking.FNC_VERIFICA_COMP_TAREA_count(trs_id,'RC','C')
FROM   tctech.vw_detalles_tareas 
