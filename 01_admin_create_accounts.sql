prompt creating HR

create user hr identified by Change0nInstall
default tablespace  data
quota  20  M on data
account unlock;

grant connect, resource to hr;

prompt creating (ras) roles
exec sys.xs_principal.create_role(name => 'employee', enabled => true);
exec sys.xs_principal.create_role(name => 'it_engineer', enabled => true);
exec sys.xs_principal.create_role(name => 'hr_representative', enabled => true);
create role db_emp;
grant db_emp to employee;
grant db_emp to it_engineer;
grant db_emp to hr_representative;
grant db_emp to employee;
grant db_emp to it_engineer;
grant db_emp to hr_representative;

prompt creating RAS users
exec  sys.xs_principal.create_user(name => 'daustin', schema => 'hr');
exec  sys.xs_principal.set_password('daustin', 'Change0nInstall');
exec  sys.xs_principal.grant_roles('daustin', 'XSCONNECT');
exec  sys.xs_principal.grant_roles('daustin', 'employee');
exec  sys.xs_principal.grant_roles('daustin', 'it_engineer');exec  sys.xs_principal.create_user(name => 'daustin', schema => 'hr');
exec  sys.xs_principal.set_password('daustin', 'welcome1');
exec  sys.xs_principal.grant_roles('daustin', 'XSCONNECT');
exec  sys.xs_principal.grant_roles('daustin', 'employee');
exec  sys.xs_principal.grant_roles('daustin', 'it_engineer');

exec  sys.xs_principal.create_user(name => 'smavris', schema => 'hr');
exec  sys.xs_principal.set_password('smavris', 'Change0nInstall');
exec  sys.xs_principal.grant_roles('smavris', 'XSCONNECT');
exec  sys.xs_principal.grant_roles('smavris', 'employee');
exec  sys.xs_principal.grant_roles('smavris', 'hr_representative');

exec sys.xs_admin_cloud_util.grant_system_privilege('ADMIN_ANY_SEC_POLICY','RASADMIN');
exec sys.xs_admin_cloud_util.grant_system_privilege('ADMIN_ANY_SEC_POLICY','HR');

grant select, insert, update, delete on hr.employees to db_emp; 

