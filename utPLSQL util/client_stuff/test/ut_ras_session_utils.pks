create or replace
package ut_ras_session_utils
    authid current_user
as
    type t_ras_session_info is record ( username varchar2(128)
                                    ,unique_dbh    varchar2(128)
                                    ,sessionid raw(32) );

    -- constants for parsing string into t_ras_session_info
    gc_separator   constant varchar2(1) := ':';
    gc_default_dbh constant varchar2(20) := 'Default';
    
    -- constants for SYS_CONTEXT and XS Namespace
    -- should be elsewhere
    
    /* parse the utPLSQL parameter into useful data */
    function parse_username_uid( a_username_uid in varchar2 ) return t_ras_session_info;
    
    /* transfers current DB CONTEXT information to XS NAMESPACE information
     * output here is input for CREATE_SESSION and ATTACH_SESSION
     *
     * NOTE: xs_sys_context() is broken. use UPPER() when calling
     */
    function context_to_namespace return dbms_xs_nsattrlist;
    
    /* appends UT Annotations to Namespace */
    procedure append_namespace( a_destination in out nocopy dbms_xs_nsattrlist, a_keys varchar2 );
    
end;
/
