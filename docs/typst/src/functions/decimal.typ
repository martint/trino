#import "/lib/trino-docs.typ": *

#anchor("doc-functions-decimal")
= Decimal functions and operators

#anchor("ref-decimal-literal")

== Decimal literals

Use the #raw("DECIMAL 'xxxxxxx.yyyyyyy'") syntax to define a decimal literal.

The precision of a decimal type for a literal will be equal to the number of digits in the literal \(including trailing and leading zeros\). The scale will be equal to the number of digits in the fractional part \(including trailing zeros\).

#list-table((
  ([Example literal], [Data type],),
  ([#raw("DECIMAL '0'")], [#raw("DECIMAL(1)")],),
  ([#raw("DECIMAL '12345'")], [#raw("DECIMAL(5)")],),
  ([#raw("DECIMAL '0000012345.1234500000'")], [#raw("DECIMAL(20, 10)")],)
), header-rows: 1)

== Binary arithmetic decimal operators

Standard mathematical operators are supported. The table below explains precision and scale calculation rules for result. Assuming #raw("x") is of type #raw("DECIMAL(xp, xs)") and #raw("y") is of type #raw("DECIMAL(yp, ys)").

#list-table((
  ([Operation], [Result type precision], [Result type scale],),
  ([#raw("x + y") and #raw("x - y")], [#code-block(none, "min(38,
    1 +
    max(xs, ys) +
    max(xp - xs, yp - ys)
)")], [#raw("max(xs, ys)")],),
  ([#raw("x * y")], [#code-block(none, "min(38, xp + yp)")], [#raw("xs + ys")],),
  ([#raw("x / y")], [#code-block(none, "min(38,
    xp + ys-xs
    + max(0, ys-xs)
    )")], [#raw("max(xs, ys)")],),
  ([#raw("x % y")], [#code-block(none, "min(xp - xs, yp - ys) +
max(xs, bs)")], [#raw("max(xs, ys)")],)
), header-rows: 1)

If the mathematical result of the operation is not exactly representable with the precision and scale of the result data type, then an exception condition is raised: #raw("Value is out of range").

When operating on decimal types with different scale and precision, the values are first coerced to a common super type. For types near the largest representable precision \(38\), this can result in Value is out of range errors when one of the operands doesn't fit in the common super type. For example, the common super type of decimal\(38, 0\) and decimal\(38, 1\) is decimal\(38, 1\), but certain values that fit in decimal\(38, 0\) cannot be represented as a decimal\(38, 1\).

== Comparison operators

All standard comparison work for the decimal type.

== Unary decimal operators

The #raw("-") operator performs negation. The type of result is same as type of argument.
