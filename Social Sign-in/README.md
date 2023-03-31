Social Sign-In
===

`v('APP_USER')` shoud be globally unique. The `sub` value is guaranteed to be unique within the provieder.

For that, the "name" parameter is set to `google_#sub#` or related text.

A human readable name is stored as an Application Item.  (map `name` to `DISPLAY_NAME`)

The roles `REGISTERED` and `UNREGISTER` are enabled based on if the user exists in a table. (`ERR_REGISTERED` for `when others`)

Furthur more, these roles are used for redirecting to the appropriate Page: either Home page or the Registration page.

Finally, the Internal Application Role (`JUST_IN_CASE`) is used to ensure "at least 1 role" is always enabled. It serves no other purpose than to ensure that things don't go sidewasy. (This seems to be a requirement for Enable External)
