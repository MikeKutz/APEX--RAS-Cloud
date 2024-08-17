grant select, insert, update, delete on test_col to data_entry_db;
grant select, update(is_valid,some_data) on test_col to data_analyzer_db;
grant select, update(is_valid)  on test_col to data_curator_db;
grant select, insert, update, delete on test_col to data_cbac_db;

-- REFERENCE (ran as ADMIN)
-- grant data_entry_db to data_entry;
-- grant data_analyzer_db to data_analyzer;
-- grant data_curator_db to data_curator;
-- exec XS_PRINCIPAL.grant_roles( 'daustin', 'data_entry' ); === grant application data_entry to daustin

declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  -- data cbac
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','insert','update','delete'),
                         principal_name => 'data_cbac_db', principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'data_cbac_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
  -- data entry
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','insert','update','delete'),
                         principal_name => 'data_entry');
 
  sys.xs_acl.create_acl(name      => 'data_entry_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
  
  -- data analyzer
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','update'),
                         principal_name => 'data_analyzer');
 
  sys.xs_acl.create_acl(name      => 'data_analyzer_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
  -- data curator
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','update'),
                         principal_name => 'data_curator');
 
  sys.xs_acl.create_acl(name      => 'data_curator_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(1);
 
  realms(1) := xs$realm_constraint_type(
    realm    => q'[my_status != hr.status_d.deprecated ]',
    acl_list => xs$name_list('data_entry_acl')
    );
  
  sys.xs_data_security.create_policy(
    name                   => 'status_ro_policy',
    realm_constraint_list  => realms
    );
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(4);
 
  realms(1) := xs$realm_constraint_type(
    realm    => q'[my_status = hr.status_d.initializing ]',
    acl_list => xs$name_list('data_entry_acl'),
    is_static => true
    );
  realms(2) := xs$realm_constraint_type(
    realm    => q'[my_status = hr.status_d.analyzing ]',
    acl_list => xs$name_list('data_analyzer_acl'),
    is_static => true
    );
  realms(3) := xs$realm_constraint_type(
    realm    => q'[my_status = hr.status_d.curating ]',
    acl_list => xs$name_list('data_curator_acl'),
    is_static => true
    );
  realms(4) := xs$realm_constraint_type(
    realm    => q'[1=1]',
    acl_list => xs$name_list('data_cbac_acl'),
    is_static => true
    );
  
  sys.xs_data_security.create_policy(
    name                   => 'status_rw_policy',
    realm_constraint_list  => realms
    );
end;
/

-- declare
--   realms   xs$realm_constraint_list := xs$realm_constraint_list();      
--   cols     xs$column_constraint_list := xs$column_constraint_list();
-- begin  
--   realms.extend(1);
 
--   realms(1) := xs$realm_constraint_type(
--     realm    => q'[my_status = hr.status_d.analyzing ]',
--     acl_list => xs$name_list('data_analyzer_acl'),
--     is_static => true
--     );
  
--   sys.xs_data_security.create_policy(
--     name                   => 'status_rw2_policy',
--     realm_constraint_list  => realms
--     );
-- end;
-- /
-- declare
--   realms   xs$realm_constraint_list := xs$realm_constraint_list();      
--   cols     xs$column_constraint_list := xs$column_constraint_list();
-- begin  
--   realms.extend(1);
 
--   realms(1) := xs$realm_constraint_type(
--     realm    => q'[my_status = hr.status_d.initializing ]',
--     acl_list => xs$name_list('data_entry_acl'),
--     is_static => true
--     );
  
--   sys.xs_data_security.create_policy(
--     name                   => 'status_rw1_policy',
--     realm_constraint_list  => realms
--     );
-- end;
-- /

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'status_ro_policy'
    ,schema => 'hr'
    ,object =>'test_col'
    ,row_acl => true
    ,owner_bypass => true
    ,statement_types => 'select'
    );
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'status_rw_policy', 
    schema => 'hr',
    object =>'test_col'
    ,row_acl => true
    ,owner_bypass => true
    ,statement_types => 'insert,update,delete'
    );
end;
/

-- begin
--   sys.xs_data_security.apply_object_policy(
--     policy => 'status_rw1_policy', 
--     schema => 'hr',
--     object =>'test_col'
--     ,row_acl => true
--     ,owner_bypass => true
--     ,statement_types => 'insert,update,delete'
--     );
--   sys.xs_data_security.apply_object_policy(
--     policy => 'status_rw2_policy', 
--     schema => 'hr',
--     object =>'test_col'
--     ,row_acl => true
--     ,owner_bypass => true
--     ,statement_types => 'insert,update,delete'
--     );
-- end;
-- /

set SERVEROUTPUT on;
begin
  if (sys.xs_diag.validate_workspace( error_limit => 200 )) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
begin
  if (sys.xs_diag.validate_principal( 'daustin')) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
begin
  if (sys.xs_diag.validate_principal( 'data_entry')) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/ 
begin
  if (sys.xs_diag.validate_acl( 'data_entry_acl')) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
begin
  if (sys.xs_diag.validate_data_security(table_name => 'test_col', error_limit => 200 )) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
begin
  if (sys.xs_diag.validate_data_security(policy => 'status_ro_policy', error_limit => 200 )) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
begin
  if (sys.xs_diag.validate_security_class(name => 'hr_privileges', error_limit => 200 )) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
select * from USER_XS_REALM_CONSTRAINTS;

-- XS$VALIDATION_TABLE contains validation errors if any.
-- Expect no rows selected.
select * from xs$validation_table order by 1, 2, 3, 4;

select * from TEST_COL;
desc test_col;
exec sys.XS_DATA_SECURITY_UTIL.schedule_static_acl_refresh( table_name => 'test_col' );
select * from user_tables;
select * from ACLMV$$78899_P800027F1;

 -- 800027a0
select to_aclid( 'data_entry_acl' );
 -- 800027a1
select to_aclid( 'data_analyzer_acl' );
-- 800027a2
select to_aclid( 'data_curator_acl' );
-- 8000279f
select to_aclid( 'data_cbac_acl' );

select * from test_col;
select * from user_tab_columns where table_name = 'TEST_COL';