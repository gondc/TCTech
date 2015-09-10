create or replace trigger trg_fechaCambioEstadoPuntaje
before update of pop_estado on puntajes_DET_ORD_VEH_PERSONAS
for each row
    when (new.pop_estado <> old.pop_estado)         
begin
    :new.pop_fecha_estado := sysdate;
end trg_fechaCambioEstadoPuntaje;​