create user hr identified by Change0nInstall
default tablespace  data
quota  20  M on data
account unlock;

grant connect, resource, create view to hr;


-- RAS Privileges for
--
-- ADMIN_SEC_POLICY | allows user to create policies
-- APPLY_SEC_POLICY | allows user to apply a policy to a table
-- ADMIN_ANY_SEC_POLICY | allows user to debug policy
-- ADMIN_ANY_NAMESPACE | allows the user to ignore ACL restriction for constrained Namespaces
-- PROVISION | (unverified) something with Principals
-- CALLBACK | allows uset to create Global Callback

exec sys.xs_admin_cloud_util.grant_system_privilege('ADMIN_ANY_SEC_POLICY','HR');

alter session set current_schema = hr;

@@./db-sample-schemas/humab_resources/hr_cre.sql
@@./db-sample-schemas/humab_resources/hr_popul.sql

Rem      hr_dn_c.sql - Add DN column to HR.EMPLOYEES and DEPARTMENTS
@@./db-sample-schemas/humab_resources/hr_dn_c.sql

-- remove extra code
drop trigger update_job_history;
drop trigger secure_employees;
drop procedure add_job_history;
drop procedure secure_dml;
