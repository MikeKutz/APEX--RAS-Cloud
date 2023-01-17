# Namespace Demo

Namespaces are to RAS as Contexts are to VPD.

Using the pair of Namespace and Attribute, you set or retrieve a VARCHAR2 value for the durration of a RAS Session. The function `dbms_xs_session.set_attribute` is to set the value while `xs_sys_context()` is used to get the value.

Unlike a Context, Namespace values are tied to a RAS Session, not the DB Session.
That means: stateless applications (eg APEX) can set the value once and the value will be that way for the user's entire session. Yes, your code can update the value durring a session. But, you don't have to set the value for every call like you do for Contexts.

Namespaces are unconstraid by default and allow anyone to create the Namespaces in their RAS Session & update its attribute. (*note* Namespaces can be created durring a RAS Session from a Namespace Template with `dbms_xs_session.create_namespace()`)

Namespaces can also be constrained to a specific ACL.
This limits the creation and modification of the Namespace to Principals with the specified ACL enabled.

On the extreme end, the system privilege `ADMIN_ANY_NAMESPACE` allows the principal to create and modify a namespace irregardless of ACL tied to it.
Like any other `ANY` privilege, you should limit its grants.

## Privilege Breakdown
The requirement for the Privilege to be a concatination ( and[`&`] ) of privileges still applies.

That is:  `Actual Privilege := DB Privilege & ACL Privilege & Security Class Privilege`

- `PUBLIC` already has the required DB Privileges to make and modify Namespaces
- The ACL should have `MODIFY_NAMESPACE` (to create the namespace) and `MODIFY_ATTRIBUTE` (to update its values).
- Both are required to be part of a Security Class that has `sys.nstemplate_sc` as a parent.

## Integration Notes
Initialize in
- Post Authentication Procedure
- `guest_to_user_event` for APEX (RAS Mode = Internal)
- `direct_login_event` for direct login users

## Scripts Description
The scripts have been tested on 21c ATP Free Tier.

Script | Run As | Constrained? | Description
---|---|---|---
`01-admin...` | ADMIN | unconstrained | creates users HR and DAUSTIN and grants appropriate privileges
`02-hr...` | HR | unconstrained | creates Namespace & init procedure
`03-daustin...` | DAUSTIN | unconstrained | demonstrates Namespace usage
`04-admin...` | ADMIN | constrained | creates DB Roles for CBAC use
`05-hr...` | HR | constrained | create Namespace & init procedures & GRANTs
`06-daustin...` | DAUSTIN | constrained | demonstrates Namespace usage and "illegal access"
`07-hr...` | HR | both | cleanup all HR generated objects

## Developer Notes
- ⚠️ The constrained Namespace demo hits the S1607572 security bug. Patch your DB with CPU from 17-Jan-2023
- ⚠️ Make sure you don't try to create a Namespace that already exists. Bad things can happen with APEX.
- ⚠️ I have not yet found the Data Dictionary View for Global Callbacks.
- 🐜 Make sure your Namespace is `UPPER()` (for non "xs$session" Namespaces) when you call `xs_sys_context()`
- 🐜 A code's granted role (CBAC) can be lost on `create or replace`. Reapply `grant` when developing.
- 📖 List of Events for procedure `dbms_xs_session.add_global_callback` (and related procedures) do not match constants in the specification for `dbms_xs_session`


