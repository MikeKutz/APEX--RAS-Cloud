create global temporary table gtt_test (
  t varchar2(256)
) on commit preserve rows;
grant insert,update,select,delete on gtt_test to public;


create or replace
package ut_gtt
  authid current_user
as
  --%suite( gtt )
  --%rollback(manual)

  procedure test_gtt( expected_count int );
  
  
  --%test( Add Rows )
  --%xsuser( daustin )
  procedure init_gtt;
  
  --%test( stateless test )
  --%xsuser( daustin )
  procedure count_gtt_1;
  
  --%test( test alt user )
  --%xsuser( smavris )
  procedure count_gtt_2;
end;
/

create or replace
package body ut_gtt
as

  procedure test_gtt( expected_count int )
  as
    total int;
  begin
    select count(*) into total
    from hr.gtt_test;
    
    ut.expect(total).to_equal( expected_count );
  end;

  procedure init_gtt
  as
  begin
    insert into hr.gtt_test (t) values ('hello'),('world'),('goodbye');
    
    test_gtt( 3 );
  end;
  
  
  procedure count_gtt_1
  as
  begin
    test_gtt( 3 );
  end;
  
  procedure count_gtt_2
  as
  begin
    test_gtt( 0 );
  end;
  
end;
/

grant execute on ut_gtt to public;

desc gtt_test;

