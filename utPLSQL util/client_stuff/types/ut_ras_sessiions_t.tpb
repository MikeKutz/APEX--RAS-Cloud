create or replace type body ut_ras_sessions_t
as
    constructor function ut_ras_sessions_t return self as result
    as
    begin
        ras_info := json_object_t( '{}' );
        
        return;
    end;
    
    member procedure set_user( a_username_uid in varchar2, a_sessionid in raw )
    as
        l_username    ut_principal;
        l_uid_json    json_object_t;
    begin
        l_username := new ut_principal(a_username_uid );
        
        if self.ras_info.has( l_username.principal_name )
        then
            /* taking advantage knowing that json_object_t act like C pointers */
            l_uid_json := self.ras_info.get_object( l_username.principal_name );
            l_uid_json.put( l_username.unique_identifier, a_sessionid );
        else
            /* object does not exist. Need to create one */
            l_uid_json := new json_object_t( '{}' );
            
            l_uid_json.put( l_username.unique_identifier, a_sessionid );
            self.ras_info.put( l_username.principal_name, l_uid_json );
        end if;
    end;
    
    member function get_sessionid( a_username_uid in varchar2 ) return raw
    as
        l_username      ut_principal;
        l_uid_json      json_object_t;
        l_sessionid_vc2 varchar2(64);
        l_sessionid_raw raw(32);
    begin
        l_username := new ut_principal( a_username_uid );

        if self.user_exists( a_username_uid )
        then
            l_uid_json := self.ras_info.get_object( l_username.principal_name );
            
            l_sessionid_vc2 := l_uid_json.get_string( l_username.unique_identifier );
            l_sessionid_raw := l_sessionid_vc2;
            
            return l_sessionid_raw;
        end if;
        
        return null;
    end;

    member function user_exists( a_username_uid in varchar2 ) return boolean
    as
        l_username ut_principal;
        l_uid_json json_object_t;
    begin
        l_username := new ut_principal( a_username_uid );
        
        if self.ras_info.has( l_username.principal_name )
        then
            l_uid_json := self.ras_info.get_object( l_username.principal_name );
            
            if l_uid_json.has( l_username.unique_identifier )
            then
                -- do I need to check for a non-null value ? no
                -- TODO:  session_exists checks for non-null value
                return true;
            end if;
        end if;
        
        return false;
    end;
    
    member function get_all_users return varchar2 -- something, pipelined
    as
        l_username varchar2(100);
        l_user_list json_key_list;
        l_uid_list  json_key_list;
        l_uid_json  json_object_t;
    begin
        l_user_list := self.ras_info.get_keys;
        
        for username in 1 .. l_user_list.count
        loop
            l_uid_json := self.ras_info.get_object( username );
            l_uid_list := l_uid_json.get_keys;
            
            for unique_dbh in 1 .. l_uid_list.count
            loop
                null;
                --pipe row ( username || ut_ras_session_utils. gc_separator || unique_dbh )
            end loop;
            
        end loop;
        
        return 'done';
    end;
    
    member procedure attach_session( username in varchar2 )
    as
    begin
      self.attach_session( new ut_principal(username ), null, null, null );
    end;
    member procedure attach_external_session( username in varchar2 )
    as
      principal_user ut_principal;
    begin
      principal_user := new ut_principal(username);
      principal_user.is_external := 1;
      self.attach_session( principal_user, null, null, null );
    end;
    member procedure attach_session( user_name             in ut_principal
                                    ,enable_roles          in ut_principal_list default null
                                    ,enable_external_roles in ut_principal_list default null
                                    ,disable_roles         in ut_principal_list default null
                                    ,ns_attributes         in ut_ns_sttrib_list default null
                                    )
    as
    begin
      null;
    end;
    
    member procedure detach_session( abort in boolean default false )
    as
    begin
      null;
    end;

    member procedure abort_all_sessions
    as
    begin
      null;
    end;

end;
/
