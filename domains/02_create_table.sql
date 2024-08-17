create domain base_name as varchar2(500 char) not null
  check ( upper(base_name) like '%-%' );
create domain pre_warp_name as varchar2(500 char) not null
  check ( upper(pre_warp_name) like 'HMS-%' );
create domain post_warp_name as varchar2(500 char) not null
  check ( regexp_like( upper(post_warp_name), '^(NSS|USS)-' ) );
create domain q_name as varchar2(500 char) not null
  check ( upper(q_name) like 'Q-%' );


drop domain if exists name_check;
create flexible domain name_check ( name )
choose domain using ( dummy int )
from
case dummy
 when 99 then hr.q_name( name )
 when 2 then hr.post_warp_name( name )
 when 1 then hr.pre_warp_name( name )
end;
/

drop table if exists ships purge;
create table ships (
   ship_name   base_name
  ,speed       number
);

drop trigger ships_trg;
create or replace
trigger ships_trg
before insert or update on ships
for each row
declare
  dc int;
  sn hr.ships.ship_name%type;
  realm# int;
begin
  select case 1
      when  ORA_CHECK_ACL(TO_ACLID('hr.q_acl'),'insert','update') then 99
      when  ORA_CHECK_ACL(TO_ACLID('hr.post_warp_acl'),'insert','update') then 2
      when  ORA_CHECK_ACL(TO_ACLID('hr.pre_warp_acl'),'insert','update') then 1
      else 0
    end
    into realm#;

--  if realm# = 0 -- check if pollicy is on the table
--  then
--    raise_application_error(-20001, 'no acl active');
--  end if;
  
  select domain_check( 'name_check',
                       cast(:new.ship_name as varchar2(500 char)),
                       realm#
                      )
                      into dc;

  dbms_output.put_line( 'Realm ' || realm# || ' name="' || :new.ship_name || '" check=' || dc );
  dbms_output.put_line( 'Realm ' || realm# || ' name="' || :new.ship_name || '" check=' || dc );
                      
  if dc != 1
  then
    raise_application_error(-20000, 'bad name');
  end if;
end;
/


grant insert,update,select,delete on ships to db_warp_role;
grant execute on base_name to db_warp_role;
grant execute on pre_warp_name to db_warp_role;
grant execute on post_warp_name to db_warp_role;
grant execute on q_name to db_warp_role;
grant execute on name_check to db_warp_role;

