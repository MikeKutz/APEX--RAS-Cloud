prompt creating Security Class
declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_ns_privilege', 
    parent_list => xs$name_list( 'sys.nstemplate_sc'),
    priv_list   => null );
end;
/

prompt creating ACLs
declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);

  -- NS_MOD_ACL: allows code (via CBAC) to initialize a Namespace
  aces(1) := xs$ace_type(privilege_list => xs$name_list('MODIFY_ATTRIBUTE','MODIFY_NAMESPACE'),
                         principal_name => 'db_pass_ns',
                         principal_type => 2
                         );
 
  sys.xs_acl.create_acl(name      => 'pass_ns_acl',
                    ace_list  => aces,
                    sec_class => 'hr_ns_privilege');
 
  -- NS_MOD_ACL: allows code (via CBAC) to initialize a Namespace
  -- NOT USED
  aces(1) := xs$ace_type(privilege_list => xs$name_list('MODIFY_ATTRIBUTE','MODIFY_NAMESPACE'),
                         principal_name => 'db_fail_ns',
                         principal_type => 2
                         );
 
  sys.xs_acl.create_acl(name      => 'fail_ns_acl',
                    ace_list  => aces,
                    sec_class => 'hr_ns_privilege');
end;
/

prompt creating Namespaces and attributes
begin
    sys.xs_namespace.create_template(  'test$pass', acl => 'pass_ns_acl'  );
    sys.xs_namespace.ADD_ATTRIBUTES (  'test$pass',  'value' );

    -- because the wrong ACL is assigned to the Namespace Template, initialization code should fail
    sys.xs_namespace.create_template(  'test$fail' , acl => 'pass_ns_acl'  );
    sys.xs_namespace.ADD_ATTRIBUTES (  'test$fail',  'value' );
end;
/

create or replace
procedure init_pass
    authid current_user
as
begin
    dbms_xs_sessions.create_namespace( 'test$pass' );
    dbms_xs_sessions.set_attribute( 'test$pass', 'value',  42 );
end;
/
create or replace
procedure init_pass_no_cbac
    authid current_user
as
begin
    dbms_xs_sessions.create_namespace( 'test$pass' );
    dbms_xs_sessions.set_attribute( 'test$pass', 'value',  42 );
end;
/

create or replace
procedure init_fail
    authid current_user
as
begin
    dbms_xs_sessions.create_namespace( 'test$fail' );
    dbms_xs_sessions.set_attribute( 'test$fail', 'value',  43 );
end;
/

prompt granting CBAC Roles to Initialization Procedures
grant db_pass_ns to procedure init_pass;
grant db_fail_ns to procedure init_fail;

grant execute on init_pass to public;
grant execute on init_fail to public;
grant execute on init_pass_no_cbac to public;
