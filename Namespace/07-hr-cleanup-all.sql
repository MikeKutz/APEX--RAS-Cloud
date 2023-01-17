exec sys.xs_namespace.delete_template( 'test$public' );
exec sys.xs_namespace.delete_template( 'test$pass' );
exec sys.xs_namespace.delete_template( 'test$fail' );

exec xs_acl.delete_acl( 'pass_ns_acl' );
exec xs_acl.delete_acl( 'fail_ns_acl' );

drop procedure init_public;
drop procedure init_pass;
drop procedure init_fail;
drop procedure init_pass_no_cbac;

-- drop security class
exec xs_security_class.delete_security_class('hr_ns_privilege', xs_admin_util.cascade_option);

