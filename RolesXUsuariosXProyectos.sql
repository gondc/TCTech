SELECT APEX_ITEM.HIDDEN(5, ROWNUM) || APEX_ITEM.HIDDEN(1, a.USR_CODIGO) || APEX_ITEM.CHECKBOX2(2,ROWNUM,DECODE(NVL((SELECT 1 
                                                 FROM   PROYECTOS_ROLES_USUARIOS pru
                                                 WHERE  pru.USR_CODIGO = a.USR_CODIGO  
												 AND    pru.PRY_ID = :P92_PRY_ID),0),0,'UNCHECKED',1,'CHECKED')) as Incluir,
     a.USR_CODIGO as Usuario, APEX_ITEM.SELECT_LIST_FROM_QUERY(3, NVL((SELECT pru.ROL_CODIGO 
                                                 FROM   PROYECTOS_ROLES_USUARIOS pru
                                                 WHERE  pru.USR_CODIGO = a.USR_CODIGO  
												 AND    pru.PRY_ID = :P92_PRY_ID),null), 'SELECT r.ROL_DESCRIPCION, r.ROL_CODIGO 
	 FROM ROLES r WHERE EXISTS (SELECT 1 FROM ROLES_USUARIOS ru
           WHERE ru.ROL_CODIGO = r.ROL_CODIGO
           AND ru.USR_CODIGO = ''' || a.USR_CODIGO || ''') and r.ROL_CODIGO not in(''MNI_RRHH'',''CAJ_COMPRAS'',''CAJ_VENTAS'',''CTA_CTE_CLIENTES''
		   ,''CTA_CTE_PROVEEDORES'',''TCM_ALQUILERES'',''TCM_COMPRAS'') order by 1', null, 'YES', '%NULL%', '--') as Rol, 
		   NVL((SELECT APEX_ITEM.DATE_POPUP2(4, prus.PRU_FECHA_INICIO, 'dd/mm/yyyy')
					from PROYECTOS_ROLES_USUARIOS prus where prus.PRY_ID = :P92_PRY_ID and prus.USR_CODIGO = a.USR_CODIGO),
						APEX_ITEM.DATE_POPUP2(4, TO_CHAR(SYSDATE, 'dd/mm/yyyy'), 'dd/mm/yyyy')) as Fecha_Inicio
FROM USUARIOS a  WHERE a.USR_FECHA_BAJA IS NULL
AND exists (SELECT 1
                    FROM  WWV_FLOW_FND_USER
                    WHERE USER_NAME = a.USR_CODIGO) AND NOT EXISTS (SELECT 1 FROM ROLES_USUARIOS rus 
																			WHERE rus.USR_CODIGO = a.USR_CODIGO AND
																			rus.ROL_CODIGO = 'MNI_TECNICO')
 order by 1;
