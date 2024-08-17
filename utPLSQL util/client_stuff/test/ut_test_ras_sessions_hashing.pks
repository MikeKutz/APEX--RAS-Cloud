create or replace
package ut_test_ras_sessions_hashing
    authid current_user
as
    /* this is a test */
    --%suite( test RAS Sessions )

    
    --%test%( Split Userdame-UDBH )
    procedure splitting;

    --%test( simple set/ get )
    --%rasuser( daustin )
    procedure set_get;

    --%test( test multi set_user )
    procedure set_get_multi;

    --%beforeall
    procedure beforeall;
    
    --%afterall
    procedure show_json;

end;
/


    