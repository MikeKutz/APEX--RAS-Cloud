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

