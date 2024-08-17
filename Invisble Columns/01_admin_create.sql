select * from dba_roles;

-- db roles
create role show_new_db;
create role show_active_db;
create role show_all_db;

-- db priv to db role
grant insert,update,select,delete on hr.test_hidden to show_new_db, show_active_db, show_all_db;

-- ras roles
begin
--  return;
  xs_principal.create_role( 'show_new', enabled => true);
  xs_principal.create_role( 'show_active', enabled => true);
  xs_principal.create_role( 'show_all', enabled => true);
end;
/

-- db role to ras role
grant show_new_db to show_new;
grant show_active_db to show_active;
grant show_all_db to show_all;

-- ras role to ras user(s)
begin
  xs_principal.grant_roles( 'daustin', 'show_new' );
  xs_principal.grant_roles( 'smavris', 'show_all' );
end;
/

