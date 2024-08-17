create or replace
package ut_ras_hr_demo
  -- MUST be Invoker's Rights to use XS_SESSION_ADMIN Role
  authid current_user
as
  /* sample UT using RAS Sessions
   *
   * This tests the Policies for the RAS HR Demo (see Oracle Doc)
   */
  --%suite(UT RAS HR Demo)

  --%test( pre-owner count of HR.EMPLOYEES )
  procedure test_owner_pre;

  --%test( daustin count of HR.EMPLOYEES )
  procedure test_daustin;

  --%test( mid-owner count of HR.EMPLOYEES )
  procedure test_owner_mid;
  
  --%test( smavris count of HR.EMPLOYEES )
  procedure test_smavris;

  --%test( post-owner count of HR.EMPLOYEES )
  procedure test_owner_post;

  --%beforeall
  procedure init;
  
  --%afterall
  procedure clean_up;
end ut_ras_hr_demo;
/
