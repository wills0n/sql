/* Переносим по одному месяцу */

declare
   from_TS varchar2(25);
   to_TS varchar2(25);
   PART_NAME varchar2(25);
begin
   from_TS := 'CURRENT_DATA';
   to_TS := 'PROC2020_3Q';  /* Меняем это значение, это табличное пространство, оно строится так: PROC - не меняется, затем год, потом _ и квартал, соответственно когда партиция соответствует кварталу */ 
   PART_NAME := 'P_202007'; /* партиция P_ год + месяц.  Если партиция уже перенесена, то вывода не будет, проверяем следующую*/
   dbms_output.put_line('BEGIN');
   dbms_output.put_line('    --START CMD_TRF_SPOOL');
   for vstr in (select '    BILLER.MOVE_IOT_TABLE.CMD_TRF_SPOOL('''||partition_name||''','''||to_TS||''');' as a
                from user_segments
                where segment_name like 'CMD_TRF_SPOOL_PK'
                and partition_name like PART_NAME||'%'
                and tablespace_name = from_TS
                order by partition_name)
   loop
      dbms_output.put_line(vstr.a);
   end loop;
   dbms_output.put_line('    --END CMD_TRF_SPOOL');
   dbms_output.put_line(' ');
   dbms_output.put_line(' ');
   dbms_output.put_line(' ');
   dbms_output.put_line(' ');
   dbms_output.put_line('    --START CMD_TRF_SPOOL_VPN');
   for vstr in (select '    BILLER.MOVE_IOT_TABLE.CMD_TRF_SPOOL_VPN('''||partition_name||''','''||to_TS||''');' as a
                from user_segments
                where segment_name like 'CMD_TRF_SPOOL_VPN_PK'
                and partition_name like PART_NAME||'%'
                and tablespace_name = from_TS
                order by partition_name)
   loop
      dbms_output.put_line(vstr.a);
   end loop;
   dbms_output.put_line('    --END CMD_TRF_SPOOL_VPN');
   dbms_output.put_line('END;');
end;

