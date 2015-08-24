create or replace trigger trg_actualizarImporteProveedor
after insert on RELACIONES_DET_ORD_DET_COMP
for each row 
declare 	
	tipoComprobante VARCHAR2(3);
	importe NUMBER(15,2);
begin
	select c.TCM_CODIGO into tipoComprobante from COMPROBANTES c where c.CMP_NUMERO = :new.CMP_NUMERO;
	if tipoComprobante = 'OC' then
		select d.DCO_IMPORTE into importe from DETALLES_COMPROBANTES d where d.CMP_NUMERO = :new.CMP_NUMERO
			and d.DCO_NUMERO = :new.DCO_NUMERO;
		update DETALLES_TAREAS set DTA_IMPORTE_PROVEEDOR = importe where TRS_ID = :new.TRS_ID;
	end if;
end;
	