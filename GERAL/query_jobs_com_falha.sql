------------------------------------------------------------
--
-- Verifica Jobs com Falha
-- 
-- Fabio Pelissari
--
------------------------------------------------------------
set serveroutput on lines 240

DECLARE
    instanceName varchar2(10);
    qtdMaxProcess number;
    qtdMaxSessions number;
    processAtual number;
    sessionsAtual number;
    v_versao varchar2(200);
    VALID varchar2(90);
    INST_NAME varchar2(90);

BEGIN
   dbms_output.put_line(chr(10)||'=========================  INSTANCE  =========================');
	for x in (SELECT DISTINCT INS.INSTANCE_NAME INSTANCIA, INS.STATUS,DAT.NAME,DAT.OPEN_MODE,DAT.LOG_MODE,
			 DAT.DATABASE_ROLE,INS.HOST_NAME,INS.LOGINS,to_char(sysdate, 'dd/mm/yyyy hh24:mi') DATA_EXECUCAO,
			 to_char(INS.STARTUP_TIME,'dd/mm/yyyy hh24:mi') STARTUP_TIME,VER.BANNER VERSAO,DAT.FORCE_LOGGING
    		  FROM V$INSTANCE INS, V$DATABASE DAT, V$VERSION VER
    		  WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%' ORDER BY 1
	) loop
	   dbms_output.put_line(chr(10)||'Nome do servidor:............. ' || x.HOST_NAME);
	   dbms_output.put_line('Nome da instancia:............ ' || x.INSTANCIA);
	   dbms_output.put_line('Nome do banco:................ ' || x.name);
	   dbms_output.put_line('Data e hora de execucao:...... ' || x.DATA_EXECUCAO);
	   dbms_output.put_line('Startup time:................. ' || x.STARTUP_TIME);
	   dbms_output.put_line('Tipo de banco:................ ' || x.DATABASE_ROLE);
	   dbms_output.put_line('Status do banco:.............. ' || x.STATUS);
	   dbms_output.put_line('Open mode:.................... ' || x.OPEN_MODE);
	   dbms_output.put_line('Logins:....................... ' || x.LOGINS);
	   dbms_output.put_line('Modo archive:................. ' || x.LOG_MODE);
	   dbms_output.put_line('Versao do RDBMS:.............. ' || x.VERSAO || chr(10));
	end loop;


  dbms_output.put_line('========================== DETALHE DO JOB ===========================');

    SELECT count(*) into VALID FROM DBA_JOBS where BROKEN='N' and FAILURES > 0;

    if VALID = 0 then
        DBMS_OUTPUT.PUT_LINE(chr(10)||chr(10)||chr(10)||'Nao existe jobs com falhas no momento.'||chr(10)||chr(10));
    else
        FOR X IN ( SELECT JOB,INTERVAL,LOG_USER,TO_CHAR(LAST_DATE,'DD/MM/YYYY HH24:MI:SS') LAST_DATE,TO_CHAR(NEXT_DATE,'DD/MM/YYYY HH24:MI:SS')
                          NEXT_DATE,WHAT,FAILURES,decode(BROKEN,'N','HABILITADO','DESABILITADO') BROKEN,TOTAL_TIME,INSTANCE
                   FROM DBA_JOBS 
                   WHERE BROKEN='N' 
                     AND FAILURES>0 ORDER BY INSTANCE,LAST_DATE,JOB
                 )  LOOP

            DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB);
            DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.LOG_USER);
            DBMS_OUTPUT.PUT_LINE('PROCEDIMENTO EXECUTADO:..... '||X.WHAT);
            DBMS_OUTPUT.PUT_LINE('STATUS:..................... '||x.BROKEN);
            DBMS_OUTPUT.PUT_LINE('QUANTIDADE DE FALHAS:....... '||X.FAILURES);
            DBMS_OUTPUT.PUT_LINE('ULTIMA EXECUCAO:............ '||nvl(X.LAST_DATE,'------> Job saiu do estado bloqueado mas ainda nao foi executado. <------' ));
            DBMS_OUTPUT.PUT_LINE('TEMPO TOTAL DA EXECUCAO:.... '||round(X.TOTAL_TIME) || ' segundos.');
            DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_DATE);
            DBMS_OUTPUT.PUT_LINE('INTERVALO:.................. '||X.INTERVAL);

        END LOOP;
       
        /*
        for y in (select distinct value from v$parameter where name = 'background_dump_dest') loop
            select value into INST_NAME from v$parameter where name='instance_name';
                DBMS_OUTPUT.PUT_LINE(chr(10)||'ALERT.LOG:.................. '||y.value||'/alert_'||INST_NAME||'.log'||CHR(10));
            end loop;
        */

        FOR RY IN (select VALUE from V$diag_info where NAME = 'Diag Trace') loop
           select ''||ry.value||'/alert_'||value||'.log' into INST_NAME from v$parameter where name='instance_name';

           DBMS_OUTPUT.PUT_LINE(chr(10)||'ALERT.LOG:.................. '||INST_NAME||CHR(10));
        END LOOP;

        end if;
dbms_output.put_line(chr(10)||chr(10));

END;
/