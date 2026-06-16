#import "/lib/trino-docs.typ": *

#anchor("doc-admin-preview-web-interface")
= Preview Web UI

In addition to the #link(label("doc-admin-web-interface"))[Web UI], Trino includes a preview version of a new web interface. It changes look and feel, available features, and many other aspects. In the future this new user interface will replace the existing user interface.

#warning[
The Preview Web UI is not suitable for production usage, and only available for testing and evaluation purposes. Feedback and assistance with development is encouraged. Find collaborators and discussions in ongoing pull requests and the #link("https://trinodb.slack.com/messages/CKCEWGYT0")[\#web-ui channel].
]

== Activation

The Preview Web UI is available by default, but can be disabled in #link(label("ref-config-properties"))[Deploying Trino] with the following configuration:

#code-block("properties", "web-ui.preview.enabled=false")

== Access

Once activated, users can access the interface in the URL context #raw("/ui/preview") after successful login to the #link(label("doc-admin-web-interface"))[Web UI]. For example, the full URL on a locally running Trino installation or Trino docker container without TLS configuration is #link("http://localhost:8080/ui/preview")[http:\/\/localhost:8080\/ui\/preview].

== Authentication

The Preview Web UI requires users to authenticate. If Trino is not configured to require authentication, then any username can be used, and no password is required or allowed. The UI shows the login dialog for password authentication with the password input deactivated. This is also automatically the case if the cluster is only configured to use HTTP. Typically, users login with the same username that they use for running queries.

If no system access control is installed, then all users are able to view and kill any query. This can be restricted by using #link(label("ref-query-rules"))[query rules] with the #link(label("doc-security-built-in-system-access-control"))[System access control]. Users always have permission to view or kill their own queries.

=== Password authentication

Typically, a password-based authentication method such as #link(label("doc-security-ldap"))[LDAP] or #link(label("doc-security-password-file"))[password file] is used to secure both the Trino server and the Web UI. When the Trino server is configured to use a password authenticator, the Web UI authentication type is automatically set to #raw("FORM"). In this case, the Web UI displays a login form that accepts a username and password.

=== Fixed user authentication

If you require the Preview Web UI to be accessible without authentication, you can set a fixed username that will be used for all Web UI access by setting the authentication type to #raw("FIXED") and setting the username with the #raw("web-ui.user") configuration property. If there is a system access control installed, this user must have permission to view ,and possibly to kill, queries.

=== Other authentication types

The following Preview Web UI authentication types are also supported:

- #raw("CERTIFICATE"), see details in #link(label("doc-security-certificate"))[Certificate authentication]
- #raw("KERBEROS"), see details in #link(label("doc-security-kerberos"))[Kerberos authentication]
- #raw("JWT"), see details in #link(label("doc-security-jwt"))[JWT authentication]
- #raw("OAUTH2"), see details in #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]

For these authentication types, the username is defined by #link(label("doc-security-user-mapping"))[User mapping].
