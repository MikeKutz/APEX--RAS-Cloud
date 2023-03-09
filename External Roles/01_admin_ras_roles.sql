prompt creating (ras) roles
exec sys.xs_principal.create_dynamic_role(name => 'RAS_DB_EMP');
-- external_emp
-- external_it
-- external_hr

grant db_emp to ras_db_emp;


prompt creating Direct login RAS users
prompt
prompt all user/roles are EXTERNAL
--exec  sys.xs_principal.create_user(name => 'daustin', schema => 'hr');
--exec  sys.xs_principal.set_password('daustin', 'Change0nInstall');

--exec  sys.xs_principal.create_user(name => 'smavris', schema => 'hr');
--exec  sys.xs_principal.set_password('smavris', 'Change0nInstall');



