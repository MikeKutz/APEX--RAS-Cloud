set serveroutput on;
clear screen
declare
    sessionid  raw(32);
    
    output  varchar2(256);
    ns      dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
begin
    ns.extend(1);
    ns(1) := new dbms_xs_nsattr( 'UT3_INFO', 'SUITE_START_TIME', 'NOW' );
    
    dbms_xs_sessions.create_session( 'daustin', sessionid);

    dbms_xs_sessions.attach_session( sessionid, namespaces => ns  );
    select xs_sys_context( 'UT3_INFO', 'SUITE_START_TIME' ) into output
    from dual;
    dbms_output.put_line('info="' || output || '"' );
    dbms_xs_sessions.detach_session;

    dbms_xs_sessions.destroy_session( sessionid );
exception
    when others then
        if sessionid is not null
        then
            dbms_xs_sessions.destroy_session( sessionid );
        end if;
        
        raise;
end;
/
