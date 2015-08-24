create or replace FUNCTION FNC_VERIFICA_OBSERVACION_TAREA (I_TRS_ID IN TAREAS.TRS_ID%TYPE) RETURN VARCHAR2 IS

V_FLAG VARCHAR2(1);

cursor cur is SELECT 1  
  FROM   OBSERVACIONES_TAREAS O WHERE O.TRS_ID = I_TRS_ID 
  AND    ROWNUM = 1;

BEGIN
  open cur;
  fetch cur into V_FLAG;
    if cur%NOTFOUND THEN
        SELECT 1 into v_flag  FROM   DETALLES_ORDENATIVOS D
            WHERE d.trs_id = I_TRS_ID AND d.dor_motivo_cancelacion IS NOT NULL
            AND    ROWNUM = 1;
            return 'S';
    else
        RETURN 'S';
        end if;
    close cur;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';
END;​