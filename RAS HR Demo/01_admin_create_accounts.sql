prompt creating (ras) roles
exec sys.xs_principal.create_role(name => 'employee', enabled => true);
exec sys.xs_principal.create_role(name => 'it_engineer', enabled => true);
exec sys.xs_principal.create_role(name => 'hr_representative', enabled => true);

grant db_emp to employee;
grant db_emp to it_engineer;
grant db_emp to hr_representative;


prompt creating Direct login RAS users
exec  sys.xs_principal.create_user(name => 'daustin', schema => 'hr');
exec  sys.xs_principal.set_password('daustin', 'Change0nInstall');
exec  sys.xs_principal.grant_roles('daustin', 'XSCONNECT');
exec  sys.xs_principal.grant_roles('daustin', 'employee');
exec  sys.xs_principal.grant_roles('daustin', 'it_engineer');

exec  sys.xs_principal.create_user(name => 'smavris', schema => 'hr');
exec  sys.xs_principal.set_password('smavris', 'Change0nInstall');
exec  sys.xs_principal.grant_roles('smavris', 'XSCONNECT');
exec  sys.xs_principal.grant_roles('smavris', 'employee');
exec  sys.xs_principal.grant_roles('smavris', 'hr_representative');

prompt grant RAS privileges to HR
exec sys.xs_admin_cloud_util.grant_system_privilege( 'ADMIN_ANY_SEC_POLICY','HR' );


