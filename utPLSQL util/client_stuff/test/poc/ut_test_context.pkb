create or replace
package body ut_test_context
as
    procedure show_off
    as
        sessionid   raw(32);
        
        ns          dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
        context_og  varchar2(256);
        context_in  varchar2(256);
        context_xs  varchar2(256);
        
        
    begin
        ns := ut_ras_session_utils.context_to_namespace;
        
        context_og := sys_context( 'UT3_INFO', 'SUITE_START_TIME' );
        
        dbms_xs_sessions.create_session( 'daustin', sessionid);
    
        dbms_xs_sessions.attach_session( sessionid, namespaces => ns  );
        select xs_sys_context( 'UT3_INFO', 'SUITE_START_TIME' )
            into context_xs
        from dual;
        dbms_xs_sessions.detach_session;
    
        dbms_xs_sessions.destroy_session( sessionid );
        context_in := sys_context( 'UT3_INFO', 'SUITE_START_TIME' );
        
        dbms_output.put_line( 'og = ' || context_og );
        dbms_output.put_line( 'in = ' || context_in );
        dbms_output.put_line( 'xs = ' || context_xs );
    end;
end;
/

