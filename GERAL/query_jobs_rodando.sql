------------------------------------------------------------
--
-- Verifica Jobs Rodando
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
    VALID number;
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

    SELECT count(*) into VALID FROM DBA_SCHEDULER_RUNNING_JOBS;

    if VALID = 0 then
        dbms_output.put_line(chr(10)||chr(10));
        dbms_output.put_line('- ------------------------------------------ -');
        dbms_output.put_line('- NAO EXISTE JOBS RODANDO NESTE MOMENTO -');
       dbms_output.put_line('- ------------------------------------------ -');
    else
    /*
        FOR X IN (  select SID, j.JOB,j.SCHEMA_USER, j.LAST_DATE, j.THIS_DATE, j.TOTAL_TIME,j.NEXT_DATE,j.BROKEN,j.WHAT , j.INTERVAL 
                          from dba_jobs j, dba_jobs_running d where j.job = d.job
                       )  LOOP
 */
 
         FOR X IN (  select  a.JOB_NAME,  a.OWNER, to_char(LAST_START_DATE, 'dd/mm/yyyy hh24:mi') LAST_START_DATE,   to_char(NEXT_RUN_DATE, 'dd/mm/yyyy hh24:mi') NEXT_RUN_DATE,
                           REPEAT_INTERVAL,       a.state,       a.JOB_ACTION,       a.ENABLED,       b.ELAPSED_TIME
                           from  dba_scheduler_jobs a,   DBA_SCHEDULER_RUNNING_JOBS b
                           where b.owner    = a.owner  and b.job_name = a.job_name
                       )  LOOP
                       
            DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB_NAME);
            DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.OWNER);
            DBMS_OUTPUT.PUT_LINE('PROCEDIMENTO EXECUTADO:..... '||X.JOB_ACTION);
            DBMS_OUTPUT.PUT_LINE('UTL EXECUCAO:......... '||X.LAST_START_DATE);
            DBMS_OUTPUT.PUT_LINE('STATUS:............................. '||x.state);
            DBMS_OUTPUT.PUT_LINE('TEMPO TOTAL DA EXECUCAO:.... '||(X.ELAPSED_TIME) );
            DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_RUN_DATE);
            DBMS_OUTPUT.PUT_LINE('INTERVALO:.................. '||X.REPEAT_INTERVAL||CHR(10));

  dbms_output.put_line('========================== DETALHE DO JOB ===========================');
  
        END LOOP;
       
        end if;
dbms_output.put_line(chr(10)||chr(10));

END;
/