#import "/lib/trino-docs.typ": *

#anchor("doc-functions-variant")
= VARIANT functions and operators

The #raw("VARIANT") type represents a semi-structured value as defined by the #link("https://iceberg.apache.org/spec/#semi-structured-types")[Apache Iceberg Variant specification].

#raw("VARIANT") values are created using casts, decoded using casts, and dereferenced using the SQL subscript operator \(#raw("[]")\).

== Equality semantics

Two #raw("VARIANT") values are equal when they represent the same logical value, regardless of internal encoding details.

This means equality is based on value semantics, not byte-for-byte encoding. For example:

- Numbers compare by numeric value across numeric encodings.
- Strings compare by string bytes, regardless of short-string or regular string encoding.
- Timestamps compare by instant\/value, even when encoded at different precisions \(microseconds vs nanoseconds\), when the values are exactly representable at both precisions.
- #raw("TIMESTAMP") and #raw("TIMESTAMP WITH TIME ZONE") remain distinct timestamp kinds and are not equal to each other.

For numbers, additional edge-case rules apply:

- Integer and decimal forms are compared by exact numeric value: #raw("1"), #raw("1.0"), and #raw("1.00") are equal.
- Floating-point values \(#raw("REAL"), #raw("DOUBLE")\) are equal to exact numerics only when the floating-point value can be represented exactly as a variant decimal. Example: #raw("0.5") equals #raw("DECIMAL '0.5'"), but #raw("0.1") does not equal #raw("DECIMAL '0.1'"), because binary floating-point cannot represent #raw("0.1") exactly.
- #raw("+0.0") and #raw("-0.0") are equal.
- #raw("NaN") is not equal to any value, including itself.

== Subscript operator

Elements of a #raw("VARIANT") value can be accessed using the SQL subscript operator \(#raw("[]")\). The result of a subscript operation is always a #raw("VARIANT") value.

=== Objects

When the underlying value is an object, use a #raw("VARCHAR") key:

#code-block("sql", "variant_expression['key']")

If the specified key does not exist in the object, the result is SQL #raw("NULL").

=== Arrays

When the underlying value is an array, use a #raw("bigint") with one-based indexing:

#code-block("sql", "variant_expression[index]")

The same SQL array indexing rules apply:

- Indexes start at #raw("1")
- Index #raw("0") or negative indexes are invalid and result in an error
- An index greater than the array length results in an error

== Functions

#function-def("fn-variant-is-null", "variant_is_null(variant)", "boolean")[
Returns #raw("true") if the input value represents a #emph[variant null].

This function distinguishes a variant null value from SQL #raw("NULL").

- Returns #raw("true") if the value is a variant null
- Returns #raw("false") for all other variant values
- Returns SQL #raw("NULL") if the input is SQL #raw("NULL")

Example:

#code-block("sql", "SELECT variant_is_null(CAST(JSON 'null' AS VARIANT)); -- true
SELECT variant_is_null(CAST(42 AS VARIANT));          -- false
SELECT variant_is_null(NULL);                         -- NULL")
]

== Cast to VARIANT

The following SQL types can be cast to #raw("VARIANT"):

=== Scalar types

- #raw("BOOLEAN")
- #raw("TINYINT")
- #raw("SMALLINT")
- #raw("INTEGER")
- #raw("BIGINT")
- #raw("REAL")
- #raw("DOUBLE")
- #raw("DECIMAL")
- #raw("VARCHAR")
- #raw("VARBINARY")
- #raw("DATE")
- #raw("TIME(p)")
- #raw("TIMESTAMP(p)")
- #raw("TIMESTAMP(p) WITH TIME ZONE")
- #raw("UUID")
- #raw("JSON")
- #raw("VARIANT")

=== Container types

- #raw("ARRAY")
- #raw("MAP") \(with #raw("VARCHAR") key type\)
- #raw("ROW")

Container values may contain any supported scalar or container type, including nested containers, #raw("JSON"), and #raw("VARIANT") values.

== Cast from VARIANT

A #raw("VARIANT") value can be cast to the following SQL types when the underlying value is compatible with the target type.

Standard Trino cast coercions apply. For example, a #raw("VARIANT") value containing a string can be cast to a numeric type if the string represents a valid value for the target type and fits within its range.

=== Scalar types

- #raw("BOOLEAN")
- #raw("TINYINT")
- #raw("SMALLINT")
- #raw("INTEGER")
- #raw("BIGINT")
- #raw("REAL")
- #raw("DOUBLE")
- #raw("DECIMAL")
- #raw("VARCHAR")
- #raw("VARBINARY")
- #raw("DATE")
- #raw("TIME(p)")
- #raw("TIMESTAMP(p)")
- #raw("TIMESTAMP(p) WITH TIME ZONE")
- #raw("UUID")
- #raw("JSON")
- #raw("VARIANT")

=== Container types

- #raw("ARRAY")
- #raw("MAP") \(with #raw("VARCHAR") key type\)
- #raw("ROW")

Casting to container types is supported when the structure of the target type is compatible with the contents of the #raw("VARIANT") value. If the underlying value is incompatible with the requested type, the cast fails.
