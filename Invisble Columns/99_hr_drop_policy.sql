set serveroutput on
clear screen

declare
  sql_in clob;
  sql_out clob;
begin
  sql_in := q'[alter application table test_hidden drop policy satus_policy]';
  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
  dbms_output.put_line( sql_out );

  sql_in := q'[drop application policy status_policy]';
  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
  dbms_output.put_line( sql_out );

end;
/

/*******************************/
<<alter_table>>
declare    
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for ALTER_TABLE ( alter_table )
    * 
    * @headcom
    **/
    
    xs_data_security.remove_object_policy( 
         policy        => 'status_policy'
        ,schema        => user
        ,object        => 'test_hidden'
          );
end alter_table;
/

<<drop_policy>>
declare    
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for DROP_POLICY ( drop_policy )
    * 
    * @headcom
    **/
    
    xs_data_security.delete_policy( policy =>  'status_policy'
          ,delete_option => xs_admin_util.default_option
        );
end drop_policy;
/

