#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-427")
= Release 427 \(26 Sep 2023\)

== General

- Add support for comparing IPv4 and IPv6 addresses and CIDRs with #link(label("ref-ip-address-contains"))[contains]. \(#issue("18497", "https://github.com/trinodb/trino/issues/18497")\)
- Improve performance of #raw("GROUP BY") and #raw("DISTINCT"). \(#issue("19059", "https://github.com/trinodb/trino/issues/19059")\)
- Reduce coordinator memory footprint when scannning tables. \(#issue("19009", "https://github.com/trinodb/trino/issues/19009")\)
- Fix failure due to exceeding node memory limits with #raw("INSERT") statements. \(#issue("18771", "https://github.com/trinodb/trino/issues/18771")\)
- Fix query hang for certain #raw("LIKE") patterns involving a mix of #raw("%") and #raw("_"). \(#issue("19146", "https://github.com/trinodb/trino/issues/19146")\)

== Security

- Ensure authorization is checked when accessing table comments with table redirections. \(#issue("18514", "https://github.com/trinodb/trino/issues/18514")\)

== Delta Lake connector

- Add support for reading tables with #link("https://docs.delta.io/latest/delta-deletion-vectors.html")[Deletion Vectors]. \(#issue("16903", "https://github.com/trinodb/trino/issues/16903")\)
- Add support for Delta Lake writer #link("https://docs.delta.io/latest/versioning.html#features-by-protocol-version")[version 7]. \(#issue("15873", "https://github.com/trinodb/trino/issues/15873")\)
- Add support for writing columns with the #raw("timestamp(p)") type. \(#issue("16927", "https://github.com/trinodb/trino/issues/16927")\)
- Reduce data read from Parquet files for queries with filters. \(#issue("19032", "https://github.com/trinodb/trino/issues/19032")\)
- Improve performance of writing to Parquet files. \(#issue("19122", "https://github.com/trinodb/trino/issues/19122")\)
- Fix error reading Delta Lake table history when the initial transaction logs have been removed. \(#issue("18845", "https://github.com/trinodb/trino/issues/18845")\)

== Elasticsearch connector

- Fix query failure when a #raw("LIKE") clause contains multi-byte characters. \(#issue("18966", "https://github.com/trinodb/trino/issues/18966")\)

== Hive connector

- Add support for changing column comments when using the Glue catalog. \(#issue("19076", "https://github.com/trinodb/trino/issues/19076")\)
- Reduce data read from Parquet files for queries with filters. \(#issue("19032", "https://github.com/trinodb/trino/issues/19032")\)
- Improve performance of reading text files. \(#issue("18959", "https://github.com/trinodb/trino/issues/18959")\)
- Allow changing a column's type from #raw("double") to #raw("varchar") in Hive tables. \(#issue("18930", "https://github.com/trinodb/trino/issues/18930")\)
- Remove legacy Hive readers and writers. The #raw("*_native_reader_enabled") and #raw("*_native_writer_enabled") session properties and #raw("*.native-reader.enabled") and #raw("*.native-writer.enabled") configuration properties are removed. \(#issue("18241", "https://github.com/trinodb/trino/issues/18241")\)
- Remove support for S3 Select. The #raw("s3_select_pushdown_enabled") session property and the #raw("hive.s3select*") configuration properties are removed. \(#issue("18241", "https://github.com/trinodb/trino/issues/18241")\)
- Remove support for disabling optimized symlink listing. The #raw("optimize_symlink_listing") session property and #raw("hive.optimize-symlink-listing") configuration property are removed. \(#issue("18241", "https://github.com/trinodb/trino/issues/18241")\)
- Fix incompatibility with Hive OpenCSV deserialization. As a result, when the escape character is explicitly set to #raw("\""), a #raw("\\") \(backslash\) must be used instead. \(#issue("18918", "https://github.com/trinodb/trino/issues/18918")\)
- Fix performance regression when reading CSV files on AWS S3. \(#issue("18976", "https://github.com/trinodb/trino/issues/18976")\)
- Fix failure when creating a table with a #raw("varchar(0)") column. \(#issue("18811", "https://github.com/trinodb/trino/issues/18811")\)

== Hudi connector

- Fix query failure when reading from Hudi tables with #link("https://hudi.apache.org/docs/concepts/#timeline")[#raw("instants")] that have been replaced. \(#issue("18213", "https://github.com/trinodb/trino/issues/18213")\)

== Iceberg connector

- Add support for usage of #raw("date") and #raw("timestamp") arguments in #raw("FOR TIMESTAMP AS OF") expressions. \(#issue("14214", "https://github.com/trinodb/trino/issues/14214")\)
- Add support for using tags with #raw("AS OF VERSION") queries. \(#issue("19111", "https://github.com/trinodb/trino/issues/19111")\)
- Reduce data read from Parquet files for queries with filters. \(#issue("19032", "https://github.com/trinodb/trino/issues/19032")\)
- Improve performance of writing to Parquet files. \(#issue("19090", "https://github.com/trinodb/trino/issues/19090")\)
- Improve performance of reading tables with many equality delete files. \(#issue("17114", "https://github.com/trinodb/trino/issues/17114")\)

== Ignite connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)

== MariaDB connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)

== MongoDB connector

- Fix query failure when mapping MongoDB #raw("Decimal128") values with leading zeros. \(#issue("19068", "https://github.com/trinodb/trino/issues/19068")\)

== MySQL connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)
- Change mapping for MySQL #raw("TIMESTAMP") types from #raw("timestamp(n)") to #raw("timestamp(n) with time zone"). \(#issue("18470", "https://github.com/trinodb/trino/issues/18470")\)

== Oracle connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)
- Fix potential query failure when joins are pushed down to Oracle. \(#issue("18924", "https://github.com/trinodb/trino/issues/18924")\)

== PostgreSQL connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)

== Redshift connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)

== SingleStore connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)

== SQL Server connector

- Add support for #raw("UPDATE"). \(#issue("16445", "https://github.com/trinodb/trino/issues/16445")\)

== SPI

- Change #raw("BlockBuilder") to no longer extend #raw("Block"). \(#issue("18738", "https://github.com/trinodb/trino/issues/18738")\)
