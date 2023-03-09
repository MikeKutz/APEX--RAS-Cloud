# APEX with External RAS
End-user needs both DB Privileges and RAS Privileges in order to perform a task.

In this example:
- DB Privileges are granted via Internal Application Role
- RAS Privileges are granted via External Application Role

When "RAS Mode" is set to "Enable External", at least 1 internal dynamic role *must* be enabled.  The role for DB Privileges will satisfy this requirement.

~~At this time, the function `apex_authorization.enable_dynamic_roles()` does not register External Roles as per documentation.~~
At this time, the function `apex_authorization.enable_dynamic_roles()` does not register `lower()` Internal Roles as per documentation. (21c ATP Free Tier)


## Enable Dynamic Roles
The default configuration for an APEX application does not allow for dynamic roles.

In order to allow them, set "Shared Components -> Security Attributes -> Authorization -> Source for Role or Group Schems" to "Authentication Scheme"

{image}


## DB Privileges
This example uses separate roles for DB Privileges and RAS Privileges.

This step creates the roles for DB Privileges.
```sql
 -- same as RAS HR Demo
create role db_emp;
grant select,update,insert,delete on hr.employees to db_emp;

-- Dynamic Application Role for DB Privileges
exec xs_principal.create_dynamic_role( 'ras_db_emp' );
grant db_emp to ras_db_emp;
```

This will apply to all users. As such, we enable it within the RAS configuration. (ie listed on RHS)

{image}

## RAS Priviliges
External Roles do not need to be defined ahead of time.

### Defining Usage
When defining the ACEs/ACLs, use PTYPE_EXTERNAL.
```sql
-- modified snippet from RAS HR Demo
aces(1) := xs$ace_type(privilege_list => xs$name_list('select','view_salary'),
                       principal_name => 'employee',
                       principal_type => 4 -- PTYPE_EXTERNAL
                       )                       ;

```

### Enabling Role(s)
You statically enable an Internal role by ensuring it is listed on the right side in RAS setting for the Authentication Scheme. In this example, we enable `ras_db_emp` for all authenticated users. *note* at least 1 Internal Dynamic must be enabled after the Post-Authentication Procedure is complete.

You dynamically enable an External Role within the Authentication Scheme's Post-Authentication Procedure. You dynamically enable Interal Application Roles in the same way. (🐜 These must be `UPPER()`)

```sql
procedure enable_roles
as
begin
    --If the role is not Listed in DBA_XS_DYNAMIC_ROLES, it is an External Role
    --NOTE: Internal Roles can be dynamically enabled too, but require UPPER()
    case upper(v('APP_USER')) 
        when 'SMAVRIS' then
            apex_authorization.enable_dynamic_groups(
                apex_t_varchar2( 'employee', 'hr_representative' ));
        when 'DAUSTIN' then
            apex_authorization.enable_dynamic_groups(
                apex_t_varchar2( 'employee', 'it_engineer' ));
        else
            -- allow for registrary/etc
            apex_authorization.enable_dynamic_groups(
                apex_t_varchar2( 'guest_user' ));
    end case;
end;
```
Example:
{image}

### Using RAS Roles for Authorization

Each role should have its own Authentication Scheme.

You can simplify creating the Authentication Scheme by using the Scheme Type "Is In Role or Group".  You'll also need to set the Type of role to "Workspace Group". ("Custom" also seems to work.)

Example: {image}

🐜 BUGS 🐜:
- Name(s) must be in `UPPER()`
- This method does not work on External Application roles

Workaround for External Application Roles: use Scheme Type "Exists SQL Query"

Example:
```sql
select null from v$xs_session_roles where role_name='MY_EXTERNAL_ROLE'
```

## APEX Demo
### Enable RAS on Instance
Log in workspace:internal user:ADMIN

### Create APEX User
Create APEX Users for your workspace
- SMARVIS
- DAUSTIN
- JDOE (not an employee)

### RAS Objects
1. As ADMIN, run `./External Roles/01_admin_create_accounts.sql`
1. As HR, run `./External Roles/02_hr_install_schema.sql`

### Import Application
Import `./External Roles/APEX_22.2_External-RAS.sql`

- Page 1 shows `hr.employees`
- Page 2 shows current session roles

Only `SMARVIS` and `DAUSTIN` have the appropriate roles enabled.  The Post-Authentication Procedure will need to be enhanced in order to accomodate other employees.

*Note* RAS Policies are still be enabled within code thus they can cause a *catch-22* type of situation. Temporarially enabling RAS Privileges within code (via CBAC) will encounter CVE-2023-21829.

EXAMPLE:
```sql
create or replace
procedure hr.enable_roles
    authid definer
as
    department_name  hr.departments.department_name%type;
begin
    select b.department_name
        into enable_roles.department_name
    from hr.employees a
        join hr.departments b on a.department_id=b.department_id
    where upper(a.email) = upper(sys_context('apex$session','app_user'));

    -- adjust 40,60 to match RAS HR Demo roles
    case department_name
        when 'IT' then department_name := 'it_engineer';
        when 'Human Resources' then department_name := 'hr_representative';
        else null;
    end case;

    -- all others, make RAS valid names
    department_name := replace( department_name, ' ', '_' );

    apex_authorization.enable_dynamic_groups(
        apex_t_varchar2( 'employee', department_name ));
exception
    when no_data_found then
        apex_authorization.enable_dynamic_groups(
            apex_t_varchar2( 'guest_user' ));
end;
/

grant execute on hr.enable_roles to APEX_220200;
```
Without CBAC:
- if Definer's Rights, policy must have `owner_bypass => true`
- if Invoker's Rights, even a `select` statement is not yet enabled.

With CBAC
- A DB Role (PTYPE_DB) can be made part of a `1=1` domain
- That role can then be granted to the code (CBAC)
  - *caution* This method envokes CVE-2023-21829
- The role needs to be granted to the definer `with delegate option` (if definer didn't create it)
- The role does not have to be a `default` role for CBAC to work.