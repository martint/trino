#import "/lib/trino-docs.typ": *

#anchor("doc-functions-conversion")
= Conversion functions

Trino will implicitly convert numeric and character values to the correct type if such a conversion is possible. Trino will not convert between character and numeric types. For example, a query that expects a varchar will not automatically convert a bigint value to an equivalent varchar.

When necessary, values can be explicitly cast to a particular type.

== Conversion functions

#function-def("fn-cast", "cast(value AS type)", "type")[
Explicitly cast a value as a type. This can be used to cast a varchar to a numeric value type and vice versa.
]

#function-def("fn-try-cast", "try_cast(value AS type)", "type")[
Like #link(label("fn-cast"), raw("cast")), but returns null if the cast fails.
]

== Formatting

#function-def("fn-format", "format(format, args...)", "varchar")[
Returns a formatted string using the specified #link("https://docs.oracle.com/en/java/javase/23/docs/api/java.base/java/util/Formatter.html#syntax")[format string] and arguments:

#code-block(none, "SELECT format('%s%%', 123);
-- '123%'

SELECT format('%.5f', pi());
-- '3.14159'

SELECT format('%03d', 8);
-- '008'

SELECT format('%,.2f', 1234567.89);
-- '1,234,567.89'

SELECT format('%-7s,%7s', 'hello', 'world');
-- 'hello  ,  world'

SELECT format('%2$s %3$s %1$s', 'a', 'b', 'c');
-- 'b c a'

SELECT format('%1$tA, %1$tB %1$te, %1$tY', date '2006-07-04');
-- 'Tuesday, July 4, 2006'")
]

#function-def("fn-format-number", "format_number(number)", "varchar")[
Returns a formatted string using a unit symbol:

#code-block(none, "SELECT format_number(123456); -- '123K'
SELECT format_number(1000000); -- '1M'")
]

== Data size

The #raw("parse_data_size") function supports the following units:

#list-table((
  ([Unit], [Description], [Value],),
  ([#raw("B")], [Bytes], [1],),
  ([#raw("kB")], [Kilobytes], [1024],),
  ([#raw("MB")], [Megabytes], [1024#super[2]],),
  ([#raw("GB")], [Gigabytes], [1024#super[3]],),
  ([#raw("TB")], [Terabytes], [1024#super[4]],),
  ([#raw("PB")], [Petabytes], [1024#super[5]],),
  ([#raw("EB")], [Exabytes], [1024#super[6]],),
  ([#raw("ZB")], [Zettabytes], [1024#super[7]],),
  ([#raw("YB")], [Yottabytes], [1024#super[8]],)
), header-rows: 1)

#function-def("fn-parse-data-size", "parse_data_size(string)", "decimal(38)")[
Parses #raw("string") of format #raw("value unit") into a number, where #raw("value") is the fractional number of #raw("unit") values:

#code-block(none, "SELECT parse_data_size('1B'); -- 1
SELECT parse_data_size('1kB'); -- 1024
SELECT parse_data_size('1MB'); -- 1048576
SELECT parse_data_size('2.3MB'); -- 2411724")
]

== Miscellaneous

#function-def("fn-typeof", "typeof(expr)", "varchar")[
Returns the name of the type of the provided expression:

#code-block(none, "SELECT typeof(123); -- integer
SELECT typeof('cat'); -- varchar(3)
SELECT typeof(cos(2) + 1.5); -- double")
]
