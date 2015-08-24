create or replace procedure SP_asignarProyectosRolUser(pruFechaInicio DATE, usrCodigo varchar2, pryID number, rolCodigo varchar2) is
	existePRU VARCHAR2(100);	
BEGIN
	begin
		SELECT ROL_CODIGO INTO existePRU FROM PROYECTOS_ROLES_USUARIOS 
			WHERE USR_CODIGO = usrCodigo AND PRY_ID = pryID;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			existePRU := NULL;
	END;
	IF existePRU IS NOT NULL THEN						
		IF existePRU <> rolCodigo
		then
			DELETE FROM PROYECTOS_ROLES_USUARIOS WHERE USR_CODIGO = usrCodigo AND PRY_ID = pryID;
			INSERT INTO PROYECTOS_ROLES_USUARIOS(PRU_FECHA_INICIO, USR_CODIGO, PRU_ID, PRY_ID, ROL_CODIGO)
				VALUES(pruFechaInicio, usrCodigo, pru_id.nextval, pryID, rolCodigo);
		END IF;
	ELSE		
		INSERT INTO PROYECTOS_ROLES_USUARIOS(PRU_FECHA_INICIO, USR_CODIGO, PRU_ID, PRY_ID, ROL_CODIGO)
				VALUES(pruFechaInicio, usrCodigo, pru_id.nextval, pryID, rolCodigo);
	END IF;		
	COMMIT;
EXCEPTION	
	WHEN OTHERS THEN
		rollback;
		RAISE_APPLICATION_ERROR(-20000, 'Error en el proceso de Proyectos Usuarios - ' || SQLERRM);
END;

