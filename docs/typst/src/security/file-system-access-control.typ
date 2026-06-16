#import "/lib/trino-docs.typ": *

#anchor("doc-security-file-system-access-control")
= File-based access control

To secure access to data in your cluster, you can implement file-based access control where access to data and operations is defined by rules declared in manually-configured JSON files.

There are two types of file-based access control:

- #strong[System-level access control] uses the access control plugin with a single JSON file that specifies authorization rules for the whole cluster.
- #strong[Catalog-level access control] uses individual JSON files for each catalog for granular control over the data in that catalog, including column-level authorization.

#anchor("ref-system-file-based-access-control")

== System-level access control files

The access control plugin allows you to specify authorization rules for the cluster in a single JSON file.

=== Configuration

To use the access control plugin, add an #raw("etc/access-control.properties") file containing two required properties: #raw("access-control.name"), which must be set to #raw("file"), and #raw("security.config-file"), which must be set to the location of the config file. The configuration file location can either point to the local disc or to a http endpoint. For example, if a config file named #raw("rules.json") resides in #raw("etc"), add an #raw("etc/access-control.properties") with the following contents:

#code-block("text", "access-control.name=file
security.config-file=etc/rules.json")

If the config should be loaded via the http endpoint #raw("http://trino-test/config") and is wrapped into a JSON object and available via the #raw("data") key #raw("etc/access-control.properties") should look like this:

#code-block("text", "access-control.name=file
security.config-file=http://trino-test/config
security.json-pointer=/data")

The config file is specified in JSON format. It contains rules that define which users have access to which resources. The rules are read from top to bottom and the first matching rule is applied. If no rule matches, access is denied. A JSON pointer \(RFC 6901\) can be specified using the #raw("security.json-pointer") property to specify a nested object inside the JSON content containing the rules. Per default, the file is assumed to contain a single object defining the rules rendering the specification of #raw("security.json-pointer") unnecessary in that case.

=== Refresh

By default, when a change is made to the JSON rules file, Trino must be restarted to load the changes. There is an optional property to refresh the properties without requiring a Trino restart. The refresh period is specified in the #raw("etc/access-control.properties"):

#code-block("text", "security.refresh-period=1s")

=== Catalog, schema, and table access

Access to catalogs, schemas, tables, and views is controlled by the catalog, schema, and table rules. The catalog rules are coarse-grained rules used to restrict all access or write access to catalogs. They do not explicitly grant any specific schema or table permissions. The table and schema rules are used to specify who can create, drop, alter, select, insert, delete, etc. for schemas and tables.

For each rule set, permission is based on the first matching rule, read from the top to the bottom of the configuration file. If no rule matches, access is denied.

If no rules are provided at all, then access is granted. You can remove access grant by adding a section with an empty set of rules at that particular level, for example:

#code-block("json", "{
  \"schemas\": []
}")

At the catalog level you have to add a single "dummy" rule for each accessible catalog.

#note[
These rules do not apply to system-defined tables in the #raw("information_schema") schema.
]

The following table summarizes the permissions required for each SQL command:

#list-table((
  ([SQL command], [Catalog], [Schema], [Table], [Note],),
  ([SHOW CATALOGS], [], [], [], [Always allowed],),
  ([SHOW SCHEMAS], [read-only], [any\*], [any\*], [Allowed if catalog is #link(label("ref-system-file-auth-visibility"))[visible]],),
  ([SHOW TABLES], [read-only], [any\*], [any\*], [Allowed if schema #link(label("ref-system-file-auth-visibility"))[visible]],),
  ([CREATE SCHEMA], [read-only], [owner], [], [],),
  ([DROP SCHEMA], [all], [owner], [], [],),
  ([SHOW CREATE SCHEMA], [all], [owner], [], [],),
  ([ALTER SCHEMA ... RENAME TO], [all], [owner\*], [], [Ownership is required on both old and new schemas],),
  ([ALTER SCHEMA ... SET AUTHORIZATION], [all], [owner], [], [],),
  ([CREATE TABLE], [all], [], [owner], [],),
  ([DROP TABLE], [all], [], [owner], [],),
  ([ALTER TABLE ... RENAME TO], [all], [], [owner\*], [Ownership is required on both old and new tables],),
  ([ALTER TABLE ... SET PROPERTIES], [all], [], [owner], [],),
  ([CREATE VIEW], [all], [], [owner], [],),
  ([DROP VIEW], [all], [], [owner], [],),
  ([ALTER VIEW ... RENAME TO], [all], [], [owner\*], [Ownership is required on both old and new views],),
  ([REFRESH MATERIALIZED VIEW], [all], [], [update], [],),
  ([COMMENT ON TABLE], [all], [], [owner], [],),
  ([COMMENT ON COLUMN], [all], [], [owner], [],),
  ([ALTER TABLE ... ADD COLUMN], [all], [], [owner], [],),
  ([ALTER TABLE ... DROP COLUMN], [all], [], [owner], [],),
  ([ALTER TABLE ... RENAME COLUMN], [all], [], [owner], [],),
  ([SHOW COLUMNS], [read-only], [], [any], [],),
  ([SELECT FROM table], [read-only], [], [select], [],),
  ([SELECT FROM view], [read-only], [], [select, grant\_select], [],),
  ([INSERT INTO], [all], [], [insert], [],),
  ([DELETE FROM], [all], [], [delete], [],),
  ([UPDATE], [all], [], [update], [],)
), header-rows: 1)

Permissions required for executing functions:

#list-table((
  ([SQL command], [Catalog], [Function permission], [Note],),
  ([#raw("SELECT function()")], [], [#raw("execute"), #raw("grant_execute*")], [#raw("grant_execute") is required when the function is used in a #raw("SECURITY DEFINER") view.],),
  ([#raw("CREATE FUNCTION")], [#raw("all")], [#raw("ownership")], [Not all connectors support #link(label("ref-udf-catalog"))[Introduction to UDFs].],),
  ([#raw("DROP FUNCTION")], [#raw("all")], [#raw("ownership")], [Not all connectors support #link(label("ref-udf-catalog"))[Introduction to UDFs].],)
), header-rows: 1)

#anchor("ref-system-file-auth-visibility")

==== Visibility

For a catalog, schema, or table to be visible in a #raw("SHOW") command, the user must have at least one permission on the item or any nested item. The nested items do not need to already exist as any potential permission makes the item visible. Specifically:

- #raw("catalog"): Visible if user is the owner of any nested schema, has permissions on any nested table or function, or has permissions to set session properties in the catalog.
- #raw("schema"): Visible if the user is the owner of the schema, or has permissions on any nested table or function.
- #raw("table"): Visible if the user has any permissions on the table.

==== Catalog rules

Each catalog rule is composed of the following fields:

- #raw("user") \(optional\): regex to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regex to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regex to match against group names. Defaults to #raw(".*").
- #raw("catalog") \(optional\): regex to match against catalog name. Defaults to #raw(".*").
- #raw("allow") \(required\): string indicating whether a user has access to the catalog. This value can be #raw("all"), #raw("read-only") or #raw("none"), and defaults to #raw("none"). Setting this value to #raw("read-only") has the same behavior as the #raw("read-only") system access control plugin.

In order for a rule to apply the username must match the regular expression specified in #raw("user") attribute.

For role names, a rule can be applied if at least one of the currently enabled roles matches the #raw("role") regular expression.

For group names, a rule can be applied if at least one group name of this user matches the #raw("group") regular expression.

The #raw("all") value for #raw("allow") means these rules do not restrict access in any way, but the schema and table rules can restrict access.

#note[
By default, all users have access to the #raw("system") catalog. You can override this behavior by adding a rule.

Boolean #raw("true") and #raw("false") are also supported as legacy values for #raw("allow"), to support backwards compatibility.  #raw("true") maps to #raw("all"), and #raw("false") maps to #raw("none").
]

For example, if you want to allow only the role #raw("admin") to access the #raw("mysql") and the #raw("system") catalog, allow users from the #raw("finance") and #raw("human_resources") groups access to #raw("postgres") catalog, allow all users to access the #raw("hive") catalog, and deny all other access, you can use the following rules:

#code-block("json", "{
  \"catalogs\": [
    {
      \"role\": \"admin\",
      \"catalog\": \"(mysql|system)\",
      \"allow\": \"all\"
    },
    {
      \"group\": \"finance|human_resources\",
      \"catalog\": \"postgres\",
      \"allow\": true
    },
    {
      \"catalog\": \"hive\",
      \"allow\": \"all\"
    },
    {
      \"user\": \"alice\",
      \"catalog\": \"postgresql\",
      \"allow\": \"read-only\"
    },
    {
      \"catalog\": \"system\",
      \"allow\": \"none\"
    }
  ]
}")

For group-based rules to match, users need to be assigned to groups by a #link(label("doc-develop-group-provider"))[Group provider].

==== Schema rules

Each schema rule is composed of the following fields:

- #raw("user") \(optional\): regex to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regex to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regex to match against group names. Defaults to #raw(".*").
- #raw("catalog") \(optional\): regex to match against catalog name. Defaults to #raw(".*").
- #raw("schema") \(optional\): regex to match against schema name. Defaults to #raw(".*").
- #raw("owner") \(required\): boolean indicating whether the user is to be considered an owner of the schema. Defaults to #raw("false").

For example, to provide ownership of all schemas to role #raw("admin"), treat all users as owners of the #raw("default.default") schema and prevent user #raw("guest") from ownership of any schema, you can use the following rules:

#code-block("json", "{
  \"schemas\": [
    {
      \"role\": \"admin\",
      \"schema\": \".*\",
      \"owner\": true
    },
    {
      \"user\": \"guest\",
      \"owner\": false
    },
    {
      \"catalog\": \"default\",
      \"schema\": \"default\",
      \"owner\": true
    }
  ]
}")

==== Table rules

Each table rule is composed of the following fields:

- #raw("user") \(optional\): regex to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regex to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regex to match against group names. Defaults to #raw(".*").
- #raw("catalog") \(optional\): regex to match against catalog name. Defaults to #raw(".*").
- #raw("schema") \(optional\): regex to match against schema name. Defaults to #raw(".*").
- #raw("table") \(optional\): regex to match against table names. Defaults to #raw(".*").
- #raw("privileges") \(required\): zero or more of #raw("SELECT"), #raw("INSERT"), #raw("DELETE"), #raw("UPDATE"), #raw("OWNERSHIP"), #raw("GRANT_SELECT")
- #raw("columns") \(optional\): list of column constraints.
- #raw("filter") \(optional\): boolean filter expression for the table.
- #raw("filter_environment") \(optional\): environment use during filter evaluation.

==== Column constraint

These constraints can be used to restrict access to column data.

- #raw("name"): name of the column.
- #raw("allow") \(optional\): if false, column can not be accessed.
- #raw("mask") \(optional\): mask expression applied to column.
- #raw("mask_environment") \(optional\): environment use during mask evaluation.

==== Filter and mask environment

- #raw("user") \(optional\): username for checking permission of subqueries in mask.

#note[
These rules do not apply to #raw("information_schema").

#raw("mask") can contain conditional expressions such as #raw("IF") or #raw("CASE"), which achieves conditional masking.
]

The example below defines the following table access policy:

- Role #raw("admin") has all privileges across all tables and schemas
- User #raw("banned_user") has no privileges
- All users have #raw("SELECT") privileges on #raw("default.hr.employees"), but the table is filtered to only the row for the current user.
- All users have #raw("SELECT") privileges on all tables in the #raw("default.default") schema, except for the #raw("address") column which is blocked, and #raw("ssn") which is masked.

#code-block("json", "{
  \"tables\": [
    {
      \"role\": \"admin\",
      \"privileges\": [\"SELECT\", \"INSERT\", \"DELETE\", \"UPDATE\", \"OWNERSHIP\"]
    },
    {
      \"user\": \"banned_user\",
      \"privileges\": []
    },
    {
      \"catalog\": \"default\",
      \"schema\": \"hr\",
      \"table\": \"employee\",
      \"privileges\": [\"SELECT\"],
      \"filter\": \"user = current_user\",
      \"filter_environment\": {
        \"user\": \"system_user\"
      }
    },
    {
      \"catalog\": \"default\",
      \"schema\": \"default\",
      \"table\": \".*\",
      \"privileges\": [\"SELECT\"],
      \"columns\" : [
         {
            \"name\": \"address\",
            \"allow\": false
         },
         {
            \"name\": \"SSN\",
            \"mask\": \"'XXX-XX-' + substring(credit_card, -4)\",
            \"mask_environment\": {
              \"user\": \"system_user\"
            }
         }
      ]
    }
  ]
}")

#anchor("ref-system-file-function-rules")

==== Function rules

These rules control the ability of a user to create, drop, and execute functions.

When these rules are present, the authorization is based on the first matching rule, processed from top to bottom. If no rules match, the authorization is denied. If function rules are not present, only functions in#raw("system.builtin") can be executed.

#note[
Users always have access to functions in the #raw("system.builtin") schema, and you cannot override this behavior by adding a rule.
]

Each function rule is composed of the following fields:

- #raw("user") \(optional\): regular expression to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regular expression to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regular expression to match against group names. Defaults to #raw(".*").
- #raw("catalog") \(optional\): regular expression to match against catalog name. Defaults to #raw(".*").
- #raw("schema") \(optional\): regular expression to match against schema name. Defaults to #raw(".*").
- #raw("function") \(optional\): regular expression to match against function names. Defaults to #raw(".*").
- #raw("privileges") \(required\): zero or more of #raw("EXECUTE"), #raw("GRANT_EXECUTE"), #raw("OWNERSHIP").

Care should be taken when granting permission to the #raw("system") schema of a catalog, as this is the schema Trino uses for table function such as #raw("query"). These table functions can be used to access or modify the underlying data of the catalog.

The following example allows the #raw("admin") user to execute #raw("system.query") table function in any catalog, and allows all users to create, drop, and execute functions \(including #raw("SECURITY DEFINER") views\) in the #raw("hive.function") schema:

#code-block("json", "{
  \"functions\": [
    {
      \"user\": \"admin\",
      \"schema\": \"system\",
      \"function\": \"query\",
      \"privileges\": [
        \"EXECUTE\"
      ]
    },
    {
      \"catalog\": \"hive\",
      \"schema\": \"function\",
      \"privileges\": [
        \"EXECUTE\", \"GRANT_EXECUTE\", \"OWNERSHIP\"
      ]
    }
  ]
}")

#anchor("ref-system-file-procedure-rules")

==== Procedure rules

These rules control the ability of a user to execute procedures using the #link(label("doc-sql-call"))[CALL] statement.

Procedures are used for administrative operations on a specific catalog, such as registering external tables or flushing the connector's cache. Available procedures are detailed in the connector documentation pages.

When procedure rules are present, the authorization is based on the first matching rule, processed from top to bottom. If no rules match, the authorization is denied. If procedure rules are not present, only procedures in #raw("system.builtin") can be executed.

Each procedure rule is composed of the following fields:

- #raw("user") \(optional\): regular expression to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regular expression to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regular expression to match against group names. Defaults to #raw(".*").
- #raw("catalog") \(optional\): regular expression to match against catalog name. Defaults to #raw(".*").
- #raw("schema") \(optional\): regular expression to match against schema name. Defaults to #raw(".*").
- #raw("procedure") \(optional\): regular expression to match against procedure names. Defaults to #raw(".*").
- #raw("privileges") \(required\): zero or more of #raw("EXECUTE"), #raw("GRANT_EXECUTE").

The following example allows the #raw("admin") user to execute and grant execution rights to call #raw("register_table") and #raw("unregister_table") in the #raw("system") schema of a catalog called  #raw("delta"), that uses the #link(label("doc-connector-delta-lake"))[Delta Lake connector]. It allows all users to execute the #raw("delta.sytem.vacuum") procedure.

#code-block("json", "{
  \"procedures\": [
    {
      \"user\": \"admin\",
      \"catalog\": \"delta\",
      \"schema\": \"system\",
      \"procedure\": \"register_table|unregister_table\",
      \"privileges\": [
        \"EXECUTE\",
        \"GRANT_EXECUTE\"
      ]
    },
    {
      \"catalog\": \"delta\",
      \"schema\": \"system\",
      \"procedure\": \"vacuum\",
      \"privileges\": [
        \"EXECUTE\"
      ]
    }
  ]
}")

#anchor("ref-system-file-table-procedure-rules")

==== Table procedure rules

Table procedures are executed using the #link(label("ref-alter-table-execute"))[ALTER TABLE ... EXECUTE] syntax.

File-based access control does not support privileges for table procedures and therefore all are effectively allowed.

#anchor("ref-verify-rules")

==== Verify configuration

To verify the system-access control file is configured properly, set the rules to completely block access to all users of the system:

#code-block("json", "{
  \"catalogs\": [
    {
      \"catalog\": \"system\",
      \"allow\": \"none\"
    }
  ]
}")

Restart your cluster to activate the rules for your cluster. With the Trino #link(label("doc-client-cli"))[CLI] run a query to test authorization:

#code-block("text", "trino> SELECT * FROM system.runtime.nodes;
Query 20200824_183358_00000_c62aw failed: Access Denied: Cannot access catalog system")

Remove these rules and restart the Trino cluster.

#anchor("ref-system-file-auth-session-property")

=== Session property rules

These rules control the ability of a user to set system and catalog session properties. The user is granted or denied access, based on the first matching rule, read from top to bottom. If no rules are specified, all users are allowed set any session property. If no rule matches, setting the session property is denied. System session property rules are composed of the following fields:

- #raw("user") \(optional\): regex to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regex to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regex to match against group names. Defaults to #raw(".*").
- #raw("property") \(optional\): regex to match against the property name. Defaults to #raw(".*").
- #raw("allow") \(required\): boolean indicating if the setting the session property should be allowed.

The catalog session property rules have the additional field:

- #raw("catalog") \(optional\): regex to match against catalog name. Defaults to #raw(".*").

The example below defines the following table access policy:

- Role #raw("admin") can set all session property
- User #raw("banned_user") can not set any session properties
- All users can set the #raw("resource_overcommit") system session property, and the #raw("bucket_execution_enabled") session property in the #raw("hive") catalog.

#code-block("json", "{
    \"system_session_properties\": [
        {
            \"role\": \"admin\",
            \"allow\": true
        },
        {
            \"user\": \"banned_user\",
            \"allow\": false
        },
        {
            \"property\": \"resource_overcommit\",
            \"allow\": true
        }
    ],
    \"catalog_session_properties\": [
        {
            \"role\": \"admin\",
            \"allow\": true
        },
        {
            \"user\": \"banned_user\",
            \"allow\": false
        },
        {
            \"catalog\": \"hive\",
            \"property\": \"bucket_execution_enabled\",
            \"allow\": true
        }
    ]
}")

#anchor("ref-query-rules")

=== Query rules

These rules control the ability of a user to execute, view, or kill a query. The user is granted or denied access, based on the first matching rule read from top to bottom. If no rules are specified, all users are allowed to execute queries, and to view or kill queries owned by any user. If no rule matches, query management is denied. Each rule is composed of the following fields:

- #raw("user") \(optional\): regex to match against username. Defaults to #raw(".*").
- #raw("role") \(optional\): regex to match against role names. Defaults to #raw(".*").
- #raw("group") \(optional\): regex to match against group names. Defaults to #raw(".*").
- #raw("queryOwner") \(optional\): regex to match against the query owner name. Defaults to #raw(".*").
- #raw("allow") \(required\): set of query permissions granted to user. Values: #raw("execute"), #raw("view"), #raw("kill")

#note[
Users always have permission to view or kill their own queries.

A rule that includes #raw("queryOwner") may not include the #raw("execute") access mode. Queries are only owned by a user once their execution has begun.
]

For example, if you want to allow the role #raw("admin") full query access, allow the user #raw("alice") to execute and kill queries, allow members of the group #raw("contractors") to view queries owned by users #raw("alice") or #raw("dave"), allow any user to execute queries, and deny all other access, you can use the following rules:

#code-block("json", "{
  \"queries\": [
    {
      \"role\": \"admin\",
      \"allow\": [\"execute\", \"kill\", \"view\"]
    },
    {
      \"user\": \"alice\",
      \"allow\": [\"execute\", \"kill\"]
    },
    {
      \"group\": \"contractors\",
      \"queryOwner\": \"alice|dave\",
      \"allow\": [\"view\"]
    },
    {
      \"allow\": [\"execute\"]
    }
  ]
}")

#anchor("ref-system-file-auth-impersonation-rules")

=== Impersonation rules

These rules control the ability of a user to impersonate another user. In some environments it is desirable for an administrator \(or managed system\) to run queries on behalf of other users. In these cases, the administrator authenticates using their credentials, and then submits a query as a different user. When the user context is changed, Trino verifies that the administrator is authorized to run queries as the target user.

When these rules are present, the authorization is based on the first matching rule, processed from top to bottom. If no rules match, the authorization is denied. If impersonation rules are not present but the legacy principal rules are specified, it is assumed impersonation access control is being handled by the principal rules, so impersonation is allowed. If neither impersonation nor principal rules are defined, impersonation is not allowed.

Each impersonation rule is composed of the following fields:

- #raw("original_user") \(optional\): regex to match against the user requesting the impersonation. Defaults to #raw(".*").
- #raw("original_role") \(optional\): regex to match against role names of the requesting impersonation. Defaults to #raw(".*").
- #raw("new_user") \(required\): regex to match against the user to impersonate. Can contain references to subsequences captured during the match against #emph[original\_user], and each reference is replaced by the result of evaluating the corresponding group respectively.
- #raw("allow") \(optional\): boolean indicating if the authentication should be allowed. Defaults to #raw("true").

The impersonation rules are a bit different from the other rules: The attribute #raw("new_user") is required to not accidentally prevent more access than intended. Doing so it was possible to make the attribute #raw("allow") optional.

The following example allows the #raw("admin") role, to impersonate any user, except for #raw("bob"). It also allows any user to impersonate the #raw("test") user. It also allows a user in the form #raw("team_backend") to impersonate the #raw("team_backend_sandbox") user, but not arbitrary users:

#code-block("json", "{
    \"impersonation\": [
        {
            \"original_role\": \"admin\",
            \"new_user\": \"bob\",
            \"allow\": false
        },
        {
            \"original_role\": \"admin\",
            \"new_user\": \".*\"
        },
        {
            \"original_user\": \".*\",
            \"new_user\": \"test\"
        },
        {
            \"original_user\": \"team_(.*)\",
            \"new_user\": \"team_$1_sandbox\",
            \"allow\": true
        }
    ]
}")

#anchor("ref-system-file-auth-principal-rules")

=== Principal rules

#warning[
Principal rules are deprecated. Instead, use #link(label("doc-security-user-mapping"))[User mapping] which specifies how a complex authentication username is mapped to a simple username for Trino, and impersonation rules defined above.
]

These rules serve to enforce a specific matching between a principal and a specified username. The principal is granted authorization as a user, based on the first matching rule read from top to bottom. If no rules are specified, no checks are performed. If no rule matches, user authorization is denied. Each rule is composed of the following fields:

- #raw("principal") \(required\): regex to match and group against principal.
- #raw("user") \(optional\): regex to match against username. If matched, it grants or denies the authorization based on the value of #raw("allow").
- #raw("principal_to_user") \(optional\): replacement string to substitute against principal. If the result of the substitution is same as the username, it grants or denies the authorization based on the value of #raw("allow").
- #raw("allow") \(required\): boolean indicating whether a principal can be authorized as a user.

#note[
You would at least specify one criterion in a principal rule. If you specify both criteria in a principal rule, it returns the desired conclusion when either of criteria is satisfied.
]

The following implements an exact matching of the full principal name for LDAP and Kerberos authentication:

#code-block("json", "{
  \"principals\": [
    {
      \"principal\": \"(.*)\",
      \"principal_to_user\": \"$1\",
      \"allow\": true
    },
    {
      \"principal\": \"([^/]+)(/.*)?@.*\",
      \"principal_to_user\": \"$1\",
      \"allow\": true
    }
  ]
}")

If you want to allow users to use the exact same name as their Kerberos principal name, and allow #raw("alice") and #raw("bob") to use a group principal named as #raw("group@example.net"), you can use the following rules.

#code-block("json", "{
  \"principals\": [
    {
      \"principal\": \"([^/]+)/?.*@example.net\",
      \"principal_to_user\": \"$1\",
      \"allow\": true
    },
    {
      \"principal\": \"group@example.net\",
      \"user\": \"alice|bob\",
      \"allow\": true
    }
  ]
}")

#anchor("ref-system-file-auth-system-information")

=== System information rules

These rules specify which users can access the system information management interface. System information access includes the following aspects:

- Read access to sensitive information from REST endpoints, such as #raw("/v1/node") and #raw("/v1/thread").
- Read access with the #link(label("doc-functions-system"))[system information functions].
- Read access with the #link(label("doc-connector-system"))[System connector].
- Write access to trigger #link(label("doc-admin-graceful-shutdown"))[Graceful shutdown].

The following REST endpoints are always public and not affected by these rules:

- #raw("GET /v1/info")
- #raw("GET /v1/info/state")
- #raw("GET /v1/status")

The user is granted or denied access based on the first matching rule read from top to bottom. If no rules are specified, all access to system information is denied. If no rule matches, system access is denied. Each rule is composed of the following fields:

- #raw("role") \(optional\): regex to match against role. If matched, it grants or denies the authorization based on the value of #raw("allow").
- #raw("user") \(optional\): regex to match against username. If matched, it grants or denies the authorization based on the value of #raw("allow").
- #raw("allow") \(required\): set of access permissions granted to user. Values: #raw("read"), #raw("write")

The following configuration provides and example:

#code-block("json", "{
  \"system_information\": [
    {
      \"role\": \"admin\",
      \"allow\": [\"read\", \"write\"]
    },
    {
      \"user\": \"alice\",
      \"allow\": [\"read\"]
    }
  ]
}")

- All users with the #raw("admin") role have read and write access to system information. This includes the ability to trigger #link(label("doc-admin-graceful-shutdown"))[Graceful shutdown].
- The user #raw("alice") can read system information.
- All other users and roles are denied access to system information.

A fixed user can be set for management interfaces using the #raw("management.user") configuration property.  When this is configured, system information rules must still be set to authorize this user to read or write to management information. The fixed management user only applies to HTTP by default. To enable the fixed user over HTTPS, set the #raw("management.user.https-enabled") configuration property.

#anchor("ref-system-file-auth-authorization")

=== Authorization rules

These rules control the ability of how owner of schema, table or view can be altered. These rules are applicable to commands like:

#code-block("sql", "ALTER SCHEMA name SET AUTHORIZATION ( user | USER user | ROLE role )
ALTER TABLE name SET AUTHORIZATION ( user | USER user | ROLE role )
ALTER VIEW name SET AUTHORIZATION ( user | USER user | ROLE role )")

When these rules are present, the authorization is based on the first matching rule, processed from top to bottom. If no rules match, the authorization is denied.

Notice that in order to execute #raw("ALTER") command on schema, table or view user requires #raw("OWNERSHIP") privilege.

Each authorization rule is composed of the following fields:

- #raw("original_user") \(optional\): regex to match against the user requesting the authorization. Defaults to #raw(".*").
- #raw("original_group") \(optional\): regex to match against group names of the requesting authorization. Defaults to #raw(".*").
- #raw("original_role") \(optional\): regex to match against role names of the requesting authorization. Defaults to #raw(".*").
- #raw("new_user") \(optional\): regex to match against the new owner user of the schema, table or view. By default it does not match.
- #raw("new_role") \(optional\): regex to match against the new owner role of the schema, table or view. By default it does not match.
- #raw("allow") \(optional\): boolean indicating if the authentication should be allowed. Defaults to #raw("true").

Notice that #raw("new_user") and #raw("new_role") are optional, however it is required to provide at least one of them.

The following example allows the #raw("admin") role, to change owner of any schema, table or view to any user, except to\`\`bob\`\`.

#code-block("json", "{
  \"authorization\": [
    {
      \"original_role\": \"admin\",
      \"new_user\": \"bob\",
      \"allow\": false
    },
    {
      \"original_role\": \"admin\",
      \"new_user\": \".*\",
      \"new_role\": \".*\"
    }
  ],
  \"schemas\": [
    {
      \"role\": \"admin\",
      \"owner\": true
    }
  ],
  \"tables\": [
    {
      \"role\": \"admin\",
      \"privileges\": [\"OWNERSHIP\"]
    }
  ]
}")

#anchor("ref-catalog-file-based-access-control")

== Catalog-level access control files

You can create JSON files for individual catalogs that define authorization rules specific to that catalog. To enable catalog-level access control files, add a connector-specific catalog configuration property that sets the authorization type to #raw("FILE") and the #raw("security.config-file") catalog configuration property that specifies the JSON rules file.

For example, the following Iceberg catalog configuration properties use the #raw("rules.json") file for catalog-level access control:

#code-block("properties", "iceberg.security=FILE
security.config-file=etc/catalog/rules.json")

Catalog-level access control files are supported on a per-connector basis, refer to the connector documentation for more information.

#note[
These rules do not apply to system-defined tables in the #raw("information_schema") schema.
]

=== Configure a catalog rules file

The configuration file is specified in JSON format. This file is composed of the following sections, each of which is a list of rules that are processed in order from top to bottom:

+ #raw("schemas")
+ #raw("tables")
+ #raw("session_properties")

The user is granted the privileges from the first matching rule. All regexes default to #raw(".*") if not specified.

==== Schema rules

These rules govern who is considered an owner of a schema.

- #raw("user") \(optional\): regex to match against username.
- #raw("group") \(optional\): regex to match against every user group the user belongs to.
- #raw("schema") \(optional\): regex to match against schema name.
- #raw("owner") \(required\): boolean indicating ownership.

==== Table rules

These rules govern the privileges granted on specific tables.

- #raw("user") \(optional\): regex to match against username.
- #raw("group") \(optional\): regex to match against every user group the user belongs to.
- #raw("schema") \(optional\): regex to match against schema name.
- #raw("table") \(optional\): regex to match against table name.
- #raw("privileges") \(required\): zero or more of #raw("SELECT"), #raw("INSERT"), #raw("DELETE"), #raw("UPDATE"), #raw("OWNERSHIP"), #raw("GRANT_SELECT").
- #raw("columns") \(optional\): list of column constraints.
- #raw("filter") \(optional\): boolean filter expression for the table.
- #raw("filter_environment") \(optional\): environment used during filter evaluation.

===== Column constraints

These constraints can be used to restrict access to column data.

- #raw("name"): name of the column.
- #raw("allow") \(optional\): if false, column can not be accessed.
- #raw("mask") \(optional\): mask expression applied to column.
- #raw("mask_environment") \(optional\): environment use during mask evaluation.

===== Filter environment and mask environment

These rules apply to #raw("filter_environment") and #raw("mask_environment").

- #raw("user") \(optional\): username for checking permission of subqueries in a mask.

#note[
#raw("mask") can contain conditional expressions such as #raw("IF") or #raw("CASE"), which achieves conditional masking.
]

==== Function rules

These rules control the ability of a user to create, drop, and execute functions.

When these rules are present, the authorization is based on the first matching rule, processed from top to bottom. If no rules match, the authorization is denied. If function rules are not present, access is not allowed.

- #raw("user") \(optional\): regular expression to match against username. Defaults to #raw(".*").
- #raw("group") \(optional\): regular expression to match against group names. Defaults to #raw(".*").
- #raw("schema") \(optional\): regular expression to match against schema name. Defaults to #raw(".*").
- #raw("function") \(optional\): regular expression to match against function names. Defaults to #raw(".*").
- #raw("privileges") \(required\): zero or more of #raw("EXECUTE"), #raw("GRANT_EXECUTE"), #raw("OWNERSHIP").

Care should be taken when granting permission to the #raw("system") schema of a catalog, as this is the schema Trino uses for table function such as #raw("query"). These table functions can be used to access or modify the underlying data of the catalog.

The following example allows the #raw("admin") user to execute #raw("system.query") table function from this catalog, and all users to create, drop, and execute functions \(including from views\) in the #raw("function") schema of this catalog:

#code-block("json", "{
  \"functions\": [
    {
      \"user\": \"admin\",
      \"schema\": \"system\",
      \"function\": \"query\",
      \"privileges\": [
        \"EXECUTE\"
      ]
    },
    {
      \"schema\": \"function\",
      \"privileges\": [
        \"EXECUTE\", \"GRANT_EXECUTE\", \"OWNERSHIP\"
      ]
    }
  ]
}")

==== Session property rules

These rules govern who may set session properties.

- #raw("user") \(optional\): regex to match against username.
- #raw("group") \(optional\): regex to match against every user group the user belongs to.
- #raw("property") \(optional\): regex to match against session property name.
- #raw("allow") \(required\): boolean indicating whether this session property may be set.

=== Example

#code-block("json", "{
  \"schemas\": [
    {
      \"user\": \"admin\",
      \"schema\": \".*\",
      \"owner\": true
    },
    {
      \"group\": \"finance|human_resources\",
      \"schema\": \"employees\",
      \"owner\": true
    },
    {
      \"user\": \"guest\",
      \"owner\": false
    },
    {
      \"schema\": \"default\",
      \"owner\": true
    }
  ],
  \"tables\": [
    {
      \"user\": \"admin\",
      \"privileges\": [\"SELECT\", \"INSERT\", \"DELETE\", \"UPDATE\", \"OWNERSHIP\"]
    },
    {
      \"user\": \"banned_user\",
      \"privileges\": []
    },
    {
      \"schema\": \"hr\",
      \"table\": \"employee\",
      \"privileges\": [\"SELECT\"],
      \"filter\": \"user = current_user\"
    },
    {
      \"schema\": \"default\",
      \"table\": \".*\",
      \"privileges\": [\"SELECT\"],
      \"columns\" : [
         {
            \"name\": \"address\",
            \"allow\": false
         },
         {
            \"name\": \"ssn\",
            \"mask\": \"'XXX-XX-' + substring(credit_card, -4)\",
            \"mask_environment\": {
              \"user\": \"admin\"
            }
         }
      ]
    }
  ],
  \"session_properties\": [
    {
      \"property\": \"force_local_scheduling\",
      \"allow\": true
    },
    {
      \"user\": \"admin\",
      \"property\": \"max_split_size\",
      \"allow\": true
    }
  ]
}")
