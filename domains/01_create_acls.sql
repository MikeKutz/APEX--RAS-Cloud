declare  
  aces xs$ace_list := xs$ace_list();  
begin 
  aces.extend(1);
 
  aces(1) := xs$ace_type(privilege_list => xs$name_list('select')
                         ,principal_name => 'any_civ'
                         ,principal_type => 1);
 
  sys.xs_acl.create_acl(name      => 'any_warp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');

  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','update','delete','insert')
                         ,principal_name => 'pre_warp_civ'
                         ,principal_type => 4);
 
  sys.xs_acl.create_acl(name      => 'pre_warp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');

  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','update','delete','insert')
                         ,principal_name => 'post_warp_civ'
                         ,principal_type => 4);
 
  sys.xs_acl.create_acl(name      => 'post_warp_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');

  aces(1) := xs$ace_type(privilege_list => xs$name_list('select','update','delete','insert')
                         ,principal_name => 'q_civ'
                         ,principal_type => 4);
 
  sys.xs_acl.create_acl(name      => 'q_acl',
                    ace_list  => aces,
                    sec_class => 'hr_privileges');
end;
/


