-- hr_cre.sql
-- hr_popul.sql

-- grants for `see_all_employees_role
grant read on hr.employees to see_all_employees_role;

-- create Security Classes
declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));

  sys.xs_security_class.create_security_class(
    name        => 'hr_ns_privileges', 
                              -- sys.NSTEMPLATE_SC
    parent_list => xs$name_list('sys.nstemplate_sc'),
    priv_list   => xs$privilege_list());
end;
/


-- create ACEs
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
  
  -- DEPT_ACL:  This ACL grants DEPARTMENT role the privilege to view the employee
  --            records in the same department, but it does not grant the VIEW_SALARY
  --            privilege that is required for access to SALARY column.
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

  -- SEE_ALL_ACL:  This ACL grants the DB role SEE_ALL_EMPLOYES_ROLE the privileges to view data
  --               The role is used for CBAC enabled code in order to retrieve the proper data
  --               and use those values to initialize the Namespace
  aces(1):= xs$ace_type(privilege_list => xs$name_list('select'),
                        principal_name => 'see_all_employees_role',
                        principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'see_all_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');

  -- MODIFY_NS_ACL:  This ACL grants the DB role SEE_ALL_EMPLOYES_ROLE the privileges to modifiy a Namespace
  aces(1):= xs$ace_type(privilege_list => xs$name_list('MODIFY_NAMESPACE','MODIFY_ATTRIBUTE'),
                        principal_name => 'ns_modifier_role',
                        principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'modify_ns_acl',
                    ace_list  => aces,
                    sec_class => 'hr_ns_privileges');
end;
/

-- create a constrained namespace
begin
    -- create Namespace
    xs_namespace.create_template( name => 'HR$SESSION',
        attr_list => XS$NS_ATTRIBUTE_LIST(
            XS$NS_ATTRIBUTE( 'employee_id' ),
            XS$NS_ATTRIBUTE( 'department_id' )
        ),
        acl => 'modify_ns_acl'
    );
end;
/


-- create Realms and Policy
declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(3);

  -- BUG: xs_sys_context requires Namespace to be UPPER in this context
 
  -- Realm #1: Only the employee's own record. 
  --           The EMPLOYEE role can view the realm including SALARY column.     
  realms(1) := xs$realm_constraint_type(
    realm    => q'[employee_id = xs_sys_context( upper( 'hr$session' ),'employee_id')]',
    acl_list => xs$name_list('emp_acl'));
 
  -- Realm #2: The records in the IT department.
  --           The IT_ENGINEER role can view the realm excluding SALARY column.
  realms(2) := xs$realm_constraint_type(
    realm    => q'[department_id =  xs_sys_context( upper( 'hr$session' ),'department_id')]',
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

-- apply policy
begin
  sys.xs_data_security.apply_object_policy(
    policy => 'employees_ds', 
    schema => 'hr',
    object =>'employees',
    owner_bypass => false
    );
end;
/

-- test RAS configuration
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
procedure init_ns
    authid current_user
as
    /* This package is used by APEX and RAS Global Callbacks
     * to create and initialize the hr$session namespace for
     * the current RAS Session
     *

-- init_ns
--    create_ns
--    lookup_and_set_attributes
--    gcb_direct
--    gcb_guest_to_user
--    post_auth

     * @headcom
     */
end;
/

create or replace
package body init_hr
as
procedure create_ns
as
begin
    sys.dbms_xs_sessions.create_namespace( 'hr$session' );
end create_ns;

procedure lookup_and_set_attributes
as
    employee_id    hr.employees.employee_id%type;
    department_id  hr.employees.department_id%type;
    email          hr.employess.email%type;
begin
    select xs_sys_context( 'xs$session`, 'username' ) -- when is it set??
        into email
    from dual;

    apex_debug.ssss( 'RAS Session Username = "%s"', email );

    select a.employee_id, a.department_id
      into employee_id, department_id
    from hr.employees a
    where a.email = lookup_and_set_attributes.email;

    SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'employee_id', employee_id );
    SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'department_id', department_id );
exception
    when no_data_found then
        SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'employee_id', -1 );
        SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'department_id', -1 );
end lookup_and_set_attributes;

end init_hr;
/

/**/

-- should really be to APEX_nnnnnn
grant execute on init_hr$session_ns to public;
grant see_all_acl to procedure init_hr$session_ns;
grant modify_ns_acl to procedure init_hr$session_ns;

/* for initialization via Post Authentication Procedure, set the Name to:
      hr.init_ns.post_auth
*/

/* for initialization via Global Callback, run this, leave Post Authentication Procedure blank
begin
  SYS.dbms_xs_sessions.add_global_callback( SYS.dbms_xs_sessions.direct_login_event, 'hr', 'init_ns', 'gcb_direct');
  SYS.dbms_xs_sessions.add_global_callback( SYS.dbms_xs_sessions.guest_to_user_event, 'hr', 'init_ns', 'gcb_guest_to_user');
end;
/
*/