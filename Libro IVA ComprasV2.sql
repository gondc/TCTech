SELECT  c.cmp_fecha_emision "Fecha",
        c.tcm_codigo "Tipo",
        t.tcm_tipo_abc||cmp_numero_legal "Numero",
        c.pro_codigo "Codigo",
        nvl(trim(c.cmp_razon_social), pr.pro_razon_social) "Razon Social",
        cnc_descripcion
          "Concepto",
       (SELECT prv_descripcion
        FROM   domicilios dom,
               provincias prv
        WHERE  dom.pro_codigo = c.pro_codigo
        AND    prv.pai_codigo = dom.pai_codigo
        AND    prv.prv_codigo = dom.prv_codigo
        AND    dom_tipo = 'L')"Provincia",
        c.tiv_codigo "Cat.", 
        pkg_general.formatear_cuit(pr.pro_cuit) "CUIT",
        sum(decode(co.gco_codigo,'IVA',NULL, d.dco_importe)) "Importe Neto Gravado",
      SUM(DECODE(d.dco_importe,(SELECT MAX(d1.dco_importe) FROM detalles_comprobantes d1 where d1.cmp_numero = c.cmp_numero),
	  (c.cmp_importe_neto)-(nvl(c.cmp_importe_gravado_por_iva,c.cmp_importe_neto)), NULL)) "Importe No Gravado", 
       SUM(DECODE(co.gco_codigo,'IVA',SIGN (c.cmp_importe_bruto)* d.dco_importe,NULL)) "IVA",
       sum(DECODE(d.dco_importe,(SELECT MAX(d1.dco_importe) FROM detalles_comprobantes d1 where d1.cmp_numero = c.cmp_numero),
				(select SIGN (co.cmp_importe_bruto)* de.dco_importe from comprobantes co 
						join detalles_comprobantes de on co.cmp_numero = de.cmp_numero
						join conceptos con on de.cnc_codigo = con.cnc_codigo 
						where con.gco_codigo||con.gil_codigo = 'IMPPE' and co.cmp_numero = c.cmp_numero), NULL)) "Perc. IVA",
       SUM(DECODE(d.dco_importe,(SELECT MAX(d1.dco_importe) FROM detalles_comprobantes d1 where d1.cmp_numero = c.cmp_numero),
				(select sum(SIGN (co.cmp_importe_bruto)* de.dco_importe) from comprobantes co 
						join detalles_comprobantes de on co.cmp_numero = de.cmp_numero
						join conceptos con on de.cnc_codigo = con.cnc_codigo 
						where con.gco_codigo||con.gil_codigo = 'IMPPB' and co.cmp_numero = c.cmp_numero 
						group by co.cmp_numero ), NULL)) "IIBB",
       SUM(DECODE(d.dco_numero+d.dco_importe,(SELECT MAX(d1.dco_numero+MAX(d1.dco_importe)) FROM detalles_comprobantes d1 
		where d1.cmp_numero = c.cmp_numero group by d1.dco_numero),
	   c.cmp_importe_bruto, Null)) "Importe del Comprobante"
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
AND co.cnc_codigo <> 'C066'
AND co.gco_codigo||co.gil_codigo NOT IN ('IMPPB', 'IMPPE')
GROUP BY  d.dco_numero,
         c.cmp_fecha_emision, 
		  cnc_descripcion,
         c.tcm_codigo,
         t.tcm_tipo_abc||cmp_numero_legal,
         c.pro_codigo,
         nvl(trim(c.cmp_razon_social), pr.pro_razon_social),
         c.tiv_codigo,
         pkg_general.formatear_cuit(pr.pro_cuit),
         c.cmp_importe_bruto
ORDER BY c.cmp_fecha_emision ASC, t.tcm_tipo_abc||cmp_numero_legal, "Importe del Comprobante" ASC