begin
    xs_data_security.remove_object_policy(policy=>'data_protect_policy',
                                          schema=>'hr', object=>'protected_data');
end;
/

exec xs_data_security.delete_policy('data_protect_policy', xs_admin_util.cascade_option);

-- common ACLs (mostly)
exec xs_acl.delete_acl('can_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('cannot_acl', xs_admin_util.cascade_option);

exec xs_security_class.delete_security_class('demo_sec', xs_admin_util.cascade_option);

drop view protected_data_view;
drop table protected_data;

