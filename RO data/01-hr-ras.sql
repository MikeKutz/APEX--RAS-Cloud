set serveroutput on
clear screen

create table protected_data (
  id int generated always as identity,
  N          varchar2(10),
  is_valid   number(1) default on null 1 check (is_valid in (1,0)),
  data_state varchar2(20),
  constraint pd_pk primary key (id)
);

create or replace
view protected_data_view bequeath CURRENT_USER
as
select * from protected_data;

grant insert,select, update, delete on protected_data to db_can;
--grant insert,select, update(is_valid) on protected_data to db_cannot;
grant insert,select on protected_data_view to db_can,db_cannot;


declare
begin
  sys.xs_security_class.create_security_class(
      name        => 'demo_sec'
      ,parent_list => xs$name_list('sys.dml')
    );
end;
/

declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  aces(1) := xs$ace_type(privilege_list => xs$name_list('insert','update','select','delete'),
                         principal_name => 'xs_can');
  sys.xs_acl.create_acl(name      => 'can_acl',
                    ace_list  => aces,
                    sec_class => 'demo_sec');

  aces(1) := xs$ace_type(privilege_list => xs$name_list('insert','select' ),
                         principal_name => 'xs_cannot');
  sys.xs_acl.create_acl(name      => 'cannot_acl',
                    ace_list  => aces,
                    sec_class => 'demo_sec');

end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(2);
 
  realms(1) := xs$realm_constraint_type(
    realm    => q'[data_state is null]',
    acl_list => xs$name_list('can_acl')
    );
  realms(2) := xs$realm_constraint_type(
    realm    => q'[data_sstate is not null]',
    acl_list => xs$name_list('cannot_acl')
    );

--  cols.extend(1);
--  cols(1) := xs$column_constraint_type(
--    column_list => xs$list('is_valid'),
--    privilege   => 'update_flag');

    
  sys.xs_data_security.create_policy(
    name                   => 'data_protect_policy',
    realm_constraint_list  => realms
--    ,column_constraint_list => cols
    );
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'data_protect_policy', 
    schema => 'hr',
    object =>'protected_data',
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

select * from xs$validation_table order by 1, 2, 3, 4;


--create or replace
--trigger protected_data_view_trg
--instead of update on protected_data_view
--for each row
--begin
--  dbms_output.put_line( 'TRIGGER CALLED' );
--  delete from protected_data where id = :old.id;
--  insert into protected_data (n) values ( null );
--end;
--/
--
  