#import "/lib/trino-docs.typ": *

#anchor("doc-functions-json")
= JSON functions and operators

The SQL standard describes functions and operators to process JSON data. They allow you to access JSON data according to its structure, generate JSON data, and store it persistently in SQL tables.

Importantly, the SQL standard imposes that there is no dedicated data type to represent JSON data in SQL. Instead, JSON data is represented as character or binary strings. Although Trino supports #raw("JSON") type, it is not used or produced by the following functions.

Trino supports three functions for querying JSON data: #link(label("ref-json-exists"))[json\_exists], #link(label("ref-json-query"))[json\_query], and #link(label("ref-json-value"))[json\_value]. Each of them is based on the same mechanism of exploring and processing JSON input using JSON path.

Trino also supports two functions for generating JSON data -- #link(label("ref-json-array"))[json\_array], and #link(label("ref-json-object"))[json\_object].

#anchor("ref-json-path-language")

== JSON path language

The JSON path language is a special language, used exclusively by certain SQL operators to specify the query to perform on the JSON input. Although JSON path expressions are embedded in SQL queries, their syntax significantly differs from SQL. The semantics of predicates, operators, etc. in JSON path expressions generally follow the semantics of SQL. The JSON path language is case-sensitive for keywords and identifiers.

#anchor("ref-json-path-syntax-and-semantics")

=== JSON path syntax and semantics

JSON path expressions are recursive structures. Although the name "path" suggests a linear sequence of operations going step by step deeper into the JSON structure, a JSON path expression is in fact a tree. It can access the input JSON item multiple times, in multiple ways, and combine the results. Moreover, the result of a JSON path expression is not a single item, but an ordered sequence of items. Each of the sub-expressions takes one or more input sequences, and returns a sequence as the result.

#note[
In the lax mode, most path operations first unnest all JSON arrays in the input sequence. Any divergence from this rule is mentioned in the following listing. Path modes are explained in #link(label("ref-json-path-modes"))[json-path-modes].
]

The JSON path language features are divided into: literals, variables, arithmetic binary expressions, arithmetic unary expressions, and a group of operators collectively known as accessors.

==== literals

- numeric literals
  
  They include exact and approximate numbers, and are interpreted as if they were SQL values.

#code-block("text", "-1, 1.2e3, NaN")

- string literals
  
  They are enclosed in double quotes.

#code-block("text", "\"Some text\"")

- boolean literals

#code-block("text", "true, false")

- null literal
  
  It has the semantics of the JSON null, not of SQL null. See #link(label("ref-json-comparison-rules"))[json-comparison-rules].

#code-block("text", "null")

==== variables

- context variable
  
  It refers to the currently processed input of the JSON function.

#code-block("text", "$")

- named variable
  
  It refers to a named parameter by its name.

#code-block("text", "$param")

- current item variable
  
  It is used inside the filter expression to refer to the currently processed item from the input sequence.

#code-block("text", "@")

- last subscript variable
  
  It refers to the last index of the innermost enclosing array. Array indexes in JSON path expressions are zero-based.

#code-block("text", "last")

==== arithmetic binary expressions

The JSON path language supports five arithmetic binary operators:

#code-block("text", "<path1> + <path2>
<path1> - <path2>
<path1> * <path2>
<path1> / <path2>
<path1> % <path2>")

Both operands, #raw("<path1>") and #raw("<path2>"), are evaluated to sequences of items. For arithmetic binary operators, each input sequence must contain a single numeric item. The arithmetic operation is performed according to SQL semantics, and it returns a sequence containing a single element with the result.

The operators follow the same precedence rules as in SQL arithmetic operations, and parentheses can be used for grouping.

==== arithmetic unary expressions

#code-block("text", "+ <path>
- <path>")

The operand #raw("<path>") is evaluated to a sequence of items. Every item must be a numeric value. The unary plus or minus is applied to every item in the sequence, following SQL semantics, and the results form the returned sequence.

==== member accessor

The member accessor returns the value of the member with the specified key for each JSON object in the input sequence.

#code-block("text", "<path>.key
<path>.\"key\"")

The condition when a JSON object does not have such a member is called a structural error. In the lax mode, it is suppressed, and the faulty object is excluded from the result.

Let #raw("<path>") return a sequence of three JSON objects:

#code-block("text", "{\"customer\" : 100, \"region\" : \"AFRICA\"},
{\"region\" : \"ASIA\"},
{\"customer\" : 300, \"region\" : \"AFRICA\", \"comment\" : null}")

the expression #raw("<path>.customer") succeeds in the first and the third object, but the second object lacks the required member. In strict mode, path evaluation fails. In lax mode, the second object is silently skipped, and the resulting sequence is #raw("100, 300").

All items in the input sequence must be JSON objects.

#note[
Trino does not support JSON objects with duplicate keys.
]

==== wildcard member accessor

Returns values from all key-value pairs for each JSON object in the input sequence. All the partial results are concatenated into the returned sequence.

#code-block("text", "<path>.*")

Let #raw("<path>") return a sequence of three JSON objects:

#code-block("text", "{\"customer\" : 100, \"region\" : \"AFRICA\"},
{\"region\" : \"ASIA\"},
{\"customer\" : 300, \"region\" : \"AFRICA\", \"comment\" : null}")

The results is:

#code-block("text", "100, \"AFRICA\", \"ASIA\", 300, \"AFRICA\", null")

All items in the input sequence must be JSON objects.

The order of values returned from a single JSON object is arbitrary. The sub-sequences from all JSON objects are concatenated in the same order in which the JSON objects appear in the input sequence.

#anchor("ref-json-descendant-member-accessor")

==== descendant member accessor

Returns the values associated with the specified key in all JSON objects on all levels of nesting in the input sequence.

#code-block("text", "<path>..key
<path>..\"key\"")

The order of returned values is that of preorder depth first search. First, the enclosing object is visited, and then all child nodes are visited.

This method does not perform array unwrapping in the lax mode. The results are the same in the lax and strict modes. The method traverses into JSON arrays and JSON objects. Non-structural JSON items are skipped.

Let #raw("<path>") be a sequence containing a JSON object:

#code-block("text", "{
    \"id\" : 1,
    \"notes\" : [{\"type\" : 1, \"comment\" : \"foo\"}, {\"type\" : 2, \"comment\" : null}],
    \"comment\" : [\"bar\", \"baz\"]
}")

#code-block("text", "<path>..comment --> [\"bar\", \"baz\"], \"foo\", null")

==== array accessor

Returns the elements at the specified indexes for each JSON array in the input sequence. Indexes are zero-based.

#code-block("text", "<path>[ <subscripts> ]")

The #raw("<subscripts>") list contains one or more subscripts. Each subscript specifies a single index or a range \(ends inclusive\):

#code-block("text", "<path>[<path1>, <path2> to <path3>, <path4>,...]")

In lax mode, any non-array items resulting from the evaluation of the input sequence are wrapped into single-element arrays. Note that this is an exception to the rule of automatic array wrapping.

Each array in the input sequence is processed in the following way:

- The variable #raw("last") is set to the last index of the array.
- All subscript indexes are computed in order of declaration. For a singleton subscript #raw("<path1>"), the result must be a singleton numeric item. For a range subscript #raw("<path2> to <path3>"), two numeric items are expected.
- The specified array elements are added in order to the output sequence.

Let #raw("<path>") return a sequence of three JSON arrays:

#code-block("text", "[0, 1, 2], [\"a\", \"b\", \"c\", \"d\"], [null, null]")

The following expression returns a sequence containing the last element from every array:

#code-block("text", "<path>[last] --> 2, \"d\", null")

The following expression returns the third and fourth element from every array:

#code-block("text", "<path>[2 to 3] --> 2, \"c\", \"d\"")

Note that the first array does not have the fourth element, and the last array does not have the third or fourth element. Accessing non-existent elements is a structural error. In strict mode, it causes the path expression to fail. In lax mode, such errors are suppressed, and only the existing elements are returned.

Another example of a structural error is an improper range specification such as #raw("5 to 3").

Note that the subscripts may overlap, and they do not need to follow the element order. The order in the returned sequence follows the subscripts:

#code-block("text", "<path>[1, 0, 0] --> 1, 0, 0, \"b\", \"a\", \"a\", null, null, null")

==== wildcard array accessor

Returns all elements of each JSON array in the input sequence.

#code-block("text", "<path>[*]")

In lax mode, any non-array items resulting from the evaluation of the input sequence are wrapped into single-element arrays. Note that this is an exception to the rule of automatic array wrapping.

The output order follows the order of the original JSON arrays. Also, the order of elements within the arrays is preserved.

Let #raw("<path>") return a sequence of three JSON arrays:

#code-block("text", "[0, 1, 2], [\"a\", \"b\", \"c\", \"d\"], [null, null]
<path>[*] --> 0, 1, 2, \"a\", \"b\", \"c\", \"d\", null, null")

==== filter

Retrieves the items from the input sequence which satisfy the predicate.

#code-block("text", "<path>?( <predicate> )")

JSON path predicates are syntactically similar to boolean expressions in SQL. However, the semantics are different in many aspects:

- They operate on sequences of items.
- They have their own error handling \(they never fail\).
- They behave different depending on the lax or strict mode.

The predicate evaluates to #raw("true"), #raw("false"), or #raw("unknown"). Note that some predicate expressions involve nested JSON path expression. When evaluating the nested path, the variable #raw("@") refers to the currently examined item from the input sequence.

The following predicate expressions are supported:

- Conjunction

#code-block("text", "<predicate1> && <predicate2>")

- Disjunction

#code-block("text", "<predicate1> || <predicate2>")

- Negation

#code-block("text", "! <predicate>")

- #raw("exists") predicate

#code-block("text", "exists( <path> )")

Returns #raw("true") if the nested path evaluates to a non-empty sequence, and #raw("false") when the nested path evaluates to an empty sequence. If the path evaluation throws an error, returns #raw("unknown").

- #raw("starts with") predicate

#code-block("text", "<path> starts with \"Some text\"
<path> starts with $variable")

The nested #raw("<path>") must evaluate to a sequence of textual items, and the other operand must evaluate to a single textual item. If evaluating of either operand throws an error, the result is #raw("unknown"). All items from the sequence are checked for starting with the right operand. The result is #raw("true") if a match is found, otherwise #raw("false"). However, if any of the comparisons throws an error, the result in the strict mode is #raw("unknown"). The result in the lax mode depends on whether the match or the error was found first.

- #raw("is unknown") predicate

#code-block("text", "( <predicate> ) is unknown")

Returns #raw("true") if the nested predicate evaluates to #raw("unknown"), and #raw("false") otherwise.

- Comparisons

#code-block("text", "<path1> == <path2>
<path1> <> <path2>
<path1> != <path2>
<path1> < <path2>
<path1> > <path2>
<path1> <= <path2>
<path1> >= <path2>")

Both operands of a comparison evaluate to sequences of items. If either evaluation throws an error, the result is #raw("unknown"). Items from the left and right sequence are then compared pairwise. Similarly to the #raw("starts with") predicate, the result is #raw("true") if any of the comparisons returns #raw("true"), otherwise #raw("false"). However, if any of the comparisons throws an error, for example because the compared types are not compatible, the result in the strict mode is #raw("unknown"). The result in the lax mode depends on whether the #raw("true") comparison or the error was found first.

#anchor("ref-json-comparison-rules")

===== Comparison rules

Null values in the context of comparison behave different than SQL null:

- null == null --\> #raw("true")
- null != null, null \< null, ... --\> #raw("false")
- null compared to a scalar value --\> #raw("false")
- null compared to a JSON array or a JSON object --\> #raw("false")

When comparing two scalar values, #raw("true") or #raw("false") is returned if the comparison is successfully performed. The semantics of the comparison is the same as in SQL. In case of an error, e.g. comparing text and number, #raw("unknown") is returned.

Comparing a scalar value with a JSON array or a JSON object, and comparing JSON arrays\/objects is an error, so #raw("unknown") is returned.

===== Examples of filter

Let #raw("<path>") return a sequence of three JSON objects:

#code-block("text", "{\"customer\" : 100, \"region\" : \"AFRICA\"},
{\"region\" : \"ASIA\"},
{\"customer\" : 300, \"region\" : \"AFRICA\", \"comment\" : null}")

#code-block("text", "<path>?(@.region != \"ASIA\") --> {\"customer\" : 100, \"region\" : \"AFRICA\"},
                                {\"customer\" : 300, \"region\" : \"AFRICA\", \"comment\" : null}
<path>?(!exists(@.customer)) --> {\"region\" : \"ASIA\"}")

The following accessors are collectively referred to as #strong[item methods].

==== double\(\)

Converts numeric or text values into double values.

#code-block("text", "<path>.double()")

Let #raw("<path>") return a sequence #raw("-1, 23e4, \"5.6\""):

#code-block("text", "<path>.double() --> -1e0, 23e4, 5.6e0")

==== ceiling\(\), floor\(\), and abs\(\)

Gets the ceiling, the floor or the absolute value for every numeric item in the sequence. The semantics of the operations is the same as in SQL.

Let #raw("<path>") return a sequence #raw("-1.5, -1, 1.3"):

#code-block("text", "<path>.ceiling() --> -1.0, -1, 2.0
<path>.floor() --> -2.0, -1, 1.0
<path>.abs() --> 1.5, 1, 1.3")

==== keyvalue\(\)

Returns a collection of JSON objects including one object per every member of the original object for every JSON object in the sequence.

#code-block("text", "<path>.keyvalue()")

The returned objects have three members:

- "name", which is the original key,
- "value", which is the original bound value,
- "id", which is the unique number, specific to an input object.

Let #raw("<path>") be a sequence of three JSON objects:

#code-block("text", "{\"customer\" : 100, \"region\" : \"AFRICA\"},
{\"region\" : \"ASIA\"},
{\"customer\" : 300, \"region\" : \"AFRICA\", \"comment\" : null}")

#code-block("text", "<path>.keyvalue() --> {\"name\" : \"customer\", \"value\" : 100, \"id\" : 0},
                      {\"name\" : \"region\", \"value\" : \"AFRICA\", \"id\" : 0},
                      {\"name\" : \"region\", \"value\" : \"ASIA\", \"id\" : 1},
                      {\"name\" : \"customer\", \"value\" : 300, \"id\" : 2},
                      {\"name\" : \"region\", \"value\" : \"AFRICA\", \"id\" : 2},
                      {\"name\" : \"comment\", \"value\" : null, \"id\" : 2}")

It is required that all items in the input sequence are JSON objects.

The order of the returned values follows the order of the original JSON objects. However, within objects, the order of returned entries is arbitrary.

==== type\(\)

Returns a textual value containing the type name for every item in the sequence.

#code-block("text", "<path>.type()")

This method does not perform array unwrapping in the lax mode.

The returned values are:

- #raw("\"null\"") for JSON null,
- #raw("\"number\"") for a numeric item,
- #raw("\"string\"") for a textual item,
- #raw("\"boolean\"") for a boolean item,
- #raw("\"date\"") for an item of type date,
- #raw("\"time without time zone\"") for an item of type time,
- #raw("\"time with time zone\"") for an item of type time with time zone,
- #raw("\"timestamp without time zone\"") for an item of type timestamp,
- #raw("\"timestamp with time zone\"") for an item of type timestamp with time zone,
- #raw("\"array\"") for JSON array,
- #raw("\"object\"") for JSON object,

==== size\(\)

Returns a numeric value containing the size for every JSON array in the sequence.

#code-block("text", "<path>.size()")

This method does not perform array unwrapping in the lax mode. Instead, all non-array items are wrapped in singleton JSON arrays, so their size is #raw("1").

It is required that all items in the input sequence are JSON arrays.

Let #raw("<path>") return a sequence of three JSON arrays:

#code-block("text", "[0, 1, 2], [\"a\", \"b\", \"c\", \"d\"], [null, null]
<path>.size() --> 3, 4, 2")

=== Limitations

The SQL standard describes the #raw("datetime()") JSON path item method. Trino does not support it.

=== Trino-specific behavior

#raw("like_regex()") accepts the standard SQL\/XQuery flags \(#raw("i"), #raw("m"), #raw("s"), #raw("x")\).

==== Limitations

- #raw("\\s"), #raw("\\d"), and #raw("\\w") match only ASCII characters, not the full Unicode character classes defined by XQuery.
- The XML name-class escapes #raw("\\i"), #raw("\\I"), #raw("\\c"), and #raw("\\C") are not supported.
- The #raw("x") extended-mode flag may not be supported in all configurations.

#anchor("ref-json-path-modes")

=== JSON path modes

The JSON path expression can be evaluated in two modes: strict and lax. In the strict mode, it is required that the input JSON data strictly fits the schema required by the path expression. In the lax mode, the input JSON data can diverge from the expected schema.

The following table shows the differences between the two modes.

#list-table((
  ([Condition], [strict mode], [lax mode],),
  ([Performing an operation which requires a non-array on an array, e.g.:

#raw("$.key") requires a JSON object

#raw("$.floor()") requires a numeric value], [ERROR], [The array is automatically unnested, and the operation is performed on each array element.],),
  ([Performing an operation which requires an array on a non-array, e.g.:

#raw("$[0]"), #raw("$[*]"), #raw("$.size()")], [ERROR], [The non-array item is automatically wrapped in a singleton array, and the operation is performed on the array.],),
  ([A structural error: accessing a non-existent element of an array or a non-existent member of a JSON object, e.g.:

#raw("$[-1]") \(array index out of bounds\)

#raw("$.key"), where the input JSON object does not have a member #raw("key")], [ERROR], [The error is suppressed, and the operation results in an empty sequence.],)
), header-rows: 1)

==== Examples of the lax mode behavior

Let #raw("<path>") return a sequence of three items, a JSON array, a JSON object, and a scalar numeric value:

#code-block("text", "[1, \"a\", null], {\"key1\" : 1.0, \"key2\" : true}, -2e3")

The following example shows the wildcard array accessor in the lax mode. The JSON array returns all its elements, while the JSON object and the number are wrapped in singleton arrays and then unnested, so effectively they appear unchanged in the output sequence:

#code-block("text", "<path>[*] --> 1, \"a\", null, {\"key1\" : 1.0, \"key2\" : true}, -2e3")

When calling the #raw("size()") method, the JSON object and the number are also wrapped in singleton arrays:

#code-block("text", "<path>.size() --> 3, 1, 1")

In some cases, the lax mode cannot prevent failure. In the following example, even though the JSON array is unwrapped prior to calling the #raw("floor()") method, the item #raw("\"a\"") causes type mismatch.

#code-block("text", "<path>.floor() --> ERROR")

#anchor("ref-json-exists")

== json\_exists

The #raw("json_exists") function determines whether a JSON value satisfies a JSON path specification.

#code-block("text", "JSON_EXISTS(
    json_input [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ],
    json_path
    [ PASSING json_argument [, ...] ]
    [ { TRUE | FALSE | UNKNOWN | ERROR } ON ERROR ]
    )")

The #raw("json_path") is evaluated using the #raw("json_input") as the context variable \(#raw("$")\), and the passed arguments as the named variables \(#raw("$variable_name")\). The returned value is #raw("true") if the path returns a non-empty sequence, and #raw("false") if the path returns an empty sequence. If an error occurs, the returned value depends on the #raw("ON ERROR") clause. The default value returned #raw("ON ERROR") is #raw("FALSE"). The #raw("ON ERROR") clause is applied for the following kinds of errors:

- Input conversion errors, such as malformed JSON
- JSON path evaluation errors, e.g. division by zero

#raw("json_input") is a character string or a binary string. It should contain a single JSON item. For a binary string, you can specify encoding.

#raw("json_path") is a string literal, containing the path mode specification, and the path expression, following the syntax rules described in #link(label("ref-json-path-syntax-and-semantics"))[json-path-syntax-and-semantics].

#code-block("text", "'strict ($.price + $.tax)?(@ > 99.9)'
'lax $[0 to 1].floor()?(@ > 10)'")

In the #raw("PASSING") clause you can pass arbitrary expressions to be used by the path expression.

#code-block("text", "PASSING orders.totalprice AS O_PRICE,
        orders.tax % 10 AS O_TAX")

The passed parameters can be referenced in the path expression by named variables, prefixed with #raw("$").

#code-block("text", "'lax $?(@.price > $O_PRICE || @.tax > $O_TAX)'")

Additionally to SQL values, you can pass JSON values, specifying the format and optional encoding:

#code-block("text", "PASSING orders.json_desc FORMAT JSON AS o_desc,
        orders.binary_record FORMAT JSON ENCODING UTF16 AS o_rec")

Note that the JSON path language is case-sensitive, while the unquoted SQL identifiers are upper-cased. Therefore, it is recommended to use quoted identifiers in the #raw("PASSING") clause:

#code-block("text", "'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS KeyName --> ERROR; no passed value found
'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS \"KeyName\" --> correct")

=== Examples

Let #raw("customers") be a table containing two columns: #raw("id:bigint"), #raw("description:varchar").

#list-table((
  ([id], [description],),
  ([101], ['{"comment" : "nice", "children" : \[10, 13, 16\]}'],),
  ([102], ['{"comment" : "problematic", "children" : \[8, 11\]}'],),
  ([103], ['{"comment" : "knows best", "children" : \[2\]}'],)
), header-rows: 1)

The following query checks which customers have children above the age of 10:

#code-block("text", "SELECT
      id,
      json_exists(
                  description,
                  'lax $.children[*]?(@ > 10)'
                 ) AS children_above_ten
FROM customers")

#list-table((
  ([id], [children\_above\_ten],),
  ([101], [true],),
  ([102], [true],),
  ([103], [false],)
), header-rows: 1)

In the following query, the path mode is strict. We check the third child for each customer. This should cause a structural error for the customers who do not have three or more children. This error is handled according to the #raw("ON ERROR") clause.

#code-block("text", "SELECT
      id,
      json_exists(
                  description,
                  'strict $.children[2]?(@ > 10)'
                  UNKNOWN ON ERROR
                 ) AS child_3_above_ten
FROM customers")

#list-table((
  ([id], [child\_3\_above\_ten],),
  ([101], [true],),
  ([102], [NULL],),
  ([103], [NULL],)
), header-rows: 1)

#anchor("ref-json-query")

== json\_query

The #raw("json_query") function extracts a JSON value from a JSON value.

#code-block("text", "JSON_QUERY(
    json_input [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ],
    json_path
    [ PASSING json_argument [, ...] ]
    [ RETURNING type [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ] ]
    [ WITHOUT [ ARRAY ] WRAPPER |
      WITH [ { CONDITIONAL | UNCONDITIONAL } ] [ ARRAY ] WRAPPER ]
    [ { KEEP | OMIT } QUOTES [ ON SCALAR STRING ] ]
    [ { ERROR | NULL | EMPTY ARRAY | EMPTY OBJECT } ON EMPTY ]
    [ { ERROR | NULL | EMPTY ARRAY | EMPTY OBJECT } ON ERROR ]
    )")

The constant string #raw("json_path") is evaluated using the #raw("json_input") as the context variable \(#raw("$")\), and the passed arguments as the named variables \(#raw("$variable_name")\).

The returned value is a JSON item returned by the path. By default, it is represented as a character string \(#raw("varchar")\). In the #raw("RETURNING") clause, you can specify other character string type or #raw("varbinary"). With #raw("varbinary"), you can also specify the desired encoding.

#raw("json_input") is a character string or a binary string. It should contain a single JSON item. For a binary string, you can specify encoding.

#raw("json_path") is a string literal, containing the path mode specification, and the path expression, following the syntax rules described in #link(label("ref-json-path-syntax-and-semantics"))[json-path-syntax-and-semantics].

#code-block("text", "'strict $.keyvalue()?(@.name == $cust_id)'
'lax $[5 to last]'")

In the #raw("PASSING") clause you can pass arbitrary expressions to be used by the path expression.

#code-block("text", "PASSING orders.custkey AS CUST_ID")

The passed parameters can be referenced in the path expression by named variables, prefixed with #raw("$").

#code-block("text", "'strict $.keyvalue()?(@.value == $CUST_ID)'")

Additionally to SQL values, you can pass JSON values, specifying the format and optional encoding:

#code-block("text", "PASSING orders.json_desc FORMAT JSON AS o_desc,
        orders.binary_record FORMAT JSON ENCODING UTF16 AS o_rec")

Note that the JSON path language is case-sensitive, while the unquoted SQL identifiers are upper-cased. Therefore, it is recommended to use quoted identifiers in the #raw("PASSING") clause:

#code-block("text", "'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS KeyName --> ERROR; no passed value found
'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS \"KeyName\" --> correct")

The #raw("ARRAY WRAPPER") clause lets you modify the output by wrapping the results in a JSON array. #raw("WITHOUT ARRAY WRAPPER") is the default option. #raw("WITH CONDITIONAL ARRAY WRAPPER") wraps every result which is not a singleton JSON array or JSON object. #raw("WITH UNCONDITIONAL ARRAY WRAPPER") wraps every result.

The #raw("QUOTES") clause lets you modify the result for a scalar string by removing the double quotes being part of the JSON string representation.

=== Examples

Let #raw("customers") be a table containing two columns: #raw("id:bigint"), #raw("description:varchar").

#list-table((
  ([id], [description],),
  ([101], ['{"comment" : "nice", "children" : \[10, 13, 16\]}'],),
  ([102], ['{"comment" : "problematic", "children" : \[8, 11\]}'],),
  ([103], ['{"comment" : "knows best", "children" : \[2\]}'],)
), header-rows: 1)

The following query gets the #raw("children") array for each customer:

#code-block("text", "SELECT
      id,
      json_query(
                 description,
                 'lax $.children'
                ) AS children
FROM customers")

#list-table((
  ([id], [children],),
  ([101], ['\[10,13,16\]'],),
  ([102], ['\[8,11\]'],),
  ([103], ['\[2\]'],)
), header-rows: 1)

The following query gets the collection of children for each customer. Note that the #raw("json_query") function can only output a single JSON item. If you don't use array wrapper, you get an error for every customer with multiple children. The error is handled according to the #raw("ON ERROR") clause.

#code-block("text", "SELECT
      id,
      json_query(
                 description,
                 'lax $.children[*]'
                 WITHOUT ARRAY WRAPPER
                 NULL ON ERROR
                ) AS children
FROM customers")

#list-table((
  ([id], [children],),
  ([101], [NULL],),
  ([102], [NULL],),
  ([103], ['2'],)
), header-rows: 1)

The following query gets the last child for each customer, wrapped in a JSON array:

#code-block("text", "SELECT
      id,
      json_query(
                 description,
                 'lax $.children[last]'
                 WITH ARRAY WRAPPER
                ) AS last_child
FROM customers")

#list-table((
  ([id], [last\_child],),
  ([101], ['\[16\]'],),
  ([102], ['\[11\]'],),
  ([103], ['\[2\]'],)
), header-rows: 1)

The following query gets all children above the age of 12 for each customer, wrapped in a JSON array. The second and the third customer don't have children of this age. Such case is handled according to the #raw("ON EMPTY") clause. The default value returned #raw("ON EMPTY") is #raw("NULL"). In the following example, #raw("EMPTY ARRAY ON EMPTY") is specified.

#code-block("text", "SELECT
      id,
      json_query(
                 description,
                 'strict $.children[*]?(@ > 12)'
                 WITH ARRAY WRAPPER
                 EMPTY ARRAY ON EMPTY
                ) AS children
FROM customers")

#list-table((
  ([id], [children],),
  ([101], ['\[13,16\]'],),
  ([102], ['\[\]'],),
  ([103], ['\[\]'],)
), header-rows: 1)

The following query shows the result of the #raw("QUOTES") clause. Note that #raw("KEEP QUOTES") is the default.

#code-block("text", "SELECT
      id,
      json_query(description, 'strict $.comment' KEEP QUOTES) AS quoted_comment,
      json_query(description, 'strict $.comment' OMIT QUOTES) AS unquoted_comment
FROM customers")

#list-table((
  ([id], [quoted\_comment], [unquoted\_comment],),
  ([101], ['"nice"'], ['nice'],),
  ([102], ['"problematic"'], ['problematic'],),
  ([103], ['"knows best"'], ['knows best'],)
), header-rows: 1)

If an error occurs, the returned value depends on the #raw("ON ERROR") clause. The default value returned #raw("ON ERROR") is #raw("NULL"). One example of error is multiple items returned by the path. Other errors caught and handled according to the #raw("ON ERROR") clause are:

- Input conversion errors, such as malformed JSON
- JSON path evaluation errors, e.g. division by zero
- Output conversion errors

#anchor("ref-json-value")

== json\_value

The #raw("json_value") function extracts a scalar SQL value from a JSON value.

#code-block("text", "JSON_VALUE(
    json_input [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ],
    json_path
    [ PASSING json_argument [, ...] ]
    [ RETURNING type ]
    [ { ERROR | NULL | DEFAULT expression } ON EMPTY ]
    [ { ERROR | NULL | DEFAULT expression } ON ERROR ]
    )")

The #raw("json_path") is evaluated using the #raw("json_input") as the context variable \(#raw("$")\), and the passed arguments as the named variables \(#raw("$variable_name")\).

The returned value is the SQL scalar returned by the path. By default, it is converted to string \(#raw("varchar")\). In the #raw("RETURNING") clause, you can specify other desired type: a character string type, numeric, boolean or datetime type.

#raw("json_input") is a character string or a binary string. It should contain a single JSON item. For a binary string, you can specify encoding.

#raw("json_path") is a string literal, containing the path mode specification, and the path expression, following the syntax rules described in #link(label("ref-json-path-syntax-and-semantics"))[json-path-syntax-and-semantics].

#code-block("text", "'strict $.price + $tax'
'lax $[last].abs().floor()'")

In the #raw("PASSING") clause you can pass arbitrary expressions to be used by the path expression.

#code-block("text", "PASSING orders.tax AS O_TAX")

The passed parameters can be referenced in the path expression by named variables, prefixed with #raw("$").

#code-block("text", "'strict $[last].price + $O_TAX'")

Additionally to SQL values, you can pass JSON values, specifying the format and optional encoding:

#code-block("text", "PASSING orders.json_desc FORMAT JSON AS o_desc,
        orders.binary_record FORMAT JSON ENCODING UTF16 AS o_rec")

Note that the JSON path language is case-sensitive, while the unquoted SQL identifiers are upper-cased. Therefore, it is recommended to use quoted identifiers in the #raw("PASSING") clause:

#code-block("text", "'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS KeyName --> ERROR; no passed value found
'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS \"KeyName\" --> correct")

If the path returns an empty sequence, the #raw("ON EMPTY") clause is applied. The default value returned #raw("ON EMPTY") is #raw("NULL"). You can also specify the default value:

#code-block("text", "DEFAULT -1 ON EMPTY")

If an error occurs, the returned value depends on the #raw("ON ERROR") clause. The default value returned #raw("ON ERROR") is #raw("NULL"). One example of error is multiple items returned by the path. Other errors caught and handled according to the #raw("ON ERROR") clause are:

- Input conversion errors, such as malformed JSON
- JSON path evaluation errors, e.g. division by zero
- Returned scalar not convertible to the desired type

The #raw("DEFAULT") expression in #raw("ON EMPTY") and #raw("ON ERROR") is only evaluated when the corresponding branch is taken. If evaluation of the #raw("ON EMPTY") default itself raises a data exception, the failure cascades to the #raw("ON ERROR") clause. Subqueries are not supported in #raw("DEFAULT") expressions.

=== Examples

Let #raw("customers") be a table containing two columns: #raw("id:bigint"), #raw("description:varchar").

#list-table((
  ([id], [description],),
  ([101], ['{"comment" : "nice", "children" : \[10, 13, 16\]}'],),
  ([102], ['{"comment" : "problematic", "children" : \[8, 11\]}'],),
  ([103], ['{"comment" : "knows best", "children" : \[2\]}'],)
), header-rows: 1)

The following query gets the #raw("comment") for each customer as #raw("char(12)"):

#code-block("text", "SELECT id, json_value(
                      description,
                      'lax $.comment'
                      RETURNING char(12)
                     ) AS comment
FROM customers")

#list-table((
  ([id], [comment],),
  ([101], ['nice        '],),
  ([102], ['problematic '],),
  ([103], ['knows best  '],)
), header-rows: 1)

The following query gets the first child's age for each customer as #raw("tinyint"):

#code-block("text", "SELECT id, json_value(
                      description,
                      'lax $.children[0]'
                      RETURNING tinyint
                     ) AS child
FROM customers")

#list-table((
  ([id], [child],),
  ([101], [10],),
  ([102], [8],),
  ([103], [2],)
), header-rows: 1)

The following query gets the third child's age for each customer. In the strict mode, this should cause a structural error for the customers who do not have the third child. This error is handled according to the #raw("ON ERROR") clause.

#code-block("text", "SELECT id, json_value(
                      description,
                      'strict $.children[2]'
                      DEFAULT 'err' ON ERROR
                     ) AS child
FROM customers")

#list-table((
  ([id], [child],),
  ([101], ['16'],),
  ([102], ['err'],),
  ([103], ['err'],)
), header-rows: 1)

After changing the mode to lax, the structural error is suppressed, and the customers without a third child produce empty sequence. This case is handled according to the #raw("ON EMPTY") clause.

#code-block("text", "SELECT id, json_value(
                      description,
                      'lax $.children[2]'
                      DEFAULT 'missing' ON EMPTY
                     ) AS child
FROM customers")

#list-table((
  ([id], [child],),
  ([101], ['16'],),
  ([102], ['missing'],),
  ([103], ['missing'],)
), header-rows: 1)

#anchor("ref-json-table")

== json\_table

The #raw("json_table") clause extracts a table from a JSON value. Use this clause to transform JSON data into a relational format, making it easier to query and analyze. Use #raw("json_table") in the #raw("FROM") clause of a #link(label("ref-select-json-table"))[#raw("SELECT")] statement to create a table from JSON data.

#code-block("text", "JSON_TABLE(
    json_input,
    json_path [ AS path_name ]
    [ PASSING value AS parameter_name [, ...] ]
    COLUMNS (
        column_definition [, ...] )
    [ PLAN ( json_table_specific_plan )
      | PLAN DEFAULT ( json_table_default_plan ) ]
    [ { ERROR | EMPTY } ON ERROR ]
)")

The #raw("COLUMNS") clause supports the following #raw("column_definition") arguments:

#code-block("text", "column_name FOR ORDINALITY
| column_name type
    [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ]
    [ PATH json_path ]
    [ { WITHOUT | WITH { CONDITIONAL | UNCONDITIONAL } } [ ARRAY ] WRAPPER ]
    [ { KEEP | OMIT } QUOTES [ ON SCALAR STRING ] ]
    [ { ERROR | NULL | EMPTY { [ARRAY] | OBJECT } | DEFAULT expression } ON EMPTY ]
    [ { ERROR | NULL | DEFAULT expression } ON ERROR ]
| NESTED [ PATH ] json_path [ AS path_name ] COLUMNS ( column_definition [, ...] )")

#raw("json_input") is a character string or a binary string. It must contain a single JSON item.

#raw("json_path") is a string literal containing the path mode specification and the path expression. It follows the syntax rules described in #link(label("ref-json-path-syntax-and-semantics"))[JSON functions and operators].

#code-block("text", "'strict ($.price + $.tax)?(@ > 99.9)'
'lax $[0 to 1].floor()?(@ > 10)'")

In the #raw("PASSING") clause, pass values as named parameters that the #raw("json_path") expression can reference.

#code-block("text", "PASSING orders.totalprice AS o_price,
        orders.tax % 10 AS o_tax")

Use named parameters to reference the values in the path expression. Prefix named parameters with #raw("$").

#code-block("text", "'lax $?(@.price > $o_price || @.tax > $o_tax)'")

You can also pass JSON values in the #raw("PASSING") clause. Use #raw("FORMAT JSON") to specify the format and #raw("ENCODING") to specify the encoding:

#code-block("text", "PASSING orders.json_desc FORMAT JSON AS o_desc,
        orders.binary_record FORMAT JSON ENCODING UTF16 AS o_rec")

The #raw("json_path") value is case-sensitive. The SQL identifiers are uppercase. Use quoted identifiers in the #raw("PASSING") clause:

#code-block("text", "'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS KeyName --> ERROR; no passed value found
'lax $.keyvalue()?(@.name == $KeyName).value' PASSING nation.name AS \"KeyName\" --> correct")

The #raw("PLAN") clause specifies how to join columns from different paths. Use #raw("OUTER") or #raw("INNER") to define how to join parent paths with their child paths. Use #raw("CROSS") or #raw("UNION") to join siblings.

#raw("COLUMNS") defines the schema of your table. Each #raw("column_definition") specifies how to extract and format your #raw("json_input") value into a relational column.

#raw("PLAN") is an optional clause to control how to process and join nested JSON data.

#raw("ON ERROR") specifies how to handle processing errors. #raw("ERROR ON ERROR") throws an error. #raw("EMPTY ON ERROR") returns an empty result set.

For each value column with #raw("DEFAULT") in its #raw("ON EMPTY") or #raw("ON ERROR") clause, the default expression is only evaluated when the corresponding branch is taken, and if the #raw("ON EMPTY") default itself raises a data exception, the failure cascades to the #raw("ON ERROR") clause. Subqueries are not supported in #raw("json_table") #raw("DEFAULT") expressions.

#raw("column_name") specifies a column name.

#raw("FOR ORDINALITY") adds a row number column to the output table, starting at #raw("1"). Specify the column name in the column definition:

#code-block("text", "row_num FOR ORDINALITY")

#raw("NESTED PATH") extracts data from nested levels of a #raw("json_input") value. Each #raw("NESTED PATH") clause can contain #raw("column_definition") values.

The #raw("json_table") function returns a result set that you can use like any other table in your queries. You can join the result set with other tables or combine multiple arrays from your JSON data.

You can also process nested JSON objects without parsing the data multiple times.

Use #raw("json_table") as a lateral join to process JSON data from another table.

=== Examples

The following query uses #raw("json_table") to extract values from a JSON array and return them as rows in a table with three columns:

#code-block("sql", "SELECT
      *
FROM
      json_table(
                '[
                  {\"id\":1,\"name\":\"Africa\",\"wikiDataId\":\"Q15\"},
                  {\"id\":2,\"name\":\"Americas\",\"wikiDataId\":\"Q828\"},
                  {\"id\":3,\"name\":\"Asia\",\"wikiDataId\":\"Q48\"},
                  {\"id\":4,\"name\":\"Europe\",\"wikiDataId\":\"Q51\"}
                ]',
                'strict $' COLUMNS (
                  NESTED PATH 'strict $[*]' COLUMNS (
                    id integer PATH 'strict $.id',
                    name varchar PATH 'strict $.name',
                    wiki_data_id varchar PATH 'strict $.\"wikiDataId\"'
                  )
                )
              );")

#list-table((
  ([id], [child], [wiki\_data\_id],),
  ([1], [Africa], [Q1],),
  ([2], [Americas], [Q828],),
  ([3], [Asia], [Q48],),
  ([4], [Europe], [Q51],)
), header-rows: 1)

The following query uses #raw("json_table") to extract values from an array of nested JSON objects. It flattens the nested JSON data into a single table. The example query processes an array of continent names, where each continent contains an array of countries and their populations.

The #raw("NESTED PATH 'lax $[*]'") clause iterates through the continent objects, while the #raw("NESTED PATH 'lax $.countries[*]'") iterates through each country within each continent. This creates a flat table structure with four rows combining each continent with each of its countries. Continent values repeat for each of their countries.

#code-block("sql", "SELECT
      *
FROM
      json_table(
                '[
                    {\"continent\": \"Asia\", \"countries\": [
                        {\"name\": \"Japan\", \"population\": 125.7},
                        {\"name\": \"Thailand\", \"population\": 71.6}
                    ]},
                    {\"continent\": \"Europe\", \"countries\": [
                        {\"name\": \"France\", \"population\": 67.4},
                        {\"name\": \"Germany\", \"population\": 83.2}
                    ]}
                ]',
                'lax $' COLUMNS (
                    NESTED PATH 'lax $[*]' COLUMNS (
                        continent varchar PATH 'lax $.continent',
                        NESTED PATH 'lax $.countries[*]' COLUMNS (
                            country varchar PATH 'lax $.name',
                            population double PATH 'lax $.population'
                        )
                    )
                ));")

#list-table((
  ([continent], [country], [population],),
  ([Asia], [Japan], [125.7],),
  ([Asia], [Thailand], [71.6],),
  ([Europe], [France], [67.4],),
  ([Europe], [Germany], [83.2],)
), header-rows: 1)

The following query uses #raw("PLAN") to specify an #raw("OUTER") join between a parent path and a child path:

#code-block("sql", "SELECT
      *
FROM
      JSON_TABLE(
                '[]',
                'lax $' AS \"root_path\"
                COLUMNS(
                    a varchar(1) PATH 'lax \"A\"',
                    NESTED PATH 'lax $[*]' AS \"nested_path\"
                            COLUMNS (b varchar(1) PATH 'lax \"B\"'))
                PLAN (\"root_path\" OUTER \"nested_path\")
                );")

#list-table((
  ([a], [b],),
  ([A], [null],)
), header-rows: 1)

The following query uses #raw("PLAN") to specify an #raw("INNER") join between a parent path and a child path:

#code-block("sql", "SELECT
      *
FROM
      JSON_TABLE(
                '[]',
                'lax $' AS \"root_path\"
                COLUMNS(
                    a varchar(1) PATH 'lax \"A\"',
                    NESTED PATH 'lax $[*]' AS \"nested_path\"
                            COLUMNS (b varchar(1) PATH 'lax \"B\"'))
                PLAN (\"root_path\" INNER \"nested_path\")
                );")

#list-table((
  ([a], [b],),
  ([null], [null],)
), header-rows: 1)

#anchor("ref-json-array")

== json\_array

The #raw("json_array") function creates a JSON array containing given elements.

#code-block("text", "JSON_ARRAY(
    [ array_element [, ...]
      [ { NULL ON NULL | ABSENT ON NULL } ] ],
    [ RETURNING type [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ] ]
    )")

=== Argument types

The array elements can be arbitrary expressions. Each passed value is converted into a JSON item according to its type, and optional #raw("FORMAT") and #raw("ENCODING") specification.

You can pass SQL values of types boolean, numeric, and character string. They are converted to corresponding JSON literals:

#code-block(none, "SELECT json_array(true, 12e-1, 'text')
--> '[true,1.2,\"text\"]'")

Additionally to SQL values, you can pass JSON values. They are character or binary strings with a specified format and optional encoding:

#code-block(none, "SELECT json_array(
                  '[  \"text\"  ] ' FORMAT JSON,
                  X'5B0035005D00' FORMAT JSON ENCODING UTF16
                 )
--> '[[\"text\"],[5]]'")

You can also nest other JSON-returning functions. In that case, the #raw("FORMAT") option is implicit:

#code-block(none, "SELECT json_array(
                  json_query('{\"key\" : [  \"value\"  ]}', 'lax $.key')
                 )
--> '[[\"value\"]]'")

Other passed values are cast to varchar, and they become JSON text literals:

#code-block(none, "SELECT json_array(
                  DATE '2001-01-31',
                  UUID '12151fd2-7586-11e9-8f9e-2a86e4085a59'
                 )
--> '[\"2001-01-31\",\"12151fd2-7586-11e9-8f9e-2a86e4085a59\"]'")

You can omit the arguments altogether to get an empty array:

#code-block(none, "SELECT json_array() --> '[]'")

=== Null handling

If a value passed for an array element is #raw("null"), it is treated according to the specified null treatment option. If #raw("ABSENT ON NULL") is specified, the null element is omitted in the result. If #raw("NULL ON NULL") is specified, JSON #raw("null") is added to the result. #raw("ABSENT ON NULL") is the default configuration:

#code-block(none, "SELECT json_array(true, null, 1)
--> '[true,1]'

SELECT json_array(true, null, 1 ABSENT ON NULL)
--> '[true,1]'

SELECT json_array(true, null, 1 NULL ON NULL)
--> '[true,null,1]'")

=== Returned type

The SQL standard imposes that there is no dedicated data type to represent JSON data in SQL. Instead, JSON data is represented as character or binary strings. By default, the #raw("json_array") function returns varchar containing the textual representation of the JSON array. With the #raw("RETURNING") clause, you can specify other character string type:

#code-block(none, "SELECT json_array(true, 1 RETURNING VARCHAR(100))
--> '[true,1]'")

You can also specify to use varbinary and the required encoding as return type. The default encoding is UTF8:

#code-block(none, "SELECT json_array(true, 1 RETURNING VARBINARY)
--> X'5b 74 72 75 65 2c 31 5d'

SELECT json_array(true, 1 RETURNING VARBINARY FORMAT JSON ENCODING UTF8)
--> X'5b 74 72 75 65 2c 31 5d'

SELECT json_array(true, 1 RETURNING VARBINARY FORMAT JSON ENCODING UTF16)
--> X'5b 00 74 00 72 00 75 00 65 00 2c 00 31 00 5d 00'

SELECT json_array(true, 1 RETURNING VARBINARY FORMAT JSON ENCODING UTF32)
--> X'5b 00 00 00 74 00 00 00 72 00 00 00 75 00 00 00 65 00 00 00 2c 00 00 00 31 00 00 00 5d 00 00 00'")

#anchor("ref-json-object")

== json\_object

The #raw("json_object") function creates a JSON object containing given key-value pairs.

#code-block("text", "JSON_OBJECT(
    [ key_value [, ...]
      [ { NULL ON NULL | ABSENT ON NULL } ] ],
      [ { WITH UNIQUE [ KEYS ] | WITHOUT UNIQUE [ KEYS ] } ]
    [ RETURNING type [ FORMAT JSON [ ENCODING { UTF8 | UTF16 | UTF32 } ] ] ]
    )")

=== Argument passing conventions

There are two conventions for passing keys and values:

#code-block(none, "SELECT json_object('key1' : 1, 'key2' : true)
--> '{\"key1\":1,\"key2\":true}'

SELECT json_object(KEY 'key1' VALUE 1, KEY 'key2' VALUE true)
--> '{\"key1\":1,\"key2\":true}'")

In the second convention, you can omit the #raw("KEY") keyword:

#code-block(none, "SELECT json_object('key1' VALUE 1, 'key2' VALUE true)
--> '{\"key1\":1,\"key2\":true}'")

=== Argument types

The keys can be arbitrary expressions. They must be of character string type. Each key is converted into a JSON text item, and it becomes a key in the created JSON object. Keys must not be null.

The values can be arbitrary expressions. Each passed value is converted into a JSON item according to its type, and optional #raw("FORMAT") and #raw("ENCODING") specification.

You can pass SQL values of types boolean, numeric, and character string. They are converted to corresponding JSON literals:

#code-block(none, "SELECT json_object('x' : true, 'y' : 12e-1, 'z' : 'text')
--> '{\"x\":true,\"y\":1.2,\"z\":\"text\"}'")

Additionally to SQL values, you can pass JSON values. They are character or binary strings with a specified format and optional encoding:

#code-block(none, "SELECT json_object(
                   'x' : '[  \"text\"  ] ' FORMAT JSON,
                   'y' : X'5B0035005D00' FORMAT JSON ENCODING UTF16
                  )
--> '{\"x\":[\"text\"],\"y\":[5]}'")

You can also nest other JSON-returning functions. In that case, the #raw("FORMAT") option is implicit:

#code-block(none, "SELECT json_object(
                   'x' : json_query('{\"key\" : [  \"value\"  ]}', 'lax $.key')
                  )
--> '{\"x\":[\"value\"]}'")

Other passed values are cast to varchar, and they become JSON text literals:

#code-block(none, "SELECT json_object(
                   'x' : DATE '2001-01-31',
                   'y' : UUID '12151fd2-7586-11e9-8f9e-2a86e4085a59'
                  )
--> '{\"x\":\"2001-01-31\",\"y\":\"12151fd2-7586-11e9-8f9e-2a86e4085a59\"}'")

You can omit the arguments altogether to get an empty object:

#code-block(none, "SELECT json_object() --> '{}'")

=== Null handling

The values passed for JSON object keys must not be null. It is allowed to pass #raw("null") for JSON object values. A null value is treated according to the specified null treatment option. If #raw("NULL ON NULL") is specified, a JSON object entry with #raw("null") value is added to the result. If #raw("ABSENT ON NULL") is specified, the entry is omitted in the result. #raw("NULL ON NULL") is the default configuration.:

#code-block(none, "SELECT json_object('x' : null, 'y' : 1)
--> '{\"x\":null,\"y\":1}'

SELECT json_object('x' : null, 'y' : 1 NULL ON NULL)
--> '{\"x\":null,\"y\":1}'

SELECT json_object('x' : null, 'y' : 1 ABSENT ON NULL)
--> '{\"y\":1}'")

=== Key uniqueness

If a duplicate key is encountered, it is handled according to the specified key uniqueness constraint.

If #raw("WITH UNIQUE KEYS") is specified, a duplicate key results in a query failure:

#code-block(none, "SELECT json_object('x' : null, 'x' : 1 WITH UNIQUE KEYS)
--> failure: \"duplicate key passed to JSON_OBJECT function\"")

Note that this option is not supported if any of the arguments has a #raw("FORMAT") specification.

If #raw("WITHOUT UNIQUE KEYS") is specified, duplicate keys are not supported due to implementation limitation. #raw("WITHOUT UNIQUE KEYS") is the default configuration.

=== Returned type

The SQL standard imposes that there is no dedicated data type to represent JSON data in SQL. Instead, JSON data is represented as character or binary strings. By default, the #raw("json_object") function returns varchar containing the textual representation of the JSON object. With the #raw("RETURNING") clause, you can specify other character string type:

#code-block(none, "SELECT json_object('x' : 1 RETURNING VARCHAR(100))
--> '{\"x\":1}'")

You can also specify to use varbinary and the required encoding as return type. The default encoding is UTF8:

#code-block(none, "SELECT json_object('x' : 1 RETURNING VARBINARY)
--> X'7b 22 78 22 3a 31 7d'

SELECT json_object('x' : 1 RETURNING VARBINARY FORMAT JSON ENCODING UTF8)
--> X'7b 22 78 22 3a 31 7d'

SELECT json_object('x' : 1 RETURNING VARBINARY FORMAT JSON ENCODING UTF16)
--> X'7b 00 22 00 78 00 22 00 3a 00 31 00 7d 00'

SELECT json_object('x' : 1 RETURNING VARBINARY FORMAT JSON ENCODING UTF32)
--> X'7b 00 00 00 22 00 00 00 78 00 00 00 22 00 00 00 3a 00 00 00 31 00 00 00 7d 00 00 00'")

#warning[
The following functions and operators are not compliant with the SQL standard, and should be considered deprecated. According to the SQL standard, there shall be no #raw("JSON") data type. Instead, JSON values should be represented as string values. The remaining functionality of the following functions is covered by the functions described previously.
]

== Cast to JSON

The following types can be cast to JSON:

- #raw("BOOLEAN")
- #raw("TINYINT")
- #raw("SMALLINT")
- #raw("INTEGER")
- #raw("BIGINT")
- #raw("REAL")
- #raw("DOUBLE")
- #raw("VARCHAR")

Additionally, #raw("ARRAY"), #raw("MAP"), and #raw("ROW") types can be cast to JSON when the following requirements are met:

- #raw("ARRAY") types can be cast when the element type of the array is one of the supported types.
- #raw("MAP") types can be cast when the key type of the map is #raw("VARCHAR") and the value type of the map is a supported type,
- #raw("ROW") types can be cast when every field type of the row is a supported type.

#note[
Cast operations with supported #link(label("ref-string-data-types"))[character string types] treat the input as a string, not validated as JSON. This means that a cast operation with a string-type input of invalid JSON results in a successful cast to invalid JSON.

Instead, consider using the #link(label("fn-json-parse"), raw("json_parse")) function to create validated JSON from a string.
]

The following examples show the behavior of casting to JSON with these types:

#code-block(none, "SELECT CAST(NULL AS JSON);
-- NULL

SELECT CAST(1 AS JSON);
-- JSON '1'

SELECT CAST(9223372036854775807 AS JSON);
-- JSON '9223372036854775807'

SELECT CAST('abc' AS JSON);
-- JSON '\"abc\"'

SELECT CAST(true AS JSON);
-- JSON 'true'

SELECT CAST(1.234 AS JSON);
-- JSON '1.234'

SELECT CAST(ARRAY[1, 23, 456] AS JSON);
-- JSON '[1,23,456]'

SELECT CAST(ARRAY[1, NULL, 456] AS JSON);
-- JSON '[1,null,456]'

SELECT CAST(ARRAY[ARRAY[1, 23], ARRAY[456]] AS JSON);
-- JSON '[[1,23],[456]]'

SELECT CAST(MAP(ARRAY['k1', 'k2', 'k3'], ARRAY[1, 23, 456]) AS JSON);
-- JSON '{\"k1\":1,\"k2\":23,\"k3\":456}'

SELECT CAST(CAST(ROW(123, 'abc', true) AS
            ROW(v1 BIGINT, v2 VARCHAR, v3 BOOLEAN)) AS JSON);
-- JSON '{\"v1\":123,\"v2\":\"abc\",\"v3\":true}'")

Casting from NULL to #raw("JSON") is not straightforward. Casting from a standalone #raw("NULL") will produce SQL #raw("NULL") instead of #raw("JSON 'null'"). However, when casting from arrays or map containing #raw("NULL")s, the produced #raw("JSON") will have #raw("null")s in it.

== Cast from JSON

Casting to #raw("BOOLEAN"), #raw("TINYINT"), #raw("SMALLINT"), #raw("INTEGER"), #raw("BIGINT"), #raw("REAL"), #raw("DOUBLE") or #raw("VARCHAR") is supported. Casting to #raw("ARRAY") and #raw("MAP") is supported when the element type of the array is one of the supported types, or when the key type of the map is #raw("VARCHAR") and value type of the map is one of the supported types. Behaviors of the casts are shown with the examples below:

#code-block(none, "SELECT CAST(JSON 'null' AS VARCHAR);
-- NULL

SELECT CAST(JSON '1' AS INTEGER);
-- 1

SELECT CAST(JSON '9223372036854775807' AS BIGINT);
-- 9223372036854775807

SELECT CAST(JSON '\"abc\"' AS VARCHAR);
-- abc

SELECT CAST(JSON 'true' AS BOOLEAN);
-- true

SELECT CAST(JSON '1.234' AS DOUBLE);
-- 1.234

SELECT CAST(JSON '[1,23,456]' AS ARRAY(INTEGER));
-- [1, 23, 456]

SELECT CAST(JSON '[1,null,456]' AS ARRAY(INTEGER));
-- [1, NULL, 456]

SELECT CAST(JSON '[[1,23],[456]]' AS ARRAY(ARRAY(INTEGER)));
-- [[1, 23], [456]]

SELECT CAST(JSON '{\"k1\":1,\"k2\":23,\"k3\":456}' AS MAP(VARCHAR, INTEGER));
-- {k1=1, k2=23, k3=456}

SELECT CAST(JSON '{\"v1\":123,\"v2\":\"abc\",\"v3\":true}' AS
            ROW(v1 BIGINT, v2 VARCHAR, v3 BOOLEAN));
-- {v1=123, v2=abc, v3=true}

SELECT CAST(JSON '[123,\"abc\",true]' AS
            ROW(v1 BIGINT, v2 VARCHAR, v3 BOOLEAN));
-- {v1=123, v2=abc, v3=true}")

JSON arrays can have mixed element types and JSON maps can have mixed value types. This makes it impossible to cast them to SQL arrays and maps in some cases. To address this, Trino supports partial casting of arrays and maps:

#code-block(none, "SELECT CAST(JSON '[[1, 23], 456]' AS ARRAY(JSON));
-- [JSON '[1,23]', JSON '456']

SELECT CAST(JSON '{\"k1\": [1, 23], \"k2\": 456}' AS MAP(VARCHAR, JSON));
-- {k1 = JSON '[1,23]', k2 = JSON '456'}

SELECT CAST(JSON '[null]' AS ARRAY(JSON));
-- [JSON 'null']")

When casting from #raw("JSON") to #raw("ROW"), both JSON array and JSON object are supported.

== Other JSON functions

In addition to the functions explained in more details in the preceding sections, the following functions are available:

#function-def("fn-is-json-scalar", "is_json_scalar(json)", "boolean")[
Determine if #raw("json") is a scalar \(i.e. a JSON number, a JSON string, #raw("true"), #raw("false") or #raw("null")\):

#code-block(none, "SELECT is_json_scalar('1');         -- true
SELECT is_json_scalar('[1, 2, 3]'); -- false")
]

#function-def("fn-json-array-contains", "json_array_contains(json, value)", "boolean")[
Determine if #raw("value") exists in #raw("json") \(a string containing a JSON array\):

#code-block(none, "SELECT json_array_contains('[1, 2, 3]', 2); -- true")
]

#function-def("fn-json-array-get", "json_array_get(json_array, index)", "json")[
#warning[
The semantics of this function are broken. If the extracted element is a string, it will be converted into an invalid #raw("JSON") value that is not properly quoted \(the value will not be surrounded by quotes and any interior quotes will not be escaped\).

We recommend against using this function. It cannot be fixed without impacting existing usages and may be removed in a future release.

Use #link(label("ref-json-query"))[json\_query] instead with JSONPath array indexing syntax, e.g., #raw("json_query(json_array, 'lax $[0]')").
]

Returns the element at the specified index into the #raw("json_array"). The index is zero-based:

#code-block(none, "SELECT json_array_get('[\"a\", [3, 9], \"c\"]', 0); -- JSON 'a' (invalid JSON)
SELECT json_array_get('[\"a\", [3, 9], \"c\"]', 1); -- JSON '[3,9]'")

This function also supports negative indexes for fetching element indexed from the end of an array:

#code-block(none, "SELECT json_array_get('[\"c\", [3, 9], \"a\"]', -1); -- JSON 'a' (invalid JSON)
SELECT json_array_get('[\"c\", [3, 9], \"a\"]', -2); -- JSON '[3,9]'")

If the element at the specified index doesn't exist, the function returns null:

#code-block(none, "SELECT json_array_get('[]', 0);                -- NULL
SELECT json_array_get('[\"a\", \"b\", \"c\"]', 10);  -- NULL
SELECT json_array_get('[\"c\", \"b\", \"a\"]', -10); -- NULL")
]

#function-def("fn-json-array-length", "json_array_length(json)", "bigint")[
Returns the array length of #raw("json") \(a string containing a JSON array\):

#code-block(none, "SELECT json_array_length('[1, 2, 3]'); -- 3")
]

#function-def("fn-json-extract", "json_extract(json, json_path)", "json")[
Evaluates the \[JSONPath\]-like expression #raw("json_path") on #raw("json") \(a string containing JSON\) and returns the result as a JSON string:

#code-block(none, "SELECT json_extract(json, '$.store.book');
SELECT json_extract(json, '$.store[book]');
SELECT json_extract(json, '$.store[\"book name\"]');")

The #link(label("ref-json-query"))[json\_query function] provides a more powerful and feature-rich alternative to parse and extract JSON data.
]

#function-def("fn-json-extract-scalar", "json_extract_scalar(json, json_path)", "varchar")[
Like #link(label("fn-json-extract"), raw("json_extract")), but returns the result value as a string \(as opposed to being encoded as JSON\). The value referenced by #raw("json_path") must be a scalar \(boolean, number or string\).

#code-block(none, "SELECT json_extract_scalar('[1, 2, 3]', '$[2]');
SELECT json_extract_scalar(json, '$.store.book[0].author');")
]

#function-def("fn-json-format", "json_format(json)", "varchar")[
Returns the JSON text serialized from the input JSON value. This is inverse function to #link(label("fn-json-parse"), raw("json_parse")).

#code-block(none, "SELECT json_format(JSON '[1, 2, 3]'); -- '[1,2,3]'
SELECT json_format(JSON '\"a\"');       -- '\"a\"'")

#note[
#link(label("fn-json-format"), raw("json_format")) and #raw("CAST(json AS VARCHAR)") have completely different semantics.

#link(label("fn-json-format"), raw("json_format")) serializes the input JSON value to JSON text conforming to #link("https://www.rfc-editor.org/rfc/rfc7159")[RFC 7159]. The JSON value can be a JSON object, a JSON array, a JSON string, a JSON number, #raw("true"), #raw("false") or #raw("null").

#code-block(none, "SELECT json_format(JSON '{\"a\": 1, \"b\": 2}'); -- '{\"a\":1,\"b\":2}'
SELECT json_format(JSON '[1, 2, 3]');        -- '[1,2,3]'
SELECT json_format(JSON '\"abc\"');            -- '\"abc\"'
SELECT json_format(JSON '42');               -- '42'
SELECT json_format(JSON 'true');             -- 'true'
SELECT json_format(JSON 'null');             -- 'null'")

#raw("CAST(json AS VARCHAR)") casts the JSON value to the corresponding SQL VARCHAR value. For JSON string, JSON number, #raw("true"), #raw("false") or #raw("null"), the cast behavior is same as the corresponding SQL type. JSON object and JSON array cannot be cast to VARCHAR.

#code-block(none, "SELECT CAST(JSON '{\"a\": 1, \"b\": 2}' AS VARCHAR); -- ERROR!
SELECT CAST(JSON '[1, 2, 3]' AS VARCHAR);        -- ERROR!
SELECT CAST(JSON '\"abc\"' AS VARCHAR);            -- 'abc' (the double quote is gone)
SELECT CAST(JSON '42' AS VARCHAR);               -- '42'
SELECT CAST(JSON 'true' AS VARCHAR);             -- 'true'
SELECT CAST(JSON 'null' AS VARCHAR);             -- NULL")
]
]

#function-def("fn-json-parse", "json_parse(string)", "json")[
Returns the JSON value deserialized from the input JSON text. This is inverse function to #link(label("fn-json-format"), raw("json_format")):

#code-block(none, "SELECT json_parse('[1, 2, 3]');   -- JSON '[1,2,3]'
SELECT json_parse('\"abc\"');       -- JSON '\"abc\"'")

#note[
#link(label("fn-json-parse"), raw("json_parse")) and #raw("CAST(string AS JSON)") have completely different semantics.

#link(label("fn-json-parse"), raw("json_parse")) expects a JSON text conforming to #link("https://www.rfc-editor.org/rfc/rfc7159")[RFC 7159], and returns the JSON value deserialized from the JSON text. The JSON value can be a JSON object, a JSON array, a JSON string, a JSON number, #raw("true"), #raw("false") or #raw("null").

#code-block(none, "SELECT json_parse('not_json');         -- ERROR!
SELECT json_parse('[\"a\": 1, \"b\": 2]'); -- JSON '[\"a\": 1, \"b\": 2]'
SELECT json_parse('[1, 2, 3]');        -- JSON '[1,2,3]'
SELECT json_parse('\"abc\"');            -- JSON '\"abc\"'
SELECT json_parse('42');               -- JSON '42'
SELECT json_parse('true');             -- JSON 'true'
SELECT json_parse('null');             -- JSON 'null'")

#raw("CAST(string AS JSON)") takes any VARCHAR value as input, and returns a JSON string with its value set to input string.

#code-block(none, "SELECT CAST('not_json' AS JSON);         -- JSON '\"not_json\"'
SELECT CAST('[\"a\": 1, \"b\": 2]' AS JSON); -- JSON '\"[\\\"a\\\": 1, \\\"b\\\": 2]\"'
SELECT CAST('[1, 2, 3]' AS JSON);        -- JSON '\"[1, 2, 3]\"'
SELECT CAST('\"abc\"' AS JSON);            -- JSON '\"\\\"abc\\\"\"'
SELECT CAST('42' AS JSON);               -- JSON '\"42\"'
SELECT CAST('true' AS JSON);             -- JSON '\"true\"'
SELECT CAST('null' AS JSON);             -- JSON '\"null\"'")
]
]

#function-def("fn-json-size", "json_size(json, json_path)", "bigint")[
Like #link(label("fn-json-extract"), raw("json_extract")), but returns the size of the value. For objects or arrays, the size is the number of members, and the size of a scalar value is zero.

#code-block(none, "SELECT json_size('{\"x\": {\"a\": 1, \"b\": 2}}', '$.x');   -- 2
SELECT json_size('{\"x\": [1, 2, 3]}', '$.x');          -- 3
SELECT json_size('{\"x\": {\"a\": 1, \"b\": 2}}', '$.x.a'); -- 0")
]
