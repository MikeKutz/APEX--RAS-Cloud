--truncate table protected_data;
insert into hr.protected_data (n) values (null);
insert into hr.protected_data (n) values (null);
insert into hr.protected_data (n) values ('hello');
commit;

select * from hr.protected_data order by id;

-- show we can update `is_valid`
prompt Expected Result for Test 1: 1 row updated
prompt Expected Result for Test 2: 1 row updated
update hr.protected_data set is_valid=0 where id = (select min(id) from hr.protected_data);
prompt Expected Result for Test 1: 0 row updated
Prompt Expected Result for Test 2: 1 row update
update hr.protected_data set is_valid=0 where id = (select max(id) from hr.protected_data);

prompt Expected Result for Test 1: 1 row updated | Actual: ORA-28115 (Issue 1)
prompt Expected Result for Test 2: 1 row updated
update hr.protected_data set n='goodbye' where id = (select min(id) from hr.protected_data);

prompt Expected Result for Test 1: 0 row updated
prompt Expected Result for Test 2: 0 row updated | Actual: 1 row updated (Issue 2)
update hr.protected_data set n='fake' where id = (select max(id) from hr.protected_data);

prompt Expected Result for Test 1: 1 row deleted | Actual: 2 row deleted
prompt Expected Result for Test 2: 1 row deleted
delete from hr.protected_data;
commit;

prompt expect for Test 1
prompt  id  |  n       | is_valid
prompt ==========================
prompt   1  | goodbye  | 0
prompt   3  | hello    | 1
prompt
prompt expect for Test 2
prompt  id  |  n       | is_valid
prompt ==========================
prompt   1  | goodbye  | 0
prompt   3  | hello    | 0 
prompt   3  | fake     | 0 (actual)

select * from hr.protected_data order by id;
/* Expecting: (1,'goodbye', 0), (3,'hello',0) */
