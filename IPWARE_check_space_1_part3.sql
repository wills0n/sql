select tablespace_name, size_autoextent_m,used_m,max_m, username, status,
     round((used_m/max_m)*100,4), round((used_m/size_autoextent_m)*100,4)
from (
SELECT tablespace_name, size_autoextent / 1024 / 1024 size_autoextent_m,
       used_bytes / 1024 / 1024 used_m,
       CASE max_bytes
          WHEN -1
             THEN -1
          ELSE(LEAST(max_bytes, size_autoextent) / 1024 / 1024)
       END max_m, username, status
  FROM adb.orafreespase4patrol
 WHERE username IN('BILLER','SNMPCOL') AND status <> 'READ ONLY'
 )  
order by tablespace_name,username;
