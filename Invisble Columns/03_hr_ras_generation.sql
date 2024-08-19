set serveroutput on
clear screen

declare
  sql_in clob;
  sql_out clob;
begin
  sql_in := q'[create application security_class status_SecClass
  under ( dml ) define privileges ( status_PPI )
]';
  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
  dbms_output.put_line( sql_out );

  sql_in := q'[create application acl show_new_acl
  for security class status_SecClass
  aces ( database principal show_new_db privileges ( insert, update, select, delete ) )]';
--  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
--  dbms_output.put_line( sql_out );

  sql_in := q'[create application acl show_active_acl
  for security class status_SecClass
  aces ( database principal show_active_db privileges ( insert, update, select, delete ) );
]';
--  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
--  dbms_output.put_line( sql_out );

  sql_in := q'[create application acl show_all_acl
  for security class status_SecClass
  aces ( database principal show_all_db privileges ( insert, update, select, delete ) );
]';
--  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
--  dbms_output.put_line( sql_out );

  sql_in := q'[create application policy status_policy for (
  rls domain ( true ) acls ( ahow_all_acl ),
  rls domain ( some_state != hr.status_d.deprecated ) acls ( show_active_acl),
  rls domain ( some_state = hr.status_d.initializing ) acls ( show_new_acl )
);
]';
  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
  dbms_output.put_line( sql_out );

  sql_in := q'[alter application table test_hidden add policy satus_policy]';
--  cSQL.ddlt_translator.translate_sql( sql_in, sql_out );
--  dbms_output.put_line( sql_out );
end;
/



/*
"w_create w_application x_object_type x_object_name
        w_for w_security w_class x_security_class
        n_ace c_start_obj_array
            (x_principal_type? n_principal o_principal_name n_privileges c_start_list l_priv (c_comma l_priv)*  c_end_list
        (c_obj_comma|c_end_obj_array))+"
*/