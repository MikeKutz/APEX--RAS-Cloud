create or replace package ut_warp_test
  authid current_user
as
  -- dummy
  
  --%suite( Flexible Domain Demo )
  --%rollback( manual )
  
  c         constant number := 2.99e8;
  warp_0_1  constant number := log( c, 10 );
  warp_2    constant number := c * 10;
  warp_9000 constant number := c * 1e30;

  --%test( raw flex test )
  --%xsextuser( galileo )
  --%xsextrole( pre_warp_civ )
  procedure acl_test;

  --%test( Galileo )
  --%xsextuser( galileo )
  --%xsextrole( pre_warp_civ )
  --%xsrole( any_civ )
  procedure galileo_pass;

  --%test( Galileo Warp fail)
  --%xsextuser( galileo )
  --%xsextrole( pre_warp_civ )
  --%xsrole( any_civ )
  --%throws(-28115)
  procedure galileo_fail;
end;
/
