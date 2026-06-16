#import "/lib/trino-docs.typ": *

#anchor("doc-sql-pattern-recognition-in-window")
= Row pattern recognition in window structures

A window structure can be defined in the #raw("WINDOW") clause or in the #raw("OVER") clause of a window operation. In both cases, the window specification can include row pattern recognition clauses. They are part of the window frame. The syntax and semantics of row pattern recognition in window are similar to those of the #link(label("doc-sql-match-recognize"))[MATCH\_RECOGNIZE] clause.

This section explains the details of row pattern recognition in window structures, and highlights the similarities and the differences between both pattern recognition mechanisms.

== Window with row pattern recognition

#strong[Window specification:]

#code-block("text", "(
[ existing_window_name ]
[ PARTITION BY column [, ...] ]
[ ORDER BY column [, ...] ]
[ window_frame ]
)")

#strong[Window frame:]

#code-block("text", "[ MEASURES measure_definition [, ...] ]
frame_extent
[ AFTER MATCH skip_to ]
[ INITIAL | SEEK ]
[ PATTERN ( row_pattern ) ]
[ SUBSET subset_definition [, ...] ]
[ DEFINE variable_definition [, ...] ]")

Generally, a window frame specifies the #raw("frame_extent"), which defines the "sliding window" of rows to be processed by a window function. It can be defined in terms of #raw("ROWS"), #raw("RANGE") or #raw("GROUPS").

A window frame with row pattern recognition involves many other syntactical components, mandatory or optional, and enforces certain limitations on the #raw("frame_extent").

#strong[Window frame with row pattern recognition:]

#code-block("text", "[ MEASURES measure_definition [, ...] ]
ROWS BETWEEN CURRENT ROW AND frame_end
[ AFTER MATCH skip_to ]
[ INITIAL | SEEK ]
PATTERN ( row_pattern )
[ SUBSET subset_definition [, ...] ]
DEFINE variable_definition [, ...]")

== Description of the pattern recognition clauses

The #raw("frame_extent") with row pattern recognition must be defined in terms of #raw("ROWS"). The frame start must be at the #raw("CURRENT ROW"), which limits the allowed frame extent values to the following:

#code-block(none, "ROWS BETWEEN CURRENT ROW AND CURRENT ROW

ROWS BETWEEN CURRENT ROW AND <expression> FOLLOWING

ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING")

For every input row processed by the window, the portion of rows enclosed by the #raw("frame_extent") limits the search area for row pattern recognition. Unlike in #raw("MATCH_RECOGNIZE"), where the pattern search can explore all rows until the partition end, and all rows of the partition are available for computations, in window structures the pattern matching can neither match rows nor retrieve input values outside the frame.

Besides the #raw("frame_extent"), pattern matching requires the #raw("PATTERN") and #raw("DEFINE") clauses.

The #raw("PATTERN") clause specifies a row pattern, which is a form of a regular expression with some syntactical extensions. The row pattern syntax is similar to the #link(label("ref-row-pattern-syntax"))[row pattern syntax in MATCH\_RECOGNIZE]. However, the anchor patterns #raw("^") and #raw("$") are not allowed in a window specification.

The #raw("DEFINE") clause defines the row pattern primary variables in terms of boolean conditions that must be satisfied. It is similar to the #link(label("ref-row-pattern-variable-definitions"))[DEFINE clause of MATCH\_RECOGNIZE]. The only difference is that the window syntax does not support the #raw("MATCH_NUMBER") function.

The #raw("MEASURES") clause is syntactically similar to the #link(label("ref-row-pattern-measures"))[MEASURES clause of MATCH\_RECOGNIZE]. The only limitation is that the #raw("MATCH_NUMBER") function is not allowed. However, the semantics of this clause differs between #raw("MATCH_RECOGNIZE") and window. While in #raw("MATCH_RECOGNIZE") every measure produces an output column, the measures in window should be considered as #strong[definitions] associated with the window structure. They can be called over the window, in the same manner as regular window functions:

#code-block(none, "SELECT cust_key, value OVER w, label OVER w
    FROM orders
    WINDOW w AS (
                 PARTITION BY cust_key
                 ORDER BY order_date
                 MEASURES
                        RUNNING LAST(total_price) AS value,
                        CLASSIFIER() AS label
                 ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING
                 PATTERN (A B+ C+)
                 DEFINE
                        B AS B.value < PREV (B.value),
                        C AS C.value > PREV (C.value)
                )")

Measures defined in a window can be referenced in the #raw("SELECT") clause and in the #raw("ORDER BY") clause of the enclosing query.

The #raw("RUNNING") and #raw("FINAL") keywords are allowed in the #raw("MEASURES") clause. They can precede a logical navigation function #raw("FIRST") or #raw("LAST"), or an aggregate function. However, they have no effect. Every computation is performed from the position of the final row of the match, so the semantics is effectively #raw("FINAL").

The #raw("AFTER MATCH SKIP") clause has the same syntax as the #link(label("ref-after-match-skip"))[AFTER MATCH SKIP clause of MATCH\_RECOGNIZE].

The #raw("INITIAL") or #raw("SEEK") modifier is specific to row pattern recognition in window. With #raw("INITIAL"), which is the default, the pattern match for an input row can only be found starting from that row. With #raw("SEEK"), if there is no match starting from the current row, the engine tries to find a match starting from subsequent rows within the frame. As a result, it is possible to associate an input row with a match which is detached from that row.

The #raw("SUBSET") clause is used to define #link(label("ref-row-pattern-union-variables"))[union variables] as sets of primary pattern variables. You can use union variables to refer to a set of rows matched to any primary pattern variable from the subset:

#code-block(none, "SUBSET U = (A, B)")

The following expression returns the #raw("total_price") value from the last row matched to either #raw("A") or #raw("B"):

#code-block(none, "LAST(U.total_price)")

If you want to refer to all rows of the match, there is no need to define a #raw("SUBSET") containing all pattern variables. There is an implicit #emph[universal pattern variable] applied to any non prefixed column name and any #raw("CLASSIFIER") call without an argument. The following expression returns the #raw("total_price") value from the last matched row:

#code-block(none, "LAST(total_price)")

The following call returns the primary pattern variable of the first matched row:

#code-block(none, "FIRST(CLASSIFIER())")

In window, unlike in #raw("MATCH_RECOGNIZE"), you cannot specify #raw("ONE ROW PER MATCH") or #raw("ALL ROWS PER MATCH"). This is because all calls over window, whether they are regular window functions or measures, must comply with the window semantics. A call over window is supposed to produce exactly one output row for every input row. And so, the output mode of pattern recognition in window is a combination of #raw("ONE ROW PER MATCH") and #raw("WITH UNMATCHED ROWS").

== Processing input with row pattern recognition

Pattern recognition in window processes input rows in two different cases:

- upon a row pattern measure call over the window:
  
  #code-block(none, "some_measure OVER w")
- upon a window function call over the window:
  
  #code-block(none, "sum(total_price) OVER w")

The output row produced for each input row, consists of:

- all values from the input row
- the value of the called measure or window function, computed with respect to the pattern match associated with the row

Processing the input can be described as the following sequence of steps:

- Partition the input data accordingly to #raw("PARTITION BY")
- Order each partition by the #raw("ORDER BY") expressions
- / For every row of the ordered partition:: / If the row is 'skipped' by a match of some previous row:: - For a measure, produce a one-row output as for an unmatched row - For a window function, evaluate the function over an empty frame and produce a one-row output / Otherwise:: - Determine the frame extent - Try match the row pattern starting from the current row within the frame extent - If no match is found, and #raw("SEEK") is specified, try to find a match starting from subsequent rows within the frame extent  / If no match is found:: - For a measure, produce a one-row output for an unmatched row - For a window function, evaluate the function over an empty frame and produce a one-row output / Otherwise:: - For a measure, produce a one-row output for the match - For a window function, evaluate the function over a frame limited to the matched rows sequence and produce a one-row output - Evaluate the #raw("AFTER MATCH SKIP") clause, and mark the 'skipped' rows

== Empty matches and unmatched rows

If no match can be associated with a particular input row, the row is #emph[unmatched]. This happens when no match can be found for the row. This also happens when no match is attempted for the row, because it is skipped by the #raw("AFTER MATCH SKIP") clause of some preceding row. For an unmatched row, every row pattern measure is #raw("null"). Every window function is evaluated over an empty frame.

An #emph[empty match] is a successful match which does not involve any pattern variables. In other words, an empty match does not contain any rows. If an empty match is associated with an input row, every row pattern measure for that row is evaluated over an empty sequence of rows. All navigation operations and the #raw("CLASSIFIER") function return #raw("null"). Every window function is evaluated over an empty frame.

In most cases, the results for empty matches and unmatched rows are the same. A constant measure can be helpful to distinguish between them:

The following call returns #raw("'matched'") for every matched row, including empty matches, and #raw("null") for every unmatched row:

#code-block(none, "matched OVER (
              ...
              MEASURES 'matched' AS matched
              ...
             )")
