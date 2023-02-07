-- RAS Roles and grants
exec sys.xs_principal.create_role(name => 'employee', enabled => true);
exec sys.xs_principal.create_role(name => 'department', enabled => true);
exec sys.xs_principal.create_role(name => 'hr_representative', enabled => true);

grant db_emp to employee;
grant db_emp to department;
grant db_emp to hr_representative;

-- RAS Internal Users (no Direct Login)
exec  sys.xs_principal.create_user(name => 'daustin' );
exec  sys.xs_principal.grant_roles('daustin', 'employee');
exec sys.xs_principal.grant_roles('daustin', 'department');

exec  sys.xs_principal.create_user(name => 'smavris' );
exec  sys.xs_principal.grant_roles('smavris', 'employee');
exec sys.xs_principal.grant_roles('smavris', 'department');
exec  sys.xs_principal.grant_roles('smavris', 'hr_representative');

-- roles for CBAC
create role ns_modifier_role;
create role see_all_employees_role;

grant ns_modifier_role to hr with delegate option;
grant see_all_employees_role to hr with delegate option;

-- set the new roles as NOT DEFAULT
alter user hr enable all roles except ns_modifier_role, see_all_employees_role;

-- grant additional RAS privileges to HR
exec sys.xs_admin_cloud_util.grant_system_privilege( 'ADMIN_ANY_SEC_POLICY','HR' );
exec sys.xs_admin_cloud_util.grant_system_privilege( 'CALLBACK','HR' );

