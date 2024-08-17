select * from hr.apex_temp;
insert  into hr.apex_temp (n) values (33);

exec hr.utl_ras.attach_session( 'daustin' );

insert  into hr.apex_temp (n) values (33);
commit;
select * from hr.apex_temp;

exec hr.utl_ras.detach_session;

select * from hr.apex_temp;

exec hr.utl_ras.attach_session( 'daustin' );
select * from hr.apex_temp;
exec hr.utl_ras.detach_session;

exec hr.utl_ras.terminate_session( 'daustin' );

exec hr.utl_ras.attach_session( 'daustin' );
select * from hr.apex_temp;
exec hr.utl_ras.detach_session;
exec hr.utl_ras.terminate_session( 'daustin' );



