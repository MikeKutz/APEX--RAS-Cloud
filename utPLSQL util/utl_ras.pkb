create or replace
package body utl_ras
as
  
  type user_session_hash_t is table of ras_session_t index by varchar2(128 byte);
  
  user_sessions  user_session_hash_t;

  procedure create_session_for_user( username in varchar2
                                    ,is_external boolean default false )
  as
    session_info  ras_session_t;
  begin
    if username is null
    then
      raise no_data_found;
    end if;
    
    session_info := new ras_session_t( username );
    
    if is_external
    then
      dbms_xs_sessions.create_session( username   => session_info.username
                                     ,sessionId   => session_info.sessionId
                                     ,is_external => true );
    else
      dbms_xs_sessions.create_session( username   => session_info.username
                                     ,sessionId   => session_info.sessionId
                                     ,is_external => false );
    end if;


    user_sessions( username ) := session_info;
  end;
  
  /* return's sessionID for user */
  function get_session_id( username in varchar2) return raw
  as
  begin
    if user_sessions.exists(username)
    then
      return user_sessions(username).sessionid;
    else
      raise no_data_found;
    end if;
  end;
  
  procedure attach_session( username in varchar2
                           ,is_external boolean default false )

  as
    sessionid            raw(32);
  begin
    assert_not_attached;
  
    dbms_xs_sessions.attach_session( get_session_id(username) );
  exception
    when no_data_found then
      create_session_for_user( username, is_external );
      dbms_xs_sessions.attach_session( get_session_id(username) );
  end;
  
  
  procedure detach_session
  as
  begin
    dbms_xs_sessions.detach_session();
  end;
  
  procedure abort_session
  as
  begin
    dbms_xs_sessions.detach_session(true);
  end;
  
  procedure assert_not_attached
  as
  begin
    if is_attached
    then
      detach_session;
      
      if is_attached
      then
        abort_session;
      end if;
    end if;
  end;
  
  function is_attached return boolean
  as
    ret_value number(1);
  begin
    select nvl2(xs_sys_context( 'xs$session', 'session_id'), 1, 0)
      into ret_value
    from dual;
    
    if ret_value = 1
      then return true;
      else return false;
    end if;
  end;

  procedure terminate_session( username in varchar2 )
  as
    sessionid  raw(32);
  begin
    assert_not_attached;
    
    sessionid := get_session_id( username );
    dbms_xs_sessions.destroy_session( sessionid );
    remove_session_id( username );
  exception
    when no_data_found then
      null;
  end;
  
  procedure terminate_all_sessions
  as
    username varchar2(128);
  begin
    assert_not_attached;
    
    username := user_sessions.first;
    while( username is not null )
    loop
        dbms_xs_sessions.destroy_session( user_sessions(username).sessionid );
        
        username := user_sessions.next(username);
    end loop;
    
    user_sessions.delete;
  end;
  
  procedure remove_session_id( username in varchar2 )
  as
  begin
    if user_sessions.exists( username )
    then
      user_sessions.delete( username );
    end if;
  end;
end;
/
