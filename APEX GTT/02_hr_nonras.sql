drop view no_ras_temp;
drop table apex$no_ras_temp$gtt purge;

create table apex$no_ras_temp$gtt (
  apex_user  varchar2(1000) default nvl2( sys_context('apex$session', 'app_session'), 'APEX', 'RAS' )
                                 || coalesce(sys_context('apex$session', 'app_session'),xs_sys_context('xs$session','session_id')) not null
  ,id        int generated always as identity
  ,n         number
  ,d         date default on null sysdate
  ,constraint no_ras_temp_pk primary key ( apex_user, id )
);

create or replace
view no_ras_temp
as
select id, n, d
from apex$no_ras_temp$gtt
where apex_user = nvl2( sys_context('apex$session', 'app_session'), 'APEX', 'RAS' )
                  || coalesce(sys_context('apex$session', 'app_session'),xs_sys_context('xs$session','session_id'));

grant insert, update,select, delete on no_ras_temp to public;


