create or replace
package body ut_ras_session_utils
as
    function parse_username_uid( a_username_uid in varchar2 ) return t_ras_session_info
    as
        l_return_value  t_ras_session_info;
    begin
        if a_username_uid is null
        then
            return null;
        end if;
        
        if instr( a_username_uid, gc_separator ) > 0
        then
            l_return_value.username   := substr( a_username_uid, 1, instr( a_username_uid, gc_separator ) - 1 );
            l_return_value.unique_dbh := nvl( substr( a_username_uid, instr( a_username_uid, gc_separator ) + 1 ), gc_default_dbh );
        else
            l_return_value.username := a_username_uid;
            l_return_value.unique_dbh := gc_default_dbh;
        end if;
            
        return l_return_value;
    end;

    function context_to_namespace return dbms_xs_nsattrlist
    as
        type t_attribute_list is table of varchar2(128);
        
        l_return_value dbms_xs_nsattrlist := new dbms_xs_nsattrlist();
        
        lc_context     constant varchar2(32) := 'UT3_INFO';
        lc_namespace   constant varchar2(32) := 'UT3_INFO';
        lc_attributes  constant t_attribute_list := new t_attribute_list(
            'CONVERAGE_RUN_ID', 'RUN_PATHS', 'SUITE_DESCRIPTION',
            'SUITE_PACKAGE', 'SUITE_PATH', 'SUITE_START_TIME',
            'CURRENT_EXECUTABLE_NAME', 'CURRNT_EXECUTABLE_TYPE',
            'CONTEXT_DESCRIPTION', 'CONTEXT_NAME', 'CONTEXT_PATH',
            'CONTEXT_START_TIME', 'TEST_DESCRIPTION', 'TEST_NAME',
            'TEST_START_TIME' );
    begin
        l_return_value.extend(lc_attributes.count);

        for i in 1 .. lc_attributes.count
        loop
            l_return_value(i) := new dbms_xs_nsattr( lc_namespace, lc_attributes(i), sys_context( lc_context, lc_attributes(i) ) );
        end loop;
        
        return l_return_value;
    end;
    
    procedure append_namespace( a_destination in out nocopy dbms_xs_nsattrlist, a_keys varchar2 )
    as
    begin
        null;
    end;
end;
/
    