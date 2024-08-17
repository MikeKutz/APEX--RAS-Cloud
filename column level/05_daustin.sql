ALTER SESSION SET EVENTS 'TRACE XSACL disk=low';


select * from hr.test_col;
select * from hr.test_col2;

update  hr.test_col set is_valid = false;  -- should be 3
update  hr.test_col set some_data = 'ZZZ'; -- should be 2
update  hr.test_col set bod = sysdate;     -- should be 1
select * from hr.test_col;

update  hr.test_col set bod = sysdate where id = 1;

select hr.status_d.initializing init
      ,hr.status_d.analyzing analyzing
      ,hr.status_d.curating curing;
ROLLBACK;