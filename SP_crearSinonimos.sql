CREATE OR REPLACE PROCEDURE sys.SP_crearSinonimos(synonyms_schema IN VARCHAR2) is
        CURSOR syn_cur IS select synonym_name from sys.all_synonyms where owner = 'ADIAZ';        
BEGIN
        FOR x IN syn_cur LOOP                
                EXECUTE IMMEDIATE 'CREATE SYNONYM '||synonyms_schema||'.'||x.synonym_name ||' FOR TCTECH.'||x.synonym_name;
        END LOOP;        
END;​