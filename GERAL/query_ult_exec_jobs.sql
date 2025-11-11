------------------------------------------------------------
--
-- Verifica as Ultimas execução de Jobs
-- 
-- Fabio Pelissari
--
------------------------------------------------------------

set serveroutput on lines 300 pages 999
declare
  v_lengString number;
  v_qtdCharacter number;

begin

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
	   dbms_output.put_line('Versao do RDBMS:.............. ' || x.VERSAO);
	end loop;


for x in (select owner, job_name, enabled,state, repeat_interval,trim(rpad(replace(trim(job_action),chr(10),chr(32)),100,chr(32)))||' (...)' job_action 
          from dba_scheduler_jobs 
          where owner = 'TASY'
--            and job_name = 'LIMPAR_REQUISICAO_MATERIAL_J'
) loop

  v_qtdCharacter:=length(x.job_action);
  dbms_output.put(chr(10));
  dbms_output.put(chr(10));
  dbms_output.put(rpad('USUARIO',20,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('NOME DO JOB',30,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('HABILITADO',6,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('ESTADO',15,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('INTERVALO',v_lengString,' '));
  dbms_output.put(chr(32));
  dbms_output.put_line(rpad('ACAO',106,' '));

  dbms_output.put(rpad('-',20,'-'));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('-',30,'-'));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('-',6,'-'));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('-',15,'-'));
  dbms_output.put(chr(32));
  dbms_output.put(rpad('-',v_lengString,'-'));
  dbms_output.put(chr(32));

  if v_qtdCharacter < 5 then
    dbms_output.put_line(rpad('-',20,'-'));
  else
    dbms_output.put_line(rpad('-',v_qtdCharacter,'-'));
  end if;

  dbms_output.put(rpad(x.owner,20,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad(x.job_name,30,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad(x.enabled,6,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad(x.state,15,' '));
  dbms_output.put(chr(32));
  dbms_output.put(rpad(x.repeat_interval,v_lengString,' '));
  dbms_output.put(chr(32));

  if v_qtdCharacter < 5 then
    dbms_output.put_line(rpad(x.job_action,20,' '));
  else
    dbms_output.put_line(rpad(x.job_action,v_qtdCharacter,' '));
  end if;



    dbms_output.put(chr(10)||chr(9));
    dbms_output.put('ULTIMAS 3 EXECUCOES');
    dbms_output.put_line(chr(10));

    dbms_output.put(chr(9));
    dbms_output.put(rpad('INSTANCE',10,' '));
    dbms_output.put(chr(32));
    dbms_output.put(rpad('DATA EXEC.',35,' '));
    dbms_output.put(chr(32));
    dbms_output.put(rpad('STATUS',10,' '));
    dbms_output.put(chr(32));
    dbms_output.put_line(rpad('ERRO',10,' '));

    dbms_output.put(chr(9));
    dbms_output.put(rpad('-',10,'-'));
    dbms_output.put(chr(32));
    dbms_output.put(rpad('-',35,'-'));
    dbms_output.put(chr(32));
    dbms_output.put(rpad('-',10,'-'));
    dbms_output.put(chr(32));
    dbms_output.put_line(rpad('-',10,'-'));


    for y in (
      select rownum, j.status, j.error#, j.actual_start_date, i.instance_name
      from
        ( select status,error#,actual_start_date,instance_id
	           from all_scheduler_job_run_details
	           where owner=x.owner
	             and job_name=x.job_name
	           order by actual_start_date desc
	      ) j,
        gv$instance i
      where j.instance_id = i.instance_number
      order by actual_start_date desc
      FETCH FIRST 3 ROWS ONLY
    ) loop

      dbms_output.put(chr(9));
      dbms_output.put(rpad(y.instance_name,10,' '));
      dbms_output.put(chr(32));
      dbms_output.put(rpad(y.actual_start_date,35,' '));
      dbms_output.put(chr(32));
      dbms_output.put(rpad(y.status,10,' '));
      dbms_output.put(chr(32));
      dbms_output.put_line(rpad(y.error#,10,' '));


    end loop;



end loop;


end;
/
