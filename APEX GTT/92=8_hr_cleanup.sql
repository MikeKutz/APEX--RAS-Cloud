-- common policy
begin
    xs_data_security.remove_object_policy(policy=>'apex_gtt_policy',
                                          schema=>'hr', object=>'apex_temp');
end;
/

exec SYS.dbms_xs_sessions.delete_global_callback( SYS.dbms_xs_sessions.direct_logoff_event, 'hr', null, 'cleanup_temp');
exec SYS.dbms_xs_sessions.delete_global_callback( SYS.dbms_xs_sessions.terminate_session_event, 'hr', null, 'cleanup_temp2');

exec xs_data_security.delete_policy('apex_gtt_policy', xs_admin_util.cascade_option);
exec xs_acl.delete_acl('apex_gtt_acl', xs_admin_util.cascade_option);
exec xs_security_class.delete_security_class('temp_sec', xs_admin_util.cascade_option);


drop procedure cleanup_temp;

drop table apex_temp purge;
