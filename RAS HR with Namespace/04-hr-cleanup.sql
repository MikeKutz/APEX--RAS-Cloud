-- remove policy from object
begin
    xs_data_security.remove_object_policy(policy=>'employees_ds',
                                          schema=>'hr', object=>'employees');
end;
/

-- drop policy
exec xs_data_security.delete_policy('employees_ds', xs_admin_util.cascade_option);

-- drop ACLs
begin
    xs_acl.delete_acl('emp_acl', xs_admin_util.cascade_option);
    xs_acl.delete_acl('hr_acl', xs_admin_util.cascade_option);
    xs_acl.delete_acl('dept_acl', xs_admin_util.cascade_option);
    xs_acl.delete_acl('see_all_acl', xs_admin_util.cascade_option);
    xs_acl.delete_acl('modify_ns_acl', xs_admin_util.cascade_option);
end;
/

-- drop Namespace
exec SYS.xs_namespace.delete_template( 'HR$SESSION' );

-- drop security classes
exec xs_security_class.delete_security_class('hr_privileges', xs_admin_util.cascade_option);
exec xs_security_class.delete_security_class('hr_ns_privileges', xs_admin_util.cascade_option);

-- remove callbacks
exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', null, 'init_hr$session_ns');
exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.GUEST_TO_USER_EVENT, 'hr', null, 'init_hr$session_ns');

drop package init_ns;








