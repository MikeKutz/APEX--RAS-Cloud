alter table test_dom add primary key (enum_value);
create table test_child (
  enum_value int REFERENCES test_dom(enum_value)
);

select * from test_dom;

-- test cbac insert
exec cSQL.utl_enum.add_entry( 'test_dom', 'def' );
commit;

update test_dom set other_data = sysdate where other_data is null;


-- test update other columns
update test_dom set other_data = sysdate where enum_name = 'hello';
update test_dom set stuff = 'slkj' where enum_value = (4);
update test_dom set other_data = sysdate + 4 where enum_value = 4;

insert into test_dom (enum_name) values ( 'ddd' );

-- test UPDATE of enum columns fails.
update test_dom set ENUM_NAME = 'a12' where enum_value = 4;

-- test INSERT fails
insert into test_dom (enum_name) values ( 'bbb' );
commit;

set serveroutput on;
DECLARE
 rid rowid;
BEGIN
  select rowid into rid
  from test_dom
  where enum_value = 2;

  update test_dom set stuff = 'hyperspace' where rowid = rid;

  -- close c;
  commit;
end;
/
select * from test_dom;

update test_dom set stuff = 'hyperspace' where rowid = (select rid from data);

create table test_dom2 (
  ora$value  int INVISIBLE not null
  ,enum_value as ( cSQL.utl_enum.get_name( ora$value ) )
);

insert into test_dom2 (ora$value) values (20);

select * from test_dom2;
select * from all_domains;

select d.enum_name
from sys.day_enum_d d
where length( d.enum_name ) > 3
  and d.enum_value = mod( 1, 7 ) + 1;
