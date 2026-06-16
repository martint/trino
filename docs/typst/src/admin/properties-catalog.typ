#import "/lib/trino-docs.typ": *

#anchor("doc-admin-properties-catalog")
= Catalog management properties

The following properties are used to configure catalog management with further controls for dynamic catalog management.

#anchor("ref-prop-catalog-management")

== #raw("catalog.management")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]
- #strong[Allowed values:] #raw("static"), #raw("dynamic")
- #strong[Default value:] #raw("static")

When set to #raw("static"), Trino reads catalog property files and configures available catalogs only on server startup. When set to #raw("dynamic"), catalog configuration can also be managed using #link(label("doc-sql-create-catalog"))[CREATE CATALOG] and #link(label("doc-sql-drop-catalog"))[DROP CATALOG]. New worker nodes joining the cluster receive the current catalog configuration from the coordinator node.

#warning[
This feature is experimental only. Because of the security implications the syntax might change and be backward incompatible.
]

#warning[
Some connectors are known not to release all resources when dropping a catalog that uses such connector. This includes all connectors that can read data from HDFS, S3, GCS, or Azure, which are #link(label("doc-connector-hive"))[Hive connector], #link(label("doc-connector-iceberg"))[Iceberg connector], #link(label("doc-connector-delta-lake"))[Delta Lake connector], and #link(label("doc-connector-hudi"))[Hudi connector].
]

#warning[
The complete #raw("CREATE CATALOG") query is logged, and visible in the #link(label("doc-admin-web-interface"))[Web UI]. This includes any sensitive properties, like passwords and other credentials. See #link(label("doc-security-secrets"))[Secrets].
]

== #raw("catalog.prune.update-interval")

- #strong[Type:] #link(label("ref-prop-type-duration"))[Properties reference]
- #strong[Default value:] #raw("5s")
- #strong[Minimum value:] #raw("1s")

Requires #link(label("ref-prop-catalog-management"))[Catalog management properties] to be set to #raw("dynamic"). Interval for pruning dropped catalogs. Dropping a catalog does not interrupt any running queries that use it, but makes it unavailable to any new queries.

#anchor("ref-prop-catalog-store")

== #raw("catalog.store")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]
- #strong[Allowed values:] #raw("file"), #raw("memory")
- #strong[Default value:] #raw("file")

Requires #link(label("ref-prop-catalog-management"))[Catalog management properties] to be set to #raw("dynamic"). When set to #raw("file"), creating and dropping catalogs using the SQL commands adds and removes catalog property files on the coordinator node. Trino server process requires write access in the catalog configuration directory. Existing catalog files are also read on the coordinator startup. When set to #raw("memory"), catalog configuration is only managed in memory, and any existing files are ignored on startup.

== #raw("catalog.config-dir")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]
- #strong[Default value:] #raw("etc/catalog/")

Requires #link(label("ref-prop-catalog-management"))[Catalog management properties] to be set to #raw("static") or #link(label("ref-prop-catalog-store"))[Catalog management properties] to be set to #raw("file"). The directory with catalog property files.

== #raw("catalog.disabled-catalogs")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]

Requires #link(label("ref-prop-catalog-management"))[Catalog management properties] to be set to #raw("static") or #link(label("ref-prop-catalog-store"))[Catalog management properties] to be set to #raw("file"). Comma-separated list of catalogs to ignore on startup.

== #raw("catalog.read-only")

- #strong[Type:] #link(label("ref-prop-type-string"))[Properties reference]
- #strong[Default value:] #raw("false")

Requires #link(label("ref-prop-catalog-store"))[Catalog management properties] to be set to #raw("file"). If true, existing catalog property files cannot be removed with #raw("DROP CATALOG"), and no new catalog files can be written with identical names with #raw("CREATE CATALOG"). As a result, a coordinator restart resets the known catalogs to the existing files only.
