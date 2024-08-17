create domain if not exists status_d as enum ( initializing, analyzing, curating, finalized, deprecated );
grant execute on status_d to public;
drop table if exists test_col purge;

create table test_col2 (
   id        int generated always as identity
 , bod       date default on null sysdate
 , my_status  int --  status_d  default on null status_d.initializing
 , is_valid  int -- Boolean  default on null true
 , some_data varchar2(50)
);

insert into test_col2 ( some_data, my_status ) values
  ('abc', status_d.initializing);
insert into test_col2 ( some_data, my_status ) values
  ('def', status_d.analyzing);
insert into test_col2 ( some_data, my_status ) values
  ('ghi', status_d.curating);
insert into test_col2 ( some_data, my_status ) values
  ('jkl', status_d.finalized);
insert into test_col2 ( some_data, my_status ) values
  ('mno', status_d.deprecated);
commit;
grant select, insert, update, delete on test_col2 to data_entry_db;
grant select, update(is_valid,some_data) on test_col2 to data_analyzer_db;
grant select, update(is_valid)  on test_col2 to data_curator_db;
grant select, insert, update, delete on test_col2 to data_cbac_db;
