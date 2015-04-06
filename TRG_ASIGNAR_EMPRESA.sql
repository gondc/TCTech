create or replace trigger Trg_AsignarEmpresa
before insert on PERSONAS_EMPRESAS
for each row
begin
	:new.EMP_CODIGO := '1';
end;

	