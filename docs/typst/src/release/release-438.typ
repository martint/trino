#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-438")
= Release 438 \(1 Feb 2024\)

== General

- Add support for using types such as #raw("char"), #raw("varchar"), #raw("uuid"), #raw("ip_address"), #raw("geometry"), and others with the #link(label("fn-reduce-agg"), raw("reduce_agg")) function. \(#issue("20452", "https://github.com/trinodb/trino/issues/20452")\)
- Fix query failure when using #raw("char") types with the #link(label("fn-reverse"), raw("reverse")) function. \(#issue("20387", "https://github.com/trinodb/trino/issues/20387")\)
- Fix potential query failure when using the #link(label("fn-max-by"), raw("max_by")) function on large datasets. \(#issue("20524", "https://github.com/trinodb/trino/issues/20524")\)
- Fix query failure when querying data with deeply nested rows. \(#issue("20529", "https://github.com/trinodb/trino/issues/20529")\)

== Security

- Add support for access control with #link(label("doc-security-opa-access-control"))[Open Policy Agent]. \(#issue("19532", "https://github.com/trinodb/trino/issues/19532")\)

== Delta Lake connector

- Add support for configuring the maximum number of values per page when writing to Parquet files with the #raw("parquet.writer.page-value-count") configuration property or the #raw("parquet_writer_page_value_count") session property. \(#issue("20171", "https://github.com/trinodb/trino/issues/20171")\)
- Add support for #raw("ALTER COLUMN ... DROP NOT NULL") statements. \(#issue("20448", "https://github.com/trinodb/trino/issues/20448")\)

== Hive connector

- Add support for configuring the maximum number of values per page when writing to Parquet files with the #raw("parquet.writer.page-value-count") configuration property or the #raw("parquet_writer_page_value_count") session property. \(#issue("20171", "https://github.com/trinodb/trino/issues/20171")\)

== Iceberg connector

- Add support for #raw("ALTER COLUMN ... DROP NOT NULL") statements. \(#issue("20315", "https://github.com/trinodb/trino/issues/20315")\)
- Add support for configuring the maximum number of values per page when writing to Parquet files with the #raw("parquet.writer.page-value-count") configuration property or the #raw("parquet_writer_page_value_count") session property. \(#issue("20171", "https://github.com/trinodb/trino/issues/20171")\)
- Add support for #raw("array"), #raw("map") and #raw("row") types in the #raw("migrate") table procedure. \(#issue("17583", "https://github.com/trinodb/trino/issues/17583")\)

== Pinot connector

- Add support for the #raw("date") type. \(#issue("13059", "https://github.com/trinodb/trino/issues/13059")\)

== PostgreSQL connector

- Add support for #raw("ALTER COLUMN ... DROP NOT NULL") statements. \(#issue("20315", "https://github.com/trinodb/trino/issues/20315")\)
