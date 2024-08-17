# utPLSQL RAS

Add-on for utPLSQL to support RAS Session

# code

name | obj | desc
----|----|----
ut_ras_utils | package | constants, one-offs, etc
ut_ras_sessions | type | Hash of name -> info
ut_ras_events | type | (attempted) plugin-in for events

# Tags

tag | Suite | Exec | max | params | desc
----|----|----|----|----|----
RASUser | Y | Y | 1 | username[:uid] | A RAS Session for this user will be used (internal)
RASExeternalUser | Y | Y | 1 | username[:uid] | A RAS Session for this user will be used (external)
RASRole | Y | Y | * | role_name[, rolename ... ] | Dyanmic Role(s) to be enabled (internal)
RASExternalRole | Y | Y | * | role_name[, rolename ... ] | Dyanmic Role(s) to be enabled (internal)
RASDisableRole | N | Y | * | role_name[, rolename ... ] | Dyanmic Role(s) to be disabled
RASNamespace | Y | ? | * | namespace[, namespace ... ] | Add Namespace to session
RASNone | N | Y | 1 | none | Disables use of RAS for a procedure mutually exclusiv with RASUser/RASExternalUser

gc_tag_\<tagname>


