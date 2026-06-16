#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-319")
= Release 319 \(22 Sep 2019\)

== General

- Fix planning failure for queries involving #raw("UNION") and #raw("DISTINCT") aggregates. \(#issue("1510", "https://github.com/trinodb/trino/issues/1510")\)
- Fix excessive runtime when parsing expressions involving #raw("CASE"). \(#issue("1407", "https://github.com/trinodb/trino/issues/1407")\)
- Fix fragment output size in #raw("EXPLAIN ANALYZE") output. \(#issue("1345", "https://github.com/trinodb/trino/issues/1345")\)
- Fix a rare failure when running #raw("EXPLAIN ANALYZE") on a query containing window functions. \(#issue("1401", "https://github.com/trinodb/trino/issues/1401")\)
- Fix failure when querying #raw("/v1/resourceGroupState") endpoint for non-existing resource group. \(#issue("1368", "https://github.com/trinodb/trino/issues/1368")\)
- Fix incorrect results when reading #raw("information_schema.table_privileges") with an equality predicate on #raw("table_name") but without a predicate on #raw("table_schema"). \(#issue("1534", "https://github.com/trinodb/trino/issues/1534")\)
- Fix planning failure due to coercion handling for correlated subqueries. \(#issue("1453", "https://github.com/trinodb/trino/issues/1453")\)
- Improve performance of queries against #raw("information_schema") tables. \(#issue("1329", "https://github.com/trinodb/trino/issues/1329")\)
- Reduce metadata querying during planning. \(#issue("1308", "https://github.com/trinodb/trino/issues/1308"), #issue("1455", "https://github.com/trinodb/trino/issues/1455")\)
- Improve performance of certain queries involving coercions and complex expressions in #raw("JOIN") conditions. \(#issue("1390", "https://github.com/trinodb/trino/issues/1390")\)
- Include cost estimates in output of #raw("EXPLAIN (TYPE IO)"). \(#issue("806", "https://github.com/trinodb/trino/issues/806")\)
- Improve support for correlated subqueries involving #raw("ORDER BY") or #raw("LIMIT"). \(#issue("1415", "https://github.com/trinodb/trino/issues/1415")\)
- Improve performance of certain #raw("JOIN") queries when automatic join ordering is enabled. \(#issue("1431", "https://github.com/trinodb/trino/issues/1431")\)
- Allow setting the default session catalog and schema via the #raw("sql.default-catalog") and #raw("sql.default-schema") configuration properties. \(#issue("1524", "https://github.com/trinodb/trino/issues/1524")\)
- Add support for #raw("IGNORE NULLS") for window functions. \(#issue("1244", "https://github.com/trinodb/trino/issues/1244")\)
- Add support for #raw("INNER") and #raw("OUTER") joins involving #raw("UNNEST"). \(#issue("1522", "https://github.com/trinodb/trino/issues/1522")\)
- Rename #raw("legacy") and #raw("flat") #link(label("doc-admin-properties-node-scheduler"))[scheduler policies] to #raw("uniform") and #raw("topology") respectively.  These can be configured via the #raw("node-scheduler.policy") configuration property. \(#issue("10491", "https://github.com/trinodb/trino/issues/10491")\)
- Add #raw("file") #link(label("doc-admin-properties-node-scheduler"))[network topology provider] which can be configured via the #raw("node-scheduler.network-topology.type") configuration property. \(#issue("1500", "https://github.com/trinodb/trino/issues/1500")\)
- Add support for #raw("SphericalGeography") to #link(label("fn-st-length"), raw("ST_Length")). \(#issue("1551", "https://github.com/trinodb/trino/issues/1551")\)

== Security

- Allow configuring read-only access in #link(label("doc-security-built-in-system-access-control"))[System access control]. \(#issue("1153", "https://github.com/trinodb/trino/issues/1153")\)
- Add missing checks for schema create, rename, and drop in file-based #raw("SystemAccessControl"). \(#issue("1153", "https://github.com/trinodb/trino/issues/1153")\)
- Allow authentication over HTTP for forwarded requests containing the #raw("X-Forwarded-Proto") header. This is disabled by default, but can be enabled using the #raw("http-server.authentication.allow-forwarded-https") configuration property. \(#issue("1442", "https://github.com/trinodb/trino/issues/1442")\)

== Web UI

- Fix rendering bug in Query Timeline resulting in inconsistency of presented information after query finishes. \(#issue("1371", "https://github.com/trinodb/trino/issues/1371")\)
- Show total memory in Query Timeline instead of user memory. \(#issue("1371", "https://github.com/trinodb/trino/issues/1371")\)

== CLI

- Add #raw("--insecure") option to skip validation of server certificates for debugging. \(#issue("1484", "https://github.com/trinodb/trino/issues/1484")\)

== Hive connector

- Fix reading from #raw("information_schema"), as well as #raw("SHOW SCHEMAS"), #raw("SHOW TABLES"), and #raw("SHOW COLUMNS") when connecting to a Hive 3.x metastore that contains an #raw("information_schema") schema. \(#issue("1192", "https://github.com/trinodb/trino/issues/1192")\)
- Improve performance when reading data from GCS. \(#issue("1443", "https://github.com/trinodb/trino/issues/1443")\)
- Allow accessing tables in Glue metastore that do not have a table type. \(#issue("1343", "https://github.com/trinodb/trino/issues/1343")\)
- Add support for Azure Data Lake \(#raw("adl")\) file system. \(#issue("1499", "https://github.com/trinodb/trino/issues/1499")\)
- Allow using custom S3 file systems by relying on the default Hadoop configuration by specifying #raw("HADOOP_DEFAULT") for the #raw("hive.s3-file-system-type") configuration property. \(#issue("1397", "https://github.com/trinodb/trino/issues/1397")\)
- Add support for instance credentials for the Glue metastore via the #raw("hive.metastore.glue.use-instance-credentials") configuration property. \(#issue("1363", "https://github.com/trinodb/trino/issues/1363")\)
- Add support for custom credentials providers for the Glue metastore via the #raw("hive.metastore.glue.aws-credentials-provider") configuration property. \(#issue("1363", "https://github.com/trinodb/trino/issues/1363")\)
- Do not require setting the #raw("hive.metastore-refresh-interval") configuration property when enabling metastore caching. \(#issue("1473", "https://github.com/trinodb/trino/issues/1473")\)
- Add #raw("textfile_field_separator") and #raw("textfile_field_separator_escape") table properties to support custom field separators for #raw("TEXTFILE") format tables. \(#issue("1439", "https://github.com/trinodb/trino/issues/1439")\)
- Add #raw("$file_size") and #raw("$file_modified_time") hidden columns. \(#issue("1428", "https://github.com/trinodb/trino/issues/1428")\)
- The #raw("hive.metastore-timeout") configuration property is now accepted only when using the Thrift metastore. Previously, it was accepted for other metastore type, but was ignored. \(#issue("1346", "https://github.com/trinodb/trino/issues/1346")\)
- Disallow reads from transactional tables. Previously, reads would appear to work, but would not return any data. \(#issue("1218", "https://github.com/trinodb/trino/issues/1218")\)
- Disallow writes to transactional tables. Previously, writes would appear to work, but the data would be written incorrectly. \(#issue("1218", "https://github.com/trinodb/trino/issues/1218")\)
