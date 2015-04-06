create or replace trigger Trg_CascadeFKPersonasEmpresas
after update of PRE_LEGAJO on PERSONAS_EMPRESAS
for each row
begin	
	update USUARIOS set PRE_LEGAJO = :new.PRE_LEGAJO WHERE PRE_LEGAJO = :old.PRE_LEGAJO;
	update PERIODOS_LABORALES set PRE_LEGAJO = :new.PRE_LEGAJO WHERE PRE_LEGAJO = :old.PRE_LEGAJO;	
end;