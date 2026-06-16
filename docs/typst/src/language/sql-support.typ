#import "/lib/trino-docs.typ": *

#anchor("doc-language-sql-support")
= SQL statement support

The SQL statement support in Trino can be categorized into several topics. Many statements are part of the core engine and therefore available in all use cases. For example, you can always set session properties or inspect an explain plan and perform other actions with the #link(label("ref-sql-globally-available"))[globally available statements].

However, the details and architecture of the connected data sources can limit some SQL functionality. For example, if the data source does not support any write operations, then a #link(label("doc-sql-delete"))[DELETE] statement cannot be executed against the data source.

Similarly, if the underlying system does not have any security concepts, SQL statements like #link(label("doc-sql-create-role"))[CREATE ROLE] cannot be supported by Trino and the connector.

The categories of these different topics are related to #link(label("ref-sql-read-operations"))[read operations], #link(label("ref-sql-write-operations"))[write operations], #link(label("ref-sql-security-operations"))[security operations] and #link(label("ref-sql-transactions"))[transactions].

Details of the support for specific statements is available with the documentation for each connector.

#anchor("ref-sql-globally-available")

== Globally available statements

The following statements are implemented in the core engine and available with any connector:

- #link(label("doc-sql-call"))[CALL]
- #link(label("doc-sql-deallocate-prepare"))[DEALLOCATE PREPARE]
- #link(label("doc-sql-describe-input"))[DESCRIBE INPUT]
- #link(label("doc-sql-describe-output"))[DESCRIBE OUTPUT]
- #link(label("doc-sql-execute"))[EXECUTE]
- #link(label("doc-sql-execute-immediate"))[EXECUTE IMMEDIATE]
- #link(label("doc-sql-explain"))[EXPLAIN]
- #link(label("doc-sql-explain-analyze"))[EXPLAIN ANALYZE]
- #link(label("doc-sql-prepare"))[PREPARE]
- #link(label("doc-sql-reset-session"))[RESET SESSION]
- #link(label("doc-sql-set-session"))[SET SESSION]
- #link(label("doc-sql-set-time-zone"))[SET TIME ZONE]
- #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS]
- #link(label("doc-sql-show-session"))[SHOW SESSION]
- #link(label("doc-sql-use"))[USE]
- #link(label("doc-sql-values"))[VALUES]

#anchor("ref-sql-catalog-management")

=== Catalog management

The following statements are used to #link(label("doc-admin-properties-catalog"))[manage dynamic catalogs]:

- #link(label("doc-sql-create-catalog"))[CREATE CATALOG]
- #link(label("doc-sql-drop-catalog"))[DROP CATALOG]

#anchor("ref-sql-read-operations")

== Read operations

The following statements provide read access to data and metadata exposed by a connector accessing a data source. They are supported by all connectors:

- #link(label("doc-sql-select"))[SELECT] including #link(label("doc-sql-match-recognize"))[MATCH\_RECOGNIZE]
- #link(label("doc-sql-describe"))[DESCRIBE]
- #link(label("doc-sql-show-catalogs"))[SHOW CATALOGS]
- #link(label("doc-sql-show-columns"))[SHOW COLUMNS]
- #link(label("doc-sql-show-create-materialized-view"))[SHOW CREATE MATERIALIZED VIEW]
- #link(label("doc-sql-show-create-schema"))[SHOW CREATE SCHEMA]
- #link(label("doc-sql-show-create-table"))[SHOW CREATE TABLE]
- #link(label("doc-sql-show-create-view"))[SHOW CREATE VIEW]
- #link(label("doc-sql-show-grants"))[SHOW GRANTS]
- #link(label("doc-sql-show-roles"))[SHOW ROLES]
- #link(label("doc-sql-show-schemas"))[SHOW SCHEMAS]
- #link(label("doc-sql-show-tables"))[SHOW TABLES]
- #link(label("doc-sql-show-stats"))[SHOW STATS]

#anchor("ref-sql-write-operations")

== Write operations

The following statements provide write access to data and metadata exposed by a connector accessing a data source. Availability varies widely from connector to connector:

#anchor("ref-sql-data-management")

=== Data management

- #link(label("doc-sql-insert"))[INSERT]
- #link(label("doc-sql-update"))[UPDATE]
- #link(label("doc-sql-delete"))[DELETE]
- #link(label("doc-sql-truncate"))[TRUNCATE]
- #link(label("doc-sql-merge"))[MERGE]

#anchor("ref-sql-schema-table-management")

=== Schema and table management

- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-alter-table"))[ALTER TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("doc-sql-alter-schema"))[ALTER SCHEMA]
- #link(label("doc-sql-comment"))[COMMENT]

#anchor("ref-sql-view-management")

=== View management

- #link(label("doc-sql-create-view"))[CREATE VIEW]
- #link(label("doc-sql-drop-view"))[DROP VIEW]
- #link(label("doc-sql-alter-view"))[ALTER VIEW]

#anchor("ref-sql-materialized-view-management")

=== Materialized view management

- #link(label("doc-sql-create-materialized-view"))[CREATE MATERIALIZED VIEW]
- #link(label("doc-sql-alter-materialized-view"))[ALTER MATERIALIZED VIEW]
- #link(label("doc-sql-drop-materialized-view"))[DROP MATERIALIZED VIEW]
- #link(label("doc-sql-refresh-materialized-view"))[REFRESH MATERIALIZED VIEW]

#anchor("ref-udf-management")

=== User-defined function management

The following statements are used to manage #link(label("ref-udf-catalog"))[Introduction to UDFs]:

- #link(label("doc-sql-create-function"))[CREATE FUNCTION]
- #link(label("doc-sql-drop-function"))[DROP FUNCTION]
- #link(label("doc-sql-show-functions"))[SHOW FUNCTIONS]

#anchor("ref-sql-security-operations")

== Security operations

The following statements provide security-related operations to security configuration, data, and metadata exposed by a connector accessing a data source. Most connectors do not support these operations:

Connector roles:

- #link(label("doc-sql-create-role"))[CREATE ROLE]
- #link(label("doc-sql-drop-role"))[DROP ROLE]
- #link(label("doc-sql-grant-roles"))[GRANT role]
- #link(label("doc-sql-revoke-roles"))[REVOKE role]
- #link(label("doc-sql-set-role"))[SET ROLE]
- #link(label("doc-sql-show-role-grants"))[SHOW ROLE GRANTS]

Grants management:

- #link(label("doc-sql-deny"))[DENY]
- #link(label("doc-sql-grant"))[GRANT privilege]
- #link(label("doc-sql-revoke"))[REVOKE privilege]

#anchor("ref-sql-transactions")

== Transactions

The following statements manage transactions. Most connectors do not support transactions:

- #link(label("doc-sql-start-transaction"))[START TRANSACTION]
- #link(label("doc-sql-commit"))[COMMIT]
- #link(label("doc-sql-rollback"))[ROLLBACK]
