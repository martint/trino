#import "/lib/trino-docs.typ": *

#anchor("doc-functions-session")
= Session information

Functions providing information about the query execution environment.

#function-def("fn-current-user", "current_user", none)[
Returns the current user running the query.
]

#function-def("fn-current-groups", "current_groups", none)[
Returns the list of groups for the current user running the query.
]

#function-def("fn-current-catalog", "current_catalog", none)[
Returns a character string that represents the current catalog name.
]

#function-def("fn-current-schema", "current_schema", none)[
Returns a character string that represents the current unqualified schema name.

#note[
This is part of the SQL standard and does not use parenthesis.
]
]
