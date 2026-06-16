#import "/lib/trino-docs.typ": *

#anchor("doc-functions-logical")
#anchor("ref-logical-operators")

= Logical operators

== Logical operators

#list-table((
  ([Operator], [Description], [Example],),
  ([#raw("AND")], [True if both values are true], [a AND b],),
  ([#raw("OR")], [True if either value is true], [a OR b],),
  ([#raw("NOT")], [True if the value is false], [NOT a],)
), header-rows: 1)

== Effect of NULL on logical operators

The result of an #raw("AND") comparison may be #raw("NULL") if one or both sides of the expression are #raw("NULL"). If at least one side of an #raw("AND") operator is #raw("FALSE") the expression evaluates to #raw("FALSE"):

#code-block(none, "SELECT CAST(null AS boolean) AND true; -- null

SELECT CAST(null AS boolean) AND false; -- false

SELECT CAST(null AS boolean) AND CAST(null AS boolean); -- null")

The result of an #raw("OR") comparison may be #raw("NULL") if one or both sides of the expression are #raw("NULL").  If at least one side of an #raw("OR") operator is #raw("TRUE") the expression evaluates to #raw("TRUE"):

#code-block(none, "SELECT CAST(null AS boolean) OR CAST(null AS boolean); -- null

SELECT CAST(null AS boolean) OR false; -- null

SELECT CAST(null AS boolean) OR true; -- true")

The following truth table demonstrates the handling of #raw("NULL") in #raw("AND") and #raw("OR"):

#list-table((
  ([a], [b], [a AND b], [a OR b],),
  ([#raw("TRUE")], [#raw("TRUE")], [#raw("TRUE")], [#raw("TRUE")],),
  ([#raw("TRUE")], [#raw("FALSE")], [#raw("FALSE")], [#raw("TRUE")],),
  ([#raw("TRUE")], [#raw("NULL")], [#raw("NULL")], [#raw("TRUE")],),
  ([#raw("FALSE")], [#raw("TRUE")], [#raw("FALSE")], [#raw("TRUE")],),
  ([#raw("FALSE")], [#raw("FALSE")], [#raw("FALSE")], [#raw("FALSE")],),
  ([#raw("FALSE")], [#raw("NULL")], [#raw("FALSE")], [#raw("NULL")],),
  ([#raw("NULL")], [#raw("TRUE")], [#raw("NULL")], [#raw("TRUE")],),
  ([#raw("NULL")], [#raw("FALSE")], [#raw("FALSE")], [#raw("NULL")],),
  ([#raw("NULL")], [#raw("NULL")], [#raw("NULL")], [#raw("NULL")],)
), header-rows: 1)

The logical complement of #raw("NULL") is #raw("NULL") as shown in the following example:

#code-block(none, "SELECT NOT CAST(null AS boolean); -- null")

The following truth table demonstrates the handling of #raw("NULL") in #raw("NOT"):

#list-table((
  ([a], [NOT a],),
  ([#raw("TRUE")], [#raw("FALSE")],),
  ([#raw("FALSE")], [#raw("TRUE")],),
  ([#raw("NULL")], [#raw("NULL")],)
), header-rows: 1)
