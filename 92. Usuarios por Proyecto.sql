DECLARE
	excpAsignar number(10);
	excpElim number(10);
	faltaRol EXCEPTION;
	PRAGMA EXCEPTION_INIT(faltaRol, -02291);	
	banExiste NUMBER(10);
	banFaltaRol number(10);
	BEGIN
	IF APEX_APPLICATION.G_F02.COUNT <> 0 THEN
		FOR j IN 1..APEX_APPLICATION.G_F05.COUNT LOOP			
			savepoint elimine;
			excpElim := 1;
			FOR k IN 1..APEX_APPLICATION.G_F02.COUNT LOOP
				if APEX_APPLICATION.G_F05(j) <> APEX_APPLICATION.G_F02(k) then
					banExiste := 0;
				else
					banExiste := 1;
					exit;
				end if;
			END LOOP;
			if banExiste = 0 then
				SP_eliminarProyectosRolUser(APEX_APPLICATION.G_F01(j), :P92_PRY_ID);
				savepoint elimine;
				excpElim := 0;
			end if;
			excpElim := 0;
		END LOOP;		
		banFaltaRol := 0;
		FOR I IN 1..APEX_APPLICATION.G_F02.COUNT LOOP				
			excpAsignar := 1;
			savepoint asigne;
			BEGIN								
				IF APEX_APPLICATION.G_F03(APEX_APPLICATION.G_F02(i)) <> '%NULL%' THEN						
					SP_asignarProyectosRolUser(APEX_APPLICATION.G_F04(APEX_APPLICATION.G_F02(i)),
						APEX_APPLICATION.G_F01(APEX_APPLICATION.G_F02(i)), :P92_PRY_ID, APEX_APPLICATION.G_F03(APEX_APPLICATION.G_F02(i)));		
					savepoint asigne;
					excpAsignar := 0;
				ELSE
					banFaltaRol := 1;
				END IF;
			EXCEPTION
				WHEN DUP_VAL_ON_INDEX THEN
					NULL;				
			END;
		END LOOP;
		if banFaltaRol = 1 then
			raise faltaRol;
		end if;
	ELSE		
		DELETE FROM PROYECTOS_ROLES_USUARIOS WHERE PRY_ID = :P92_PRY_ID;
	END IF;	
	COMMIT;
EXCEPTION
	WHEN faltaRol THEN	
		if excpElim = 1 then
			rollback to elimine;
		elsif excpAsignar = 1 then
			rollback to asigne;
		else
			rollback;
		end if;	
		RAISE_APPLICATION_ERROR(-20000, 'Debe seleccionar rol para cada uno de los usuarios que desea incluir.');		
	WHEN OTHERS THEN
		if excpElim = 1 then
			rollback to elimine;
		elsif excpAsignar = 1 then
			rollback to asigne;
		else
			rollback;
		end if;
		RAISE_APPLICATION_ERROR(-20000, 'Error en el proceso de Proyectos Usuarios - ');
END;