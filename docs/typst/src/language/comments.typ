#import "/lib/trino-docs.typ": *

#anchor("doc-language-comments")
= Comments

== Synopsis

Comments are part of a SQL statement or script that are ignored for processing. Comments begin with double dashes and extend to the end of the line. Block comments begin with #raw("/*") and extend to the next occurrence of #raw("*/"), possibly spanning over multiple lines.

== Examples

The following example displays a comment line, a comment after a valid statement, and a block comment:

#code-block("sql", "-- This is a comment.
SELECT * FROM table; -- This comment is ignored.

/* This is a block comment
   that spans multiple lines
   until it is closed. */")

== See also

#link(label("doc-sql-comment"))[COMMENT]
