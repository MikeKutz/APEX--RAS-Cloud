# Developer Notes

These are current as of CPU 17-Jan-2023. Future patches may resolve some bugs/issues

## RAS Objects

Object | Formula
---|---
ACE | Principal => Privileges
ACL | ACL Name, Security Class => ACEs
Realm | Domain => ACLs
Policy | Policy Name => Realms, Protected Columns

## VPD vs RAS vs APEX with RAS

Purpose | VPD | RAS | APEX with RAS
---|---|---|---
Session info | `context` | Namespace | `P0` Item
Define Realm | `sys_context()` | `xs_sys_context()` | `v()` or `nv()`
Initialization | logon trigger | Global Callback |  `Post-Authentication Procedure`
Users | DB | RAS + DB must match | RAS User + `APP_USER` must match(*)
Static Roles | DB Roles | DB Roles & App Roles | DB Roles & App Roles
Dynamic Roles | n/a | Dynamic App Roles | Dynamic App Roles

(*) RAS Allows undefined External Users (possibly LDAP users too)

Within APEX, Dynamic Application Roles are enabled within the `RAS Mode` settings (for all ?authenticated? APEX Sessions) or dynamically within the `Post-Authentication Procedure`.

## Post-Authentication Process

This is the algorithm used within the `Post-Authentication Process` for this repository.

1. Adjust value for `app_user`
1. Set `P0` Item values
1. Create & Update of Namespaces (untested)
1. Enablement of Dynamic Application Roles

## Global Callbacks Events

This is a list of Global Callback Events and when they are activated with respect to APEX.  The `2/3` column indicates if the procedure expects two parameters or three (ie with `username`).  Only the correct version will be called at the time of the Callback event.

Global Callback | 2/3 | When called
---|---|---
`direct_login_event` | 3 | direct users login (eg SQL*Plus)
`guest_to_user_event` | 3 |APEX Login for RAS Internal; called after `Post-Authentication Procedure`
tbd | - | APEX Login for RAS External - Not yet tested
`attach_session_event` | 2? | APEX DB Call - Similar to `DB Session Initiallization`
`detach_session_event` | 2? |APEX DB Call - Similar to `DB Session Cleanup`
`direct_logout_event` | 2? | direct users logout (eg SQL*Plus)
`terminate_session_event` | 2? | APEX Logout (delayed; most likely Scheduled job)
`create_session_event` | 2? | When APEX Starts (creates a pool of RAS Sessions)
`enable_role_event` | - |(untested) Unkown - Regular Application Roles
`disable_role_event` | - | (untested) Unknown - Regular Application Roles
`enable_dynamic_role_event` | - | (untested) `Post-Authentication Procedure` - Dynamic Application Roles
`disable_dynamic_role_event` | - |(untested) not used in APEX (no API provided)
`proxy_to_user_event` | - | not used in APEX
`revert_to_user_event` | - | not used in APEX
`create_namespace_event` | N/A | Documentation Misinformation

## Things to know

 Catagory | Description
---|---
 General | RAS adds a layer of "deny,allow" rules for RLS and Column Security on top of classic DB privileges
ℹGeneral | RAS adds a Virtual Session on top of a DB Session but before the application(eg APEX) session.  The application attaches/detaches the Virtual Session to the DB Session that is grabbed from a pool of DB Sessions
 RAS | You can `grant` up (DB to RAS) but not down (RAS to DB)
 RAS | ACE Principals prefer Roles over Users
 RAS | ACE Principal can be a DB Role; including DB Roles used for CBAC
 RAS | Privilege available is an intersection of: `DB Privilege ∩ ACL Privilege ∩ Security Class`
 RAS | Initialize a RAS Session (Direct Login) via Global Callback
 APEX | Initialize the RAS Session via `Post-Authentication Procedure`
 APEX | Ensure RAS is enabled for the Instance
 APEX | For dynamic roles, ensure they are enable for the Application `Security Attributes -> Authorization -> Source`
 APEX | `RAS Mode -> Enable Internal` requires a RAS User whose name matches USER_ID
 APEX | you can adjust the `USER_ID` in the `Post-Authentication Procedure` with `apex_custom_auth.set_user()`

## List of Bugs

### Legend

Flag | Description
---|---
❗ | Security Flaw (requires CPU to avoid)
⚠️ | Can make APEX unusable
🐜 | Bug or suspected Bug
📖 | Documentation missinformation

### Bugs

Flag | Catagory | bug id | Description
---|---|---|---
❗ | CBAC+RAS | CVE-2023-21829 | ACL privileges granted to code (CBAC) is not revoked on exit of code. patch is available in the CPU released on 17-Jan-2023. (19c, 21c)
⚠️ | APEX | - | A hiccup can occur in APEX if a RAS Session can not be completely created
⚠️ | APEX | - | `RAS Mode -> Enable External` requires at least 1 enabled dynamic role (possible 🐜)
🐜 | OCI | - | the view dba_xs_privilege_grants is incorrect (possibly OCI specific)
🐜 | RAS | - | Data Dictionary View for Global Callbacks is missing (not just undocumented)
🐜 | CBAC | - | A code's granted role (CBAC) can be lost on `create or replace`
🐜 | RAS | - | make sure your Namespace is UPPER (for non xs$session namespaces) when you call `xs_sys_context`
🐜 | APEX | - | make sure your Role name is UPPER when you call `apex_authorization.enable_dynamic_roles`
🐜 | APEX | - | `apex_authorization.enable_dynamic_roles` does not appear to enable External Roles as per documentation
🐜 | APEX | - | ending of a RAS Session is delayed when you exit an APEX Session.
📖 | Doc | - | List of Events for procedure `dbms_xs_session.add_global_callback` (and related procedures) do not match constants in specification of `dbms_xs_session`

## Other Notes

If you can't login to APEX to due a failed creation of a RAS Session, disable RAS in APEX and login 2x to reset.  The more difficult occasions could require a complete rebuild of DB (Use a Code Repository!)

DB, ACL, Security Class all need to provide the Principal the Privilege in order for Principal to do the job. Start by ensuring the DB Principal has the Privilege then ensure the ACL/ACE has the Privilege.  The validation ensures that the ACL-Security Class is correct.

Many of the `xs$` views are inaccessible by ADMIN on ATP Free Tier. This makes the correct version of `dba_xs_privilege_grants` from being used.

You may have to manually "kill the RAS session" in logout procedure of the Authentication Scheme




