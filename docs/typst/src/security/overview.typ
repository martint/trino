#import "/lib/trino-docs.typ": *

#anchor("doc-security-overview")
= Security overview

After the initial #link(label("doc-installation"))[installation] of your cluster, security is the next major concern for successfully operating Trino. This overview provides an introduction to different aspects of configuring security for your Trino cluster.

== Aspects of configuring security

The default installation of Trino has no security features enabled. Security can be enabled for different parts of the Trino architecture:

- #link(label("ref-security-client"))[security-client]
- #link(label("ref-security-inside-cluster"))[security-inside-cluster]
- #link(label("ref-security-data-sources"))[security-data-sources]

== Suggested configuration workflow

To configure security for a new Trino cluster, follow this best practice order of steps. Do not skip or combine steps.

+ #strong[Enable] #link(label("doc-security-tls"))[TLS\/HTTPS]
  
  - Work with your security team.
  - Use a #link(label("ref-https-load-balancer"))[load balancer or proxy] to terminate HTTPS, if possible.
  - Use a globally trusted TLS certificate.
  
  #link(label("ref-verify-tls"))[Verify this step is working correctly.]
+ #strong[Configure] a #link(label("doc-security-internal-communication"))[a shared secret]
  
  #link(label("ref-verify-secrets"))[Verify this step is working correctly.]
+ #strong[Enable authentication]
  
  - Start with password file authentication to get up and running.
  - Then configure your preferred authentication provider, such as #link(label("doc-security-ldap"))[LDAP].
  - Avoid the complexity of Kerberos for client authentication, if possible.
  
  #link(label("ref-verify-authentication"))[Verify this step is working correctly.]
+ #strong[Enable authorization and access control]
  
  - Start with file-based rules.
  - Then configure another access control method as required.
  
  #link(label("ref-verify-rules"))[Verify this step is working correctly.]

Configure one step at a time. Always restart the Trino server after each change, and verify the results before proceeding.

#anchor("ref-security-client")

== Securing client access to the cluster

Trino #link(label("doc-client"))[clients] include the Trino #link(label("doc-client-cli"))[CLI], the #link(label("doc-admin-web-interface"))[Web UI], the #link(label("doc-client-jdbc"))[JDBC driver], #link("https://trino.io/resources.html")[Python, Go, or other clients], and any applications using these tools.

All access to the Trino cluster is managed by the coordinator. Thus, securing access to the cluster means securing access to the coordinator.

There are three aspects to consider:

- #link(label("ref-cl-access-encrypt"))[cl-access-encrypt]: protecting the integrity of client to server communication in transit.
- #link(label("ref-cl-access-auth"))[cl-access-auth]: identifying users and user name management.
- #link(label("ref-cl-access-control"))[cl-access-control]: validating each user's access rights.

#anchor("ref-cl-access-encrypt")

=== Encryption

The Trino server uses the standard HTTPS protocol and TLS encryption, formerly known as SSL.

#anchor("ref-cl-access-auth")

=== Authentication

Trino supports several authentication providers. When setting up a new cluster, start with simple password file authentication before configuring another provider.

- Password file authentication
- LDAP authentication
- Salesforce authentication
- OAuth 2.0 authentication
- Certificate authentication
- JSON Web Token \(JWT\) authentication
- Kerberos authentication

#anchor("ref-user-name-management")

==== User name management

Trino provides ways to map the user and group names from authentication providers to Trino usernames.

- User mapping applies to all authentication systems, and allows for regular expression rules to be specified that map complex usernames from other systems \(#raw("alice@example.com")\) to simple usernames \(#raw("alice")\).
- Group mapping provides ways to assign a set of usernames to a group name to ease access control.

#anchor("ref-cl-access-control")

=== Authorization and access control

Trino's default method of access control allows all operations for all authenticated users.

To implement access control, use:

- File-based system access control, where you configure JSON files that specify fine-grained user access restrictions at the catalog, schema, or table level.
- opa-access-control, where you use Open Policy Agent to make access control decisions on a fined-grained level.
- ranger-access-control, where you use Apache Ranger to make fine-grained access control decisions, apply dynamic row-filters and column-masking at query execution time, and generate audit logs.

In addition, Trino #link(label("doc-develop-system-access-control"))[provides an API] that allows you to create a custom access control method, or to extend an existing one.

Access control can limit access to columns of a table. The default behavior of a query to all columns with a #raw("SELECT *") statement is to show an error denying access to any inaccessible columns.

You can change this behavior to silently hide inaccessible columns with the global property #raw("hide-inaccessible-columns") configured in #link(label("ref-config-properties"))[config-properties]:

#code-block("properties", "hide-inaccessible-columns = true")

#anchor("ref-security-inside-cluster")

== Securing inside the cluster

You can secure the internal communication between coordinator and workers inside the clusters.

Secrets in properties files, such as passwords in catalog files, can be secured with secrets management.

#anchor("ref-security-data-sources")

== Securing cluster access to data sources

Communication between the Trino cluster and data sources is configured for each catalog. Each catalog uses a connector, which supports a variety of security-related configurations.

More information is available with the documentation for individual #link(label("doc-connector"))[connectors].

Secrets management can be used for the catalog properties files content.
