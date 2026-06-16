#import "/lib/trino-docs.typ": *

#anchor("doc-security")
= Security

== Introduction

- #link(label("doc-security-overview"))[Security overview]

== Cluster access security

- #link(label("doc-security-tls"))[TLS and HTTPS]
- #link(label("doc-security-inspect-pem"))[PEM files]
- #link(label("doc-security-inspect-jks"))[JKS files]

#anchor("ref-security-authentication")

== Authentication

- #link(label("doc-security-authentication-types"))[Authentication types]
- #link(label("doc-security-password-file"))[Password file authentication]
- #link(label("doc-security-ldap"))[LDAP authentication]
- #link(label("doc-security-salesforce"))[Salesforce authentication]
- #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]
- #link(label("doc-security-kerberos"))[Kerberos authentication]
- #link(label("doc-security-certificate"))[Certificate authentication]
- #link(label("doc-security-jwt"))[JWT authentication]

== User name management

- #link(label("doc-security-user-mapping"))[User mapping]
- #link(label("doc-security-group-mapping"))[Group mapping]

#anchor("ref-security-access-control")

== Access control

- #link(label("doc-security-built-in-system-access-control"))[System access control]
- #link(label("doc-security-file-system-access-control"))[File-based access control]
- #link(label("doc-security-opa-access-control"))[Open Policy Agent access control]
- #link(label("doc-security-ranger-access-control"))[Ranger access control]

== Security inside the cluster

- #link(label("doc-security-internal-communication"))[Secure internal communication]
- #link(label("doc-security-secrets"))[Secrets]
