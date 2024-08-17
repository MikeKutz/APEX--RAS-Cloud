create or replace
package body ut_test_ras_sessions_hashing
as
    test_obj  ut_ras_sessions_t;

    procedure beforeall
    as
    begin
        test_obj := new ut_ras_sessions_t;
    end;
    
    --test%( testX )
    procedure splitting
    as
        l_single  ut_ras_session_utils.t_ras_session_info;
        l_double  ut_ras_session_utils.t_ras_session_info;
        l_null    ut_ras_session_utils.t_ras_session_info;
    begin
        l_single := ut_ras_session_utils.parse_username_uid( 'foo' );
        ut.expect( l_single.unique_dbh ).to_equal( 'Default' );
        ut.expect( l_single.username ).to_equal( 'foo' );


        l_double := ut_ras_session_utils.parse_username_uid( 'foo:bar' );
        ut.expect( l_double.username ).to_equal( 'foo' );
        ut.expect( l_double.unique_dbh ).to_equal( 'bar' );

        l_null := ut_ras_session_utils.parse_username_uid( 'foo:' );
        ut.expect( l_null.username ).to_equal( 'foo' );
        ut.expect( l_single.unique_dbh ).to_equal( 'Default' );

    
    end;
    
    --%test( simple set/ get )
    procedure set_get
    as
        sessionid  raw(32);
        saved_id   raw(32);
    begin
        sessionid := '1234';
        test_obj.set_user( 'bob:1', sessionid );
        saved_id := test_obj.get_sessionid( 'bob:1' );
        ut.expect( saved_id ).to_equal( sessionid );
    end;

    --test%( testX )
    --%disabled
    procedure set_get_multi
    as
        larry_sid  raw(32) := '1234';
        moe_sid    raw(32) := '3456';
        curly_sid  raw(32) := '4567';
        shemp_sid  raw(32) := '8765';
        saved_id   raw(32);
    begin
        test_obj.set_user( 'larry:king', larry_sid );
        test_obj.set_user( 'moe:', moe_sid );
        test_obj.set_user( 'curly', curly_sid );
        test_obj.set_user( 'shemp', curly_sid );
        test_obj.set_user( 'shemp', shemp_sid );
        test_obj.set_user( 'shemp:og', curly_sid );
        
        ut.expect( test_obj.get_sessionid( 'larry:king' ) ).to_equal( larry_sid );
        ut.expect( test_obj.get_sessionid( 'moe:' ) ).to_equal( moe_sid );
        ut.expect( test_obj.get_sessionid( 'curly' ) ).to_equal( curly_sid );
        ut.expect( test_obj.get_sessionid( 'shemp' ) ).to_equal( shemp_sid );
        ut.expect( test_obj.get_sessionid( 'shemp:og' ) ).to_equal( curly_sid );
    end;

    --test%( testX )
    --%disabled
    procedure check_exists
    as
    begin
        null;
    end;

    --test%( testX )
    --%disabled
    procedure get_all
    as
    begin
        null;
    end;

    --test%( testX )
    --%disabled
    procedure remove_user
    as
    begin
        null;
    end;
    
    procedure show_json
    as
        l_buffer clob;
    begin
        dbms_output.put_line( 'json text:' );
        dbms_output.put_line( test_obj.ras_info.to_string );
    end;
end;
/
