create or replace procedure SP_actualizarProyecto (par_pryID number, par_pryDescripcion varchar2,  par_pryEstado varchar2, par_pryNombre varchar2,
par_empCodigo varchar2, par_cliCodigo varchar2, par_prsNumero number, par_proCodigo varchar2)
is
    cantTareas number(10);
    estFinal number(8);
    excpNoCompleto exception;
begin    
    update proyectos set pry_descripcion = par_pryDescripcion, pry_nombre = par_pryNombre, emp_codigo = par_empCodigo, cli_codigo = par_cliCodigo,
        prs_numero = par_prsNumero, pro_codigo = par_proCodigo where pry_id = par_pryID;
    savepoint todoMenosEstado;
    select count(*) into estFinal from estados where est_codigo = par_pryEstado and est_final = 'S';
    if estFinal = 1
    then
        select count(*)
            into cantTareas
            from TAREAS
            where PRY_ID = par_pryID AND TRS_ESTADO IN('EPL', 'EPR'); 
        if cantTareas > 0
        then
            rollback to todoMenosEstado;
            RAISE_APPLICATION_ERROR(-20001,'El proyecto tiene tareas sin completar.');
        else
            update proyectos set pry_estado = par_pryEstado where pry_id = par_pryID;
        end if;
    else
        update proyectos set pry_estado = par_pryEstado where pry_id = par_pryID;
        end if;    
    commit;    
end;