#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-79")
= Release 0.79

== Hive

- Add configuration option #raw("hive.force-local-scheduling") and session property #raw("force_local_scheduling") to force local scheduling of splits.
- Add new experimental optimized RCFile reader.  The reader can be enabled by setting the configuration option #raw("hive.optimized-reader.enabled") or session property #raw("optimized_reader_enabled").

== General

- Add support for #link(label("ref-unnest"))[unnest], which can be used as a replacement for the #raw("explode()") function in Hive.
- Fix a bug in the scan operator that can cause data to be missed. It currently only affects queries over #raw("information_schema") or #raw("sys") tables, metadata queries such as #raw("SHOW PARTITIONS") and connectors that implement the #raw("ConnectorPageSource") interface.
