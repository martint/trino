#import "/lib/trino-docs.typ": *

#anchor("doc-admin-web-interface")
= Web UI

Trino provides a web-based user interface \(UI\) for monitoring a Trino cluster and managing queries. The Web UI is accessible on the coordinator via HTTP or HTTPS, using the corresponding port number specified in the coordinator #link(label("ref-config-properties"))[config-properties]. It can be configured with #link(label("doc-admin-properties-web-interface"))[Web UI properties].

The Web UI can be disabled entirely with the #raw("web-ui.enabled") property.

#anchor("ref-web-ui-authentication")

== Authentication

The Web UI requires users to authenticate. If Trino is not configured to require authentication, then any username can be used, and no password is required or allowed. Typically, users login with the same username that they use for running queries.

If no system access control is installed, then all users are able to view and kill any query. This can be restricted by using #link(label("ref-query-rules"))[query rules] with the #link(label("doc-security-built-in-system-access-control"))[System access control]. Users always have permission to view or kill their own queries.

=== Password authentication

Typically, a password-based authentication method such as #link(label("doc-security-ldap"))[LDAP] or #link(label("doc-security-password-file"))[password file] is used to secure both the Trino server and the Web UI. When the Trino server is configured to use a password authenticator, the Web UI authentication type is automatically set to #raw("FORM"). In this case, the Web UI displays a login form that accepts a username and password.

=== Fixed user authentication

If you require the Web UI to be accessible without authentication, you can set a fixed username that will be used for all Web UI access by setting the authentication type to #raw("FIXED") and setting the username with the #raw("web-ui.user") configuration property. If there is a system access control installed, this user must have permission to view \(and possibly to kill\) queries.

=== Other authentication types

The following Web UI authentication types are also supported:

- #raw("CERTIFICATE"), see details in #link(label("doc-security-certificate"))[Certificate authentication]
- #raw("KERBEROS"), see details in #link(label("doc-security-kerberos"))[Kerberos authentication]
- #raw("JWT"), see details in #link(label("doc-security-jwt"))[JWT authentication]
- #raw("OAUTH2"), see details in #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]

For these authentication types, the username is defined by #link(label("doc-security-user-mapping"))[User mapping].

#anchor("ref-web-ui-overview")

== User interface overview

The main page has a list of queries along with information like unique query ID, query text, query state, percentage completed, username and source from which this query originated. The currently running queries are at the top of the page, followed by the most recently completed or failed queries.

The possible query states are as follows:

- #raw("QUEUED") -- Query has been accepted and is awaiting execution.
- #raw("PLANNING") -- Query is being planned.
- #raw("STARTING") -- Query execution is being started.
- #raw("RUNNING") -- Query has at least one running task.
- #raw("BLOCKED") -- Query is blocked and is waiting for resources \(buffer space, memory, splits, etc.\).
- #raw("FINISHING") -- Query is finishing \(e.g. commit for autocommit queries\).
- #raw("FINISHED") -- Query has finished executing and all output has been consumed.
- #raw("FAILED") -- Query execution failed.

The #raw("BLOCKED") state is normal, but if it is persistent, it should be investigated. It has many potential causes: insufficient memory or splits, disk or network I\/O bottlenecks, data skew \(all the data goes to a few workers\), a lack of parallelism \(only a few workers available\), or computationally expensive stages of the query following a given stage.  Additionally, a query can be in the #raw("BLOCKED") state if a client is not processing the data fast enough \(common with "SELECT \*" queries\).

For more detailed information about a query, simply click the query ID link. The query detail page has a summary section, graphical representation of various stages of the query and a list of tasks. Each task ID can be clicked to get more information about that task.

The summary section has a button to kill the currently running query. There are two visualizations available in the summary section: task execution and timeline. The full JSON document containing information and statistics about the query is available by clicking the #emph[JSON] link. These visualizations and other statistics can be used to analyze where time is being spent for a query.

== Configuring query history

The following configuration properties affect #link(label("doc-admin-properties-query-management"))[how query history is collected] for display in the Web UI:

- #raw("query.min-expire-age")
- #raw("query.max-history")

Unrelated to the storage of queries and query history in memory, you can use an #link(label("ref-admin-event-listeners"))[event listener] to publish query events, such as query started or query finished, to an external system.
