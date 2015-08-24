create or replace procedure SP_eliminarProyectosRolUser(usrCodigo varchar2, pryID number) is	
BEGIN
	DELETE FROM PROYECTOS_ROLES_USUARIOS WHERE PRY_ID = pryID AND USR_CODIGO = usrCodigo;
	COMMIT;
EXCEPTION	
	WHEN OTHERS THEN
		rollback;
		RAISE_APPLICATION_ERROR(-20000, 'Error en el proceso de Proyectos Usuarios - ' || SQLERRM);
END;