create sequence test_seq;

create table test_perms (
  id  int default on null test_seq.nextval primary key,
  some_data varchar2(50)
);
grant select any sequence on schema hr to db_emp;
grant insert,select,delete,update(some_data) on test_perms to db_emp;
drop table test_perms purge;

