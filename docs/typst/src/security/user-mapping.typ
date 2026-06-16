#import "/lib/trino-docs.typ": *

#anchor("doc-security-user-mapping")
= User mapping

User mapping defines rules for mapping from users in the authentication method to Trino users. This mapping is particularly important for #link(label("doc-security-kerberos"))[Kerberos] or certificate authentication where the user names are complex, such as #raw("alice@example") or #raw("CN=Alice Smith,OU=Finance,O=Acme,C=US").

There are two ways to map the username format of a given authentication provider into the simple username format of Trino users:

- With a single regular expression \(regex\) #link(label("ref-pattern-rule"))[pattern mapping rule]
- With a #link(label("ref-pattern-file"))[file of regex mapping rules] in JSON format

#anchor("ref-pattern-rule")

== Pattern mapping rule

If you can map all of your authentication method’s usernames with a single regular expression, consider using a #strong[Pattern mapping rule].

For example, your authentication method uses all usernames in the form #raw("alice@example.com"), with no exceptions. In this case, choose a regex that breaks incoming usernames into at least two regex capture groups, such that the first capture group includes only the name before the #raw("@") sign. You can use the simple regex #raw("(.*)(@.*)") for this case.

Trino automatically uses the first capture group – the \$1 group – as the username to emit after the regex substitution. If the regular expression does not match the incoming username, authentication is denied.

Specify your regex pattern in the appropriate property in your coordinator’s #raw("config.properties") file, using one of the #raw("*user-mapping.pattern") properties from the table below that matches the authentication type of your configured authentication provider. For example, for an #link(label("doc-security-ldap"))[LDAP] authentication provider:

#code-block("text", "http-server.authentication.password.user-mapping.pattern=(.*)(@.*)")

Remember that an #link(label("doc-security-authentication-types"))[authentication type] represents a category, such as #raw("PASSWORD"), #raw("OAUTH2"), #raw("KERBEROS"). More than one authentication method can have the same authentication type. For example, the Password file, LDAP, and Salesforce authentication methods all share the #raw("PASSWORD") authentication type.

You can specify different user mapping patterns for different authentication types when multiple authentication methods are enabled:

#list-table((
  ([Authentication type], [Property],),
  ([Password \(file, LDAP, Salesforce\)], [#raw("http-server.authentication.password.user-mapping.pattern")],),
  ([OAuth2], [#raw("http-server.authentication.oauth2.user-mapping.pattern")],),
  ([Certificate], [#raw("http-server.authentication.certificate.user-mapping.pattern")],),
  ([Header], [#raw("http-server.authentication.header.user-mapping.pattern")],),
  ([JSON Web Token], [#raw("http-server.authentication.jwt.user-mapping.pattern")],),
  ([Kerberos], [#raw("http-server.authentication.krb5.user-mapping.pattern")],),
  ([Insecure], [#raw("http-server.authentication.insecure.user-mapping.pattern")],)
), header-rows: 1)

#anchor("ref-pattern-file")

== File mapping rules

Use the #strong[File mapping rules] method if your authentication provider expresses usernames in a way that cannot be reduced to a single rule, or if you want to exclude a set of users from accessing the cluster.

The rules are loaded from a JSON file identified in a configuration property. The mapping is based on the first matching rule, processed from top to bottom. If no rules match, authentication is denied.  Each rule is composed of the following fields:

- #raw("pattern") \(required\): regex to match against the authentication method's username.
- #raw("user") \(optional\): replacement string to substitute against #emph[pattern]. The default value is #raw("$1").
- #raw("allow") \(optional\): boolean indicating whether authentication is to be allowed for the current match.
- #raw("case") \(optional\): one of:
  
  - #raw("keep") - keep the matched username as is \(default behavior\)
  - #raw("lower") - lowercase the matched username; thus both #raw("Admin") and #raw("ADMIN") become #raw("admin")
  - #raw("upper") - uppercase the matched username; thus both #raw("admin") and #raw("Admin") become #raw("ADMIN")

The following example maps all usernames in the form #raw("alice@example.com") to just #raw("alice"), except for the #raw("test") user, which is denied authentication. It also maps users in the form #raw("bob@uk.example.com") to #raw("bob_uk"):

#code-block("json", "{
    \"rules\": [
        {
            \"pattern\": \"test@example\\\\.com\",
            \"allow\": false
        },
        {
            \"pattern\": \"(.+)@example\\\\.com\"
        },
        {
            \"pattern\": \"(?<user>.+)@(?<region>.+)\\\\.example\\\\.com\",
            \"user\": \"${user}_${region}\"
        },
        {
            \"pattern\": \"(.*)@uppercase.com\",
            \"case\": \"upper\"
        }
    ]
}")

Set up the preceding example to use the #link(label("doc-security-ldap"))[LDAP] authentication method with the #link(label("doc-security-authentication-types"))[PASSWORD] authentication type by adding the following line to your coordinator's #raw("config.properties") file:

#code-block("text", "http-server.authentication.password.user-mapping.file=etc/user-mapping.json")

You can place your user mapping JSON file in any local file system location on the coordinator, but placement in the #raw("etc") directory is typical. There is no naming standard for the file or its extension, although using #raw(".json") as the extension is traditional. Specify an absolute path or a path relative to the Trino installation root.

You can specify different user mapping files for different authentication types when multiple authentication methods are enabled:

#list-table((
  ([Authentication type], [Property],),
  ([Password \(file, LDAP, Salesforce\)], [#raw("http-server.authentication.password.user-mapping.file")],),
  ([OAuth2], [#raw("http-server.authentication.oauth2.user-mapping.file")],),
  ([Certificate], [#raw("http-server.authentication.certificate.user-mapping.file")],),
  ([Header], [#raw("http-server.authentication.header.user-mapping.pattern")],),
  ([JSON Web Token], [#raw("http-server.authentication.jwt.user-mapping.file")],),
  ([Kerberos], [#raw("http-server.authentication.krb5.user-mapping.file")],),
  ([Insecure], [#raw("http-server.authentication.insecure.user-mapping.file")],)
), header-rows: 1)
