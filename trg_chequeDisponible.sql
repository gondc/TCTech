create or replace trigger trg_chequeDisponible
before insert on chequeras
for each row
begin
	:new.che_disponible := 'S';
end trg_chequeDisponible;