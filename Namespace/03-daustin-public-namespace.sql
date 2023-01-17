-- should PASS
exec hr.init_public;

-- TEST FOR A SECOND BUG (simplified
select xs_sys_context( lower( 'test$public' ), lower( 'value' ) ) public_ll
      ,xs_sys_context( lower( 'test$public' ), upper( 'value' ) ) public_lu
      ,xs_sys_context( upper( 'test$public' ), lower( 'value' ) ) public_ul
      ,xs_sys_context( upper( 'test$public' ), upper( 'value' ) ) public_uu

      ,xs_sys_context( lower( 'xs$session' ), lower( 'username' ) ) user_ll
      ,xs_sys_context( lower( 'xs$session' ), upper( 'username' ) ) user_lu
      ,xs_sys_context( upper( 'xs$session' ), lower( 'username' ) ) user_ul
      ,xs_sys_context( upper( 'xs$session' ), upper( 'username' ) ) user_uu
from dual;

