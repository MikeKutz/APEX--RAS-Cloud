create or replace
package body ut_test_hr_demo
as
  function count_employees return int
  as
    n int;
  begin
    select count(*) into n
    from hr.employees;
    
    return n;
  end;

  --%test( daustin access validation )
  --%RASUser( daustin )
  procedure test_daustin
  as
  begin
    -- ran due to RASUser( daustin ) tag
    hr.utl_ras.attach_session( 'daustin', is_external => false );
    
    ut.expect( count_employees ).to_equal( 5 );
    
    -- ran due to RASUser tag for Procedure exists
    hr.utl_ras.detach_session;
  end;
  
  --%test( smavris access validation )
  --%RASUser( smavris )
  procedure test_smavris
  as
  begin
    -- ran due to RASUser( smavris ) tag for Procedure
    hr.utl_ras.attach_session( 'smavris', is_external => false );
    
    ut.expect( count_employees ).to_equal( 107 );
    
    -- ran due to RASUser tag for Procedure exists
    hr.utl_ras.detach_session;
  end;

  --%test(  pre-owner count of HR.EMPLOYEES )
  --%RASNone
  procedure test_owner
  as
  begin
    -- ran because of RASNone tag
    hr.utl_ras.assert_not_attached;
    
    ut.expect( count_employees ).to_equal( 0 );
  end;
  
  --%test(  post-owner count of HR.EMPLOYEES )
  procedure test_owner2
  as
  begin
    test_owner;
  end;
  
  procedure clean_up
  as
  begin
    -- ran because a RASUser tag was used
    hr.utl_ras.terminate_all_sessions;
  end;
    
end;