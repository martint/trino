#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-341")
= Release 341 \(8 Sep 2020\)

== General

- Add support for variable-precision #raw("TIME") type. \(#issue("4381", "https://github.com/trinodb/trino/issues/4381")\)
- Add support for variable precision #raw("TIME WITH TIME ZONE") type. \(#issue("4905", "https://github.com/trinodb/trino/issues/4905")\)
- Add #link(label("doc-connector-iceberg"))[Iceberg connector].
- Add #link(label("fn-human-readable-seconds"), raw("human_readable_seconds")) function. \(#issue("4344", "https://github.com/trinodb/trino/issues/4344")\)
- Add #link(label("ref-function-reverse-varbinary"))[#raw("reverse()")] function for #raw("VARBINARY"). \(#issue("4741", "https://github.com/trinodb/trino/issues/4741")\)
- Add support for #link(label("fn-extract"), raw("extract")) for #raw("timestamp(p) with time zone") with values of #raw("p") other than 3. \(#issue("4867", "https://github.com/trinodb/trino/issues/4867")\)
- Add support for correlated subqueries in recursive queries. \(#issue("4877", "https://github.com/trinodb/trino/issues/4877")\)
- Add #link(label("ref-optimizer-rule-stats"))[System connector] system table. \(#issue("4659", "https://github.com/trinodb/trino/issues/4659")\)
- Report dynamic filters statistics. \(#issue("4440", "https://github.com/trinodb/trino/issues/4440")\)
- Improve query scalability when new nodes are added to cluster. \(#issue("4294", "https://github.com/trinodb/trino/issues/4294")\)
- Improve error message when JSON parsing fails. \(#issue("4616", "https://github.com/trinodb/trino/issues/4616")\)
- Reduce latency when dynamic filtering is in use. \(#issue("4924", "https://github.com/trinodb/trino/issues/4924")\)
- Remove support for political time zones in #raw("TIME WITH TIME ZONE") type. \(#issue("191", "https://github.com/trinodb/trino/issues/191")\)
- Remove deprecated #raw("reorder_joins") session property. \(#issue("5027", "https://github.com/trinodb/trino/issues/5027")\)
- Remove the #raw("deprecated.legacy-timestamp") configuration property and the #raw("legacy_timestamp") session property. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Change timestamp operations to match the SQL specification. The value of a #raw("TIMESTAMP") type is not affected by the session time zone. \(#issue("37", "https://github.com/trinodb/trino/issues/37")\)
- Preserve precision when applying #raw("AT TIME ZONE") to values of type #raw("TIMESTAMP"). \(#issue("4866", "https://github.com/trinodb/trino/issues/4866")\)
- Fix serialization of #raw("NULL") values in #raw("ROW"), #raw("MAP") and #raw("ARRAY") types for old Presto clients. \(#issue("4778", "https://github.com/trinodb/trino/issues/4778")\)
- Fix failure when aggregation query contains duplicate expressions. \(#issue("4872", "https://github.com/trinodb/trino/issues/4872")\)
- Fix compiler failure when querying timestamps with a precision greater than 6. \(#issue("4824", "https://github.com/trinodb/trino/issues/4824")\)
- Fix parsing failure of timestamps due to daylight saving changes. \(#issue("37", "https://github.com/trinodb/trino/issues/37")\)
- Fix failure when calling #link(label("fn-extract"), raw("extract")) with #raw("TIMEZONE_HOUR") and #raw("TIMEZONE_MINUTE") for #raw("TIMESTAMP WITH TIME ZONE") type. \(#issue("4867", "https://github.com/trinodb/trino/issues/4867")\)
- Fix query deadlock for connectors that wait for dynamic filters. \(#issue("4946", "https://github.com/trinodb/trino/issues/4946")\)
- Fix failure when #raw("TIME") or #raw("TIMESTAMP") subtraction returns a negative value. \(#issue("4847", "https://github.com/trinodb/trino/issues/4847")\)
- Fix failure when duplicate expressions appear in #raw("DISTINCT") clause. \(#issue("4787", "https://github.com/trinodb/trino/issues/4787")\)
- Fix failure for certain join queries during spilling or when available memory is low. \(#issue("4994", "https://github.com/trinodb/trino/issues/4994")\)
- Fix issue where the #raw("query_max_scan_physical_bytes") session property was ignored if the #raw("query.max-scan-physical-bytes") configuration property was not defined. \(#issue("5009", "https://github.com/trinodb/trino/issues/5009")\)
- Correctly compute sample ratio when #raw("TABLESAMPLE") is used with a fractional percentage. \(#issue("5074", "https://github.com/trinodb/trino/issues/5074")\)
- Fail queries with a proper error message when #raw("TABLESAMPLE") is used with a non-numeric sample ratio. \(#issue("5074", "https://github.com/trinodb/trino/issues/5074")\)
- Fail with an explicit error rather than #raw("OutOfMemoryError") for certain operations. \(#issue("4890", "https://github.com/trinodb/trino/issues/4890")\)

== Security

- Add #link(label("doc-security-salesforce"))[Salesforce password authentication]. \(#issue("4372", "https://github.com/trinodb/trino/issues/4372")\)
- Add support for interpolating #link(label("doc-security-secrets"))[secrets] into #raw("access-control.properties"). \(#issue("4854", "https://github.com/trinodb/trino/issues/4854")\)
- Only request HTTPS client certificate when certificate authentication is enabled. \(#issue("4804", "https://github.com/trinodb/trino/issues/4804")\)
- Add #link(label("doc-security-user-mapping"))[User mapping] support for uppercasing or lowercasing usernames. \(#issue("4736", "https://github.com/trinodb/trino/issues/4736")\)

== Web UI

- Fix display of physical input read time in detailed query view. \(#issue("4962", "https://github.com/trinodb/trino/issues/4962")\)

== JDBC driver

- Implement #raw("ResultSet.getStatement()"). \(#issue("4957", "https://github.com/trinodb/trino/issues/4957")\)

== BigQuery connector

- Add support for hourly partitioned tables. \(#issue("4968", "https://github.com/trinodb/trino/issues/4968")\)
- Redact the value of #raw("bigquery.credentials-key") in the server log. \(#issue("4968", "https://github.com/trinodb/trino/issues/4968")\)

== Cassandra connector

- Map Cassandra #raw("TIMESTAMP") type to Presto #raw("TIMESTAMP(3) WITH TIME ZONE") type. \(#issue("2269", "https://github.com/trinodb/trino/issues/2269")\)

== Hive connector

- Skip stripes and row groups based on timestamp statistics for ORC files. \(#issue("1147", "https://github.com/trinodb/trino/issues/1147")\)
- Skip S3 objects with the #raw("DeepArchive") storage class \(in addition to the #raw("Glacier") storage class\) when #raw("hive.s3.skip-glacier-objects") is enabled. \(#issue("5002", "https://github.com/trinodb/trino/issues/5002")\)
- Use a temporary staging directory for temporary files when writing to sorted bucketed tables. This allows using a more efficient file system for temporary files. \(#issue("3434", "https://github.com/trinodb/trino/issues/3434")\)
- Fix metastore cache invalidation for #raw("GRANT") and #raw("REVOKE"). \(#issue("4768", "https://github.com/trinodb/trino/issues/4768")\)
- Add Parquet and RCBinary #link(label("ref-hive-configuration-properties"))[configuration properties] #raw("hive.parquet.time-zone") and #raw("hive.rcfile.time-zone") to adjust binary timestamp values to a specific time zone. For Hive 3.1+, this should be set to UTC. The default value is the JVM default time zone, for backwards compatibility with earlier versions of Hive. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Add ORC #link(label("ref-hive-configuration-properties"))[configuration property] #raw("hive.orc.time-zone") to set the default time zone for legacy ORC files that did not declare a time zone. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Replace the #raw("hive.time-zone") configuration property with format specific properties: #raw("hive.orc.time-zone"), #raw("hive.parquet.time-zone"), #raw("hive.rcfile.time-zone"). \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Allow using the cluster default role with S3 security mapping. \(#issue("4931", "https://github.com/trinodb/trino/issues/4931")\)
- Remove support for bucketing on timestamp. The definition of the hash function for timestamp incorrectly depends on the storage time zone and can result in incorrect results. \(#issue("4759", "https://github.com/trinodb/trino/issues/4759")\)
- Decrease the number of requests to the Glue metastore when fetching partitions. This helps avoid hitting rate limits and decreases service costs. \(#issue("4938", "https://github.com/trinodb/trino/issues/4938")\)
- Match the existing user and group of the table or partition when creating new files on HDFS. \(#issue("4414", "https://github.com/trinodb/trino/issues/4414")\)
- Fix invalid timestamp values for nested data in Text, Avro, SequenceFile, JSON and CSV formats. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Fix query failure when reading an ORC ACID table with a filter after the table underwent a minor table compaction. \(#issue("4622", "https://github.com/trinodb/trino/issues/4622")\)
- Fix incorrect query results when reading an ORC ACID table that has deleted rows and underwent a minor compaction. \(#issue("4623", "https://github.com/trinodb/trino/issues/4623")\)
- Fix query failure when storage caching is enabled and cached data is evicted during query execution. \(#issue("3580", "https://github.com/trinodb/trino/issues/3580")\)

== JMX connector

- Change #raw("timestamp") column type in history tables to #raw("TIMESTAMP WITH TIME ZONE"). \(#issue("4753", "https://github.com/trinodb/trino/issues/4753")\)

== Kafka connector

- Preserve time zone when parsing #raw("TIMESTAMP WITH TIME ZONE") values. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)

== Kinesis connector

- Preserve time zone when parsing #raw("TIMESTAMP WITH TIME ZONE") values. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)

== Kudu connector

- Fix delete when applied on table having primary key of decimal type. \(#issue("4683", "https://github.com/trinodb/trino/issues/4683")\)

== Local File connector

- Change #raw("timestamp") column type to #raw("TIMESTAMP WITH TIME ZONE"). \(#issue("4752", "https://github.com/trinodb/trino/issues/4752")\)

== MySQL connector

- Improve performance of aggregation queries by pushing the aggregation computation into the MySQL database. Currently, the following aggregate functions are eligible for pushdown: #raw("count"),  #raw("min"), #raw("max"), #raw("sum") and #raw("avg"). \(#issue("4138", "https://github.com/trinodb/trino/issues/4138")\)

== Oracle connector

- Add #raw("oracle.connection-pool.inactive-timeout") configuration property to specify how long pooled connection can be inactive before it is closed. It defaults to 20 minutes. \(#issue("4779", "https://github.com/trinodb/trino/issues/4779")\)
- Add support for database internationalization. \(#issue("4775", "https://github.com/trinodb/trino/issues/4775")\)
- Add resilience to momentary connection authentication issues. \(#issue("4947", "https://github.com/trinodb/trino/issues/4947")\)
- Allowing forcing the mapping of certain types to #raw("VARCHAR"). This can be enabled by setting the #raw("jdbc-types-mapped-to-varchar") configuration property to a comma-separated list of type names. \(#issue("4955", "https://github.com/trinodb/trino/issues/4955")\)
- Prevent query failure for pushdown of predicates involving a large number of conjuncts. \(#issue("4918", "https://github.com/trinodb/trino/issues/4918")\)

== Phoenix connector

- Fix overwriting of former value when insert is applied without specifying that column. \(#issue("4670", "https://github.com/trinodb/trino/issues/4670")\)

== Pinot connector

- Add support for #raw("REAL") and #raw("INTEGER") types. \(#issue("4725", "https://github.com/trinodb/trino/issues/4725")\)
- Add support for functions in pass-through queries. \(#issue("4801", "https://github.com/trinodb/trino/issues/4801")\)
- Enforce a limit on the number of rows fetched from Pinot. This can be configured via the #raw("pinot.max-rows-per-split-for-segment-queries") configuration property. \(#issue("4723", "https://github.com/trinodb/trino/issues/4723")\)
- Fix incorrect results for #raw("count(*)") queries. \(#issue("4802", "https://github.com/trinodb/trino/issues/4802")\)
- Fix incorrect results for queries involving #link(label("fn-avg"), raw("avg")) over columns of type #raw("long"), #raw("int"), or #raw("float"). \(#issue("4802", "https://github.com/trinodb/trino/issues/4802")\)
- Fix incorrect results when columns in pass-through query do not match selected columns. \(#issue("4802", "https://github.com/trinodb/trino/issues/4802")\)

== Prometheus connector

- Change the type of the #raw("timestamp") column to #raw("TIMESTAMP(3) WITH TIME ZONE") type. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)

== PostgreSQL connector

- Improve performance of aggregation queries with predicates by pushing the computation of both the filtering and aggregations into the PostgreSQL server where possible. \(#issue("4111", "https://github.com/trinodb/trino/issues/4111")\)
- Fix handling of PostgreSQL arrays when #raw("unsupported-type-handling") is set to #raw("CONVERT_TO_VARCHAR"). \(#issue("4981", "https://github.com/trinodb/trino/issues/4981")\)

== Raptor connector

- Remove the #raw("storage.shard-day-boundary-time-zone") configuration property, which was used to work around legacy timestamp semantics in Presto. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)

== Redis connector

- Preserve time zone when parsing #raw("TIMESTAMP WITH TIME ZONE") values. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)

== SPI

- The #raw("TIMESTAMP") type is encoded as a number of fractional seconds from #raw("1970-01-01 00:00:00") in the proleptic Gregorian calendar. This value is no longer adjusted to the session time zone. Timestamps with precision less than or equal to 3 are now represented in microseconds. \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Remove #raw("isLegacyTimestamp()") from #raw("ConnectorSession"). \(#issue("4799", "https://github.com/trinodb/trino/issues/4799")\)
- Enable connectors to wait for dynamic filters before producing data on worker nodes. \(#issue("3414", "https://github.com/trinodb/trino/issues/3414")\)
