create or replace trigger Trg_CascadePKPersonasVOP
after update of PRS_NUMERO on VEHICULOS_ORDENATIVOS_PERSONAS
for each row
begin	
	update PUNTAJES_DET_ORD_VEH_PERSONAS set PRS_NUMERO = :new.PRS_NUMERO WHERE PRS_NUMERO = :old.PRS_NUMERO;	
end;