begin
  sys.xs_security_class.create_security_class(
    name        => 'hr_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('view_salary')));
end;
/

create table temp_t (
     session_id varchar2(200) invisible default xs_sys_context(upper('xs$session'), 'session_id' ) not null,
     temp_id    int generated always as identity not null,
     data1      date,
     data2      number,
     data3      varchar2(30),
     constraint temp_t_pk primary key (session_id, temp_id)
);

create role db_xs_temp;
grant insert, update, select, delete on temp_t to db_xs_temp;
grant db_xs_temp to public;

declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  -- EMP_ACL: This ACL grants EMPLOYEE role the privileges to view an employee's
  --          own record including SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','insert', 'update', 'delete'),
                         principal_name => 'db_xs_temp',
                         principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'xs_temp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(1);
 
  -- Realm #1: Only the employee's own record. 
  --           The EMPLOYEE role can view the realm including SALARY column.     
  realms(1) := xs$realm_constraint_type(
    realm    => q'[session_id = xs_sys_context(upper('xs$session'),'session')]',
    acl_list => xs$name_list('xs_temp_acl'));

  sys.xs_data_security.create_policy(
    name                   => 'temp_table_rls',
    realm_constraint_list  => realms,
    column_constraint_list => cols);
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'temp_table_rls', 
    schema => 'hr',
    object =>'temp_t',
    owner_bypass => true
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


-- todo
create role db_xs_temp_cbac;
grant delete on temp_t to db_xs_temp_cbac;
grant db_xs_temp_cbac to hr with delegate option;

-- ACL for db_xs_temp_cbac 
-- modify Policy to ad ACL to 1=1

create or replace
package global_callbacks
as
  procedure end_session( ses_id raw, other_data int);
end;
/

create or replace
package body global_callbacks
as
    procedure end_session( ses_id in raw, error out pls_integer)
    as
        str_session_id hr.temp_t.session_id%type;
    begin
        -- todo convert to varchar2
    
        delete from hr.temp_t t where t.session_id = str_session_id;
        error := 0;
    exception
        when others then
            error := 0;
            -- log error
            null;
    end;
end;
/

grant db_xs_temp_cbac to package global_callbacks;
begin
    -- don't know which ones are needed.
    sys.dbms_xs_sessions.add_global_callback( SYS.dbms_xs_sessions.direct_logout_event, 'hr', 'global_callbacks', 'end_session');
    sys.dbms_xs_sessions.add_global_callback( SYS.dbms_xs_sessions.destroy_session_event, 'hr', 'global_callbacks', 'end_session');
end;
/
