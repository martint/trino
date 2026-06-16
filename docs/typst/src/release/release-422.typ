#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-422")
= Release 422 \(13 Jul 2023\)

== General

- Add support for adding nested fields with an #raw("ADD COLUMN") statement. \(#issue("16248", "https://github.com/trinodb/trino/issues/16248")\)
- Improve performance of #raw("INSERT") and #raw("CREATE TABLE AS ... SELECT") queries. \(#issue("18005", "https://github.com/trinodb/trino/issues/18005")\)
- Prevent queries from hanging when worker nodes fail and the #raw("task.retry-policy") configuration property is set to #raw("TASK"). \(#issue("18175 ", "https://github.com/trinodb/trino/issues/18175 ")\)

== Security

- Add support for validating JWT types with OAuth 2.0 authentication. \(#issue("17640", "https://github.com/trinodb/trino/issues/17640")\)
- Fix error when the #raw("http-server.authentication.type") configuration property is set to #raw("oauth2") or #raw("jwt") and the #raw("principal-field") property's value differs. \(#issue("18210", "https://github.com/trinodb/trino/issues/18210")\)

== BigQuery connector

- Add support for writing to columns with a #raw("timestamp(p) with time zone") type. \(#issue("17793", "https://github.com/trinodb/trino/issues/17793")\)

== Delta Lake connector

- Add support for renaming columns. \(#issue("15821", "https://github.com/trinodb/trino/issues/15821")\)
- Improve performance of reading from tables with a large number of #link("https://docs.delta.io/latest/delta-batch.html#-data-retention")[checkpoints]. \(#issue("17405", "https://github.com/trinodb/trino/issues/17405")\)
- Disallow using the #raw("vacuum") procedure when the max #link("https://docs.delta.io/latest/versioning.html#features-by-protocol-version")[writer version] is above 5. \(#issue("18095", "https://github.com/trinodb/trino/issues/18095")\)

== Hive connector

- Add support for reading the #raw("timestamp with local time zone") Hive type. \(#issue("1240", "https://github.com/trinodb/trino/issues/1240")\)
- Add a native Avro file format writer. This can be disabled with the #raw("avro.native-writer.enabled") configuration property or the #raw("avro_native_writer_enabled") session property. \(#issue("18064", "https://github.com/trinodb/trino/issues/18064")\)
- Fix query failure when the #raw("hive.recursive-directories") configuration property is set to true and partition names contain non-alphanumeric characters. \(#issue("18167", "https://github.com/trinodb/trino/issues/18167")\)
- Fix incorrect results when reading text and #raw("RCTEXT") files with a value that contains the character that separates fields. \(#issue("18215", "https://github.com/trinodb/trino/issues/18215")\)
- Fix incorrect results when reading concatenated #raw("GZIP") compressed text files. \(#issue("18223", "https://github.com/trinodb/trino/issues/18223")\)
- Fix incorrect results when reading large text and sequence files with a single header row. \(#issue("18255", "https://github.com/trinodb/trino/issues/18255")\)
- Fix incorrect reporting of bytes read for compressed text files. \(#issue("1828", "https://github.com/trinodb/trino/issues/1828")\)

== Iceberg connector

- Add support for adding nested fields with an #raw("ADD COLUMN") statement. \(#issue("16248", "https://github.com/trinodb/trino/issues/16248")\)
- Add support for the #raw("register_table") procedure to register Hadoop tables. \(#issue("16363", "https://github.com/trinodb/trino/issues/16363")\)
- Change the default file format to Parquet. The #raw("iceberg.file-format") catalog configuration property can be used to specify a different default file format. \(#issue("18170", "https://github.com/trinodb/trino/issues/18170")\)
- Improve performance of reading #raw("row") types from Parquet files. \(#issue("17387", "https://github.com/trinodb/trino/issues/17387")\)
- Fix failure when writing to tables sorted on #raw("UUID") or #raw("TIME") types. \(#issue("18136", "https://github.com/trinodb/trino/issues/18136")\)

== Kudu connector

- Add support for table comments when creating tables. \(#issue("17945", "https://github.com/trinodb/trino/issues/17945")\)

== Redshift connector

- Prevent returning incorrect results by throwing an error when encountering unsupported types. Previously, the query would fall back to the legacy type mapping. \(#issue("18209", "https://github.com/trinodb/trino/issues/18209")\)
