 REM run this as HR to cleanup and RAS objects
 REM this is used for all examples
 
-- common policy
begin
    xs_data_security.remove_object_policy(policy=>'employees_ds',
                                          schema=>'hr', object=>'employees');
end;
/

exec xs_data_security.delete_policy('employees_ds', xs_admin_util.cascade_option);

-- common ACLs (mostly)
exec xs_acl.delete_acl('emp_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('it_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('dept_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('hr_acl', xs_admin_util.cascade_option);

-- Namespaces
exec sys.xs_namespace.delete_template(  'hr$session'  );
exec sys.xs_namespace.delete_template(  'TEST$PASS'  );
exec sys.xs_namespace.delete_template(  'TEST$fail'  );

exec xs_acl.delete_acl('cbac_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('PASS_NS_ACL', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('FAIL_NS_ACL', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('TEST_EXT_ACL', xs_admin_util.cascade_option);


-- global callback
exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', null, 'init_hr_ras_template');

-- Security Classes
exec xs_security_class.delete_security_class('hr_privileges', xs_admin_util.cascade_option);
exec xs_security_class.delete_security_class('HR_NS_PRIVILEGE', xs_admin_util.cascade_option);







