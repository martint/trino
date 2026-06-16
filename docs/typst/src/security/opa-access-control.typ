#import "/lib/trino-docs.typ": *

#anchor("doc-security-opa-access-control")
= Open Policy Agent access control

The Open Policy Agent access control plugin enables the use of #link("https://www.openpolicyagent.org/")[Open Policy Agent \(OPA\)] as authorization engine for fine-grained access control to catalogs, schemas, tables, and more in Trino. Policies are defined in OPA, and Trino checks access control privileges in OPA.

== Requirements

- A running #link("https://www.openpolicyagent.org/docs/latest/#running-opa")[OPA deployment]
- Network connectivity from the Trino cluster to the OPA server

With the requirements fulfilled, you can proceed to set up Trino and OPA with your desired access control configuration.

== Trino configuration

To use only OPA for access control, create the file #raw("etc/access-control.properties") with the following minimal configuration:

#code-block("properties", "access-control.name=opa
opa.policy.uri=https://opa.example.com/v1/data/trino/allow")

To combine OPA access control with file-based or other access control systems, follow the instructions about #link(label("ref-multiple-access-control"))[System access control].

The following table lists the configuration properties for the OPA access control:

#list-table((
  ([Name], [Description],),
  ([#raw("opa.policy.uri")], [The #strong[required] URI for the OPA endpoint, for example, #raw("https://opa.example.com/v1/data/trino/allow").],),
  ([#raw("opa.policy.row-filters-uri")], [The #strong[optional] URI for fetching row filters - if not set no row filtering is applied. For example, #raw("https://opa.example.com/v1/data/trino/rowFilters").],),
  ([#raw("opa.policy.column-masking-uri")], [The #strong[optional] URI for fetching column masks - if not set no masking is applied. For example, #raw("https://opa.example.com/v1/data/trino/columnMask").],),
  ([#raw("opa.policy.batch-column-masking-uri")], [The #strong[optional] URI for fetching columns masks in batches; must #strong[not] be used with #raw("opa.policy.column-masking-uri"). For example, #raw("http://opa.example.com/v1/data/trino/batchColumnMasks").],),
  ([#raw("opa.policy.batched-uri")], [The #strong[optional] URI for activating batch mode for certain authorization queries where batching is applicable, for example #raw("https://opa.example.com/v1/data/trino/batch"). Batch mode is described #link(label("ref-opa-batch-mode"))[Open Policy Agent access control].],),
  ([#raw("opa.log-requests")], [Configure if request details, including URI, headers and the entire body, are logged prior to sending them to OPA. Defaults to #raw("false").],),
  ([#raw("opa.log-responses")], [Configure if OPA response details, including URI, status code, headers and the entire body, are logged. Defaults to #raw("false").],),
  ([#raw("opa.allow-permission-management-operations")], [Configure if permission management operations are allowed. Find more details in #link(label("ref-opa-permission-management"))[Open Policy Agent access control]. Defaults to #raw("false").],),
  ([#raw("opa.http-client.*")], [Optional HTTP client configurations for the connection from Trino to OPA, for example #raw("opa.http-client.http-proxy") for configuring the HTTP proxy. Find more details in #link(label("doc-admin-properties-http-client"))[HTTP client properties].],),
  ([#raw("opa.context-file")], [Optional properties file, containing user defined properties \(e.g. tenant namespace, tier or cluster\) to be included in the OPA query context.],)
), header-rows: 1, title: "OPA access control configuration properties")

=== Logging

When request or response logging is enabled, details are logged at the #raw("DEBUG") level under the #raw("io.trino.plugin.opa.OpaHttpClient") logger. The Trino logging configuration must be updated to include this class, to ensure log entries are created.

Note that enabling these options produces very large amounts of log data.

#anchor("ref-opa-permission-management")

=== Permission management

The following operations are allowed or denied based on the setting of #raw("opa.allow-permission-management-operations") If set to #raw("true"), these operations are allowed. If set to #raw("false"), they are denied. In both cases, no request is sent to OPA.

- #raw("GrantSchemaPrivilege")
- #raw("DenySchemaPrivilege")
- #raw("RevokeSchemaPrivilege")
- #raw("GrantTablePrivilege")
- #raw("DenyTablePrivilege")
- #raw("RevokeTablePrivilege")
- #raw("CreateRole")
- #raw("DropRole")
- #raw("GrantRoles")
- #raw("RevokeRoles")

The setting defaults to #raw("false") due to the complexity and potential unexpected consequences of having SQL-style grants and roles together with OPA.

You must enable permission management if another custom security system in Trino is capable of grant management and used together with OPA access control.

Additionally, users are always allowed to show information about roles \(#raw("SHOW ROLES")\), regardless of this setting. The following operations are #emph[always] allowed:

- #raw("ShowRoles")
- #raw("ShowCurrentRoles")
- #raw("ShowRoleGrants")

== OPA configuration

The OPA access control in Trino contacts OPA for each query and issues an authorization request. OPA must return a response containing a boolean #raw("allow") field, which determines whether the operation is permitted or not.

Policies in OPA are defined with the purpose built policy language Rego. Find more information in the #link("https://www.openpolicyagent.org/docs/latest/policy-language/")[detailed documentation]. After the initial installation and configuration in Trino, these policies are the main configuration aspect for your access control setup.

A query from the OPA access control in Trino to OPA contains a #raw("context") and an #raw("action") as its top level fields.

The #raw("context") object contains all other contextual information about the query:

- #raw("identity"): The identity of the user performing the operation, containing the following two fields:
  
  - #raw("user"): username
  - #raw("groups"): list of groups this user belongs to
- #raw("queryId"): Query id
- #raw("softwareStack"): Information about the software stack issuing the request to OPA. The following information is included:
  
  - #raw("trinoVersion"): Version of Trino used

The #raw("action") object contains information about what action is performed on what resources. The following fields are provided:

- #raw("operation"): the performed operation, for example #raw("SelectFromColumns").
- #raw("resource"): information about the accessed objects
- #raw("targetResource"): information about any newly created object, if applicable
- #raw("grantee"): grantee of a grant operation.

Fields that are not applicable for a specific operation are set to null. Examples are an empty  #raw("targetResource") if not modifying a table or schema or catalog is modified, or an empty #raw("grantee") if not granting permissions is set. Any null field is omitted altogether from the #raw("action") object.

=== Example requests to OPA

Accessing a table results in a query similar to the following example:

#code-block("json", "{
  \"context\": {
    \"identity\": {
      \"user\": \"foo\",
      \"groups\": [\"some-group\"]
    },
    \"queryId\": \"20250718_081710_03427_trino\",
    \"softwareStack\": {
      \"trinoVersion\": \"434\"
    }
  },
  \"action\": {
    \"operation\": \"SelectFromColumns\",
    \"resource\": {
      \"table\": {
        \"catalogName\": \"example_catalog\",
        \"schemaName\": \"example_schema\",
        \"tableName\": \"example_table\",
        \"columns\": [
          \"column1\",
          \"column2\",
          \"column3\"
        ]
      }
    }
  }
}")

The #raw("targetResource") is used in cases where a new resource, distinct from the one in #raw("resource") is created. For example, when renaming a table.

#code-block("json", "{
  \"context\": {
    \"identity\": {
      \"user\": \"foo\",
      \"groups\": [\"some-group\"]
    },
    \"queryId\": \"20250718_081710_03427_trino\",
    \"softwareStack\": {
      \"trinoVersion\": \"434\"
    }
  },
  \"action\": {
    \"operation\": \"RenameTable\",
    \"resource\": {
      \"table\": {
        \"catalogName\": \"example_catalog\",
        \"schemaName\": \"example_schema\",
        \"tableName\": \"example_table\"
      }
    },
    \"targetResource\": {
      \"table\": {
        \"catalogName\": \"example_catalog\",
        \"schemaName\": \"example_schema\",
        \"tableName\": \"new_table_name\"
      }
    }
  }
}")

== Row filtering

Row filtering allows Trino to remove some rows from the result before returning it to the caller, controlling what data different users can see. The plugin supports retrieving filter definitions from OPA by configuring the OPA endpoint for row filter processing with #raw("opa.policy.row-filters-uri").

For example, an OPA policy for row filtering may be defined by the following rego script:

#code-block("text", "  package trino
  import future.keywords.in
  import future.keywords.if
  import future.keywords.contains

  default allow := true

  table_resource := input.action.resource.table
  is_admin {
    input.context.identity.user == \"admin\"
  }

  rowFilters contains {\"expression\": \"user_type <> 'customer'\"} if {
      not is_admin
      table_resource.catalogName == \"sample_catalog\"
      table_resource.schemaName == \"sample_schema\"
      table_resource.tableName == \"restricted_table\"
  }")

The response expected by the plugin is an array of objects, each of them in the format #raw("{\"expression\":\"clause\"}"). Each expression essentially behaves like an additional #raw("WHERE") clause. The script can also return multiple row filters for a single OPA request, and all filters are subsequently applied.

Each object may contain an identity field. The identity field allows Trino to evaluate these row filters under a #strong[different] identity - such that a filter can target a column the requesting user cannot see.

== Column masking

Column masking allows Trino to obscure data in one or more columns of the result set for specific users, without outright denying access. The plugin supports fetching column masks from OPA by configuring the OPA endpoint for columns mask processing with #raw("opa.policy.column-masking-uri") in the opa-plugin configuration.

For example, a policy configuring column masking may be defined by the following rego script:

#code-block("text", "  package trino
  import future.keywords.in
  import future.keywords.if
  import future.keywords.contains

  default allow := true

  column_resource := input.action.resource.column
  is_admin {
    input.context.identity.user == \"admin\"
  }

  columnMask := {\"expression\": \"NULL\"} if {
      not is_admin
      column_resource.catalogName == \"sample_catalog\"
      column_resource.schemaName == \"sample_schema\"
      column_resource.tableName == \"restricted_table\"
      column_resource.columnName == \"user_phone\"
  }

  columnMask := {\"expression\": \"'****' || substring(user_name, -3)\"} if {
      not is_admin
      column_resource.catalogName == \"sample_catalog\"
      column_resource.schemaName == \"sample_schema\"
      column_resource.tableName == \"restricted_table\"
      column_resource.columnName == \"user_name\"
  }")

Unlike row filtering, only a #strong[single column mask] may be returned for a given column.

The same "identity" field may be returned to evaluate column masks under a different identity.

=== Batch column masking

If column masking is enabled, by default, the plugin will fetch each column mask individually from OPA. When working with very wide tables this can result in a performance degradation.

Configuring #raw("opa.policy.batch-column-masking-uri") allows Trino to fetch the masks for multiple columns in a single request. The list of requested columns is included in the request under #raw("action.filterResources").

If #raw("opa.policy.batch-column-masking-uri") is set it overrides the value of #raw("opa.policy.column-masking-uri") so that the plugin uses batch column masking.

An OPA policy supporting batch column masking must return a list of objects, each containing the following data:

- #raw("viewExpression"):
  
  - #raw("expression"): the expression to apply to the column, as a string
  - #raw("identity") \(optional\): the identity to evaluate the expression as, as a string
- #raw("index"): a reference the index of the column in the request to which this mask applies

For example, a policy configuring batch column masking may be defined by the following rego script:

#code-block("text", "package trino
import future.keywords.in
import future.keywords.if
import future.keywords.contains

default allow := true

batchColumnMasks contains {
  \"index\": i,
  \"viewExpression\": {
    \"expression\": \"NULL\"
  }
} if {
  some i
  column_resource := input.action.filterResources[i]
  column_resource.catalogName == \"sample_catalog\"
  column_resource.schemaName == \"sample_schema\"
  column_resource.tableName == \"restricted_table\"
  column_resource.columnName == \"user_phone\"
}


batchColumnMasks contains {
  \"index\": i,
  \"viewExpression\": {
    \"expression\": \"'****' || substring(user_name, -3)\",
    \"identity\": \"admin\"
  }
} if {
  some i
  column_resource := input.action.filterResources[i]
  column_resource.catalogName == \"sample_catalog\"
  column_resource.schemaName == \"sample_schema\"
  column_resource.tableName == \"restricted_table\"
  column_resource.columnName == \"user_name\"
}")

A batch column masking request is similar to the following example:

#code-block("json", "{
    \"context\": {
        \"identity\": {
            \"user\": \"foo\",
            \"groups\": [\"some-group\"]
        },
        \"queryId\": \"20250718_081710_03427_trino\",
        \"softwareStack\": {
            \"trinoVersion\": \"434\"
        }
    },
    \"action\": {
        \"operation\": \"GetColumnMask\",
        \"filterResources\": [
            {
                \"column\": {
                    \"catalogName\": \"sample_catalog\",
                    \"schemaName\": \"sample_schema\",
                    \"tableName\": \"restricted_table\",
                    \"columnName\": \"user_phone\",
                    \"columnType\": \"VARCHAR\"
                }
            },
            {
                \"column\": {
                    \"catalogName\": \"sample_catalog\",
                    \"schemaName\": \"sample_schema\",
                    \"tableName\": \"restricted_table\",
                    \"columnName\": \"user_name\",
                    \"columnType\": \"VARCHAR\"
                }
            }
        ]
    }
}")

The related OPA response is displayed in the following snippet:

#code-block("json", "[
    {
        \"index\": 0,
        \"viewExpression\": {
            \"expression\": \"NULL\"
        }
    },
    {
        \"index\": 1,
        \"viewExpression\": {
            \"expression\": \"'****' || substring(user_name, -3)\",
            \"identity\": \"admin\"
        }
    }
]")

#anchor("ref-opa-batch-mode")

== Batch mode

A very powerful feature provided by OPA is its ability to respond to authorization queries with more complex answers than a #raw("true") or #raw("false") boolean value.

Many features in Trino require filtering to determine to which resources a user is granted access. These resources are catalogs, schema, queries, views, and others objects.

If #raw("opa.policy.batched-uri") is not configured, Trino sends one request to OPA for each object, and then creates a filtered list of permitted objects.

Configuring #raw("opa.policy.batched-uri") allows Trino to send a request to the batch endpoint, with a list of resources in one request using the under #raw("action.filterResources") node.

All other fields in the request are identical to the non-batch endpoint.

An OPA policy supporting batch operations must return a list containing the #emph[indices] of the items for which authorization is granted. Returning a #raw("null") value or an empty list is equivalent and denies any access.

You can add batching support for policies that do not support it:

#code-block("text", "package foo

import future.keywords.contains

# ... rest of the policy ...
# this assumes the non-batch response field is called \"allow\"
batch contains i {
    some i
    raw_resource := input.action.filterResources[i]
    allow with input.action.resource as raw_resource
}

# Corner case: filtering columns is done with a single table item, and many columns inside
# We cannot use our normal logic in other parts of the policy as they are based on sets
# and we need to retain order
batch contains i {
    some i
    input.action.operation == \"FilterColumns\"
    count(input.action.filterResources) == 1
    raw_resource := input.action.filterResources[0]
    count(raw_resource[\"table\"][\"columns\"]) > 0
    new_resources := [
        object.union(raw_resource, {\"table\": {\"column\": column_name}})
        | column_name := raw_resource[\"table\"][\"columns\"][_]
    ]
    allow with input.action.resource as new_resources[i]
}")
