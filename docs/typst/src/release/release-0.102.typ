#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-0-102")
= Release 0.102

== Unicode support

All string functions have been updated to support Unicode. The functions assume that the string contains valid UTF-8 encoded code points. There are no explicit checks for valid UTF-8, and the functions may return incorrect results on invalid UTF-8.  Invalid UTF-8 data can be corrected with #link(label("fn-from-utf8"), raw("from_utf8")).

Additionally, the functions operate on Unicode code points and not user visible #emph[characters] \(or #emph[grapheme clusters]\).  Some languages combine multiple code points into a single user-perceived #emph[character], the basic unit of a writing system for a language, but the functions will treat each code point as a separate unit.

== Regular expression functions

All #link(label("doc-functions-regexp"))[Regular expression functions] have been rewritten to improve performance. The new versions are often twice as fast and in some cases can be many orders of magnitude faster \(due to removal of quadratic behavior\). This change introduced some minor incompatibilities that are explained in the documentation for the functions.

== General

- Add support for partitioned right outer joins, which allows for larger tables to be joined on the inner side.
- Add support for full outer joins.
- Support returning booleans as numbers in JDBC driver
- Fix #link(label("fn-contains"), raw("contains")) to return #raw("NULL") if the value was not found, but a #raw("NULL") was.
- Fix nested #link(label("ref-row-type"))[row-type] rendering in #raw("DESCRIBE").
- Add #link(label("fn-array-join"), raw("array_join")).
- Optimize map subscript operator.
- Add #link(label("fn-from-utf8"), raw("from_utf8")) and #link(label("fn-to-utf8"), raw("to_utf8")) functions.
- Add #raw("task_writer_count") session property to set #raw("task.writer-count").
- Add cast from #raw("ARRAY(F)") to #raw("ARRAY(T)").
- Extend implicit coercions to #raw("ARRAY") element types.
- Implement implicit coercions in #raw("VALUES") expressions.
- Fix potential deadlock in scheduler.

== Hive

- Collect more metrics from #raw("PrestoS3FileSystem").
- Retry when seeking in #raw("PrestoS3FileSystem").
- Ignore #raw("InvalidRange") error in #raw("PrestoS3FileSystem").
- Implement rename and delete in #raw("PrestoS3FileSystem").
- Fix assertion failure when running #raw("SHOW TABLES FROM schema").
- Fix S3 socket leak when reading ORC files.
