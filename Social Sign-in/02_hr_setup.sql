create table registered_users (
  user_id   int generated always as identity,
  sub          varchar2(512) not null,
  iss          varchar2(512),
  apex_auth    varchar2(12)  default 'unknown' not null,
  display_name varchar2(32 char) not null,
  app_user as (apex_auth || '_' || sub ) not null,
  constraint reg_user_pk primary key (user_id),
  constraint reg_user_uq1 unique (app_user)
);

create or replace
package app_user_registration
    authid definer
as
    /* lorem ipsum
    *
    * all values based on `APP_USER` and `DISPLAY_NAME` (application item)
    *
    * Definer's Rights to avoid CVE-2023-21829
    *
    * @headcom
    */
    did_not_agree exception;
    
    agree_flag constant varchar2(3) := 'Y';
    
    function tos_md return varchar2;
    procedure register_user  ( i_agree in varchar2 );
    procedure deregister_user( i_agree in varchar2 );
    procedure enable_roles;
end app_user_registration;
/

create or replace
package body app_user_registration
as
    $if dbms_db_version.version >= 20 $then
    -- unknown if this is correct
    procedure enable_roles;
    pragma suppress_warning_6009(enable_roles);
    $end
    
    function tos_md return varchar2
    as
    begin
        -- TODO: replace with multilingual lookup
        return q'[# TERMS OF SERVICE
Please Read and accept in order to register

## Legal
lorem ipsum dol-monty python rust wd40

Information collected to make this app useable
- Service (google, facebook, etc.; part of a unique user identifier)
- Service user id (unique id in google, facebook, etc.; part of a unique user identifier)
- name (used for initial Display Value)
- email (requested but not stored)

Data is not sold, traded, or otherwise given away.

Developers and DBAs have access to the data but only for debuging purposes.
]';
    end tos_md;
    
    procedure register_user  ( i_agree in varchar2 )
    as
        u  varchar2(512);
        iss varchar2(512);
        sub varchar2(512);
    begin
        u := v('APP_USER');
         iss := substr(u, 1, instr(u,'_') - 1);
         sub := substr(u, instr(u,'_') + 1);
         
        apex_debug.trace( 'Register User - Begin for "%s"', u);
        apex_debug.enter( $$plsql_unit || '.register_user', 'i_agree', i_agree
                                                           , 'app_user', u
                                                           , 'iss', iss
                                                           , 'sub', sub);

        if i_agree != agree_flag
        then
            apex_debug.error('Register User - User did not agree');
            raise did_not_agree;
        end if;

        insert into registered_users ( apex_auth, sub, display_name )
            values ( iss
                    ,sub
                    ,v('display_name')
                    );
                    
        apex_debug.info( 'Register User - User "%s" registered', u );
        apex_debug.trace( 'Register User - not tracking user_id' );
        apex_debug.trace( 'Register User - End for "%s"', u);
    end register_user;

    procedure deregister_user( i_agree in varchar2 )
    as
        u varchar2(512);
    begin
        u := v('APP_USER');
        apex_debug.trace( 'Deregister User - begin for "%s"', u);
        apex_debug.enter( $$plsql_unit || '.deregister_user', 'i_agree', i_agree, 'app_user', u );

        if i_agree != agree_flag
        then
            apex_debug.error('Deregister User - User did not agree');
            raise did_not_agree;
        end if;
        
        delete from registered_users a
            where a.app_user = u;

        apex_debug.info( 'Register User - User "%s" removed', u );

        apex_debug.trace( 'Degister User - End for "%s"', u);
    end deregister_user;

    procedure enable_roles
    as
        rcd registered_users%rowtype;
        u varchar2(512);
    begin
        u := v('APP_USER');
        apex_debug.trace( 'Enable Roles - Begin for "%s"', u);
        apex_debug.enter( $$plsql_unit || '.enable_roles', 'app_user', u );

        select * into rcd
        from registered_users a
        where a.app_user = u;
        apex_debug.trace( 'Enable Roles - User was found', u);

        -- bug - Internal Dynamic App Role name must be `UPPER()`
        apex_authorization.enable_dynamic_groups( apex_t_varchar2 ( upper( 'registered' ) ) );
        apex_debug.trace( 'Enable Roles - REGISTERED role enabled', u);
        
        -- load other roles here
        
        apex_debug.trace( 'Enable Roles - End for "%s"', u);
    exception
        when no_data_found then
            apex_debug.trace( 'Enable Roles - User "%s" not found', u);

            apex_authorization.enable_dynamic_groups( apex_t_varchar2 ( upper( 'unregistered' ) ) );
            apex_debug.trace( 'Enable Roles - UNREGISTERED role enabled', u);

            apex_debug.trace( 'Enable Roles - End for "%s"', u);
        when others then
            apex_debug.error( 'Enable Roles - ERROR in procedure', u);

            apex_authorization.enable_dynamic_groups( apex_t_varchar2 ( upper( 'REGISTRATION_ERROR' ) ) );
            apex_debug.trace( 'Enable Roles - REGISTRATION_ERROR role enabled', u);
            
            apex_debug.error('Critical error %s', sqlerrm);
    end enable_roles;
end app_user_registration;
/

grant execute on app_user_registration to public; -- i forgot which schema needs it
  