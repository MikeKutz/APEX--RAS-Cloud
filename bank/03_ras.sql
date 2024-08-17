declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','insert','update','delete'),
                         principal_name => 'banker', principal_type => 1);

  sys.xs_acl.create_acl(name      => 'banker_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
 

  aces(1) := xs$ace_type(privilege_list => xs$name_list('select'),
                         principal_name => 'bank_customer', principal_type => 1);
  sys.xs_acl.create_acl(name      => 'bank_cust_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
begin  
  realms.extend(2);
 
  -- realms for BANKS_user user sees all banks only their accounts
  realms(1) := xs$realm_constraint_type(
    realm    => q'[1=1]',
    acl_list => xs$name_list('bank_cust_acl'));
  -- realms for BANKS teller see all accounts only their users
  realms(2) := xs$realm_constraint_type(
    realm    => q'[bank_id = xs_sys_context('BANK$SESSION', 'bank_id' )]',
    acl_list => xs$name_list('banker_acl'));


  sys.xs_data_security.create_policy(
    name                   => 'banks_policy',
    realm_constraint_list  => realms
  );
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
begin  
  realms.extend(2);
 
  -- realms for BANKS user sees all banks
  realms(1) := xs$realm_constraint_type(
    realm    => q'[1=1]',
    acl_list => xs$name_list('banker_acl'));
  -- realms for BANKS user sees all banks
  realms(2) := xs$realm_constraint_type(
    realm    => q'[customer_id = xs_sys_context('BANK$SESSION', 'customer_id' )]',
    acl_list => xs$name_list('bank_cust_acl'));


  sys.xs_data_security.create_policy(
    name                   => 'customers_policy',
    realm_constraint_list  => realms
  );
end;
/

--declare
--  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
--begin  
--  realms.extend(1);
-- 
--  -- follow
--  realms(1) := xs$realm_constraint_type(
--                        parent_schemma => 'hr',
--                        parent_object  => 'accounts',
--                        key_list       => xs$key_list( xs$key_type( 'account_id', 'account_id', 1 ) )
--               );
--
--  sys.xs_data_security.create_policy(
--    name                   => 'accounts_children_policy',
--    realm_constraint_list  => realms
--  );
--end;
--/

-- apply policy to BANKS
begin
  sys.xs_data_security.apply_object_policy(
    policy => 'banks_policy', 
    schema => 'hr',
    object =>'banks',
    owner_bypass => false
    );
end;
/

-- apply palicy to CUSTOMERS
begin
  sys.xs_data_security.apply_object_policy(
    policy => 'customers_policy', 
    schema => 'hr',
    object =>'customers',
    owner_bypass => false
    );
end;
/

-- apply policies to ACCOUNTS
-- policies are "AND" (must match customer_id AND bank_id)
begin
  sys.xs_data_security.apply_object_policy(
    policy => 'banks_policy', 
    schema => 'hr',
    object =>'accounts',
    owner_bypass => false
    );
  sys.xs_data_security.apply_object_policy(
    policy => 'customers_policy', 
    schema => 'hr',
    object =>'accounts',
    owner_bypass => false
    );

end;
/

-- apply policy to all children of ACCOUNTS
--begin
--  sys.xs_data_security.apply_object_policy(
--    policy => 'accounts_children_policy', 
--    schema => 'bank_schema',
--    object =>'transactions',
--    owner_bypass => false
--    );
--end;
--/


begin
    sys.xs_namespace.create_template(  'bank$session'  );
    sys.xs_namespace.ADD_ATTRIBUTES (  'bank$session',  'bank_id' );
    sys.xs_namespace.ADD_ATTRIBUTES (  'bank$session',  'customer_id' );

end;
/

set serveroutput on;
begin
  if (sys.xs_diag.validate_workspace()) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
-- XS$VALIDATION_TABLE contains validation errors if any.
-- Expect no rows selected.
select * from xs$validation_table order by 1, 2, 3, 4;
