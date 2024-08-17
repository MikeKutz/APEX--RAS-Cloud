begin
    xs_data_security.remove_object_policy(policy=>'warp_policy',
                                          schema=>'hr', object=>'ships');
end;
/

drop role db_warp_role;

exec xs_acl.delete_principal( 'any_civ' );