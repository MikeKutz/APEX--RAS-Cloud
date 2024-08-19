<<create_secclass>>
declare    
    /*** 
    * 
    **/
    priv    xs$privilege_list;
    /*** 
    * 
    **/
    parent_list    xs$name_list;
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for CREATE_SECCLASS ( create_secclass )
    * 
    * @headcom
    **/
    
    priv := new xs$privilege_list();
      
      priv.extend(1);
      priv( priv.last ) := new xs$privilege( 'status_PPI' );
      
    
      parent_list := new xs$name_list();
      
      parent_list.extend(1);
      parent_list( parent_list.last ) := 'sys.dml';
      
    
      sys.xs_security_class.create_security_class( name => 'status_SecClass'
        ,priv_list   => priv
        ,parent_list => parent_list
        );
      exception
        when others then
          dbms_output.put_line( 'something went wrong' );
end create_secclass;
/

<<make_acl>>
declare    
    /*** 
    * 
    **/
    priv    xs$name_list;
    /*** 
    * 
    **/
    ace    xs$ace_type;
    /*** 
    * 
    **/
    aces    xs$ace_list;
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for MAKE_ACL ( make_acl )
    * 
    * @headcom
    **/
    
    aces := new xs$ace_list();
    
    -- ACE for "show_new_db"
    priv := new xs$name_list();
    
    priv.extend(1);
    priv( priv.last ) := 'insert';
    priv.extend(1);
    priv( priv.last ) := 'update';
    priv.extend(1);
    priv( priv.last ) := 'select';
    priv.extend(1);
    priv( priv.last ) := 'delete';
    
    ace := new xs$ace_type( privilege_list => priv
        ,principal_name => 'show_new_db'
                         -- SHOW_NEW_DB 
        ,principal_type => 2
       );
    
    aces.extend(1);
    aces( aces.last ):= ace;
    
    /******************************************************************/
    
    sys.xs_acl.create_acl( name => 'show_new_acl'
                          ,ace_list => aces
                          ,sec_class => 'status_SecClass' );
                          --             STATUS_SECCLASS
end make_acl;
/

<<make_acl>>
declare    
    /*** 
    * 
    **/
    priv    xs$name_list;
    /*** 
    * 
    **/
    ace    xs$ace_type;
    /*** 
    * 
    **/
    aces    xs$ace_list;
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for MAKE_ACL ( make_acl )
    * 
    * @headcom
    **/
    
    aces := new xs$ace_list();
    
    -- ACE for "show_active_db"
    priv := new xs$name_list();
    
    priv.extend(1);
    priv( priv.last ) := 'insert';
    priv.extend(1);
    priv( priv.last ) := 'update';
    priv.extend(1);
    priv( priv.last ) := 'select';
    priv.extend(1);
    priv( priv.last ) := 'delete';
    
    ace := new xs$ace_type( privilege_list => priv
        ,principal_name => 'show_active_db'
        ,principal_type => 2
       );
    
    aces.extend(1);
    aces( aces.last ):= ace;
    
    /******************************************************************/
    
    sys.xs_acl.create_acl( name => 'show_active_acl'
                          ,ace_list => aces
                          ,sec_class => 'status_SecClass' );
end make_acl;
/

<<make_acl>>
declare    
    /*** 
    * 
    **/
    priv    xs$name_list;
    /*** 
    * 
    **/
    ace    xs$ace_type;
    /*** 
    * 
    **/
    aces    xs$ace_list;
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for MAKE_ACL ( make_acl )
    * 
    * @headcom
    **/
    
    aces := new xs$ace_list();
    
    -- ACE for "show_all_db"
    priv := new xs$name_list();
    
    priv.extend(1);
    priv( priv.last ) := 'insert';
    priv.extend(1);
    priv( priv.last ) := 'update';
    priv.extend(1);
    priv( priv.last ) := 'select';
    priv.extend(1);
    priv( priv.last ) := 'delete';
    
    ace := new xs$ace_type( privilege_list => priv
        ,principal_name => 'show_all_db'
        ,principal_type => 2
       );
    
    aces.extend(1);
    aces( aces.last ):= ace;
    
    /******************************************************************/
    
    sys.xs_acl.create_acl( name => 'show_all_acl'
                          ,ace_list => aces
                          ,sec_class => 'status_SecClass' );
end make_acl;
/

<<make_policy>>
declare    
    /*** 
    * 
    **/
    realms    xs$realm_constraint_list;
    /*** 
    * 
    **/
    cols    xs$column_constraint_list;
    /*** 
    * 
    **/
    acls    xs$name_list;
    /*** 
    * 
    **/
    col_list    xs$list;
    /*** 
    * 
    **/
    fk_columns    xs$key_list;
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for MAKE_POLICY ( make_policy )
    * 
    * @headcom
    **/
    
    realms := new xs$realm_constraint_list();
    cols := new xs$column_constraint_list();
    
    -- Row Level policy
    acls := new xs$name_list();
    acls.extend(1);
    acls( acls.last ) := 'show_all_acl';
    
    realms.extend(1);
    realms( realms.last ) := new xs$realm_constraint_type(
        realm     => q'?1 = 1?'
      ,acl_list  => acls
      ,is_static => false
    );
    -- Row Level policy
    acls := new xs$name_list();
    acls.extend(1);
    acls( acls.last ) := 'show_active_acl';
    
    realms.extend(1);
    realms( realms.last ) := new xs$realm_constraint_type(
        realm     => q'?some_state != 2?'
      ,acl_list  => acls
      ,is_static => false
    );
    -- Row Level policy
    acls := new xs$name_list();
    acls.extend(1);
    acls( acls.last ) := 'show_new_acl';
                      --  show_new_acl
    
    realms.extend(1);
    realms( realms.last ) := new xs$realm_constraint_type(
        realm     => q'?some_state = hr.status_d.initializing?'
--        realm     => q'?some_state = 1?'
      ,acl_list  => acls
      ,is_static => false
    );
    
    
    xs_data_security.create_policy( name=> 'status_policy'
       ,realm_constraint_list => realms
      ,column_constraint_list => cols
    );
end make_policy;
/

<<alter_table>>
declare    
    -- no custom declarations defined
begin
    /*** 
    * TODO - write documenation for ALTER_TABLE ( alter_table )
    * 
    * @headcom
    **/
    
    xs_data_security.apply_object_policy(
         policy        => 'status_policy'
                        -- status_policy
        ,schema        => 'HR'
        ,object        => 'test_hidden'
        --                 test_hidden
        ,row_acl       => false
        ,owner_bypass  => false
        ,statement_types => null -- todo
      );
end alter_table;
/



begin
  if (sys.xs_diag.validate_workspace()) then
    dbms_output.put_line('All configurations are correct.');
  else
    dbms_output.put_line('Some configurations are incorrect.');
  end if;
end;
/
-- XS$VALIDATION_TABLE contains validation errors if any.
-- Expect no rows selected.
select * from xs$validation_table order by 1, 2, 3, 4;