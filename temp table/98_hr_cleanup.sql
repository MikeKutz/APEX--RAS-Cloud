begin
    xs_data_security.remove_object_policy(policy=>'temp_table_rls',
                                          schema=>'hr', object=>'temp_t');
end;
/

exec xs_data_security.delete_policy('temp_table_rls', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('xs_temp_acl', xs_admin_util.cascade_option);

