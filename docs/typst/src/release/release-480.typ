#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-480")
= Release 480 \(24 Mar 2026\)

== General

- Add the #link(label("ref-number-data-type"))[number] type. \(#issue("28319", "https://github.com/trinodb/trino/issues/28319")\)
- Add coordinator and worker counts to #raw("/metrics") endpoint. \(#issue("27408", "https://github.com/trinodb/trino/issues/27408")\)
- Allow configuring the maximum amount of memory to use while writing tables through the #raw("task.scale-writers.max-writer-memory-percentage") configuration property. \(#issue("27874", "https://github.com/trinodb/trino/issues/27874")\)
- Add variant of #link(label("fn-array-first"), raw("array_first")) for finding the first element that matches a predicate. \(#issue("27706", "https://github.com/trinodb/trino/issues/27706")\)
- Add #link(label("doc-functions-datasketches"))[DataSketches functions]. \(#issue("27563", "https://github.com/trinodb/trino/issues/27563")\)
- #breaking-marker("../release.html#breaking-changes") Remove #raw("enable-large-dynamic-filters") configuration property and the corresponding system session property #raw("enable_large_dynamic_filters"). \(#issue("27637", "https://github.com/trinodb/trino/issues/27637")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("dynamic-filtering.small*") and #raw("dynamic-filtering.large-broadcast*") configuration properties. \(#issue("27637", "https://github.com/trinodb/trino/issues/27637")\)
- #breaking-marker("../release.html#breaking-changes") Remove #raw("deprecated.http-server.authentication.oauth2.groups-field") configuration property. \(#issue("28646", "https://github.com/trinodb/trino/issues/28646")\)
- Improve performance for remote data exchanges on newer CPU architectures and Graviton 4 CPUs. \(#issue("27586", "https://github.com/trinodb/trino/issues/27586")\)
- Improve performance of queries with remote data exchanges or aggregations. \(#issue("27657", "https://github.com/trinodb/trino/issues/27657")\)
- Reduce out-of-memory errors for queries involving window functions when spilling is enabled. \(#issue("27873", "https://github.com/trinodb/trino/issues/27873")\)
- Improve query performance when exchange manager is configured but query does not use task level retries. \(#issue("28698", "https://github.com/trinodb/trino/issues/28698")\)
- Allow query parameters within table #raw("[VERSION | TIMESTAMP] AS OF") clause. \(#issue("28681", "https://github.com/trinodb/trino/issues/28681")\)
- Fix incorrect results when using #link(label("fn-localtimestamp"), raw("localtimestamp")) with precision 3. \(#issue("27806", "https://github.com/trinodb/trino/issues/27806")\)
- Fix #link(label("fn-localtimestamp"), raw("localtimestamp")) failure for precisions 7 and 8. \(#issue("27807", "https://github.com/trinodb/trino/issues/27807")\)
- Fix spurious query failures when querying the #raw("system") catalog during catalog drop operations. \(#issue("28017", "https://github.com/trinodb/trino/issues/28017")\)
- Fix failure when executing #link(label("fn-date-add"), raw("date_add")) function with a value greater than #raw("Integer.MAX_VALUE"). \(#issue("27899", "https://github.com/trinodb/trino/issues/27899")\)
- Fix incorrect results when the result of casting #raw("json"), #raw("time"), #raw("boolean") or #raw("interval") values to #raw("varchar(n)") doesn't fit in the target type. \(#issue("552", "https://github.com/trinodb/trino/issues/552")\)
- Fix query failures and increased latency when using Azure exchange manager. \(#issue("28058", "https://github.com/trinodb/trino/issues/28058")\)

== Web UI

- Add cluster status info to the header in the preview UI. \(#issue("27712", "https://github.com/trinodb/trino/issues/27712")\)
- Sort stages in the query details page numerically rather than alphabetically. \(#issue("27655", "https://github.com/trinodb/trino/issues/27655")\)

== JDBC driver

- Return the correct class name for #raw("map"), #raw("row"), #raw("time with time zone"), #raw("timestamp with time zone"), #raw("varbinary") and #raw("null") values when calling #raw("ResultSetMetaData.getColumnClassName"). \(#issue("28314", "https://github.com/trinodb/trino/issues/28314")\)

== ClickHouse connector

- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Delta Lake connector

- #breaking-marker("../release.html#breaking-changes") Remove live files table metadata cache. The configuration properties #raw("metadata.live-files.cache-size"), #raw("metadata.live-files.cache-ttl") and #raw("checkpoint-filtering.enabled") are now defunct and must be removed from server configurations. \(#issue("27618", "https://github.com/trinodb/trino/issues/27618")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.write-validation-threads") configuration property. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("parquet.optimized-writer.validation-percentage") configuration property, use #raw("parquet.writer.validation-percentage"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.block-size") configuration property, use #raw("parquet.writer.block-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.page-size") configuration property, use #raw("parquet.writer.page-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("gcs.use-access-token") configuration property. \(#issue("26941", "https://github.com/trinodb/trino/issues/26941")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.fs.new-file-inherit-ownership") configuration property. \(#issue("28029", "https://github.com/trinodb/trino/issues/28029")\)
- Improve the effectiveness of Bloom filters for high-cardinality columns in Parquet files. \(#issue("27656", "https://github.com/trinodb/trino/issues/27656")\)
- Remove the requirement for the #raw("PutObjectTagging") AWS S3 permission when writing to Delta Lake tables on S3. \(#issue("27701", "https://github.com/trinodb/trino/issues/27701")\)
- Fix potential table corruption when executing #raw("CREATE OR REPLACE") with table definition changes. \(#issue("27805", "https://github.com/trinodb/trino/issues/27805")\)
- Fix query failures and increased latency when using Azure file system. \(#issue("28058", "https://github.com/trinodb/trino/issues/28058")\)
- Fix failure when the file path contains #raw("#") in GCS. \(#issue("28292", "https://github.com/trinodb/trino/issues/28292")\)
- Fix NPE when loading parquet column index with non stats supported column. \(#issue("28560", "https://github.com/trinodb/trino/issues/28560")\)

== DuckDB connector

- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Hive connector

- Add support for reading nanosecond-precision timestamps from Parquet files into #raw("timestamp(p) with time zone") columns. \(#issue("27861", "https://github.com/trinodb/trino/issues/27861")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.write-validation-threads") configuration property. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("parquet.optimized-writer.validation-percentage") configuration property, use the #raw("parquet.writer.validation-percentage"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.block-size") configuration property, use #raw("parquet.writer.block-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.page-size") configuration property, use #raw("parquet.writer.page-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("gcs.use-access-token") configuration property. \(#issue("26941", "https://github.com/trinodb/trino/issues/26941")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.fs.new-file-inherit-ownership") configuration property. \(#issue("28029", "https://github.com/trinodb/trino/issues/28029")\)
- Improve the effectiveness of Bloom filters for high-cardinality columns in Parquet files. \(#issue("27656", "https://github.com/trinodb/trino/issues/27656")\)
- Fix query failures and increased latency when using Azure file system. \(#issue("28058", "https://github.com/trinodb/trino/issues/28058")\)
- Fix incorrect memory accounting for #raw("INSERT") queries targeting bucketed and sorted tables. \(#issue("28315", "https://github.com/trinodb/trino/issues/28315")\)
- Fix #raw("INSERT") into and #raw("ANALYZE") on tables with #raw("timestamp") columns when using Hive metastore version 4. \(#issue("26214", "https://github.com/trinodb/trino/issues/26214"), #issue("28330", "https://github.com/trinodb/trino/issues/28330")\)

== Hudi connector

- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.write-validation-threads") configuration property. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("parquet.optimized-writer.validation-percentage") configuration property, use #raw("parquet.writer.validation-percentage"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.block-size") configuration property, use #raw("parquet.writer.block-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.page-size") configuration property, use #raw("parquet.writer.page-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("gcs.use-access-token") configuration property. \(#issue("26941", "https://github.com/trinodb/trino/issues/26941")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.fs.new-file-inherit-ownership") configuration property. \(#issue("28029", "https://github.com/trinodb/trino/issues/28029")\)
- Fix query failures and increased latency when using Azure file system. \(#issue("28058", "https://github.com/trinodb/trino/issues/28058")\)
- Fix failure when the file path contains #raw("#") in GCS. \(#issue("28292", "https://github.com/trinodb/trino/issues/28292")\)

== Iceberg connector

- Add support for the BigLake metastore in Iceberg REST catalog. \(#issue("26219", "https://github.com/trinodb/trino/issues/26219")\)
- Add #raw("delete_after_commit_enabled") and #raw("max_previous_versions") table properties. \(#issue("14128", "https://github.com/trinodb/trino/issues/14128")\)
- Add support for column default values in Iceberg v3 tables. \(#issue("27837", "https://github.com/trinodb/trino/issues/27837")\)
- Add support for creating, writing to or deleting from Iceberg v3 tables. \(#issue("27786", "https://github.com/trinodb/trino/issues/27786"), #issue("27788", "https://github.com/trinodb/trino/issues/27788")\)
- Add support for Iceberg v3 tables in #raw("optimize"), #raw("expire_snapshots") and #raw("remove_orphan_files") table procedures. \(#issue("27836", "https://github.com/trinodb/trino/issues/27836")\)
- Add support for Iceberg v3 #link("https://iceberg.apache.org/spec/#row-lineage")[row lineage]. \(#issue("27836", "https://github.com/trinodb/trino/issues/27836")\)
- Add #raw("content") column to #raw("$manifests") and #raw("$all_manifests") metadata tables. \(#issue("27975", "https://github.com/trinodb/trino/issues/27975")\)
- Add support for changing #raw("map") and #raw("array") nested types through #raw("ALTER ... SET DATA TYPE"). \(#issue("27998", "https://github.com/trinodb/trino/issues/27998")\)
- Add support for creating materialized views with columns of #raw("number") type. \(#issue("28399", "https://github.com/trinodb/trino/issues/28399")\)
- Clean up unused files from materialized views when they are refreshed. \(#issue("28008", "https://github.com/trinodb/trino/issues/28008")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.write-validation-threads") configuration property. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("parquet.optimized-writer.validation-percentage") configuration property, use #raw("parquet.writer.validation-percentage"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.block-size") configuration property, use #raw("parquet.writer.block-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.parquet.writer.page-size") configuration property, use #raw("parquet.writer.page-size"), instead. \(#issue("27729", "https://github.com/trinodb/trino/issues/27729")\)
- #breaking-marker("../release.html#breaking-changes") Remove the deprecated #raw("gcs.use-access-token") configuration property. \(#issue("26941", "https://github.com/trinodb/trino/issues/26941")\)
- #breaking-marker("../release.html#breaking-changes") Remove the #raw("hive.fs.new-file-inherit-ownership") configuration property. \(#issue("28029", "https://github.com/trinodb/trino/issues/28029")\)
- #breaking-marker("../release.html#breaking-changes") Remove support for the #raw("iceberg.extended-statistics.enabled") configuration option and #raw("extended_statistics_enabled") session property. \(#issue("27914", "https://github.com/trinodb/trino/issues/27914")\)
- Improve the effectiveness of Bloom filters for high-cardinality columns in Parquet files. \(#issue("27656", "https://github.com/trinodb/trino/issues/27656")\)
- Improve query performance when querying a fresh materialized view. \(#issue("27608", "https://github.com/trinodb/trino/issues/27608")\)
- Improve #raw("optimize") to clean up partition scoped equality delete files when a partition filter is used. \(#issue("28371", "https://github.com/trinodb/trino/issues/28371")\)
- Enhance #raw("optimize_manifests") to cluster manifests by partition, improving read performance for queries that apply partition filters. \(#issue("27358", "https://github.com/trinodb/trino/issues/27358")\)
- Reduce planning time of queries on tables containing delete files. \(#issue("27955", "https://github.com/trinodb/trino/issues/27955")\)
- Reduce planning time for queries involving simple #raw("FROM") and #raw("WHERE") clauses. \(#issue("27973", "https://github.com/trinodb/trino/issues/27973")\)
- Reduce query planning time on large tables. \(#issue("28068", "https://github.com/trinodb/trino/issues/28068")\)
- Add support for temporary GCS credentials provided by REST catalog. \(#issue("24518", "https://github.com/trinodb/trino/issues/24518")\)
- Fix failure when reading #raw("$files") metadata tables when scheme involving #raw("bucket") or #raw("truncate") changes. \(#issue("26109", "https://github.com/trinodb/trino/issues/26109")\)
- Fix failure when reading #raw("$file_modified_time") metadata column on tables with equality deletes. \(#issue("27850", "https://github.com/trinodb/trino/issues/27850")\)
- Avoid large footers in Parquet files from certain rare string inputs. \(#issue("27903", "https://github.com/trinodb/trino/issues/27903")\)
- Fix failures for queries with joins on metadata columns. \(#issue("27984", "https://github.com/trinodb/trino/issues/27984")\)
- Fix query failures and increased latency when using Azure file system. \(#issue("28058", "https://github.com/trinodb/trino/issues/28058")\)
- Fix incorrect memory accounting for #raw("INSERT") queries targeting bucketed and sorted tables. \(#issue("28315", "https://github.com/trinodb/trino/issues/28315")\)
- Fix an issue where using #raw("ALTER TABLE ... SET PROPERTIES") to set partition spec unintentionally removed existing partition columns from the partition spec. \(#issue("26492", "https://github.com/trinodb/trino/issues/26492")\)
- Fix failures when reading from tables with #raw("write.parquet.compression-codec") property set to #raw("LZ4"). \(#issue("28291", "https://github.com/trinodb/trino/issues/28291")\)
- Fix value of #raw("compression-codec") table property written by Trino to be compliant with Iceberg spec. \(#issue("28293", "https://github.com/trinodb/trino/issues/28293")\)
- Fix failure when the file path contains #raw("#") in GCS. \(#issue("28292", "https://github.com/trinodb/trino/issues/28292")\)
- Fix failure when reading tables with #raw("iceberg.jdbc-catalog.schema-version=V0"). \(#issue("28419", "https://github.com/trinodb/trino/issues/28419")\)
- Avoid worker crashes when reading from tables with a larger number of equality deletes. \(#issue("28468", "https://github.com/trinodb/trino/issues/28468")\)
- Fix failure when querying #raw("$files") table after #raw("CREATE OR REPLACE TABLE") with a different partitioning schema. \(#issue("25339", "https://github.com/trinodb/trino/issues/25339")\)

== Ignite connector

- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Lakehouse connector

- Improved performance and memory usage when #link("https://iceberg.apache.org/spec/#equality-delete-files")[Equality Delete] files are used \(#issue("28507", "https://github.com/trinodb/trino/issues/28507")\)
- Fix failure when reading Iceberg #raw("$files") tables. \(#issue("26751", "https://github.com/trinodb/trino/issues/26751")\)

== MariaDB connector

- Add support for reading MariaDB #raw("DECIMAL(p, s)") columns when #raw("p > 38"). \(#issue("28744", "https://github.com/trinodb/trino/issues/28744")\)
- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== MySQL connector

- Add support for reading MySQL #raw("DECIMAL(p, s)") columns when #raw("p > 38"). \(#issue("28744", "https://github.com/trinodb/trino/issues/28744")\)
- #breaking-marker("../release.html#breaking-changes") Remove incorrect support for reading MySQL #raw("BIT(n)") columns when #raw("n > 1"). \(#issue("28744", "https://github.com/trinodb/trino/issues/28744")\)
- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Oracle connector

- Add support for configuring the connection wait timeout through the #raw("oracle.connection-pool.wait-timeout") catalog property. \(#issue("27744", "https://github.com/trinodb/trino/issues/27744")\)
- Add support for reading all Oracle #raw("NUMBER") columns. \(#issue("28747", "https://github.com/trinodb/trino/issues/28747"), #issue("28401", "https://github.com/trinodb/trino/issues/28401")\)
- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)
- Fix failure when reading #raw("float") type in #raw("query") table function. \(#issue("27880", "https://github.com/trinodb/trino/issues/27880")\)

== PostgreSQL connector

- Add support for reading all PostgreSQL #raw("NUMERIC") and #raw("DECIMAL") columns. \(#issue("28141", "https://github.com/trinodb/trino/issues/28141")\)
- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Redshift connector

- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== SingleStore connector

- Remove incorrect support for reading SingleStore #raw("BIT(n)") columns when #raw("n > 1"). \(#issue("28744", "https://github.com/trinodb/trino/issues/28744")\)
- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Snowflake connector

- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== SQL Server connector

- Fix failure when creating a table if a prior #raw("CREATE TABLE ... AS SELECT") operation for the same table failed. \(#issue("27702", "https://github.com/trinodb/trino/issues/27702")\)

== Vertica connector

- #breaking-marker("../release.html#breaking-changes") Remove the Vertica connector. \(#issue("26904", "https://github.com/trinodb/trino/issues/26904")\)

== SPI

- Remove support for #raw("TypeSignatureParameter"). Use #raw("TypeParameter") instead. \(#issue("27574", "https://github.com/trinodb/trino/issues/27574")\)
- Remove support for #raw("ParameterKind"). Use #raw("TypeParameter.Type"), #raw("TypeParameter.Numeric"), and #raw("TypeParameter.Variable") instead. \(#issue("27574", "https://github.com/trinodb/trino/issues/27574")\)
- Remove support for #raw("NamedType"), #raw("NamedTypeSignature") and #raw("NamedTypeParameter"). Use #raw("TypeParameter.Type") instead. \(#issue("27574", "https://github.com/trinodb/trino/issues/27574")\)
- Deprecate #raw("MaterializedViewFreshness#getLastFreshTime"). Use #raw("getLastKnownFreshTime") instead. \(#issue("27803", "https://github.com/trinodb/trino/issues/27803")\)
- Change #raw("ColumnMetadata.comment") and #raw("ColumnMetadata.extraInfo") to #raw("Optional<String>"). \(#issue("28151", "https://github.com/trinodb/trino/issues/28151")\)
