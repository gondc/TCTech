create or replace trigger Trg_CascadePKPersonas
after update of PRS_NUMERO on PERSONAS
for each row
begin
	update PERSONAS_EMPRESAS set PRS_NUMERO = :new.PRS_NUMERO WHERE PRS_NUMERO = :old.PRS_NUMERO;
	update TELEFONOS set PRS_NUMERO = :new.PRS_NUMERO WHERE PRS_NUMERO = :old.PRS_NUMERO;
	update DOMICILIOS set PRS_NUMERO = :new.PRS_NUMERO WHERE PRS_NUMERO = :old.PRS_NUMERO;
	update VEHICULOS_ORDENATIVOS_PERSONAS set PRS_NUMERO = :new.PRS_NUMERO WHERE PRS_NUMERO = :old.PRS_NUMERO;		
end;

