-- dynamic roles
exec SYS.xs_principal.delete_principal( 'REGISTERED', xs_admin_util.cascade_option );
exec SYS.xs_principal.delete_principal( 'UNREGISTERED', xs_admin_util.cascade_option );
exec SYS.xs_principal.delete_principal( 'RAS_DB_EMP', xs_admin_util.cascade_option );

-- regular roles
exec SYS.xs_principal.delete_principal( 'EMPLOYEE', xs_admin_util.cascade_option );
exec SYS.xs_principal.delete_principal( 'IT_ENGINEER', xs_admin_util.cascade_option );
exec SYS.xs_principal.delete_principal( 'HR_REPRESENTATIVE', xs_admin_util.cascade_option );

-- internal users
exec SYS.xs_principal.delete_principal( 'SMAVRIS', xs_admin_util.cascade_option );
exec SYS.xs_principal.delete_principal( 'DAUSTIN', xs_admin_util.cascade_option );

select * from DBA_XS_ACLS where name = 'DATA_ENTRY_ACL';
select * from DBA_XS_ACES where acl='DATA_ENTRY_ACL';

select * from DBA_XS_ROLE_GRANTS where grantee = 'DATA_ENTRY';
SELECT * FROM DBA_TAB_PRIVS WHERE OWNER = 'HR' and grantee = 'DATA_ENTRY_DB';

select c.ACL, c.PRINCIPAL, g.GRANTED_ROLE DB_ROLE,c.PRIVILEGE, p.OWNER || '.' || p.TABLE_NAME table_name
from DBA_XS_ACES c
  join DBA_XS_ROLE_GRANTS g on c.PRINCIPAL = g.GRANTEE
  join DBA_TAB_PRIVS p on  g.GRANTED_ROLE = p.GRANTEE and c.PRIVILEGE = p.PRIVILEGE
where c.acl='DATA_ENTRY_ACL';

select * from DBA_XS_REALM_CONSTRAINTS;

select * from hr.test_col where my_status = 1;