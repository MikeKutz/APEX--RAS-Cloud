begin
    xs_admin_cloud_util.GRANT_SYSTEM_PRIVILEGE( 'CALLBACK', 'HR' );
    
end;
/

exec sys.xs_principal.create_role(name => 'department', enabled => true);

create role cbac_role;
create role ns_modifier_role;
create role see_all_employees_role;
grant ns_modifier_role to cbac_role;
grant see_all_employees_role to cbac_role;
grant cbac_role to HR with delegate option;