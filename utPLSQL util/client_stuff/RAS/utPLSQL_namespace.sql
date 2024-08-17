declare
    type t_attribute_list is table of varchar2(128);

    l_attr_list  xs$ns_attribute_list := new xs$ns_attribute_list();
    
    lc_attributes  constant t_attribute_list := new t_attribute_list(
    'CONVERAGE_RUN_ID', 'RUN_PATHS', 'SUITE_DESCRIPTION',
    'SUITE_PACKAGE', 'SUITE_PATH', 'SUITE_START_TIME',
    'CURRENT_EXECUTABLE_NAME', 'CURRNT_EXECUTABLE_TYPE',
    'CONTEXT_DESCRIPTION', 'CONTEXT_NAME', 'CONTEXT_PATH',
    'CONTEXT_START_TIME', 'TEST_DESCRIPTION', 'TEST_NAME',
    'TEST_START_TIME' );

begin
    l_attr_list.extend( lc_attributes.count );
    
    for i in 1 .. lc_attributes.count
    loop
        l_attr_list(i) := new xs$ns_attribute( lc_attributes(i) );
    end loop;
    
    
    xs_namespace.create_template( name => 'UT3_INFO', attr_list => l_attr_list );
end;
/
