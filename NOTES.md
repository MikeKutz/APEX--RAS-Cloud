# Developer Notes

- ℹ️ NOTE: these are current as of CPU 17-Jan-2023. Future patches may resolve some bugs/issues
- ℹ️ General: RAS adds a layer of "deny,allow" rules for RLS and Column Security on top of classic DB privileges
  - DB, ACL, Security Class all need to provide the Principal the Privilege in order for Principal to do the job
- ℹ️ RAS: ACE Principals prefer Roles over Users
- ℹ️ APEX: Ensure RAS is enabled for the Instance
- ℹ️ APEX: For dynamic roles, ensure they are enable for the Application (Security Attributes->Authorization->Source)
- ⚠️ APEX: A hiccup can occur in APEX if a RAS Session can not be completely created
  - disable RAS and login 2x to reset
  - the more difficult ones could require a complete rebuild of DB (Use a Code Repository!)
- ⚠️ APEX: RAS Mode->Enable External requires at least 1 enabled dynamic role (possible 🐜)
- ℹ️ APEX: RAS Mode->Enable Internal requires a RAS User whose name matches USER_ID
- ℹ️ APEX: you can adjust the USER_ID in the Post Authentication Procedure with `apex_custom_auth.set_user()`
- 🐜 OCI: the view dba_xs_privilege_grants is incorrect (OCI specific??)
- 🐜 RAS: Data Dictionary View for Global Callbacks is missing (not just undocumented)
  - many of the `xs$` views are inaccessible by ADMIN on ATP Free Tier
- 🐜 CBAC: A code's granted role (CBAC) can be lost on `create or replace`
- ❗ CBAC+RAS: ACL privileges granted to code (CBAC) is not revoked on exit of code. patch for CVE-2023-21829 is available in the CPU released on 17-Jan-2023. (19c, 21c)
- 🐜 RAS: make sure your Namespace is UPPER (for non xs$session namespaces) when you call `xs_sys_context`
- 🐜 APEX: make sure your Role name is UPPER when you call `apex_authorization.enable_dynamic_roles`
- 🐜 APEX: It doesn't appear to enable External Roles either (per documentation)
- ℹ️ APEX: Initialization of a RAS Session should be done in the Post Authentication Procedure
  - User name adjustment
  - Protected P0 Item values
  - Enablement of Dynamic Application Roles
  - Create & Update of Namespaces (untested)
- 🐜 APEX: ending of a RAS Session is delayed when you exit an APEX Session.
   - "kill RAS session" in logout procedure
- 📖 Doc: List of Events for procedure `dbms_xs_session.add_global_callback` (and related procedures) do not match constants in specification of `dbms_xs_session`
- ℹ️ RAS: Events for RAS Session Initialization via Global Callback
  - `direct_login_event` for direct users (eg SQLPlus)
  - `guest_to_user_event` for APEX+RAS Internal
  - (TBD) for APEX+RAS External (most likely, the same)



