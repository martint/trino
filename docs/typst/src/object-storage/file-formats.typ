#import "/lib/trino-docs.typ": *

#anchor("doc-object-storage-file-formats")
= Object storage file formats

Object storage connectors support one or more file formats specified by the underlying data source.

#anchor("ref-orc-format-configuration")

== ORC format configuration properties

The following properties are used to configure the read and write operations with ORC files performed by supported object storage connectors:

#list-table((
  ([Property Name], [Description], [Default],),
  ([#raw("orc.time-zone")], [Sets the default time zone for legacy ORC files that did not declare a time zone.], [JVM default],),
  ([#raw("orc.bloom-filters.enabled")], [Enable bloom filters for predicate pushdown.], [#raw("false")],),
  ([#raw("orc.read-legacy-short-zone-id")], [Allow reads on ORC files with short zone ID in the stripe footer.], [#raw("false")],)
), header-rows: 1, title: "ORC format configuration properties")

#link(label("ref-file-compression"))[General properties] is automatically performed and some details can be configured.

== ORC support limitations

#link("https://github.com/trinodb/trino/issues/26865")[Trino ignores Calendar entry in ORC file metadata.] As a result Trino always treats dates and timestamps as values written using proleptic Gregorian calendar. This causes incorrect values read when reading date\/time values before Oct 15, 1582 that were written using hybrid Julian-Gregorian calendar.

#anchor("ref-parquet-format-configuration")

== Parquet format configuration properties

The following properties are used to configure the read and write operations with Parquet files performed by supported object storage connectors:

#list-table((
  ([Property Name], [Description], [Default],),
  ([#raw("parquet.time-zone")], [Adjusts timestamp values to a specific time zone. For Hive 3.1+, set this to UTC.], [JVM default],),
  ([#raw("parquet.writer.validation-percentage")], [Percentage of parquet files to validate after write by re-reading the whole file. The equivalent catalog session property is #raw("parquet_optimized_writer_validation_percentage"). Validation can be turned off by setting this property to #raw("0").], [#raw("5")],),
  ([#raw("parquet.writer.page-size")], [Maximum size of pages written by Parquet writer. The equivalent catalog session property is #raw("parquet_writer_page_size").], [#raw("1 MB")],),
  ([#raw("parquet.writer.page-value-count")], [Maximum values count of pages written by Parquet writer. The equivalent catalog session property is #raw("parquet_writer_page_value_count").], [#raw("80000")],),
  ([#raw("parquet.writer.row-group-size")], [Maximum size of row groups written by Parquet writer. The equivalent catalog session property is #raw("parquet_writer_row_group_size").], [#raw("128 MB")],),
  ([#raw("parquet.writer.row-group-max-row-count")], [Maximum number of rows in row groups written by Parquet writer. The equivalent catalog session property is #raw("parquet_writer_row_group_max_row_count").], [#raw("unlimited")],),
  ([#raw("parquet.writer.batch-size")], [Maximum number of rows processed by the parquet writer in a batch. The equivalent catalog session property is #raw("parquet_writer_batch_size").], [#raw("10000")],),
  ([#raw("parquet.writer.delta-length-byte-array-encoding-enabled")], [Use #raw("DELTA_LENGTH_BYTE_ARRAY") encoding for #raw("BYTE_ARRAY") columns when the Parquet dictionary encoding is not effective.], [#raw("true")],),
  ([#raw("parquet.use-bloom-filter")], [Whether bloom filters are used for predicate pushdown when reading Parquet files. Set this property to #raw("false") to disable the usage of bloom filters by default. The equivalent catalog session property is #raw("parquet_use_bloom_filter").], [#raw("true")],),
  ([#raw("parquet.use-column-index")], [Skip reading Parquet pages by using Parquet column indices. The equivalent catalog session property is #raw("parquet_use_column_index"). Only supported by the Delta Lake and Hive connectors.], [#raw("true")],),
  ([#raw("parquet.ignore-statistics")], [Ignore statistics from Parquet to allow querying files with corrupted or incorrect statistics. The equivalent catalog session property is #raw("parquet_ignore_statistics").], [#raw("false")],),
  ([#raw("parquet.max-read-block-row-count")], [Sets the maximum number of rows read in a batch. The equivalent catalog session property is named #raw("parquet_max_read_block_row_count") and supported by the Delta Lake, Hive, Iceberg and Hudi connectors.], [#raw("8192")],),
  ([#raw("parquet.small-file-threshold")], [#link(label("ref-prop-type-data-size"))[Data size] below which a Parquet file is read entirely. The equivalent catalog session property is named #raw("parquet_small_file_threshold").], [#raw("3MB")],),
  ([#raw("parquet.experimental.vectorized-decoding.enabled")], [Enable using Java Vector API \(SIMD\) for faster decoding of parquet files. The equivalent catalog session property is #raw("parquet_vectorized_decoding_enabled").], [#raw("true")],),
  ([#raw("parquet.max-footer-read-size")], [Sets the maximum allowed read size for Parquet file footers. Attempting to read a file with a footer larger than this value will result in an error. This prevents workers from going into full GC or crashing due to poorly configured Parquet writers.], [#raw("15MB")],),
  ([#raw("parquet.footer-read-size")], [Sets the expected Parquet footer size used for the initial file-tail read. If the actual footer is larger, Trino reads the footer again using the actual size.], [#raw("48kB")],),
  ([#raw("parquet.max-page-read-size")], [Maximum allowed size of a parquet page during reads. Files with parquet pages larger than this will generate an exception on read.], [#raw("500MB")],)
), header-rows: 1, title: "Parquet format configuration properties")

#link(label("ref-file-compression"))[General properties] is automatically performed and some details can be configured.
