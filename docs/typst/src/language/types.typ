#import "/lib/trino-docs.typ": *

#anchor("doc-language-types")
= Data types

Trino has a set of built-in data types, described below. Additional types can be #link(label("doc-develop-types"))[provided by plugins].

#anchor("ref-type-mapping-overview")

== Trino type support and mapping

Connectors to data sources are not required to support all Trino data types described on this page. If there are data types similar to Trino's that are used on the data source, the connector may map the Trino and remote data types to each other as needed.

Depending on the connector and the data source, type mapping may apply in either direction as follows:

- #strong[Data source to Trino] mapping applies to any operation where columns in the data source are read by Trino, such as a #link(label("doc-sql-select"))[SELECT] statement, and the underlying source data type needs to be represented by a Trino data type.
- #strong[Trino to data source] mapping applies to any operation where the columns or expressions in Trino need to be translated into data types or expressions compatible with the underlying data source. For example, #link(label("doc-sql-create-table-as"))[CREATE TABLE AS] statements specify Trino types that are then mapped to types on the remote data source. Predicates like #raw("WHERE") also use these mappings in order to ensure that the predicate is translated to valid syntax on the remote data source.

Data type support and mappings vary depending on the connector. Refer to the #link(label("doc-connector"))[connector documentation] for more information.

#anchor("ref-boolean-data-types")

== Boolean

=== #raw("BOOLEAN")

This type captures boolean values #raw("true") and #raw("false").

#anchor("ref-integer-data-types")

== Integer

Integer numbers can be expressed as numeric literals in the following formats:

- Decimal integer. Examples are #raw("-7"), #raw("0"), or #raw("3").
- Hexadecimal integer composed of #raw("0X") or #raw("0x") and the value. Examples are #raw("0x0A") for decimal #raw("10") or #raw("0x11") for decimal #raw("17").
- Octal integer composed of #raw("0O") or #raw("0o") and the value. Examples are #raw("0o40") for decimal #raw("32") or #raw("0o11") for decimal #raw("9").
- Binary integer composed of #raw("0B") or #raw("0b") and the value. Examples are #raw("0b1001") for decimal #raw("9") or #raw("0b101010") for decimal \`42\`\`.

Underscore characters are ignored within literal values, and can be used to increase readability. For example, decimal integer #raw("123_456") is equivalent to #raw("123456"). Preceding underscores, trailing underscores, and consecutive underscores are not permitted.

Integers are supported by the following data types.

=== #raw("TINYINT")

A 8-bit signed two's complement integer with a minimum value of #raw("-2^7") or #raw("-0x80") and a maximum value of #raw("2^7 - 1") or #raw("0x7F").

=== #raw("SMALLINT")

A 16-bit signed two's complement integer with a minimum value of #raw("-2^15") or #raw("-0x8000") and a maximum value of #raw("2^15 - 1") or #raw("0x7FFF").

=== #raw("INTEGER") or #raw("INT")

A 32-bit signed two's complement integer with a minimum value of #raw("-2^31") or #raw("-0x80000000") and a maximum value of #raw("2^31 - 1") or #raw("0x7FFFFFFF").  The names #raw("INTEGER") and #raw("INT") can both be used for this type.

=== #raw("BIGINT")

A 64-bit signed two's complement integer with a minimum value of #raw("-2^63") or #raw("-0x8000000000000000") and a maximum value of #raw("2^63 - 1") or #raw("0x7FFFFFFFFFFFFFFF").

#anchor("ref-floating-point-data-types")

== Floating-point

Floating-point, fixed-precision numbers can be expressed as numeric literal using scientific notation such as #raw("1.03e1") and are cast as #raw("DOUBLE") data type. Underscore characters are ignored within literal values, and can be used to increase readability. For example, value #raw("123_456.789e4") is equivalent to #raw("123456.789e4"). Preceding underscores, trailing underscores, consecutive underscores, and underscores beside the comma \(#raw(".")\) are not permitted.

=== #raw("REAL")

A real is a 32-bit inexact, variable-precision implementing the IEEE Standard 754 for Binary Floating-Point Arithmetic.

Example literals: #raw("REAL '10.3'"), #raw("REAL '10.3e0'"), #raw("REAL '1.03e1'")

=== #raw("DOUBLE")

A double is a 64-bit inexact, variable-precision implementing the IEEE Standard 754 for Binary Floating-Point Arithmetic.

Example literals: #raw("DOUBLE '10.3'"), #raw("DOUBLE '1.03e1'"), #raw("10.3e0"), #raw("1.03e1")

#anchor("ref-number-data-type")

=== #raw("NUMBER")

A floating point, decimal number of unspecified precision of at least 50 decimal digits. The type supports positive values as small as #raw("1e-100") or smaller, and values as large as #raw("1e100") or larger.

#code-block("sql", "SELECT NUMBER '3.1415926535897932384626433832795028841971693993751'
-- 3.1415926535897932384626433832795028841971693993751 without loss of precision

SELECT NUMBER '12345678901234567890123456789012345678901234567890e30'
-- 1.234567890123456789012345678901234567890123456789E+79 without loss of precision")

The #raw("NUMBER") type supports the special values #raw("Infinity"), #raw("-Infinity"), and #raw("NaN"), following similar semantics to floating-point types:

#code-block("sql", "SELECT NUMBER 'Infinity';
-- Infinity

SELECT NUMBER '-Infinity';
-- -Infinity

SELECT NUMBER 'NaN';
-- NaN")

Division by zero raises a "Division by zero" error:

#code-block("sql", "SELECT NUMBER '1' / NUMBER '0';
-- ERROR: Division by zero")

#raw("NaN") is not equal to any value, including itself:

#code-block(none, "SELECT NUMBER 'NaN' = NUMBER 'NaN';
-- false")

Ordering follows the convention: #raw("-Infinity") \< all finite values \< #raw("Infinity") \< #raw("NaN").

Example literals: #raw("NUMBER '10.3'"), #raw("NUMBER '1234567890'"), #raw("NUMBER '1e3'"), #raw("NUMBER 'Infinity'"), #raw("NUMBER 'NaN'")

#anchor("ref-exact-numeric-data-types")

== Exact numeric

Exact numeric values can be expressed as numeric literals such as #raw("1.1"), and are supported by the #raw("DECIMAL") data type.

Underscore characters are ignored within literal values, and can be used to increase readability. For example, decimal #raw("123_456.789_123") is equivalent to #raw("123456.789123"). Preceding underscores, trailing underscores, consecutive underscores, and underscores beside the comma \(#raw(".")\) are not permitted.

Leading zeros in literal values are permitted and ignored. For example, #raw("000123.456") is equivalent to #raw("123.456").

=== #raw("DECIMAL")

A exact decimal number. Precision up to 38 digits is supported but performance is best up to 18 digits.

The decimal type takes two literal parameters:

- #strong[precision] - total number of digits
- #strong[scale] - number of digits in fractional part. Scale is optional and defaults to 0.

Example type definitions: #raw("DECIMAL(10,3)"), #raw("DECIMAL(20)")

Example literals: #raw("DECIMAL '10.3'"), #raw("DECIMAL '1234567890'"), #raw("1.1")

#anchor("ref-string-data-types")

== String

=== #raw("VARCHAR")

Variable length character data with an optional maximum length.

Example type definitions: #raw("varchar"), #raw("varchar(20)")

SQL statements support simple literal, as well as Unicode usage:

- literal string : #raw("'Hello winter !'")
- Unicode string with default escape character: #raw("U&'Hello winter \\2603 !'")
- Unicode string with custom escape character: #raw("U&'Hello winter #2603 !' UESCAPE '#'")

A Unicode string is prefixed with #raw("U&") and requires an escape character before any Unicode character usage with 4 digits. In the examples above #raw("\\2603") and #raw("#2603") represent a snowman character. Long Unicode codes with 6 digits require usage of the plus symbol before the code. For example, you need to use #raw("\\+01F600") for a grinning face emoji.

Single quotes in string literals can be escaped by using another single quote: #raw("'I am big, it''s the pictures that got small!'")

=== #raw("CHAR")

Fixed length character data. A #raw("CHAR") type without length specified has a default length of 1. A #raw("CHAR(x)") value always has a fixed length of #raw("x") characters. For example, casting #raw("dog") to #raw("CHAR(7)") adds four implicit trailing spaces.

As with #raw("VARCHAR"), a single quote in a #raw("CHAR") literal can be escaped with another single quote:

#code-block("sql", "SELECT CHAR 'All right, Mr. DeMille, I''m ready for my close-up.'")

Example type definitions: #raw("char"), #raw("char(20)")

=== #raw("VARBINARY")

Variable length binary data.

SQL statements support usage of binary literal data with the prefix #raw("X") or #raw("x"). The binary data has to use hexadecimal format. For example, the binary form of #raw("eh?") is #raw("X'65683F'") as you can confirm with the following statement:

#code-block("sql", "SELECT from_utf8(x'65683F');")

Binary literals ignore any whitespace characters. For example, the literal #raw("X'FFFF 0FFF  3FFF FFFF'") is equivalent to #raw("X'FFFF0FFF3FFFFFFF'").

#note[
Binary strings with length are not yet supported: #raw("varbinary(n)")
]

#anchor("ref-json-data-type")

=== #raw("JSON")

JSON value type, which can be a JSON object, a JSON array, a JSON number, a JSON string, #raw("true"), #raw("false") or #raw("null").

#anchor("ref-variant-data-type")

=== #raw("VARIANT")

A semi-structured value type. A #raw("VARIANT") value can represent any of the following:

- object \(key-value structure\)
- array
- string
- number \(integer, decimal, and floating-point\)
- boolean
- null
- date and time values

#raw("VARIANT") is designed for working with semi-structured data efficiently, and is commonly used with connectors and file formats that support a native variant type.

#raw("VARIANT") differs from #link(label("ref-json-data-type"))[json-data-type] in that it preserves the full underlying value type, rather than reducing values to a limited set of JSON types.

Examples:

#code-block("sql", "SELECT typeof(CAST(JSON '{\"a\": 1, \"b\": [true, null]}' AS VARIANT));
-- variant

SELECT CAST(CAST(JSON '123' AS VARIANT) AS BIGINT);
-- 123")

#raw("VARIANT") follows the #link("https://github.com/apache/parquet-format/blob/master/VariantEncoding.md")[Apache Iceberg Variant specification]. Trino implements this specification directly, including its type system, value encoding, and semantics.

This ensures consistent behavior when reading and writing variant values across systems that support the same specification.

See also #link(label("doc-functions-variant"))[VARIANT functions and operators]

#anchor("ref-date-time-data-types")

== Date and time

See also #link(label("doc-functions-datetime"))[Date and time functions and operators]

#anchor("ref-date-data-type")

=== #raw("DATE")

Calendar date \(year, month, day\).

Example: #raw("DATE '2001-08-22'")

=== #raw("TIME")

#raw("TIME") is an alias for #raw("TIME(3)") \(millisecond precision\).

=== #raw("TIME(P)")

Time of day \(hour, minute, second\) without a time zone with #raw("P") digits of precision for the fraction of seconds. A precision of up to 12 \(picoseconds\) is supported.

Example: #raw("TIME '01:02:03.456'")

#anchor("ref-time-with-time-zone-data-type")

=== #raw("TIME WITH TIME ZONE")

Time of day \(hour, minute, second, millisecond\) with a time zone. Values of this type are rendered using the time zone from the value. Time zones are expressed as the numeric UTC offset value:

#code-block(none, "SELECT TIME '01:02:03.456 -08:00';
-- 1:02:03.456-08:00")

#anchor("ref-timestamp-data-type")

=== #raw("TIMESTAMP")

#raw("TIMESTAMP") is an alias for #raw("TIMESTAMP(3)") \(millisecond precision\).

=== #raw("TIMESTAMP(P)")

Calendar date and time of day without a time zone with #raw("P") digits of precision for the fraction of seconds. A precision of up to 12 \(picoseconds\) is supported. This type is effectively a combination of the #raw("DATE") and #raw("TIME(P)") types.

#raw("TIMESTAMP(P) WITHOUT TIME ZONE") is an equivalent name.

Timestamp values can be constructed with the #raw("TIMESTAMP") literal expression. Alternatively, language constructs such as #raw("localtimestamp(p)"), or a number of #link(label("doc-functions-datetime"))[date and time functions and operators] can return timestamp values.

Casting to lower precision causes the value to be rounded, and not truncated. Casting to higher precision appends zeros for the additional digits.

The following examples illustrate the behavior:

#code-block(none, "SELECT TIMESTAMP '2020-06-10 15:55:23';
-- 2020-06-10 15:55:23

SELECT TIMESTAMP '2020-06-10 15:55:23.383345';
-- 2020-06-10 15:55:23.383345

SELECT typeof(TIMESTAMP '2020-06-10 15:55:23.383345');
-- timestamp(6)

SELECT cast(TIMESTAMP '2020-06-10 15:55:23.383345' as TIMESTAMP(1));
 -- 2020-06-10 15:55:23.4

SELECT cast(TIMESTAMP '2020-06-10 15:55:23.383345' as TIMESTAMP(12));
-- 2020-06-10 15:55:23.383345000000")

#anchor("ref-timestamp-with-time-zone-data-type")

=== #raw("TIMESTAMP WITH TIME ZONE")

#raw("TIMESTAMP WITH TIME ZONE") is an alias for #raw("TIMESTAMP(3) WITH TIME ZONE") \(millisecond precision\).

#anchor("ref-timestamp-p-with-time-zone-data-type")

=== #raw("TIMESTAMP(P) WITH TIME ZONE")

Instant in time that includes the date and time of day with #raw("P") digits of precision for the fraction of seconds and with a time zone. Values of this type are rendered using the time zone from the value. Time zones can be expressed in the following ways:

- #raw("UTC"), with #raw("GMT"), #raw("Z"), or #raw("UT") usable as aliases for UTC.
- #raw("+hh:mm") or #raw("-hh:mm") with #raw("hh:mm") as an hour and minute offset from UTC. Can be written with or without #raw("UTC"), #raw("GMT"), or #raw("UT") as an alias for UTC.
- An #link("https://www.iana.org/time-zones")[IANA time zone name].

The following examples demonstrate some of these syntax options:

#code-block(none, "SELECT TIMESTAMP '2001-08-22 03:04:05.321 UTC';
-- 2001-08-22 03:04:05.321 UTC

SELECT TIMESTAMP '2001-08-22 03:04:05.321 -08:30';
-- 2001-08-22 03:04:05.321 -08:30

SELECT TIMESTAMP '2001-08-22 03:04:05.321 GMT-08:30';
-- 2001-08-22 03:04:05.321 -08:30

SELECT TIMESTAMP '2001-08-22 03:04:05.321 America/New_York';
-- 2001-08-22 03:04:05.321 America/New_York")

=== #raw("INTERVAL YEAR TO MONTH")

Span of years and months.

Example: #raw("INTERVAL '3' MONTH")

=== #raw("INTERVAL DAY TO SECOND")

Span of days, hours, minutes, seconds and milliseconds.

Example: #raw("INTERVAL '2' DAY")

#anchor("ref-structural-data-types")

== Structural

#anchor("ref-array-type")

=== #raw("ARRAY")

An array of the given component type.

Example: #raw("ARRAY[1, 2, 3]")

More information in #link(label("doc-functions-array"))[Array functions and operators].

#anchor("ref-map-type")

=== #raw("MAP")

A map between the given component types. A map is a collection of key-value pairs, where each key is associated with a single value. Map keys are required, while map values can be null.

Example: #raw("MAP(ARRAY['foo', 'bar'], ARRAY[1, 2])")

More information in #link(label("doc-functions-map"))[Map functions and operators].

#anchor("ref-row-type")

=== #raw("ROW")

A structure made up of fields that allows mixed types. The fields may be of any SQL type.

By default, row fields are not named, but names can be assigned.

Example: #raw("CAST(ROW(1, 2e0) AS ROW(x BIGINT, y DOUBLE))")

Named row fields are accessed with field reference operator \(#raw(".")\).

Example: #raw("CAST(ROW(1, 2.0) AS ROW(x BIGINT, y DOUBLE)).x")

Named or unnamed row fields are accessed by position with the subscript operator \(#raw("[]")\). The position starts at #raw("1") and must be a constant.

Example: #raw("ROW(1, 2.0)[1]")

== Network address

#anchor("ref-ipaddress-type")

=== #raw("IPADDRESS")

An IP address that can represent either an IPv4 or IPv6 address. Internally, the type is a pure IPv6 address. Support for IPv4 is handled using the #emph[IPv4-mapped IPv6 address] range \(#link("https://www.rfc-editor.org/rfc/rfc4291#section-2.5.5.2")[RFC 4291\#section-2.5.5.2]\). When creating an #raw("IPADDRESS"), IPv4 addresses will be mapped into that range. When formatting an #raw("IPADDRESS"), any address within the mapped range will be formatted as an IPv4 address. Other addresses will be formatted as IPv6 using the canonical format defined in #link("https://www.rfc-editor.org/rfc/rfc5952")[RFC 5952].

Examples: #raw("IPADDRESS '10.0.0.1'"), #raw("IPADDRESS '2001:db8::1'")

== UUID

#anchor("ref-uuid-type")

=== #raw("UUID")

This type represents a UUID \(Universally Unique IDentifier\), also known as a GUID \(Globally Unique IDentifier\), using the format defined in #link("https://www.rfc-editor.org/rfc/rfc4122")[RFC 4122].

Example: #raw("UUID '12151fd2-7586-11e9-8f9e-2a86e4085a59'")

== HyperLogLog

Calculating the approximate distinct count can be done much more cheaply than an exact count using the #link("https://wikipedia.org/wiki/HyperLogLog")[HyperLogLog] data sketch. See #link(label("doc-functions-hyperloglog"))[HyperLogLog functions].

#anchor("ref-hyperloglog-type")

=== #raw("HyperLogLog")

A HyperLogLog sketch allows efficient computation of #link(label("fn-approx-distinct"), raw("approx_distinct")). It starts as a sparse representation, switching to a dense representation when it becomes more efficient.

#anchor("ref-p4hyperloglog-type")

=== #raw("P4HyperLogLog")

A P4HyperLogLog sketch is similar to #link(label("ref-hyperloglog-type"))[hyperloglog-type], but it starts \(and remains\) in the dense representation.

== SetDigest

#anchor("ref-setdigest-type")

=== #raw("SetDigest")

A SetDigest \(setdigest\) is a data sketch structure used in calculating #link("https://wikipedia.org/wiki/Jaccard_index")[Jaccard similarity coefficient] between two sets.

SetDigest encapsulates the following components:

- #link("https://wikipedia.org/wiki/HyperLogLog")[HyperLogLog]
- #link("http://wikipedia.org/wiki/MinHash#Variant_with_a_single_hash_function")[MinHash with a single hash function]

The HyperLogLog structure is used for the approximation of the distinct elements in the original set.

The MinHash structure is used to store a low memory footprint signature of the original set. The similarity of any two sets is estimated by comparing their signatures.

SetDigests are additive, meaning they can be merged together.

== Quantile digest

#anchor("ref-qdigest-type")

=== #raw("QDigest")

A quantile digest \(qdigest\) is a summary structure which captures the approximate distribution of data for a given input set, and can be queried to retrieve approximate quantile values from the distribution.  The level of accuracy for a qdigest is tunable, allowing for more precise results at the expense of space.

A qdigest can be used to give approximate answer to queries asking for what value belongs at a certain quantile.  A useful property of qdigests is that they are additive, meaning they can be merged together without losing precision.

A qdigest may be helpful whenever the partial results of #raw("approx_percentile") can be reused.  For example, one may be interested in a daily reading of the 99th percentile values that are read over the course of a week.  Instead of calculating the past week of data with #raw("approx_percentile"), #raw("qdigest")s could be stored daily, and quickly merged to retrieve the 99th percentile value.

== T-Digest

#anchor("ref-tdigest-type")

=== #raw("TDigest")

A T-digest \(tdigest\) is a summary structure which, similarly to qdigest, captures the approximate distribution of data for a given input set. It can be queried to retrieve approximate quantile values from the distribution.

TDigest has the following advantages compared to QDigest:

- higher performance
- lower memory usage
- higher accuracy at high and low percentiles

T-digests are additive, meaning they can be merged together.
