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


-- '67gjxy9gdbz0c'
-- '67gjxy9gdbz0c'   '68zdvnprakmkz'
select * from v$vpd_policy where policy = 'STATUS_POLICY';
select * from v$sql where sql_text like '%test_col%';
select * from DBA_XS_ROLES;

select sql_id, s.sql_text, v.predicate, v.POLICY_FUNCTION_OWNER, v.policy
from v$sql s
  join v$vpd_policy v using (sql_id)
where sql_id = '67gjxy9gdbz0c';

select sql_id, s.sql_text, v.predicate, v.POLICY_FUNCTION_OWNER, v.policy
from v$sql s
  join v$vpd_policy v using (sql_id)
where v.policy = 'STATUS_POLICY';

select c.ACL, c.PRINCIPAL, g.GRANTED_ROLE DB_ROLE,c.PRIVILEGE, p.OWNER || '.' || p.TABLE_NAME table_name, r.realm
from DBA_XS_ACES c
  join DBA_XS_ROLE_GRANTS g on c.PRINCIPAL = g.GRANTEE
  join DBA_TAB_PRIVS p on  g.GRANTED_ROLE = p.GRANTEE and c.PRIVILEGE = p.PRIVILEGE
  -- need to include OWNERs and Policy
  left outer join DBA_XS_REALM_CONSTRAINTS r on c.acl = r.acl 
where c.principal='DATA_ENTRY';

select * from DBA_XS_REALM_CONSTRAINTS;
