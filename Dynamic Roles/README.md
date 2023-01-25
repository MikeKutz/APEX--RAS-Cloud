This example demonstrates both External Users and Dynamic Roles

1. create dynamic roles
1. creat
1. enable them in the Post Authorization Procedure


The roles are re-worked as dynamic application roles.
Additionally, 2x other roles are created. (mostly so we can debug any errors)


```sql
procedure enable_roles
as
  rec  hr.employees%rowtype;
begin
  select * into rec where email=xs_sys_context('xs$session','username');

  -- enable employee

  case rec.department_id
    when 60 then -- enable IT_DEPARTMENT
    when 40 then -- enable HR_representitive
    else -- enable employee_not_assigned
  end case;

exception
  when no_data_found
   -- external users requires AT LEAST 1 Dynamic Role enabled
   -- enable employee_NOT_FOUND
end;
```