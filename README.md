APEX-RAS Examples for Cloud
===

These examples were tested on Oracle Cloud (OCI) ATP Free Tier 21c.

Some of the examples invoke CVE-2023-21829. The patch for this bug was made available in a CPU that was released on 17-January-2023 for the 19c and 21c versions of the Oracle Database.

Comments in the example will note other known bugs within Oracle.

# Available Demos

Each folder goes through one concept within the combined APEX-RAS framework.

Order | Folder | Description
---|---|---
1 | [RAS HR Demo](./RAS%20HR%20Demo/README.md) | RAS HR Demo from the [Oracle documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/dbfsg/real-application-security-hr-demo.html)
2 | [Namespaces](./Namespace/README.md) | Explaination and examples of RAS Namespace
3 | [RAS HR with Namespace](./RAS%20HR%20with%20Namespace/README.md) | Rework of the base RAS HR Demo using Namespaces (& GC)
4 | [Parameterized ACL](./Parameterized%20ACL/README.md) | Base RAS HR Demo using Parametereized ACLs
5 | [Dynamic Roles](./Dynamic%20Roles/README.md) | APEX Application demonstrating the use of RAS External users and dynamic application roles
7 | [External Roles](./External%20Roles/README.md) | RAS HR Demo using External Roles & Namespaces (🐜 prevents usability)
8 | LDAP RAS | (planned) RAS using LDAP DN
9 | LDAP APEX | (planned) RAS+APEX using LDAP DN

# Common APEX Prep Steps

1. ensure RAS is enabaled on the Instance
1. Ensure Dynamic Roles are available for the application
1. Create APEX Users
   - A few examples come with a script for creating them in bulk.

## Enable RAS on Instance

1. Login to the APEX instance Workspace INTERNAL as user ADMIN.  (password is the DB password)
2. browse to `Real Application Security`
3. set `Allow Real Application Security` to `Yes`

## Enable Dynamic Roles (opt)

This step is only needed for using RAS External Roles

1. Login to your Workspace with developer privileges
1. Within your application, click `Shared Components`
1. Under the `Security` section, click on `Security Attributes`
1. Browse to `Authorization` section
1. Set `Source for Role or Group Schemes` to `Authentication Scheme`

## Enable RAS in APP

RAS is enabled in indivual `Authentication Scheme` (Shared Component)

- `Source -> PL/SQL Code` allows for procedure definitions
- `Lodin Processing -> Post-Authentication Procedure Name` is where you set the "RAS Session Initialization

Things to do within Post-Authentication:
- initialize P0 Item values
- create & initialize Namespaces
- modify value for `APP_USER`
- enable/disable Dynamic Roles

## Create APEX Users

The Authentication Scheme defines if RAS is used (or not) and how.

For this demo, an `Oracle APEX Account` scheme is used.  As such, APEX users will need to be created.

(goal: bulk script for all `HR.EMPLOYEES.EMAIL` )
