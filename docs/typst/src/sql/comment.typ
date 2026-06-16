#import "/lib/trino-docs.typ": *

#anchor("doc-sql-comment")
= COMMENT

== Synopsis

#code-block("text", "COMMENT ON ( TABLE | VIEW | COLUMN ) name IS 'comments'")

== Description

Set the comment for an object. The comment can be removed by setting the comment to #raw("NULL").

== Examples

Change the comment for the #raw("users") table to be #raw("master table"):

#code-block(none, "COMMENT ON TABLE users IS 'master table';")

Change the comment for the #raw("users") view to be #raw("master view"):

#code-block(none, "COMMENT ON VIEW users IS 'master view';")

Change the comment for the #raw("users.name") column to be #raw("full name"):

#code-block(none, "COMMENT ON COLUMN users.name IS 'full name';")

== See also

#link(label("doc-language-comments"))[Comments]
