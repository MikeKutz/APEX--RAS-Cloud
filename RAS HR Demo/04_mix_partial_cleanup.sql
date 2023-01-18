 begin
    xs_data_security.remove_object_policy(policy=>'employees_ds',
                                          schema=>'hr', object=>'employees');
  end;
/


exec xs_data_security.delete_policy('employees_ds', xs_admin_util.cascade_option);

exec xs_acl.delete_acl('emp_acl', xs_admin_util.cascade_option);

exec xs_acl.delete_acl('it_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('dept_acl', xs_admin_util.cascade_option);

exec xs_acl.delete_acl('hr_acl', xs_admin_util.cascade_option);

exec sys.xs_namespace.delete_template(  'hr$session'  );
exec xs_acl.delete_acl('cbac_acl', xs_admin_util.cascade_option);

--exec xs_acl.delete_acl('sa_acl', xs_admin_util.cascade_option);

--Exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', 'set_ns_pkg', 'direct_login');
--exec SYS.XS_NAMESPACE.DELETE_TEMPLATE('test', xs_admin_util.cascade_option);

exec xs_security_class.delete_security_class('hr_privileges', xs_admin_util.cascade_option);

 exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', null, 'init_hr_ras_template');






