create or replace procedure sp_improductivos is
begin
	insert into dias_improductivos (di_fecha, prs_numero) (select sysdate, p.prs_numero from personas p join personas_empresas pe on p.prs_numero = pe.prs_numero join usuarios u 
		on u.pre_legajo = pe.pre_legajo join roles_usuarios ru on ru.usr_codigo = u.usr_codigo where pe.pre_estado = 'A' and ru.rol_codigo = 'MNI_TECNICO'
		and not exists (select 1 from ordenativos o join vehiculos_ordenativos_personas vop on o.ord_id = vop.ord_id where o.ord_fecha_fin is null
		and vop.prs_numero = p.prs_numero));
exception
	when no_data_found then
		null;
end;