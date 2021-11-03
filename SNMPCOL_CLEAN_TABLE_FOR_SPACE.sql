  -- SELECT min(a.id) FROM snmp_config a where id>(select max(id)-300 from snmp_config);

   /*
   SNMP_COLLECTOR_CONFIG
   */
   create table snmp_collector_config_1 as
   SELECT a.config_id, a.collector_id, a.collector_ip, a.collector_port,
          a.collector_priority
     FROM snmp_collector_config a where a.config_id<(SELECT min(a.id) FROM snmp_config a where id>(select max(id)-300 from snmp_config));

  
   TRUNCATE table snmp_collector_config drop storage;
   commit;

  
   insert into snmp_collector_config (config_id, collector_id, collector_ip, collector_port, collector_priority)
   SELECT config_id, collector_id, collector_ip, collector_port, collector_priority FROM snmp_collector_config_1;
   commit;

   drop table snmp_collector_config_1;

   /*
   SNMP_INVESTIGATION_RESULT
   */
   create table snmp_investigation_result_1 as
   SELECT a.id, a.collector_router_config_id, a.collector_id, a.created,
          a.available, a.used_snmp_version, a.response_time
     FROM snmp_investigation_result a where a.collector_router_config_id in (SELECT a.id
     FROM snmp_collector_router_config a where config_id>=(SELECT min(a.id) FROM snmp_config a where id>(select max(id)-300 from snmp_config)));
  
   truncate table snmp_investigation_result drop storage;
   commit;

   insert into snmp_investigation_result (id, collector_router_config_id, collector_id, created, available, used_snmp_version, response_time)
   SELECT id, collector_router_config_id, collector_id, created, available, used_snmp_version, response_time
     FROM snmp_investigation_result_1;
   commit;

   drop table snmp_investigation_result_1;

   /*
   SNMP_COLLECTOR_ROUTER_CONFIG
   */

   ALTER TABLE snmp_getting_data_result
   DROP CONSTRAINT fk_col_config__getting_data;
   ALTER TABLE snmp_investigation_result
   DROP CONSTRAINT fk_col_config__investigation;

   create table snmp_collector_router_config_1 as
   SELECT a.id, a.config_id, a.router_id, a.router_ip, a.router_community,
          a.router_snmp_version, a.router_request_frequency
     FROM snmp_collector_router_config a where config_id>=(SELECT min(a.id) FROM snmp_config a where id>(select max(id)-300 from snmp_config));
  
   truncate table snmp_collector_router_config drop storage;
   commit;

   insert into snmp_collector_router_config (id, config_id, router_id, router_ip, router_community, router_snmp_version, router_request_frequency)
   SELECT id, config_id, router_id, router_ip, router_community, router_snmp_version, router_request_frequency
     FROM snmp_collector_router_config_1;
   commit;

   drop table snmp_collector_router_config_1;

   ALTER TABLE snmp_getting_data_result
   ADD CONSTRAINT fk_col_config__getting_data FOREIGN KEY (
     collector_router_config_id)
   REFERENCES snmp_collector_router_config (id) ON DELETE CASCADE;
   ALTER TABLE snmp_investigation_result
   ADD CONSTRAINT fk_col_config__investigation FOREIGN KEY (
     collector_router_config_id)
   REFERENCES snmp_collector_router_config (id) ON DELETE CASCADE;

   /*
   SNMP_CONFIG
   */

   delete  FROM snmp_config a where id<(SELECT min(a.id) FROM snmp_config a where id>(select max(id)-300 from snmp_config));
   commit;
   
   truncate table snmp_event_log;
   commit;
   
/*   
   select 'purge table "'||object_name||'";' from user_recyclebin;
*/
