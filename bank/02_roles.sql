exec xs_principal.create_dynamic_role( 'banker' );
exec xs_principal.create_dynamic_role( 'bank_customer' );
create role bank_db;
grant bank_db to banker,bank_customer;