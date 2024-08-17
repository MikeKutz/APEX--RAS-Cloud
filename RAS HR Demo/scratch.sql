create table test_dom (
  enum_value int generated always as IDENTITY,
  enum_name  varchar2(40) not null,
  other_data date,
  stuff    varchar2(50)
);
declare
begin
  sys.xs_security_class.create_security_class(
    name        => 'enum_privileges', 
    parent_list => xs$name_list('sys.dml'),
    priv_list   => xs$privilege_list(xs$privilege('modify_map')));
end;
/

declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  -- EMP_ACL: This ACL grants EMPLOYEE role the privileges to view an employee's
  --          own record including SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','insert','update','delete','modify_map'),
                         principal_name => 'enum_cbac', principal_type => 2);
--                         principal_name => 'employee');
 
  sys.xs_acl.create_acl(name      => 'enum_admin',
                    ace_list  => aces,
                    sec_class => 'enum_privileges');
  
  -- IT_ACL:  This ACL grants IT_ENGINEER role the privilege to view the employee
  --          records in IT department, but it does not grant the VIEW_SALARY
  --          privilege that is required for access to SALARY column.
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','update'),
                         principal_name => 'HR', principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'enum_owner',
                    ace_list  => aces,
                    sec_class => 'enum_privileges');

  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','modify_map'),
                         principal_name => 'HR', principal_type => 2);
 
  sys.xs_acl.create_acl(name      => 'enum_ro',
                    ace_list  => aces,
                    sec_class => 'enum_privileges');

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
    realm    => q'[true]',
    acl_list => xs$name_list('enum_admin', 'enum_ro')
    );
 
  cols.extend(1);
  cols(1) := xs$column_constraint_type(
    column_list => xs$list('enum_name','enum_value'),
    privilege   => 'modify_map');
 
  sys.xs_data_security.create_policy(
    name                   => 'enum_policy',
    realm_constraint_list  => realms,
    column_constraint_list => cols);
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(1);

    realms(1) := xs$realm_constraint_type(
    realm    => q'[true]',
    acl_list => xs$name_list('enum_admin', 'enum_owner')
    );

  cols.extend(1);
  cols(1) := xs$column_constraint_type(
    column_list => xs$list('enum_name','enum_value'),
    privilege   => 'modify_map');
 
  sys.xs_data_security.create_policy(
    name                   => 'enum2_policy',
    realm_constraint_list  => realms,
    column_constraint_list => cols);
end;
/
 

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'enum_policy', 
    schema => 'hr',
    object =>'test_dom',
    owner_bypass => false,
    statement_types => 'select'
    );
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'enum2_policy', 
    schema => 'hr',
    object =>'test_dom',
    owner_bypass => false,
    statement_types => 'insert,update,delete'
    );
end;
/


set SERVEROUTPUT on;
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


begin
  sys.xs_data_security.DISABLE_OBJECT_POLICY(
    policy => 'enum_policy', 
    schema => 'hr',
    object =>'test_dom'
    );
  sys.xs_data_security.DISABLE_OBJECT_POLICY(
    policy => 'enum_policy2', 
    schema => 'hr',
    object =>'test_dom'
    );
  sys.xs_data_security.DISABLE_OBJECT_POLICY(
    policy => 'enum2_policy', 
    schema => 'hr',
    object =>'test_dom'
    );
end;
/


begin
  sys.xs_data_security.DISABLE_OBJECT_POLICY(
    policy => 'enum2_policy', 
    schema => 'hr',
    object =>'test_dom'
    );
end;
/

BEGIN
  sys.xs_data_security.delete_policy(
    policy                   => 'enum_policy' );
end;
/
begin
  sys.xs_data_security.delete_policy(
    policy                   => 'enum2_policy' );

end;
/

exec xs_acl.DELETE_ACL( 'enum_ro' );
exec xs_acl.DELETE_ACL( 'enum_owner' );
exec xs_acl.DELETE_ACL( 'enum_admin' );

exec xs_security_class.delete_security_class('enum_privileges', xs_admin_util.cascade_option);


declare
  val varchar2(128 byte);
begin
  select enum_value
    into val
  from sys.day_enum_d
  where enum_value = 1 and length(enum_name) > 3;
end;
/

select enum_name
  -- into val
from sys.day_enum_d
where enum_value = 1 and length(enum_name) > 3;
