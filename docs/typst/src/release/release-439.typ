#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-439")
= Release 439 \(15 Feb 2024\)

== General

- Fix failure when setting session properties for a catalog with a #raw(".") in its name. \(#issue("20474", "https://github.com/trinodb/trino/issues/20474")\)
- Fix potential out-of-memory query failures when using the experimental scheduler. \(#issue("20694", "https://github.com/trinodb/trino/issues/20694")\)
- Fix potential performance regression when dynamic filters are not applied. \(#issue("20709", "https://github.com/trinodb/trino/issues/20709")\)

== BigQuery connector

- Fix failure when pushing down predicates into BigQuery views. \(#issue("20627", "https://github.com/trinodb/trino/issues/20627")\)

== Delta Lake connector

- Improve performance when reading data by adding support for #link(label("doc-object-storage-file-system-cache"))[caching data on local storage]. \(#issue("18719", "https://github.com/trinodb/trino/issues/18719")\)
- Fix potential crash when reading corrupted Snappy data. \(#issue("20631", "https://github.com/trinodb/trino/issues/20631")\)

== Hive connector

- #breaking-marker("../release.html#breaking-changes") Improve performance of caching data on local storage. Deprecate the #raw("hive.cache.enabled") configuration property in favor of #link(label("doc-object-storage-file-system-cache"))[#raw("fs.cache.enabled")]. \(#issue("20658", "https://github.com/trinodb/trino/issues/20658"), #issue("20102", "https://github.com/trinodb/trino/issues/20102")\)
- Fix query failure when a value has not been specified for the #raw("orc_bloom_filter_fpp") table property. \(#issue("16589", "https://github.com/trinodb/trino/issues/16589")\)
- Fix potential query failure when writing ORC files. \(#issue("20587", "https://github.com/trinodb/trino/issues/20587")\)
- Fix potential crash when reading corrupted Snappy data. \(#issue("20631", "https://github.com/trinodb/trino/issues/20631")\)

== Hudi connector

- Fix potential crash when reading corrupted Snappy data. \(#issue("20631", "https://github.com/trinodb/trino/issues/20631")\)

== Iceberg connector

- Improve performance when reading data by adding support for #link(label("doc-object-storage-file-system-cache"))[caching data on local storage]. \(#issue("20602", "https://github.com/trinodb/trino/issues/20602")\)
- Fix query failure when a value has not been specified for the #raw("orc_bloom_filter_fpp") table property. \(#issue("16589", "https://github.com/trinodb/trino/issues/16589")\)
- Fix potential query failure when writing ORC files. \(#issue("20587", "https://github.com/trinodb/trino/issues/20587")\)
- Fix potential crash when reading corrupted Snappy data. \(#issue("20631", "https://github.com/trinodb/trino/issues/20631")\)

== Redshift connector

- Fix potential crash when reading corrupted Snappy data. \(#issue("20631", "https://github.com/trinodb/trino/issues/20631")\)
