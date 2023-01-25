begin
    -- readjust HR
   sys.xs_acl.add_acl_parameter(acl => 'hr_acl',
                           policy => 'employees_ds',
                           parameter => 'dept_id',
                           value => 90); -- number
   sys.xs_acl.add_acl_parameter(acl => 'hr_acl',
                           policy => 'employees_ds',
                           parameter => 'view_sal',
                           value => 'no'); -- varchar2
end;
/