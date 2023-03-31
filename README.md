APEX-RAS Examples for Cloud
===

Real Application Security (RAS) Examples for Oracle Cloud Infrastructure (OCI) and a few HOWTO for integrating with Application Express (APEX).

# Introduction

This repository contains a few examples of using Real Application Security (RAS) including the RAS HR Demo as seen in the Oracle Documentation (URL). There also exists a few demos on how to use RAS within the APEX environment. (Most importantly, it notes all the bugs/issues you'll run into as you try it yourself.)

These examples were tested on Oracle Cloud (OCI) ATP Free Tier 21c; 19c should work too.  The code makes use of the `XS_ADMIN_CLOUD_UTIL` package. If you are not using an Autonomous Database, use the version without `_CLOUD` in the name ( `XS_ADMIN_UTIL` )

Some of the examples will invoke CVE-2023-21829. The patch for this bug was made available in the CPU that was released on 17-January-2023 for the 19c and 21c versions of the Oracle Database. (I don't think Free Tier is patched)

Individual `README.md` files (and code comments) will note other known bugs within the Oracle Database. (See List of Bugs section for consolidated list)

# Menu

- Arvailable Demos
- Common APEX Prep Steps
- RAS Basics
- List of Bugs and Headaches

# Available Demos

Each folder goes through one concept within the combined APEX-RAS framework.

Order | Folder | Description
---|---|---
1 | [RAS HR Demo](./RAS%20HR%20Demo/README.md) | RAS HR Demo from the [Oracle documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/dbfsg/real-application-security-hr-demo.html)
2 | [Namespaces](./Namespace/README.md) | Explaination and examples of RAS Namespace
3 | [RAS HR with Namespace](./RAS%20HR%20with%20Namespace/README.md) | Rework of the base RAS HR Demo using Namespaces (& GC)
4 | [Parameterized ACL](./Parameterized%20ACL/README.md) | Base RAS HR Demo using Parametereized ACLs
5 | [Dynamic Roles](./Dynamic%20Roles/README.md) | APEX Application demonstrating the use of RAS External users and dynamic application roles
7 | [External Roles](./External%20Roles/README.md) | RAS HR Demo using External Roles & Namespaces
8 | [Azure AD](./Azure/README.md) | APEX Application demonstrating RAS External Roles defined in Azure


# Common APEX Prep Steps

1. ensure RAS is enabaled on the Instance
1. Ensure Dynamic Roles are available for the application
1. Create APEX Users
   - A few examples come with a script for creating them in bulk.

## Enable RAS on Instance

1. Login to the APEX instance Workspace INTERNAL as user ADMIN.  (password is the DB password)
2. browse to `Real Application Security`
3. set `Allow Real Application Security` to `Yes`

{image}

## Enable Dynamic Roles (opt)

This step is only needed for using RAS External Roles

1. Login to your Workspace with developer privileges
1. Within your application, click `Shared Components`
1. Under the `Security` section, click on `Security Attributes`
1. Browse to `Authorization` section
1. Set `Source for Role or Group Schemes` to `Authentication Scheme`

{image}


## Enable RAS in APP

RAS is enabled in indivual `Authentication Scheme` (Shared Component)

- `Source -> PL/SQL Code` allows for procedure definitions
- `Login Processing -> Post-Authentication Procedure Name` is where you set the "RAS Session Initialization

Things to do within Post-Authentication:
- initialize P0 Item values
- create & initialize Namespaces
- modify value for `APP_USER`
- enable/disable Dynamic Roles

{image}

## Create APEX Users

The Authentication Scheme defines if RAS is used (or not) and how.

For this demo, an `Oracle APEX Account` scheme is used for most of the examples.  As such, APEX users will need to be created.

Primary ones to create
- DAUSTIN
- SMAVRIS
- JDOE - used for testing "those without roles"

(TODO: bulk script for adding/removing all `HR.EMPLOYEES.EMAIL` users)

# RAS Basics

Real Application Security (RAS) adds a layer of security on top of the basic DB `grant` privileges. Like Virtual Private Database (VPD), RAS is used for both Row Level Security (RLS) and Column Masking.

Unlike VPD, RAS uses an additional stateless session (RAS Session) on top of a regular DB Connection.  This allows stateless applications (eg APEX) to manage stateless connections for many active users (without having to run the Initialize and Cleanup code for each DB Call)

With Dynamic Application Roles, the Application defines who gets which Role *at runtime* while the Database only enforces those grants.

Additionally, RAS provides Namespaces variables and Cookies on a per RAS Session basis.  This allows for the Database security rules to be defined in an Application Agnostic way.

## VPD vs RAS vs APEX with RAS

The following is for relating VPD with RAS and describes "shortcuts" that can be used when using building APEX+RAS Only applications.

Purpose | VPD | RAS | APEX with RAS
---|---|---|---
Session info | `context` | Namespace | Application Item
Define Domain | `sys_context()` | `xs_sys_context()` | `v()` or `nv()`
Initialization | logon trigger | Global Callback |  `Post-Authentication Procedure`
Users | DB | RAS + DB must match | RAS User + `APP_USER` must match(*)
Static Roles | DB Roles | DB Roles & App Roles | DB Roles & App Roles
Dynamic Roles | n/a | Dynamic App Roles | Dynamic App Roles

(*) RAS Allows undefined External Users. In this case, `APP_USER` *is* the RAS User

Within APEX, Dynamic Application Roles on the right side are enabled within the `RAS Mode` settings or are enabled within the `Post-Authentication Procedure` via `apex_authorization.enable_group_roles()`.

## RAS Objects

The three primary components within RAS are: Priveleges, Principals (users/roles), and Data Domains. The combined triplette is defined in a Policy and that Policy is applied to one or more Objects (Tables).  But, in order to create a Policy, various other objects need to be created.

Object | Single | Many
---|---|---
ACE | Principal | Privileges
ACL | ACL Name, Security Class | ACEs
Realm | Domain | ACLs
Protected Columns | Custom Privilege | Columns
Policy | Policy Name | Realms, Protected Columns
Security Class | Security Class Name | Parent Sec. Class, Custom Privileges

Some examples build the ACLs first, the Parameterized ACL example builds the Policy first.

## Enforced Privileges

The actual Privileges that a Principal has is the intersection of DB Privileges (`grant`), ACE Privilege, and Security Class Privilege.  If a Privilege is not granted in all of those areas, then that Privilege is not granted.  A common mistake is forgetting to `grant` the appropriate Privilege at the DB level.

`DB Privilege ∩ ACL Privilege ∩ Security Class`

# List of Bugs and Headaches

RAS is not as well refined as one would like it to be.

Here are a few bugs and developer notes that can cause you headaches if you are not careful.

## Developer Notes

- RAS prefers the Privileges to be granted to Roles instead of indivual Users.
- DB, ACL, Security Class all need to provide the Principal the Privilege in order for Principal to do the job. Start by ensuring the DB Principal has the Privilege then ensure the ACL/ACE has the Privilege.  Start at the DB level when debuging RAS RLS problems.
- When using SQL in code, make sure you understand the difference between Invoker's Rights and Definer's Rights.
- SQL Prompt (SQL Plus, SQLcl, SQL Developer, etc.) will have DEFAULT Roles enabled when you directly login.  DBA can `alter user` and make those roles "not default".
- You can use a DB Role as a Principal and then `grant` that role to code (CBAC). It this way, your code will have different Privileges then the user. However, this pattern will invoke CVE-2023-21829. make sure your server is patched first (CPU 17-Jan-2024).
- Beware of which functions require Case Sensitive names and which Case they expect.
- A few Data Dictionary views regarding RAS are either missing or are incorrect. You can hunt for them, but many of the `xs$` views are inaccessible by ADMIN on ATP Free Tier.
- APEX Session:RAS Session are 1:1
- Initialize everything (Roles, Namespaces, `APP_USER`) in the `Post-Authentication Procedure`.
- If you are using External Users, you need to have *at least* one Internal Application Role enabled.
- If you are using Internal Users, the RAS User needs to exist and match `APP_USER`
- You'll need to copy & Modify templates (...) to display a different name then `APP_USER`
- xxx needs to be adjusted to use Dynamic Application Roles
  - Internal Dynamic Application Roles require the setting to be `something`
  - unknown what is required for External Roles (most likely `theLastValue`)
- When creating ACEs whose Principal is a non-Internal RAS Principal, be sure to set the correct `principal_type`.
- APEX delays the termination of a RAS Session vs termination of an APEX session. You may have to manually "kill the RAS session" in logout procedure of the Authentication Scheme.
- Some mistakes can prevent you from loging into APEX.  If you can't login to APEX to due a failed creation of a RAS Session, disable RAS in APEX and login 2x to reset.
- The more difficult problems could require a complete rebuild of DB.
  - Use a Code Repository!
  - Ensure the installation is a easy as possible! (this will allow you to get backup to development as quickly as possible)


## Legend

Flag | Description
---|---
❗ | Security Flaw (requires you to apply CPU)
⚠️ | Can make APEX unusable
🐜 | Bug or suspected Bug
📖 | Documentation missinformation

## Bugs

Flag | Catagory | bug id | Description
---|---|---|---
❗ | CBAC+RAS | CVE-2023-21829 | ACL privileges granted to code (CBAC) is not revoked on exit of code. patch is available in the CPU released on 17-Jan-2023. (19c, 21c). 23c is expected to be patched.
⚠️ | APEX | - | A hiccup can occur in APEX if a RAS Session can not be completely created causing DoS
⚠️ | APEX | - | `RAS Mode -> Enable External` requires at least 1 enabled dynamic role
🐜 | OCI | - | the view `dba_xs_privilege_grants` is incorrect (possibly OCI specific)
🐜 | RAS | - | Data Dictionary View for Global Callbacks is missing (not just undocumented)
🐜 | CBAC | - | A code's granted role (CBAC) can be lost on `create or replace`
🐜 | RAS | - | make sure your Namespace is UPPER (for non xs$session namespaces) when you call `xs_sys_context`
🐜 | APEX | - | make sure your Role name is UPPER when you call `apex_authorization.enable_dynamic_roles`
🐜 | APEX | - | `apex_authorization.enable_dynamic_roles` does not appear to enable External Roles as per documentation (fixed in APEX 22.2.2)
🐜 | APEX | - | When you define an Authorization Schem with "Is In Role or Group", the name needs to be UPPER
🐜 | APEX | - | ending of a RAS Session is delayed when you exit an APEX Session.
📖 | Doc | - | List of Events for procedure `dbms_xs_session.add_global_callback` (and related procedures) do not match constants in the specification of `dbms_xs_session`

