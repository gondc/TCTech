create or replace trigger tctech.trg_BIRelDetOrdDetComp
    before insert
    on tctech.relaciones_det_ord_det_comp
    for each row
    when (new.rdo_importe is null)
declare
    cantTareas number(10);
    importe number(15,3);
begin
    select count(*) into cantTareas from tctech.detalles_ordenativos where ord_id = :new.ord_id;
    select cmp_importe_neto into importe from tctech.comprobantes c join tctech.detalles_comprobantes d on
        c.cmp_numero = d.cmp_numero where c.cmp_numero = :new.cmp_numero and d.dco_numero 
        = :new.dco_numero;
    :new.rdo_importe := trunc((importe/cantTareas),2);
end trg_BIRelDetOrdDetComp;	