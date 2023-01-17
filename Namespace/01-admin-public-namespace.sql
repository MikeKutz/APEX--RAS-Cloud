-- ADMIN

prompt creating DB user: HR
create user hr identified by Change0nInstall
default tablespace  data
quota  20  M on data
account unlock;

grant connect, resource, create view to hr;

prompt creating RAS Internal w/ Direct: daustin
exec  sys.xs_principal.create_user(name => 'daustin', schema => 'hr');
exec  sys.xs_principal.set_password('daustin', 'Change0nInstall');
exec  sys.xs_principal.grant_roles('daustin', 'XSCONNECT');

-- give HR privs
prompt grants for user HR
exec sys.xs_admin_cloud_util.grant_system_privilege( 'ADMIN_ANY_SEC_POLICY','HR' );
-- ??? exec sys.xs_admin_cloud_util.grant_system_privilege( 'ADMIN_ANY_NAMESPACE','HR' );

