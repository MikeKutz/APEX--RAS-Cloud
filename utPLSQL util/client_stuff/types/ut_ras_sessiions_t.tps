create or replace type ut_ras_sessions_t authid current_user as object (
    ras_info  json_object_t,
    constructor function ut_ras_sessions_t return self as result,
    member procedure set_user( a_username_uid in varchar2, a_sessionid in raw ),
    member function get_sessionid( a_username_uid in varchar2 ) return raw,
    member function user_exists( a_username_uid in varchar2 ) return boolean,
    member function get_all_users return varchar2, -- something, pipelined
    
    member procedure attach_session( username in varchar2 ),
    member procedure attach_external_session( username in varchar2 ),
    member procedure attach_session( user_name             in ut_principal
                                    ,enable_roles          in ut_principal_list default null
                                    ,enable_external_roles in ut_principal_list default null
                                    ,disable_roles         in ut_principal_list default null
                                    ,ns_attributes         in ut_ns_attrib_list default null
                                    ),
    member procedure detach_session( abort in boolean default false ),
    member procedure abort_all_sessions
) final not persistable;
/