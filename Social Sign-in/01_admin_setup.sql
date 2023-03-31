exec sys.xs_principal.create_dynamic_role(name => 'REGISTERED', description => 'DB Privileges for Registered users');
exec sys.xs_principal.create_dynamic_role(name => 'UNREGISTERED', description => 'DB Privileges for New/Unregistered users');
exec sys.xs_principal.create_dynamic_role(name => 'REGISTRATION_ERROR', description => 'DB Privileges for when an error occurs durring registration');


exec sys.xs_principal.create_dynamic_role(name => 'jUST_IN_CASE', description => 'DB Privileges for when an error occurs durring registration');


