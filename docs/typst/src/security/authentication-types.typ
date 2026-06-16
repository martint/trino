#import "/lib/trino-docs.typ": *

#anchor("doc-security-authentication-types")
= Authentication types

Trino supports multiple authentication types to ensure all users of the system are authenticated. Different authenticators allow user management in one or more systems.

All authentication requires secure connections using #link(label("doc-security-tls"))[TLS and HTTPS] or #link(label("ref-http-server-process-forwarded"))[process forwarding enabled], and #link(label("doc-security-internal-communication"))[a configured shared secret].

You can configure one or more authentication types with the #raw("http-server.authentication.type") property. The following authentication types and authenticators are available:

- #raw("PASSWORD") for
  
  - password-file
  - ldap
  - salesforce
- #raw("OAUTH2") for oauth2
- #raw("KERBEROS") for kerberos
- #raw("CERTIFICATE") for certificate
- #raw("JWT") for jwt
- #raw("HEADER") for #link(label("doc-develop-header-authenticator"))[Header authenticator]

Get started with a basic password authentication configuration backed by a password file:

#code-block("properties", "http-server.authentication.type=PASSWORD")

== Multiple authentication types

You can use multiple authentication types, separated with commas in the configuration:

#code-block("properties", "http-server.authentication.type=PASSWORD,CERTIFICATE")

Authentication is performed in order of the entries, and first successful authentication results in access, using the mapped user from that authentication method.

== Multiple password authenticators

You can use multiple password authenticator types by referencing multiple configuration files:

#code-block("properties", "http-server.authentication.type=PASSWORD
password-authenticator.config-files=etc/ldap1.properties,etc/ldap2.properties,etc/password.properties")

In the preceding example, the configuration files #raw("ldap1.properties") and #raw("ldap2.properties") are regular LDAP authenticator configuration files. The #raw("password.properties") is a password file authenticator configuration file.

Relative paths to the installation directory or absolute paths can be used.

User authentication credentials are first validated against the LDAP server from #raw("ldap1"), then the separate server from #raw("ldap2"), and finally the password file. First successful authentication results in access, and no further authenticators are called.

== Multiple header authenticators

You can use multiple header authenticator types by referencing multiple configuration files:

#code-block("properties", "http-server.authentication.type=HEADER
header-authenticator.config-files=etc/xfcc.properties,etc/azureAD.properties")

Relative paths to the installation directory or absolute paths can be used.

The pre-configured headers are first validated against the #raw("xfcc") authenticator, then the #raw("azureAD") authenticator. First successful authentication results in access, and no further authenticators are called.
