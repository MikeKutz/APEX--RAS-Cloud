/**

-- create acls
create application acl show_new_acl
  for security class xxx
  aces ( principal show_new privileges ( insert, update, select, delete ) );
  
create application acl show_active_acl
  for security class xxx
  aces ( principal show_actuv privileges ( insert, update, select, delete ) );
    
create application acl show_all_acl
  for security class xxx
  aces ( principal show_all privileges ( insert, update, select, delete ) );


-- create policy
create application policy status_policy for (
  rls domain ( true ) acls ( ahow_all_acl ),
  rls domain ( some_state != hr.status_d.deprecated ) acls ( show_active_acl,
  rls domain ( some_state = hr.status_d.ininitializing ) acls ( show_new_acl )
);

-- apply policy
alter application table ttt add policy satus_policy
  without owner bypass
  for ( select );

*/