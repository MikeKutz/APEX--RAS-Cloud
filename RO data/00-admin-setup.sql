create role db_can;
create role db_cannot;

exec sys.xs_principal.create_role(name => 'xs_can', enabled => true);
exec sys.xs_principal.create_role(name => 'xs_cannot', enabled => true);
grant db_can to xs_can;
grant db_cannot to xs_cannot;

exec  sys.xs_principal.create_user(name => 'daustin', schema => 'hr');
exec  sys.xs_principal.set_password('daustin', 'Change0nInstall');
exec  sys.xs_principal.grant_roles('daustin', 'XSCONNECT');
exec  sys.xs_principal.grant_roles('daustin', 'xs_can');
exec  sys.xs_principal.grant_roles('daustin', 'xs_cannot');

