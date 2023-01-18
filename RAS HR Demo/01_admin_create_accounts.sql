prompt creating HR

create user hr identified by Change0nInstall
default tablespace  data
quota  20  M on data
account unlock;

grant connect, resource, create view to hr;

-- create a Policy
--exec sys.xs_admin_cloud_util.grant_system_privilege('ADMIN_SEC_POLICY','HR');
-- apply a Policy to a TABLE
--exec sys.xs_admin_cloud_util.grant_system_privilege('APPLY_SEC_POLICY','HR');
-- needed for debuging a Policy >:(
exec sys.xs_admin_cloud_util.grant_system_privilege('ADMIN_ANY_SEC_POLICY','HR');


prompt creating (ras) roles
exec sys.xs_principal.create_role(name => 'employee', enabled => true);
exec sys.xs_principal.create_role(name => 'it_engineer', enabled => true);
exec sys.xs_principal.create_role(name => 'hr_representative', enabled => true);

create role db_emp;

grant db_emp to employee;
grant db_emp to it_engineer;
grant db_emp to hr_representative;


prompt creating RAS users
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

-- for testing S1607572
create role CBAC_ROLE;
grant CBAC_ROLE to HR with delegate option;
