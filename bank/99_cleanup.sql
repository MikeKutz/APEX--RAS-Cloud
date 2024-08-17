-- common policy
begin
    xs_data_security.remove_object_policy(policy=>'banks_policy',
                                          schema=>'hr', object=>'accounts');
    xs_data_security.remove_object_policy(policy=>'customers_policy',
                                          schema=>'hr', object=>'accounts');
    xs_data_security.remove_object_policy(policy=>'banks_policy',
                                          schema=>'hr', object=>'banks');
    xs_data_security.remove_object_policy(policy=>'customers_policy',
                                          schema=>'hr', object=>'customers');
end;
/

exec xs_data_security.delete_policy('banks_policy', xs_admin_util.cascade_option);
exec xs_data_security.delete_policy('customers_policy', xs_admin_util.cascade_option);

exec sys.xs_namespace.delete_template(  'bank$session'  );

exec xs_acl.delete_acl('banker_acl', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('bank_cust_acl', xs_admin_util.cascade_option);



