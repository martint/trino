#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-477")
= Release 477 \(24 Sep 2025\)

== General

- Add #link(label("doc-connector-lakehouse"))[Lakehouse connector]. \(#issue("25347", "https://github.com/trinodb/trino/issues/25347")\)
- Add support for #link(label("doc-sql-alter-materialized-view"))[#raw("ALTER MATERIALIZED VIEW ... SET AUTHORIZATION")]. \(#issue("25910", "https://github.com/trinodb/trino/issues/25910")\)
- Add support for default column values when creating tables or adding new columns. \(#issue("25679", "https://github.com/trinodb/trino/issues/25679")\)
- Add support for #link(label("doc-sql-alter-view"))[#raw("ALTER VIEW ... REFRESH")]. \(#issue("25906", "https://github.com/trinodb/trino/issues/25906")\)
- Add support for managing and querying table branches. \(#issue("25751", "https://github.com/trinodb/trino/issues/25751"), #issue("26300", "https://github.com/trinodb/trino/issues/26300"), #issue("26136", "https://github.com/trinodb/trino/issues/26136")\)
- Add the #link(label("fn-cosine-distance"), raw("cosine_distance")) function for sparse vectors. \(#issue("24027", "https://github.com/trinodb/trino/issues/24027")\)
- #breaking-marker("../release.html#breaking-changes") Improve precision and scale inference for arithmetic operations with decimal values. The previous behavior can be restored by setting the #raw("deprecated.legacy-arithmetic-decimal-operators") config property to #raw("true"). \(#issue("26422", "https://github.com/trinodb/trino/issues/26422")\)
- #breaking-marker("../release.html#breaking-changes") Remove the HTTP server event listener plugin from the server binary distribution and the Docker container. \(#issue("25967", "https://github.com/trinodb/trino/issues/25967")\)
- #breaking-marker("../release.html#breaking-changes") Enforce requirement for catalogs to be deployed in all nodes. \(#issue("26063", "https://github.com/trinodb/trino/issues/26063")\)
- Add #raw("query.max-write-physical-size") configuration property and #raw("query_max_write_physical_size") session property to allow configuring limits on the amount of data written by a query. \(#issue("25955", "https://github.com/trinodb/trino/issues/25955")\)
- Add #raw("system.metadata.tables_authorization"), #raw("system.metadata.schemas_authorization"), #raw("system.metadata.functions_authorization") tables that expose the information about the authorization for given entities. \(#issue("25907", "https://github.com/trinodb/trino/issues/25907")\)
- Add physical data scan tracking to resource groups. \(#issue("25003", "https://github.com/trinodb/trino/issues/25003")\)
- Add #raw("internal_network_input_bytes") column to #raw("system.runtime.tasks") table. \(#issue("26524", "https://github.com/trinodb/trino/issues/26524")\)
- Add support for #raw("Geometry") type in #link(label("fn-to-geojson-geometry"), raw("to_geojson_geometry")). \(#issue("26451", "https://github.com/trinodb/trino/issues/26451")\)
- Remove #raw("raw_input_bytes") and #raw("raw_input_rows") columns from #raw("system.runtime.tasks") table. \(#issue("26524", "https://github.com/trinodb/trino/issues/26524")\)
- Do not include catalogs that failed to load in #raw("system.metadata.catalogs"). \(#issue("26493", "https://github.com/trinodb/trino/issues/26493")\)
- Simplify node discovery configuration for Kubernetes-like environments that provide DNS names for all workers when the #raw("discovery.type") config property is set to #raw("dns"). \(#issue("26119", "https://github.com/trinodb/trino/issues/26119")\)
- Improve memory usage for certain queries involving #link(label("fn-row-number"), raw("row_number")), #link(label("fn-rank"), raw("rank")), #link(label("fn-dense-rank"), raw("dense_rank")), and #raw("ORDER BY ... LIMIT"). \(#issue("25946", "https://github.com/trinodb/trino/issues/25946")\)
- Improve memory usage for queries involving #raw("GROUP BY"). \(#issue("25879", "https://github.com/trinodb/trino/issues/25879")\)
- Reduce memory required for queries containing aggregations with a #raw("DISTINCT") or #raw("ORDER BY") clause. \(#issue("26276", "https://github.com/trinodb/trino/issues/26276")\)
- Improve performance of simple queries in clusters with small number of nodes. \(#issue("26525", "https://github.com/trinodb/trino/issues/26525")\)
- Improve cluster stability when querying slow data sources and queries terminate early or are cancelled. \(#issue("26602", "https://github.com/trinodb/trino/issues/26602")\)
- Improve join and aggregation reliability when spilling. \(#issue("25892", "https://github.com/trinodb/trino/issues/25892"), #issue("25976", "https://github.com/trinodb/trino/issues/25976")\)
- Ensure spill files are cleaned up for queries involving #raw("GROUP BY"). \(#issue("26141", "https://github.com/trinodb/trino/issues/26141")\)
- Reduce out-of-memory errors for queries involving joins. \(#issue("26142", "https://github.com/trinodb/trino/issues/26142")\)
- Fix incorrect results for queries involving #raw("GROUP BY") when spilling is enabled. \(#issue("25892", "https://github.com/trinodb/trino/issues/25892")\)
- Fix failure when aggregation exists in other expressions in #raw("GROUP BY AUTO"). \(#issue("25987", "https://github.com/trinodb/trino/issues/25987")\)
- Fix incorrect results for queries involving joins using #link(label("fn-st-contains"), raw("ST_Contains")), #link(label("fn-st-intersects"), raw("ST_Intersects")), and #link(label("fn-st-distance"), raw("ST_Distance")) functions. \(#issue("26021", "https://github.com/trinodb/trino/issues/26021")\)
- Fix out-of-memory failures when the client spooling protocol is enabled. \(#issue("25999", "https://github.com/trinodb/trino/issues/25999")\)
- Fix worker crashes due to JVM out-of-memory errors when running #raw("GROUP BY") queries with aggregations containing an #raw("ORDER BY") clause. \(#issue("26276", "https://github.com/trinodb/trino/issues/26276")\)
- Fix incorrectly ignored grant when access is granted through groups via #raw("SET SESSION AUTHORIZATION"). \(#issue("26344", "https://github.com/trinodb/trino/issues/26344")\)
- Fix incorrect results for #raw("geometry_to_bing_tiles"), where the tiles wouldn't cover the full geometry area. \(#issue("26459", "https://github.com/trinodb/trino/issues/26459")\)
- Fix over-reporting the amount of memory used when aggregating over #raw("ROW") values when nested inside of an #raw("ARRAY") type \(#issue("26405", "https://github.com/trinodb/trino/issues/26405")\)
- Improve accounting of physical input metrics in output of #raw("EXPLAIN ANALYZE"). \(#issue("26637", "https://github.com/trinodb/trino/issues/26637")\)

== Web UI

- Add query details page to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("25554", "https://github.com/trinodb/trino/issues/25554")\)
- Add query JSON page to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("26319", "https://github.com/trinodb/trino/issues/26319")\)
- Add query live plan flow page to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("26392", "https://github.com/trinodb/trino/issues/26392")\)
- Add query references page to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("26327", "https://github.com/trinodb/trino/issues/26327")\)
- Add query stages view to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("26440", "https://github.com/trinodb/trino/issues/26440")\)
- Add query live plan flow page to the #link(label("doc-admin-preview-web-interface"))[Preview Web UI]. \(#issue("26610", "https://github.com/trinodb/trino/issues/26610")\)
- Enhance UI responsiveness for Trino clusters without external network access. \(#issue("26031", "https://github.com/trinodb/trino/issues/26031")\)

== CLI

- Add support for keyboard navigation with #kbd("Alt+↑") or #kbd("Alt+↓") in query history. \(#issue("26138", "https://github.com/trinodb/trino/issues/26138")\)

== Delta Lake connector

- Add support for using GCS without credentials. \(#issue("25810", "https://github.com/trinodb/trino/issues/25810")\)
- Rename #raw("s3.socket-read-timeout") config property to #raw("s3.socket-timeout"). \(#issue("26263", "https://github.com/trinodb/trino/issues/26263")\)
- Add metrics for data read from filesystem cache in #raw("EXPLAIN ANALYZE VERBOSE") output. \(#issue("26342", "https://github.com/trinodb/trino/issues/26342")\)
- Improve resource utilization when using Alluxio. \(#issue("26121", "https://github.com/trinodb/trino/issues/26121")\)
- Improve resource utilization by releasing native filesystem resources as soon as possible. \(#issue("26085", "https://github.com/trinodb/trino/issues/26085")\)
- Improve throughput for write-heavy queries on Azure when the #raw("azure.multipart-write-enabled") config option is set to #raw("true"). \(#issue("26225", "https://github.com/trinodb/trino/issues/26225")\)
- Reduce query failures due to S3 throttling. \(#issue("26407", "https://github.com/trinodb/trino/issues/26407")\)
- Avoid worker crashes due to out-of-memory errors when decoding unusually large Parquet footers. \(#issue("25973", "https://github.com/trinodb/trino/issues/25973")\)
- Fix incorrect results when reading from Parquet files produced by old versions of PyArrow. \(#issue("26058", "https://github.com/trinodb/trino/issues/26058")\)
- Fix writing malformed checkpoint files when #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vector] is enabled. \(#issue("26145", "https://github.com/trinodb/trino/issues/26145")\)
- Fix failure when reading tables that contain null values in #raw("variant") columns. \(#issue("26016", "https://github.com/trinodb/trino/issues/26016"), #issue("26184", "https://github.com/trinodb/trino/issues/26184")\)
- Fix incorrect results when reading #raw("decimal") numbers from Parquet files and the declared precision differs from the precision described in the Parquet metadata. \(#issue("26203", "https://github.com/trinodb/trino/issues/26203")\)
- Fix incorrect results when a table uses #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[deletion vector] and its partition path contains special characters. \(#issue("26299", "https://github.com/trinodb/trino/issues/26299")\)

== Exasol connector

- Add support for Exasol #raw("hashtype") type. \(#issue("26512", "https://github.com/trinodb/trino/issues/26512")\)
- Improve performance for queries involving #raw("LIMIT"). \(#issue("26592", "https://github.com/trinodb/trino/issues/26592")\)

== Hive connector

- Add support for using GCS without credentials. \(#issue("25810", "https://github.com/trinodb/trino/issues/25810")\)
- Add support for reading tables using the #link("https://doc.arcgis.com/en/velocity/ingest/esrijson.htm")[Esri JSON] format. \(#issue("25241", "https://github.com/trinodb/trino/issues/25241")\)
- Add support for #raw("extended_boolean_literal") in text-file formats. \(#issue("21156", "https://github.com/trinodb/trino/issues/21156")\)
- Add metrics for data read from filesystem cache in #raw("EXPLAIN ANALYZE VERBOSE") output. \(#issue("26342", "https://github.com/trinodb/trino/issues/26342")\)
- Add support for Twitter Elephantbird protobuf deserialization. \(#issue("26305", "https://github.com/trinodb/trino/issues/26305")\)
- Rename #raw("s3.socket-read-timeout") config property to #raw("s3.socket-timeout"). \(#issue("26263", "https://github.com/trinodb/trino/issues/26263")\)
- Improve throughput for write-heavy queries on Azure when the #raw("azure.multipart-write-enabled") config option is set to #raw("true"). \(#issue("26225", "https://github.com/trinodb/trino/issues/26225")\)
- Reduce query failures due to S3 throttling. \(#issue("26407", "https://github.com/trinodb/trino/issues/26407")\)
- Avoid worker crashes due to out-of-memory errors when decoding unusually large Parquet footers. \(#issue("25973", "https://github.com/trinodb/trino/issues/25973")\)
- Improve resource utilization when using Alluxio. \(#issue("26121", "https://github.com/trinodb/trino/issues/26121")\)
- Fix incorrect results when reading from Parquet files produced by old versions of PyArrow. \(#issue("26058", "https://github.com/trinodb/trino/issues/26058")\)
- Fix reading #raw("partition_projection_format") column property for date partition projection. \(#issue("25642", "https://github.com/trinodb/trino/issues/25642")\)
- Fix incorrect results when reading #raw("decimal") numbers from Parquet files and the declared precision differs from the precision described in the Parquet metadata. \(#issue("26203", "https://github.com/trinodb/trino/issues/26203")\)
- Fix physical input read time metric for tables containing text files. \(#issue("26612", "https://github.com/trinodb/trino/issues/26612")\)
- Add support for reading Hive OpenCSV tables with quoting and escaping disabled. \(#issue("26619", "https://github.com/trinodb/trino/issues/26619")\)

== HTTP Event Listener

- Add support for configuring the HTTP method to use via the #raw("http-event-listener.connect-http-method") config property. \(#issue("26181", "https://github.com/trinodb/trino/issues/26181")\)

== Hudi connector

- Add support for configuring batch size for reads on Parquet files using the #raw("parquet.max-read-block-row-count") configuration property or the #raw("parquet_max_read_block_row_count") session property. \(#issue("25981", "https://github.com/trinodb/trino/issues/25981")\)
- Add support for using GCS without credentials. \(#issue("25810", "https://github.com/trinodb/trino/issues/25810")\)
- Rename #raw("s3.socket-read-timeout") config property to #raw("s3.socket-timeout"). \(#issue("26263", "https://github.com/trinodb/trino/issues/26263")\)
- Improve resource utilization when using Alluxio. \(#issue("26121", "https://github.com/trinodb/trino/issues/26121")\)
- Improve throughput for write-heavy queries on Azure when the #raw("azure.multipart-write-enabled") config option is set to #raw("true"). \(#issue("26225", "https://github.com/trinodb/trino/issues/26225")\)
- Reduce query failures due to S3 throttling. \(#issue("26407", "https://github.com/trinodb/trino/issues/26407")\)
- Avoid worker crashes due to out-of-memory errors when decoding unusually large Parquet footers. \(#issue("25973", "https://github.com/trinodb/trino/issues/25973")\)
- Fix incorrect results when reading from Parquet files produced by old versions of PyArrow. \(#issue("26058", "https://github.com/trinodb/trino/issues/26058")\)
- Fix incorrect results when reading #raw("decimal") numbers from Parquet files and the declared precision differs from the precision described in the Parquet metadata. \(#issue("26203", "https://github.com/trinodb/trino/issues/26203")\)

== Iceberg connector

- Add support for #raw("SIGV4") as an independent authentication scheme. It can be enabled by setting the #raw("iceberg.rest-catalog.security") config property to #raw("SIGV4"). The #raw("iceberg.rest-catalog.sigv4-enabled") config property is no longer supported. \(#issue("26218", "https://github.com/trinodb/trino/issues/26218")\)
- Add support for using GCS without credentials. \(#issue("25810", "https://github.com/trinodb/trino/issues/25810")\)
- Allow configuring the compression codec to use for reading a table via the #raw("compression_codec") table property. The #raw("compression_codec") session is no longer supported. \(#issue("25755", "https://github.com/trinodb/trino/issues/25755")\)
- Add metrics for data read from filesystem cache in #raw("EXPLAIN ANALYZE VERBOSE") output. \(#issue("26342", "https://github.com/trinodb/trino/issues/26342")\)
- Rename #raw("s3.socket-read-timeout") config property to #raw("s3.socket-timeout"). \(#issue("26263", "https://github.com/trinodb/trino/issues/26263")\)
- Improve performance of #raw("expire_snapshots") procedure. \(#issue("26230", "https://github.com/trinodb/trino/issues/26230")\)
- Improve performance of #raw("remove_orphan_files") procedure. \(#issue("26326", "https://github.com/trinodb/trino/issues/26326"), #issue("26438", "https://github.com/trinodb/trino/issues/26438")\)
- Improve performance of queries on #raw("$files") metadata table. \(#issue("25677", "https://github.com/trinodb/trino/issues/25677")\)
- Improve performance of writes to Iceberg tables when task retries are enabled. \(#issue("26620", "https://github.com/trinodb/trino/issues/26620")\)
- Reduce memory usage of #raw("remove_orphan_files") procedure. \(#issue("25847", "https://github.com/trinodb/trino/issues/25847")\)
- Improve throughput for write-heavy queries on Azure when the #raw("azure.multipart-write-enabled") config option is set to #raw("true"). \(#issue("26225", "https://github.com/trinodb/trino/issues/26225")\)
- Reduce query failures due to S3 throttling. \(#issue("26407", "https://github.com/trinodb/trino/issues/26407"), #issue("26432", "https://github.com/trinodb/trino/issues/26432")\)
- Avoid worker crashes due to out-of-memory errors when decoding unusually large Parquet footers. \(#issue("25973", "https://github.com/trinodb/trino/issues/25973")\)
- Improve resource utilization when using Alluxio. \(#issue("26121", "https://github.com/trinodb/trino/issues/26121")\)
- Reduce amount of metadata generated in writes to Iceberg tables. \(#issue("15439", "https://github.com/trinodb/trino/issues/15439")\)
- Fix performance regression and potential query failures for #raw("REFRESH MATERIALIZED VIEW"). \(#issue("26051", "https://github.com/trinodb/trino/issues/26051")\)
- Fix incorrect results when reading from Parquet files produced by old versions of PyArrow. \(#issue("26058", "https://github.com/trinodb/trino/issues/26058")\)
- Fix failure for #raw("optimize_manifests") procedure when top-level partition columns contain null values. \(#issue("26185", "https://github.com/trinodb/trino/issues/26185")\)
- Fix incorrect results when reading #raw("decimal") numbers from Parquet files and the declared precision differs from the precision described in the Parquet metadata. \(#issue("26203", "https://github.com/trinodb/trino/issues/26203")\)
- Fix coordinator out-of-memory failures when running #raw("OPTIMIZE_MANIFESTS") on partitioned tables. \(#issue("26323", "https://github.com/trinodb/trino/issues/26323")\)

== Kafka Event Listener

- Add support for configuring the max request size with the #raw("kafka-event-listener.max-request-size") config property. \(#issue("26129", "https://github.com/trinodb/trino/issues/26129")\)
- Add support for configuring the batch size with the #raw("kafka-event-listener.batch-size") config property. \(#issue("26129", "https://github.com/trinodb/trino/issues/26129")\)

== Memory connector

- Add support for default column values. \(#issue("25679", "https://github.com/trinodb/trino/issues/25679")\)
- Add support for #raw("ALTER VIEW ... REFRESH"). \(#issue("25906", "https://github.com/trinodb/trino/issues/25906")\)

== MongoDB connector

- Fix failure when reading array type with different element types. \(#issue("26585", "https://github.com/trinodb/trino/issues/26585")\)

== MySQL Event Listener

- Ignore startup failure if #raw("mysql-event-listener.terminate-on-initialization-failure") is disabled. \(#issue("26252", "https://github.com/trinodb/trino/issues/26252")\)

== OpenLineage Event Listener

- Add user identifying fields to the OpenLineage #raw("trino_query_context") facet. \(#issue("26074", "https://github.com/trinodb/trino/issues/26074")\)
- Add #raw("query_id") field to #raw("trino_metadata") facet. \(#issue("26074", "https://github.com/trinodb/trino/issues/26074")\)
- Allow customizing the job facet name with the #raw("openlineage-event-listener.job.name-format") config property. \(#issue("25535", "https://github.com/trinodb/trino/issues/25535")\)

== PostgreSQL connector

- Add support for #raw("geometry") types when #raw("PostGIS") is installed in schemas other than #raw("public"). \(#issue("25972", "https://github.com/trinodb/trino/issues/25972")\)

== SPI

- Remove #raw("ConnectorSession") from #raw("Type.getObjectValue"). \(#issue("25945", "https://github.com/trinodb/trino/issues/25945")\)
- Remove unused #raw("NodeManager.getEnvironment") method. \(#issue("26096", "https://github.com/trinodb/trino/issues/26096")\)
- Remove #raw("@Experimental") annotation. \(#issue("26200", "https://github.com/trinodb/trino/issues/26200")\)
- Remove deprecated #raw("ConnectorPageSource.getNextPage") method. \(#issue("26222", "https://github.com/trinodb/trino/issues/26222")\)
- Remove support for #raw("EventListener#splitCompleted"). \(#issue("26436", "https://github.com/trinodb/trino/issues/26436")\) and #raw("ConnectorMetadata.refreshMaterializedView"). \(#issue("26455", "https://github.com/trinodb/trino/issues/26455")\)
- Remove unused #raw("CatalogHandle") class. \(#issue("26520", "https://github.com/trinodb/trino/issues/26520")\)
- Change the signature of #raw("ConnectorMetadata.beginRefreshMaterializedView") and #raw("ConnectorMetadata.finishRefreshMaterializedView"). Table handles for other catalogs are no longer passed to these methods. \(#issue("26454", "https://github.com/trinodb/trino/issues/26454")\)
- Deprecate #raw("NodeManager.getCurrentNode") in favor of #raw("ConnectorContext.getCurrentNode"). \(#issue("26096", "https://github.com/trinodb/trino/issues/26096")\)
- Deprecate #raw("ConnectorMetadata.delegateMaterializedViewRefreshToConnector"). \(#issue("26455", "https://github.com/trinodb/trino/issues/26455")\)
- Remove #raw("totalBytes") and #raw("totalRows") from #raw("io.trino.spi.eventlistener.QueryStatistics"). \(#issue("26524", "https://github.com/trinodb/trino/issues/26524")\)
