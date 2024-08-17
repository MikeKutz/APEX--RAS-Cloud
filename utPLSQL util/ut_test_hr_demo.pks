create or replace
package ut_test_hr_demo
  authid current_user
as
  /* run as HR to show `owner_override => false`
   * testing schema needs the XS_SESSION_ADMIN role
   * Assumes the Oracle RAS HR Demo is in effect (see Oracle doc)
   */
  --%suite(RAS HR Demo)

  --%test( pre-owner count of HR.EMPLOYEES )
  procedure test_owner;

  --%test( daustin count of HR.EMPLOYEES )
  procedure test_daustin;

  --%test( post-owner count of HR.EMPLOYEES )
  procedure test_owner2;
  
  --%test( smavris count of HR.EMPLOYEES )
  procedure test_smavris;
  
  /* this is actually implied */
  --%afterall
  procedure clean_up;
end;