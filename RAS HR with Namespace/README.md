# RAS HR Demo with Namespace
In this demonstration, we will enhance the Oracle Documentation HR Demo example my use of Namespaces and Global Callbacks.

As a reminder, RAS is like VPD on steroids
- use Namespaces instead of a `context`
- use `xs_sys_contex` instead of `sys_context`
- use Global Callbacks instead of Logon Triggers (skip for this demo)
- unlike VPD, values remain across stateless calls (eg APEX Pages) for the same RAS Session

## Department Specific Security
The `it_role` is specific for the IT Department (`department_id=60`). Instead, we want to generalize this to be the department assigned at the creation of the RAS Session (`department_id=xs_sys_context('hr$session','department_id')`)

With that, we will need a generic role to use instead of the `it_role` created in the documentation.
```sql
-- as a DBA (on OCI: ADMIN)
exec sys.xs_principal.create_role(name => 'department', enabled => true);
grant db_emp to department;
```

And assign that role to the current RAS Users
```sql
-- as a DBA (on OCI: ADMIN)
exec sys.xs_principal.grant_roles(rec.email, 'department');
exec sys.xs_principal.grant_roles(rec.email, 'department');
```

## Namespaces
With RAS, Namespaces are used instead of `context`s.

⚠️Unlike VPD, Namespaces can be modified by the end user *by default*.⚠️

The security of the Namespace can be limited to assigning an ACL when you create the Namespace Template. Once done, only the Principal of that ACL can modify its attributes.  A DB Role is used as the Principal which, in turn, will be applied to the initialization procedure (CBAC)

First, create the role for use CBAC and assign it to HR.
```sql
-- as a DBA ( on OCI: ADMIN)
-- create role cbac_ns_role;
create role see_all_employees_role;
create role ns_modifier_role;
grant see_all_employees_role to HR with delegate option;
grant ns_modifier_role to HR with delegate option;
```

Since we are going to limit which Principals can modify the Namespace, we need to create the ACL.
```sql
declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);

  -- CBAC_ACL : This will allow the procedure to SELECT, create Namespace, and modify its attributes
  --            As a DB Principal, "principal_type => 2"
  aces(1):= xs$ace_type(privilege_list => xs$name_list('select'),
                        principal_name => 'cbac_ns_role', -- DB Role
                        principal_type => 2 -- used for DB Principals
                        );
 
  sys.xs_acl.create_acl(name      => 'cbac_ns_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');

end;
/
```

With each RAS Session, a Namespace does not exist until it is created from a Namespace Template.

To create the Namespace Template with limited access, run:
```sql
-- as the HR user
exec sys.xs_namespace.create_template(  'hr$session', acl => 'cbac_acl'  );
exec sys.xs_namespace.ADD_ATTRIBUTES (  'hr$session',  'employee_id' );
exec sys.xs_namespace.ADD_ATTRIBUTES (  'hr$session',  'department_id' );
```

Next, we'll create the initialization procedure and assign it the appropriate role.
```sql
-- as a DBA ( on OCI: ADMIN)
create  or  replace
procedure init_hr_ras_template(sessionid in RAW, user in VARCHAR2, error out PLS_INTEGER)
    authid definer
as
  employee_id    hr.employees.employee_id%type;
  department_id  hr.employees.department_id%type;
begin
  error := 0;

   SYS.dbms_xs_sessions.create_namespace('hr$session'); -- not needed if included in APEX Authentication Schema

  select a.employee_id,  a.department_id
    into  init_hr_ras_template.employee_id
        , init_hr_ras_template.department_id
   from hr.employees a
   where a.email  = init_hr_ras_template.user;
   
   SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'employee_id', employee_id);
   SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'department_id', department_id);
exception
    when no_data_found then
        -- used to identify when it has/hasn't been initialized
        SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'employee_id', -1);
        SYS.dbms_xs_sessions.set_attribute( 'hr$session', 'department_id', -1);
end;
/
-- grant read on employees to cbac_ns_role; -- as a Definer's Rights procedure, this is not necessary
grant cbac_ns_role to procedure init_hr_ras_template;
```

## Policy Redux
The Policy will need to be modified in order to take advantage of the Namespace. The simplest way to procede will be to delete the policy and remake it.

Run this cleanup code to unassign the policy and then drop it.
```sql
-- as HR
 begin
    xs_data_security.remove_object_policy(policy=>'employees_ds',
                                          schema=>'hr', object=>'employees');

    xs_data_security.delete_policy('employees_ds', xs_admin_util.cascade_option);
end;
/
```

Now, we recreate the Policy, apply it to `employees`, and reverify the RAS configuration.
```sql
-- as HR
declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(3);
 
  -- Realm #1: Only the employee's own record. 
  --           The EMPLOYEE role can view the realm including SALARY column.     
  realms(1) := xs$realm_constraint_type(
    realm    => q'[employee_id = xs_sys_context('HR$SESSION','employee_id')]', -- see 🐜 note
    acl_list => xs$name_list('emp_acl'));
 
  -- Realm #2: The records in the IT department.
  --           The IT_ENGINEER role can view the realm excluding SALARY column.
  realms(2) := xs$realm_constraint_type(
    realm    => q'[department_id = xs_sys_context('HR$SESSION','department_id')]', -- see 🐜 note
    acl_list => xs$name_list('dept_acl'));
 
  -- Realm #3: All the records.
  --           The HR_REPRESENTATIVE role can view and update the realm including SALARY column.
  realms(3) := xs$realm_constraint_type(
    realm    => '1 = 1',
    acl_list => xs$name_list('hr_acl'
                            , 'cbac_acl' -- allows code to "see all" also
                            ));
 
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

set  serveroutput on;
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
```
***NOTES***
- 🐜 use `upper(namespace)` for Namespace in `xs_sys_context`
- 🐜 use the original case for the attribute name in `xs_sys_context`
- The `xs$session` Namespace and its attributes are not affected by this bug.

## Global Callbacks
The final step is to automate the initialization process by creating some Global Callbacks.
```sql
-- run as DBA (on OCI: ADMIN)

-- initializes for Direct Logins (eg SQLPlus)
exec SYS.dbms_xs_sessions.add_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', null, 'init_hr_ras_template');
-- initializes for applications (eg APEX)
exec SYS.dbms_xs_sessions.add_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.CREATE_SESSION_EVENT, 'hr', null, 'init_hr_ras_template');
```
***NOTES***
- ⚠️ there are no Data Dictionary objects for Global Callbacks. **DO NOT FORGET WHAT YOU CREATED**

## Test
Now, we login as DAUSTIN and validate that the Namespace has been initialized
```sql
select xs_sys_context(  'hr$session', 'employee_id' ) employee_id,     -- if null, 🐜
       xs_sys_context(  'hr$session', 'department_id' ) department_id, -- if null, 🐜
       xs_sys_context(  upper('hr$session'), 'employee_id' ) employee_id_upper,
       xs_sys_context(  upper('hr$session'), 'department_id' ) department_id_upper,
       xs_sys_context( 'xs$session', 'username' ) xs_user_ll,
       xs_sys_context( upper('xs$session'), 'username' ) xs_user_ul,
       xs_sys_context( 'xs$session', upper('username') ) xs_user_lu,
       xs_sys_context( upper('xs$session'), upper('username') ) xs_user_uu
from dual;
```
***NOTES***
- if the `employee_id_upper` value is NULL, then the Namespace was not initialized
- if the `employee_id_upper` value is -1, then name was not found. try re-granting the role to the code.

To test with other departments, create a user for all other employees listed in `HR.employees`:
```sql
-- run as DBA (on OCI: ADMIN)
begin
    for rec in (select email from hr.employees minus select name from dba_xs_principals)
    loop
        sys.xs_principal.create_user(name => rec.email, schema => 'hr');
        sys.xs_principal.set_password(rec.email, 'Change0nInstall');
        sys.xs_principal.grant_roles(rec.email, 'XSCONNECT');
        sys.xs_principal.grant_roles(rec.email, 'employee');
        sys.xs_principal.grant_roles(rec.email, 'department');

        if rec.department_id = 40
        then
            sys.xs_principal.grant_roles(rec.email, 'hr_representative');
        end if;
    
    end loop;
end;
/
```

## (OPT) Additional Security
⚠️ Due to HR having the role `cbac_ns_role` enabled by default, HR can now see all rows once logged in.

To set the role as disabled:
```sql
-- run as DBA (on OCI: ADMIN)
alter user HR enable all roles except cbac_ns_role;
```

Now, HR will see zero employees (by default) once logged in.  Someone will have to enable the role first, which is an auditable action.

## CLEANUP
In addition to the Documentation cleanup, you will need to run a few extra commands.


To remove Global Callbacks, and the other roles
```sql
-- run as DBA (on OCI: ADMIN)
exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.DIRECT_LOGIN_EVENT, 'hr', null, 'init_hr_ras_template');
exec SYS.dbms_xs_sessions.delete_GLOBAL_CALLBACK( SYS.dbms_xs_sessions.CREATE_SESSION_EVENT, 'hr', null, 'init_hr_ras_template');
drop role cbac_ns_role;
```

To remove the Namespace Template, extra ACL and the initializateion procedure.
```sql
-- as HR, after deleting the Policy
exec sys.xs_namespace.delete_template(  'hr$session'  );
exec xs_acl.delete_acl('cbac_acl', xs_admin_util.cascade_option);
drop procedure init_hr_ras_template;
```
