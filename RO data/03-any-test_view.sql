set SERVEROUT on
insert into hr.protected_data_view (n) values (null);
insert into hr.protected_data_view (n) values (null);
insert into hr.protected_data_view (n) values ('hello');
insert into hr.protected_data_view (n, is_valid) values ('helo', 0);
commit;

select * from hr.protected_data_view order by id;

-- show we can update `is_valid`
update hr.protected_data_view set is_valid=0 where id = (select min(id) from hr.protected_data_view where n is null);
update hr.protected_data_view set is_valid=0 where id = (select max(id) from hr.protected_data_view where n is not null);

-- show update ability of `n`
update hr.protected_data_view set n='goodbye' where id = (select min(id) from hr.protected_data_view where n is null);

-- still - problems here; privilege comes from login user, not ACL Principal
-- THIS SHOULD FAIL
update hr.protected_data_view set n='fake' where id = (select max(id) from hr.protected_data_view where n is not null);

delete from hr.protected_data_view;
commit;

select * from hr.protected_data_view order by id;
/* Expecting: (1,'goodbye', 0), (3,'hello',0) */
