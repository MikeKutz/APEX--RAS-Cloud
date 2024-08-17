REM If Unit Tests fail, patch server for CVE-2023-21829

clear screen
set SERVEROUTPUT on
exec ut.run();
select count(*) N from hr.employees;
exec ut.run();
select count(*) N from hr.employees;
