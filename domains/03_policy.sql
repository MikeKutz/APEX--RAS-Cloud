 -- create and apply policy
 /* data domains
 -- pre-warp: speed < 2.99e8
 -- post-warp: apeed < 2.99e11
 -- q-warp: speed < 2.99e30
 */
 
 declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(4);
 
  -- Realm #1: Only the employee's own record. 
  --           The EMPLOYEE role can view the realm including SALARY column.     
  realms(1) := xs$realm_constraint_type(
    realm    => q'[speed > 0]',
--    realm    => q'[email = xs_sys_context('xs$session','username')]',
    acl_list => xs$name_list('any_warp_acl'));
 
  -- Realm #2: The records in the IT department.
  --           The IT_ENGINEER role can view the realm excluding SALARY column.
  realms(2) := xs$realm_constraint_type(
    realm    => 'speed between 0 and 2.99e8',
    acl_list => xs$name_list('pre_warp_acl'));

  realms(3) := xs$realm_constraint_type(
    realm    => 'speed between 0 and 2.99e11',
    acl_list => xs$name_list('post_warp_acl'));

  realms(4) := xs$realm_constraint_type(
    realm    => 'speed between 0 and 2.99e30',
    acl_list => xs$name_list('q_acl'));

  sys.xs_data_security.create_policy(
    name                   => 'warp_policy',
    realm_constraint_list  => realms
    );
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'warp_policy', 
    schema => 'hr',
    object =>'ships',
    owner_bypass => false
    );
end;
/

--exec SYS.xs_data_security.remove_object_policy( 'employees_ds', 'hr', 'employees' );

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
