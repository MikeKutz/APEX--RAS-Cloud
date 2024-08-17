exec xs_acl.delete_acl('data_cbac_acl' );
exec xs_acl.delete_acl('data_entry_acl' );
exec xs_acl.delete_acl('data_analyzer_acl' );
exec xs_acl.delete_acl('data_curator_acl' );


exec xs_principal.delete_principal ('data_cbac');
exec xs_principal.delete_principal ('data_entry');
exec xs_principal.delete_principal ('data_analyzer');
exec xs_principal.delete_principal ('data_curator');


