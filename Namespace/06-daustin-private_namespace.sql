-- related to S1607572 [CVE-2023-21829]: ACL check follow through to Next procedure
exec hr.init_pass_no_cbac;
exec hr.init_pass;
exec hr.init_fail;

select xs_sys_context( lower( 'test$pass' ), lower( 'value' ) ) pass_ll
      ,xs_sys_context( lower( 'test$pass' ), upper( 'value' ) ) pass_lu
      ,xs_sys_context( upper( 'test$pass' ), lower( 'value' ) ) pass_ul
      ,xs_sys_context( upper( 'test$pass' ), upper( 'value' ) ) pass_uu

      ,xs_sys_context( lower( 'test$fail' ), lower( 'value' ) ) fail_ll
      ,xs_sys_context( lower( 'test$fail' ), upper( 'value' ) ) fail_lu
      ,xs_sys_context( upper( 'test$fail' ), lower( 'value' ) ) fail_ul
      ,xs_sys_context( upper( 'test$fail' ), upper( 'value' ) ) fail_uu

      ,xs_sys_context( lower( 'xs$session' ), lower( 'username' ) ) user_ll
      ,xs_sys_context( lower( 'xs$session' ), upper( 'username' ) ) user_lu
      ,xs_sys_context( upper( 'xs$session' ), lower( 'username' ) ) user_ul
      ,xs_sys_context( upper( 'xs$session' ), upper( 'username' ) ) user_uu
from dual;

