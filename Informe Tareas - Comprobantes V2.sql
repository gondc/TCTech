SELECT Numero,
       Service_Type "Service Type", 
       Proyecto, 
       Cell_Id_A "Cell Id A", 
        Site_A "Site A", 
       Cell_Id_B "Cell Id B", 
       Site_B "Site B", 
       Estado, 
       F_Solicitud "F. Solicitud", 
       F_Creacion "F. Creacion", 
       F_Inicio "F. Inicio", 
       F_Fin"F. Fin", 
       F_Valorizada "F. Valorizada",
       Facturable,
       Importe,
Importe_Proveedor "Importe Proveedor",
	    Saldo_OCC "Saldo OCC",
       F_Fact "F. Fact.",
       F_Cierre "F. Cierre",
       OBS,
       Link, 
       Zona, 
       Usuario, 
       Who_Order "Who Order", 
       Rollout_Manager "Rollout Manager", 
       Client_Responsable "Client Resposable", 
       TR, 
       AVI, 
       Comentario, 
       Titulo, 
       Tarea_Padre "Tarea Padre", 
       Etapa, 
       Concepto,
       trs_id,
       dta_id,
        Compras,
        Recepcion,
        Facturas,
       Recibos,
        Gastos,    
        Evaluaciones,
        Ordenativos,
       Compras_con,
        Facturas_con,
       Recibos_con,
      OC_Cliente "O.C. Cliente",
      Pos "Pos.",
        Proveedor
FROM   TareasComprobantes
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
                         AND    TO_CHAR(cmp_fecha_emision,'MONTH') = :P32_MES))
       OR :P32_CONSULTA IS NULL)
and Proyecto like '%' || :P32_PROYECTOS
ORDER BY Numero DESC