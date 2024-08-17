drop table ships purge;

drop domain name_check;
drop domain pre_warp_name;
drop domain post_warp_name;
drop domain q_name;

-- remove policy
-- drop policy
exec xs_acl.delete_acl('any_warp_acl');
exec xs_acl.delete_acl('pre_warp_acl');
exec xs_acl.delete_acl('post_warp_acl');
exec xs_acl.delete_acl('q_acl');

drop role db_warp_role;
