create or replace trigger trg_importeDefaultTarea
before insert on DETALLES_TAREAS
for each row
begin
	if :new.DTA_IMPORTE is null then
		:new.DTA_IMPORTE := 0;
	end if;
end;