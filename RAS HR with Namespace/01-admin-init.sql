@@../01-admin-create-user.sql

-- grant RAS privileges to HR
begin
    xs_admin_cloud_util.GRANT_SYSTEM_PRIVILEGE( 'ADMIN_ANY_POLICY', 'HR' ); -- required for debug
    xs_admin_cloud_util.GRANT_SYSTEM_PRIVILEGE( 'CALLBACK', 'HR' );
end;
/

-- RAS Roles and grants
exec sys.xs_principal.create_role(name => 'department', enabled => true);
grant db_emp to department;

-- RAS Internal Users
exec sys.xs_principal.grant_roles('SMARVIS', 'department');
exec sys.xs_principal.grant_roles('DAUSTIN', 'department');

-- Create APEX Users


-- roles for CBAC
create role ns_modifier_role;
create role see_all_employees_role;

grant ns_modifier_role to hr with delegate option;
grant see_all_employees_role to hr with delegate option;

alter user hr enable all roles except ns_modifier_role, see_all_employees_role;

