create or replace
package body ut_ras_hr_demo
as
  sessionid_daustin  raw(32);
  sessionid_smavris  raw(32);

  /* create all RAS Sessions */
  procedure init
  as
  begin
    dbms_xs_sessions.create_session( 'daustin', sessionid_daustin );
    dbms_xs_sessions.create_session( 'smavris', sessionid_smavris );
  end init;
    
  /* destroy all RAS Sessions */  
  procedure clean_up
  as
  begin
    dbms_xs_sessions.destroy_session( sessionid_daustin );
    dbms_xs_sessions.destroy_session( sessionid_smavris );
  end clean_up;
  
  /* common function for aquiring
   * count(*) of HR.EMPLOYEES
   */
  function count_employees return int
  as
    n int;
  begin
    select count(*) into n
    from hr.employees;
    
    return n;
  end count_employees;
  
  /* common function to test
   * count(*) is zero
   */
  procedure test_zero
  as
  begin
    ut.expect( count_employees ).to_equal( 0 );
  end test_zero;

  /* get count as DAUSTIN */
  procedure test_daustin
  as
  begin
    dbms_xs_sessions.ATTACH_SESSION(sessionid_daustin);
    
    ut.expect( count_employees ).to_equal( 5 );
    
    dbms_xs_sessions.detach_session();
  end test_daustin;
  
 /* get count as SMAVRIS */
  procedure test_smavris
  as
  begin
    dbms_xs_sessions.ATTACH_SESSION(sessionid_smavris);
    
    ut.expect( count_employees ).to_equal( 107 );
    
    dbms_xs_sessions.detach_session();
  end test_smavris;

  procedure test_owner_pre
  as
  begin
    test_zero;
  end test_owner_pre;
  
  procedure test_owner_mid
  as
  begin
    test_zero;
  end test_owner_mid;
  
  procedure test_owner_post
  as
  begin
    test_zero;
  end test_owner_post;
end ut_ras_hr_demo;
/
