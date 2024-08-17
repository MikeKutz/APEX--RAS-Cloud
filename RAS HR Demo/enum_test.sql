create table enum_demo (
  enum_value  int,
  enum_name   varchar2(128 byte)
);

drop table enum_data;
drop table enum_demo purge;

-------  schema setup
create table enum_demo
  ( enum_value int generated always as identity primary key
    , enum_name varchar2(128 byte) not null unique);
select * from enum_demo;

create table enum_data ( ora$enum_value int INVISIBLE
  ,entry_date  date default on null SYSDATE
  ,stuff    varchar2(50)
  ,FOREIGN key (ora$enum_value) references enum_demo(enum_value)
);

create or replace
trigger ez_trg
  after insert
  on enum_demo
  for each row
begin
  insert into enum_data ( ora$enum_value ) values ( :new.enum_value );
end;
/

create or replace view enum_v
as
select c.*, d.*
from enum_demo c
  join enum_data d on c.enum_value = d.ora$enum_value;

select * from enum_v;

----------- init data
insert into enum_demo (enum_name)
select enum_name from sys.day_enum_d where length(enum_name) > 3;
commit;

--- apply RAS
begin
  sys.xs_data_security.apply_object_policy(
    policy => 'enum_policy'
    ,schema => 'hr'
    ,object =>'enum_demo'
    ,owner_bypass => false
    );
end;
/


insert into enum_demo (enum_name) values ( 'should fail' );

exec cSQL.utl_enum.add_entry( 'enum_demo', 'cbac' );

insert into enum_demo (enum_name) values ( 'should fail' ); -- CVE-2023-21829

select * from enum_v;
update enum_v set stuff = 'hello' where enum_value = 23;

update enum_v set enum_name = 'blargsday';

update enum_demo set enum_name = 'sss' where enum_value = 16;



begin
  sys.xs_data_security.DISABLE_OBJECT_POLICY(
    policy => 'enum_policy', 
    schema => 'hr',
    object =>'enum_demo'
    );
end;
/

exec cSQL.utl_enum.drop_value ( 'enum_demo', 1 );
exec cSQL.utl_enum.drop_value ( 'enum_demo', 2 );
exec cSQL.utl_enum.drop_value ( 'enum_demo', 3 );
exec cSQL.utl_enum.drop_value ( 'enum_demo', 4 );
exec cSQL.utl_enum.drop_value ( 'enum_demo', 5 );
exec cSQL.utl_enum.drop_value ( 'enum_demo', 6 );
exec cSQL.utl_enum.drop_value ( 'enum_demo', 7 );
commit;

