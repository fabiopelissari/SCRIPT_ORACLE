------------------------------------------------------------
--
-- Verifica Lock
-- 
-- Fabio Pelissari
--
------------------------------------------------------------
set serveroutput on 
set lines 300 
set pages 2000 
set long 999999 
set size unlimited
set tab off
col sql_fulltext for a200

declare
vvalid           varchar2(90);
begin

    dbms_output.put_line(chr(10)||'=========================  INSTANCE  =========================');
    for ry in (SELECT DISTINCT INS.INSTANCE_NAME INSTANCIA, INS.STATUS,DAT.NAME,DAT.OPEN_MODE,DAT.LOG_MODE,
		      DAT.DATABASE_ROLE,INS.HOST_NAME,INS.LOGINS,to_char(sysdate, 'dd/mm/yyyy hh24:mi') DATA_EXECUCAO,
		      to_char(INS.STARTUP_TIME,'dd/mm/yyyy hh24:mi') STARTUP_TIME,VER.BANNER VERSAO,DAT.FORCE_LOGGING
    	       FROM V$INSTANCE INS, V$DATABASE DAT, V$VERSION VER
    	       WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%' ORDER BY 1
            ) loop
	   dbms_output.put_line(chr(10)||'Nome do servidor:............. ' || ry.HOST_NAME);
	   dbms_output.put_line('Nome da instancia:............ ' || ry.INSTANCIA);
	   dbms_output.put_line('Nome do banco:................ ' || ry.name);
	   dbms_output.put_line('Status do banco:.............. ' || ry.STATUS);
	   dbms_output.put_line('Open mode:.................... ' || ry.OPEN_MODE);
	   dbms_output.put_line('Versao do RDBMS:.............. ' || ry.VERSAO);
    end loop;



    for ljb in ( select l1.sid,max(l2.ctime) ctime,l1.id1,l1.id2,l1.TYPE,l1.inst_id
                 from gv$lock l1, gv$lock l2
                 where l1.block>0 and l2.block=0 and l1.id1=l2.id1 and l1.id2=l2.id2
                 group by l1.sid,l1.id1,l1.id2,l1.TYPE,l1.inst_id
                 order by 2 asc
               ) loop

    for x in ( select s.state,s.event,s.last_call_et,s.saddr,s.sid,s.prev_hash_value,s.sql_hash_value,s.username,
                      s.status,s.osuser,s.machine,s.program,s.serial#,i.instance_name,i.host_name,
                      s.sql_id,s.inst_id,to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time, s.client_info
               from gv$session s, gv$instance i where sid=ljb.sid and s.inst_id=i.inst_id and s.inst_id=ljb.inst_id and username is not null
             ) loop
             vvalid:= x.username;

             dbms_output.put_line('============================================== BLOQUEADOR ============================================== ');
             dbms_output.put_line('DATABASE INFORMATION:');
             dbms_output.put_line(rpad('USUARIO BLOQUEADOR:',29,'.')||chr(32)||lpad(x.username,25,' ')||chr(32)||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
             dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,25,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
             dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,25,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name );
             dbms_output.put_line('CLIENT INFO:................. '||x.client_info);
             dbms_output.put_line('LOGON TIME:.................. '||x.logon_time);
             dbms_output.put_line('EVENTO:...................... '||x.event||' ('||x.state||')' );

             dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
             dbms_output.put_line('SESSION PROGRAM:................. ' || x.program ||chr(10) );

            dbms_output.put_line('FINALIZAR SESSAO: ');
            dbms_output.put_line('===>'||'   alter system kill session '''||x.sid||','||x.serial#||',@'||x.inst_id||''' immediate;   '||'<==='|| chr(10));


   end loop;

  dbms_output.put_line(chr(10)||chr(10));
end loop;

if vvalid is null then
    dbms_output.put_line(chr(10)||chr(10));
    dbms_output.put_line('- ------------------------------------------ -');
    dbms_output.put_line('- NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO -');
    dbms_output.put_line('- ------------------------------------------ -');
  dbms_output.put_line(chr(10)||chr(10));
end if;

end;
/