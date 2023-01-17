prompt creating Namespaces and attributes
begin
    sys.xs_namespace.create_template(  'test$public'  );
    sys.xs_namespace.ADD_ATTRIBUTES (  'test$public',  'value' );

end;
/

prompt creating Initialization procedures
create or replace
procedure init_public
    authid current_user
as
begin
    dbms_xs_sessions.create_namespace( 'test$public' );
    dbms_xs_sessions.set_attribute( 'test$public', 'value',  41 );
end;
/

grant execute on init_public to public;

