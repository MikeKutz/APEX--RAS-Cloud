create or replace package body ut_warp_test
as
  procedure galileo_pass
  as
  begin
    insert into hr.ships values ( 'HMS-Enterprise', warp_0_1 );

    ut.expect( sql%rowcount ).to_equal( 1 );
    
    commit;
  end;
  
  procedure galileo_fail
  as
  begin
    insert into hr.ships values ( 'HMS-Enterprise', 3e8 );

    ut.expect( sql%rowcount ).to_equal( 0 );
    
    commit;
  end;
  
  procedure acl_test
  as
    ret number;
    dummy varchar2(1) := 'x';
    speed number := 2.99;
  begin
  
    select count(*) into ret
    from v$xs_session_roles
    where role_name in ( 'PRE_WARP_CIV' );
    dbms_output.put_line( 'I have ' || ret || ' roles');
    ut.expect( ret ).to_equal( 1 );

    select ORA_CHECK_ACL(TO_ACLID('HR.PRE_WARP_ACL'),'INSERT') into ret;
    dbms_output.put_line( 'I have ' || ret || ' acls');
    ut.expect( ret ).to_equal( 1 );
  end;
end;
/
