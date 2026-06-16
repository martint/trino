#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-338")
= Release 338 \(07 Jul 2020\)

== General

- Fix incorrect results when joining tables on a masked column. \(#issue("4251", "https://github.com/trinodb/trino/issues/4251")\)
- Fix planning failure when multiple columns have a mask. \(#issue("4322", "https://github.com/trinodb/trino/issues/4322")\)
- Fix incorrect comparison for #raw("TIMESTAMP WITH TIME ZONE") values with precision larger than 3. \(#issue("4305", "https://github.com/trinodb/trino/issues/4305")\)
- Fix incorrect rounding for timestamps before 1970-01-01. \(#issue("4370", "https://github.com/trinodb/trino/issues/4370")\)
- Fix query failure when using #raw("VALUES") with a floating point #raw("NaN") value. \(#issue("4119", "https://github.com/trinodb/trino/issues/4119")\)
- Fix query failure when joining tables on a #raw("real") or #raw("double") column and one of the joined tables contains #raw("NaN") value. \(#issue("4272", "https://github.com/trinodb/trino/issues/4272")\)
- Fix unauthorized error for internal requests to management endpoints. \(#issue("4304", "https://github.com/trinodb/trino/issues/4304")\)
- Fix memory leak while using dynamic filtering. \(#issue("4228", "https://github.com/trinodb/trino/issues/4228")\)
- Improve dynamic partition pruning for broadcast joins. \(#issue("4262", "https://github.com/trinodb/trino/issues/4262")\)
- Add support for setting column comments via the #raw("COMMENT ON COLUMN") syntax. \(#issue("2516", "https://github.com/trinodb/trino/issues/2516")\)
- Add compatibility mode for legacy clients when rendering datetime type names with default precision in #raw("information_schema") tables. This can be enabled via the #raw("deprecated.omit-datetime-type-precision") configuration property or #raw("omit_datetime_type_precision") session property. \(#issue("4349", "https://github.com/trinodb/trino/issues/4349"), #issue("4377", "https://github.com/trinodb/trino/issues/4377")\)
- Enforce #raw("NOT NULL") column declarations when writing data. \(#issue("4144", "https://github.com/trinodb/trino/issues/4144")\)

== JDBC driver

- Fix excessive CPU usage when reading query results. \(#issue("3928", "https://github.com/trinodb/trino/issues/3928")\)
- Implement #raw("DatabaseMetaData.getClientInfoProperties()"). \(#issue("4318", "https://github.com/trinodb/trino/issues/4318")\)

== Elasticsearch connector

- Add support for reading numeric values encoded as strings. \(#issue("4341", "https://github.com/trinodb/trino/issues/4341")\)

== Hive connector

- Fix incorrect query results when Parquet file has no min\/max statistics for an integral column. \(#issue("4200", "https://github.com/trinodb/trino/issues/4200")\)
- Fix query failure when reading from a table partitioned on a #raw("real") or #raw("double") column containing a #raw("NaN") value. \(#issue("4266", "https://github.com/trinodb/trino/issues/4266")\)
- Fix sporadic failure when writing to bucketed sorted tables on S3. \(#issue("2296", "https://github.com/trinodb/trino/issues/2296")\)
- Fix handling of strings when translating Hive views. \(#issue("3266", "https://github.com/trinodb/trino/issues/3266")\)
- Do not require cache directories to be configured on coordinator. \(#issue("3987", "https://github.com/trinodb/trino/issues/3987"), #issue("4280", "https://github.com/trinodb/trino/issues/4280")\)
- Fix Azure ADL caching support. \(#issue("4240", "https://github.com/trinodb/trino/issues/4240")\)
- Add support for setting column comments. \(#issue("2516", "https://github.com/trinodb/trino/issues/2516")\)
- Add hidden #raw("$partition") column for partitioned tables that contains the partition name. \(#issue("3582", "https://github.com/trinodb/trino/issues/3582")\)

== Kafka connector

- Fix query failure when a column is projected and also referenced in a query predicate when reading from Kafka topic using #raw("RAW") decoder. \(#issue("4183", "https://github.com/trinodb/trino/issues/4183")\)

== MySQL connector

- Fix type mapping for unsigned integer types. \(#issue("4187", "https://github.com/trinodb/trino/issues/4187")\)

== Oracle connector

- Exclude internal schemas \(e.g., sys\) from schema listings. \(#issue("3784", "https://github.com/trinodb/trino/issues/3784")\)
- Add support for connection pooling. \(#issue("3770", "https://github.com/trinodb/trino/issues/3770")\)

== Base-JDBC connector library

- Exclude the underlying database's #raw("information_schema") from schema listings. \(#issue("3834", "https://github.com/trinodb/trino/issues/3834")\)
