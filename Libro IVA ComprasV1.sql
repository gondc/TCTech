SELECT  c.cmp_fecha_emision "Fecha",
        c.tcm_codigo "Tipo",
        t.tcm_tipo_abc||cmp_numero_legal "Numero",
        c.pro_codigo "Codigo",
        nvl(trim(c.cmp_razon_social), pr.pro_razon_social) "Razon Social",
        (SELECT cnc_descripcion
         FROM   detalles_comprobantes d1,
                conceptos cnc
         WHERE  cnc.cnc_codigo = d1.cnc_codigo
         AND    ROWNUM = 1
         AND    cnc.gco_codigo = 'CMP'
         AND    d1.cmp_numero = c.cmp_numero
         AND    dco_importe = (SELECT MAX(dco_importe)
                               FROM   detalles_comprobantes d2
                               WHERE  d2.cmp_numero = c.cmp_numero
                               AND    d2.cnc_codigo <> pkg_consultas.fnc_par_valor(e_par_tipo => 'CNC',
                                                       e_par_codigo => 'CONCEPTOS_NO_GRAVADOS')))"Concepto",
       (SELECT prv_descripcion
        FROM   domicilios dom,
               provincias prv
        WHERE  dom.pro_codigo = c.pro_codigo
        AND    prv.pai_codigo = dom.pai_codigo
        AND    prv.prv_codigo = dom.prv_codigo
        AND    dom_tipo = 'L')"Provincia",
        c.tiv_codigo "Cat.", 
        pkg_general.formatear_cuit(pr.pro_cuit) "CUIT",
        nvl(c.cmp_importe_gravado_por_iva,c.cmp_importe_neto) "Importe Neto Gravado",
       (c.cmp_importe_neto)-(nvl(c.cmp_importe_gravado_por_iva,c.cmp_importe_neto)) "Importe No Gravado", --8
       SUM(DECODE(co.gco_codigo,'IVA',SIGN (c.cmp_importe_bruto)* d.dco_importe,NULL)) "IVA",
       SUM(DECODE(co.gco_codigo||co.gil_codigo,'IMPPE',SIGN (c.cmp_importe_bruto)* d.dco_importe,NULL)) "Perc. IVA",
       SUM(DECODE(co.gco_codigo||co.gil_codigo,'IMPPB',SIGN (c.cmp_importe_bruto)* d.dco_importe,NULL)) "IIBB",
       c.cmp_importe_bruto "Importe del Comprobante"
FROM    comprobantes c, 
        tipos_comprobantes t, 
        proveedores pr, 
        detalles_comprobantes d, 
        conceptos co
WHERE   c.tcm_codigo = t.tcm_codigo
AND     c.pro_codigo = pr.pro_codigo
AND     c.cmp_numero = d.cmp_numero
AND     d.cnc_codigo = co.cnc_codigo
AND     c.cmp_fecha_anulacion IS NULL
AND     :P84_PIV_CODIGO = c.piv_codigo
AND     t.tcm_libro_iva_compras = 'S'
GROUP BY c.cmp_numero_legal,
         c.cmp_numero,
         c.cmp_fecha_emision, 
         c.tcm_codigo,
         t.tcm_tipo_abc||cmp_numero_legal,
         c.pro_codigo,
         nvl(trim(c.cmp_razon_social), pr.pro_razon_social),
         c.tiv_codigo,
         pkg_general.formatear_cuit(pr.pro_cuit),
         nvl(c.cmp_importe_gravado_por_iva,c.cmp_importe_neto),
         c.cmp_importe_neto,
         c.cmp_importe_bruto
ORDER BY c.cmp_fecha_emision ASC