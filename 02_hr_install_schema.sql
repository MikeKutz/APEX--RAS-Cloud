@hr_cre.sql
@hr_popul.sql

declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));
end;
/declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));
end;
/


declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  -- EMP_ACL: This ACL grants EMPLOYEE role the privileges to view an employee's
  --          own record including SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','view_salary'),
                         principal_name => 'employee');
 
  sys.xs_acl.create_acl(name      => 'emp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
  
  -- IT_ACL:  This ACL grants IT_ENGINEER role the privilege to view the employee
  --          records in IT department, but it does not grant the VIEW_SALARY
  --          privilege that is required for access to SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select'),
                         principal_name => 'it_engineer');
 
  sys.xs_acl.create_acl(name      => 'it_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
 
  -- HR_ACL:  This ACL grants HR_REPRESENTITIVE role the privileges to view and update all
  --          employees' records including SALARY column.
  aces(1):= xs$ace_type(privilege_list => xs$name_list('select', 'insert', 
                                          'update', 'delete', 'view_salary'),
                        principal_name => 'hr_representative');
 
  sys.xs_acl.create_acl(name      => 'hr_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(3);
 
  -- Realm #1: Only the employee's own record. 
  --           The EMPLOYEE role can view the realm including SALARY column.     
  realms(1) := xs$realm_constraint_type(
    realm    => 'email = xs_sys_context(''xs$session'',''username'')',
    acl_list => xs$name_list('emp_acl'));
 
  -- Realm #2: The records in the IT department.
  --           The IT_ENGINEER role can view the realm excluding SALARY column.
  realms(2) := xs$realm_constraint_type(
    realm    => 'department_id = 60',
    acl_list => xs$name_list('it_acl'));
 
  -- Realm #3: All the records.
  --           The HR_REPRESENTATIVE role can view and update the realm including SALARY column.
  realms(3) := xs$realm_constraint_type(
    realm    => '1 = 1',
    acl_list => xs$name_list('hr_acl'));
 
  -- Column constraint protects SALARY column by requiring VIEW_SALARY 
  -- privilege.
  cols.extend(1);
  cols(1) := xs$column_constraint_type(
    column_list => xs$list('salary'),
    privilege   => 'view_salary');
 
  sys.xs_data_security.create_policy(
    name                   => 'employees_ds',
    realm_constraint_list  => realms,
    column_constraint_list => cols);
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'employees_ds', 
    schema => 'hr',
    object =>'employees');
end;
/

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

@hr_cre.sql
@hr_popul.sql

declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));
end;
/declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));
end;
/


declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  -- EMP_ACL: This ACL grants EMPLOYEE role the privileges to view an employee's
  --          own record including SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','view_salary'),
                         principal_name => 'employee');
 
  sys.xs_acl.create_acl(name      => 'emp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
  
  -- IT_ACL:  This ACL grants IT_ENGINEER role the privilege to view the employee
  --          records in IT department, but it does not grant the VIEW_SALARY
  --          privilege that is required for access to SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select'),
                         principal_name => 'it_engineer');
 
  sys.xs_acl.create_acl(name      => 'it_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
 
  -- HR_ACL:  This ACL grants HR_REPRESENTITIVE role the privileges to view and update all
  --          employees' records including SALARY column.
  aces(1):= xs$ace_type(privilege_list => xs$name_list('select', 'insert', 
                                          'update', 'delete', 'view_salary'),
                        principal_name => 'hr_representative');
 
  sys.xs_acl.create_acl(name      => 'hr_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(3);
 
  -- Realm #1: Only the employee's own record. 
  --           The EMPLOYEE role can view the realm including SALARY column.     
  realms(1) := xs$realm_constraint_type(
    realm    => 'email = xs_sys_context(''xs$session'',''username'')',
    acl_list => xs$name_list('emp_acl'));
 
  -- Realm #2: The records in the IT department.
  --           The IT_ENGINEER role can view the realm excluding SALARY column.
  realms(2) := xs$realm_constraint_type(
    realm    => 'department_id = 60',
    acl_list => xs$name_list('it_acl'));
 
  -- Realm #3: All the records.
  --           The HR_REPRESENTATIVE role can view and update the realm including SALARY column.
  realms(3) := xs$realm_constraint_type(
    realm    => '1 = 1',
    acl_list => xs$name_list('hr_acl'));
 
  -- Column constraint protects SALARY column by requiring VIEW_SALARY 
  -- privilege.
  cols.extend(1);
  cols(1) := xs$column_constraint_type(
    column_list => xs$list('salary'),
    privilege   => 'view_salary');
 
  sys.xs_data_security.create_policy(
    name                   => 'employees_ds',
    realm_constraint_list  => realms,
    column_constraint_list => cols);
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'employees_ds', 
    schema => 'hr',
    object =>'employees');
end;
/

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

