/* Переносим по одному месяцу */


      /*
      'CURRENT_DATA' - откуда переносим.
      'PROC2010_3Q'  - куда переносим.

      Перенос организован через замену партиции в большой таблице на временную таблицу.
      Дополнительно происходит сжатие данных.
      Запускать каждый процесс надо в один поток (ограничение архитектуры).
      По причине активности в БД достаточно часто падает (на целостности данных это не отражается).

      Для переноса вспомогательных таблиц формируются и последовательно выполняются скрипты:
      */

declare
   from_TS varchar2(25);
   to_TS varchar2(25);
   PART_NAME varchar2(25);
begin
   from_TS := 'CURRENT_DATA';
   to_TS := 'PROC2020_3Q';  /* Меняем это значение, это табличное пространство, оно строится так: PROC - не меняется, затем год, потом _ и квартал, соответственно когда партиция соответствует кварталу */ 
   PART_NAME := 'P_202007'; /* партиция P_ год + месяц.  Если партиция уже перенесена, то вывода не будет, проверяем следующую*/
   dbms_output.put_line('BEGIN');
   dbms_output.put_line('--START SECONDARY TABLES');
   for vstr in (select 'EXECUTE IMMEDIATE ''ALTER TABLE BILLER.'||segment_name||' MOVE PARTITION '||partition_name||' TABLESPACE '||to_TS||' COMPRESS'';' as a
      from user_segments
      where partition_name = PART_NAME
      and tablespace_name = from_TS
      and segment_type = 'TABLE PARTITION'
      and segment_name not in (
      select distinct segment_name from user_segments
      where tablespace_name like 'TRF20%'
      and segment_type = 'TABLE PARTITION'
      )
      order by 1)
   loop
      dbms_output.put_line('    '||vstr.a);
   end loop;
   dbms_output.put_line('--END SECONDARY TABLES');
   dbms_output.put_line(' ');
   dbms_output.put_line(' ');
   dbms_output.put_line(' ');
   dbms_output.put_line(' ');
   dbms_output.put_line('--START SECONDARY TABLES INDEXES');
   for vstr in (select 'EXECUTE IMMEDIATE ''ALTER INDEX BILLER.'||segment_name||' REBUILD PARTITION '||partition_name||' TABLESPACE '||to_TS||''';' as a
      from user_segments
      where partition_name = PART_NAME
      and tablespace_name = from_TS
      and segment_type = 'INDEX PARTITION'
      and segment_name not in (
      select distinct segment_name from user_segments
      where tablespace_name like 'TRF20%'
      and segment_type = 'INDEX PARTITION'
      )
      order by 1)
   loop
      dbms_output.put_line('    '||vstr.a);
   end loop;
   dbms_output.put_line('--END SECONDARY TABLES INDEXES');
   dbms_output.put_line('END;');
end;

