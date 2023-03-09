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
