-- hr_cre.sql
-- hr_popul.sql

grant read on hr.employees to see_all_employees_role;

declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));

  sys.xs_security_class.create_security_class(
    name        => 'hr_ns_privileges', 
                              -- sys.NSTEMPLATE_SC
    parent_list => xs$name_list('sys.nstemplate_sc'), --ADMIN_ANY_NAMESPACE
    priv_list   => xs$privilege_list());
end;
/



declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  -- EMP_ACL: This ACL grants EMPLOYEE role the privileges to view an employee's
  --          own record including SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','view_salary'),
                         principal_name => 'db_emp', principal_type => 2);
--                         principal_name => 'employee');
 
  sys.xs_acl.create_acl(name      => 'emp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
  
  -- IT_ACL:  This ACL grants IT_ENGINEER role the privilege to view the employee
  --          records in IT department, but it does not grant the VIEW_SALARY
  --          privilege that is required for access to SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select'),
                         principal_name => 'department');
 
  sys.xs_acl.create_acl(name      => 'dept_acl',
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

  aces(1):= xs$ace_type(privilege_list => xs$name_list('select'),
                        principal_name => 'see_all_employees_role',
                        principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'see_all_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');

                                                   --   MODIFY_NAMESPACE
  aces(1):= xs$ace_type(privilege_list => xs$name_list('MODIFY_NAMESPACE','MODIFY_ATTRIBUTE'),
                        principal_name => 'ns_modifier_role',
                        principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'modify_ns',
                    ace_list  => aces,
                    sec_class => 'hr_ns_privileges');
end;
/


begin
    -- create Namespace
    xs_namespace.create_template( name => 'HR$SESSION',
        attr_list => XS$NS_ATTRIBUTE_LIST(
            XS$NS_ATTRIBUTE( 'employee_id' ),
            XS$NS_ATTRIBUTE( 'department_id' )
        ),
        acl => 'modify_ns'
    );
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
    realm    => q'[employee_id = xs_sys_context('HR$SESSION','employee_id')]',
--    realm    => q'[email = xs_sys_context('xs$session','username')]',
    acl_list => xs$name_list('emp_acl'));
 
  -- Realm #2: The records in the IT department.
  --           The IT_ENGINEER role can view the realm excluding SALARY column.
  realms(2) := xs$realm_constraint_type(
    realm    => q'[department_id =  xs_sys_context('HR$SESSION','department_id')]',
    acl_list => xs$name_list('dept_acl'));
 
  -- Realm #3: All the records.
  --           The HR_REPRESENTATIVE role can view and update the realm including SALARY column.
  realms(3) := xs$realm_constraint_type(
    realm    => '1 = 1',
    acl_list => xs$name_list('hr_acl','see_all_acl'));
 
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
    object =>'employees',
    owner_bypass => false
    );
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


create or replace
procedure init_hr$session_ns(sessionid in raw, p_user in varchar2, error out pls_integer)
  authid current_user
as
    employee_id hr.employees.employee_id%type;
    department_id hr.employees.department_id%type;
begin
    error := 0;
    
    select a.employee_id, a.department_id
      into employee_id, department_id
    from hr.employees a
    where a.email = p_user;
    
    sys.dbms_xs_sessions.create_namespace( 'HR$SESSION' );
    SYS.dbms_xs_sessions.set_attribute( 'HR$SESSION', 'employee_id', employee_id );
    SYS.dbms_xs_sessions.set_attribute( 'HR$SESSION', 'department_id', department_id );
exception
    when no_data_found then
        error := 0;
        null;
end;
/

/**/

grant execute on init_hr$session_ns to public;
grant cbac_role to procedure init_hr$session_ns;

begin
  SYS.dbms_xs_sessions.add_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', null, 'init_hr$session_ns');
  SYS.dbms_xs_sessions.add_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.guest_to_user_event, 'hr', null, 'init_hr$session_ns');
end;
/
