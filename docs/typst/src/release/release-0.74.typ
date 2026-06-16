#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-74")
= Release 0.74

== Bytecode compiler

This version includes new infrastructure for bytecode compilation, and lays the groundwork for future improvements. There should be no impact in performance or correctness with the new code, but we have added a flag to revert to the old implementation in case of issues. To do so, add #raw("compiler.new-bytecode-generator-enabled=false") to #raw("etc/config.properties") in the coordinator and workers.

== Hive storage format

The storage format to use when writing data to Hive can now be configured via the #raw("hive.storage-format") option in your Hive catalog properties file. Valid options are #raw("RCBINARY"), #raw("RCTEXT"), #raw("SEQUENCEFILE") and #raw("TEXTFILE"). The default format if the property is not set is #raw("RCBINARY").

== General

- Show column comments in #raw("DESCRIBE")
- Add #link(label("fn-try-cast"), raw("try_cast")) which works like #link(label("fn-cast"), raw("cast")) but returns #raw("null") if the cast fails
- #raw("nullif") now correctly returns a value with the type of the first argument
- Fix an issue with #link(label("fn-timezone-hour"), raw("timezone_hour")) returning results in milliseconds instead of hours
- Show a proper error message when analyzing queries with non-equijoin clauses
- Improve "too many failures" error message when coordinator can't talk to workers
- Minor optimization of #link(label("fn-json-size"), raw("json_size")) function
- Improve feature normalization algorithm for machine learning functions
- Add exponential back-off to the S3 FileSystem retry logic
- Improve CPU efficiency of semi-joins
