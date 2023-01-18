APEX-RAS Examples for Cloud
===

These examples were tested on Oracle Cloud (OCI) ATP Free Tier 21c.

Some examples invoke CVE-2023-21829. The patch for this bug was made available in a CPU that was released on 17-January-2023 for the 19c and 21c versions of the Oracle Database.

Each folder goes through one concept within the combined APEX-RAS framework.

Order | Folder | Description
---|---|---
1 | [RAS HR Demo](./RAS HR Demo/README.md) | RAS HR Demo from the [Oracle documentation](https://docs.oracle.com/en/database/oracle/oracle-database/21/dbfsg/real-application-security-hr-demo.html)
2 | Namespaces | Explaination and examples of RAS Namespace
3 | RAS HR with Namespace | Rework of the base RAS HR Demo using Namespaces
4 | External Users | Simplified APEX demo using External RAS Users
5 | Parameterized ACL | Base RAS HR Demo using Parametereized ACLs
6 | External Roles | RAS HR Demo using External Roles & Namespaces (🐜 prevents usability)

# Common APEX Prep Steps

1. ensure RAS is enabaled on the Instance
1. Ensure Dynamic Roles are available for the application
1. Create APEX Users
   - A few examples come with a script for creating them in bulk.

