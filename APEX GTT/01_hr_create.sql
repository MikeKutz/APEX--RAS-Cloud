create table apex_temp (
  "__xs_session_id"  varchar2(32) default xs_sys_context('xs$session','session_id') not null
  ,id                int generated always as identity
  ,n                 number
  ,d                 date default on null sysdate
  ,constraint apex_temp_pk primary key ( "__xs_session_id"
  ,id )
);

create table session_log (
  sessionid  raw(64),
  event_name varchar2(40),
  ts         timestamp with time zone default current_timestamp
);

create or replace
procedure cleanup_temp (sessionid in raw, u in varchar2, error_t out pls_integer)
  authid definer
as
  session_id_converted   apex_temp."__xs_session_id"%type;
  
  procedure log_me
  as
    pragma autonomous_transaction;
  begin
    insert into hr.session_log (sessionid, event_name)
    values ( sessionid, '3 parm - logoff' );
    
    commit;
  end;
begin
  error_t := 0;
  log_me;
  
  delete from hr.apex_temp a
  where "__xs_session_id" = xs_sys_context('xs$session','session_id');
  
  commit;
exception
  when others then
    null;
end;
/

create or replace
procedure cleanup_temp2 (sessionid in raw, error_t out pls_integer)
  authid definer
as
  session_id_converted   apex_temp."__xs_session_id"%type;
  
  procedure log_me
  as
    pragma autonomous_transaction;
  begin
    insert into hr.session_log (sessionid, event_name)
    values ( sessionid, '2 parm - session term ( ' || length(sessionid) || ' )' );
    
    commit;
  end;
begin
  error_t := 0;
  log_me;
  
  delete from hr.apex_temp a
  where "__xs_session_id" = sessionid;
  
  commit;
exception
  when others then
    null;
end;
/


grant insert,select,update,delete on apex_temp to public;
grant execute on cleanup_temp to public;

declare
begin
  sys.xs_security_class.create_security_class(
      name        => 'temp_sec'
      ,parent_list => xs$name_list('sys.dml')
      ,priv_list => xs$privilege_list()
    );
end;
/

declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  aces(1) := xs$ace_type(privilege_list => xs$name_list('insert','update','select','delete'),
                         principal_name => 'public',
                         principal_type => 2);
  sys.xs_acl.create_acl(name      => 'apex_gtt_acl',
                    ace_list  => aces,
                    sec_class => 'temp_sec');
end;
/

declare
  realms   xs$realm_constraint_list := xs$realm_constraint_list();      
  cols     xs$column_constraint_list := xs$column_constraint_list();
begin  
  realms.extend(1);
 
  realms(1) := xs$realm_constraint_type(
    realm    => q'["__xs_session_id" = xs_sys_context('xs$session','session_id') ]',
    acl_list => xs$name_list('apex_gtt_acl')
    );

  sys.xs_data_security.create_policy(
    name                   => 'apex_gtt_policy',
    realm_constraint_list  => realms
    );
end;
/

begin
  sys.xs_data_security.apply_object_policy(
    policy => 'apex_gtt_policy', 
    schema => 'hr',
    object =>'apex_temp',
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

select * from xs$validation_table order by 1, 2, 3, 4;

exec SYS.dbms_xs_sessions.add_global_callback( SYS.dbms_xs_sessions.direct_logoff_event, 'hr', null, 'cleanup_temp');
exec SYS.dbms_xs_sessions.add_global_callback( SYS.dbms_xs_sessions.terminate_session_event, 'hr', null, 'cleanup_temp2');


