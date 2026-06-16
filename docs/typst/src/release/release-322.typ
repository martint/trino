#import "/lib/trino-docs.typ": *

#anchor("doc-release-release-322")
= Release 322 \(16 Oct 2019\)

== General

- Improve performance of certain join queries by reducing the amount of data that needs to be scanned. \(#issue("1673", "https://github.com/trinodb/trino/issues/1673")\)

== Server RPM

- Fix a regression that caused zero-length files in the RPM. \(#issue("1767", "https://github.com/trinodb/trino/issues/1767")\)

== Other connectors

These changes apply to MySQL, PostgreSQL, Redshift, and SQL Server.

- Add support for providing credentials using a keystore file. This can be enabled by setting the #raw("credential-provider.type") configuration property to #raw("KEYSTORE") and by setting the #raw("keystore-file-path"), #raw("keystore-type"), #raw("keystore-password"), #raw("keystore-user-credential-password"), #raw("keystore-password-credential-password"), #raw("keystore-user-credential-name"), and #raw("keystore-password-credential-name") configuration properties. \(#issue("1521", "https://github.com/trinodb/trino/issues/1521")\)
