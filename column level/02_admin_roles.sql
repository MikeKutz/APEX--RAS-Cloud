-- database roles
create role data_cbac_db;
create role data_entry_db;
create role data_analyzer_db;
create role data_curator_db;
-- RAS roles
exec xs_principal.create_role('data_entry', true);
exec xs_principal.create_role('data_analyzer', true);
exec xs_principal.create_role('data_curator', true);
-- data_cbac_db is used directly in ACE definition

grant data_entry_db to data_entry;
grant data_analyzer_db to data_analyzer;
grant data_curator_db to data_curator;

exec XS_PRINCIPAL.grant_roles( 'daustin', 'data_entry' );
exec XS_PRINCIPAL.grant_roles( 'daustin', 'data_analyzer' );
exec XS_PRINCIPAL.grant_roles( 'daustin', 'data_curator' );

exec sys.XS_DATA_SECURITY_UTIL.schedule_static_acl_refresh( table_name => 'test_col' );



