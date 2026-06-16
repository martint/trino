#import "/lib/trino-docs.typ": *

#anchor("doc-functions-teradata")
= Teradata functions

These functions provide compatibility with Teradata SQL.

== String functions

#function-def("fn-char2hexint", "char2hexint(string)", "varchar")[
Returns the hexadecimal representation of the UTF-16BE encoding of the string.
]

#function-def("fn-index", "index(string, substring)", "bigint")[
Alias for #link(label("fn-strpos"), raw("strpos")) function.
]

== Date functions

The functions in this section use a format string that is compatible with the Teradata datetime functions. The following table, based on the Teradata reference manual, describes the supported format specifiers:

#list-table((
  ([Specifier], [Description],),
  ([#raw("- / , . ; :")], [Punctuation characters are ignored],),
  ([#raw("dd")], [Day of month \(1-31\)],),
  ([#raw("hh")], [Hour of day \(1-12\)],),
  ([#raw("hh24")], [Hour of the day \(0-23\)],),
  ([#raw("mi")], [Minute \(0-59\)],),
  ([#raw("mm")], [Month \(01-12\)],),
  ([#raw("ss")], [Second \(0-59\)],),
  ([#raw("yyyy")], [4-digit year],),
  ([#raw("yy")], [2-digit year],)
), header-rows: 1)

#warning[
Case insensitivity is not currently supported. All specifiers must be lowercase.
]

#function-def("fn-to-char", "to_char(timestamp, format)", "varchar")[
Formats #raw("timestamp") as a string using #raw("format").
]

#function-def("fn-to-timestamp", "to_timestamp(string, format)", "timestamp")[
Parses #raw("string") into a #raw("TIMESTAMP") using #raw("format").
]

#function-def("fn-to-date", "to_date(string, format)", "date")[
Parses #raw("string") into a #raw("DATE") using #raw("format").
]
