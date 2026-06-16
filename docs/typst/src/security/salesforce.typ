#import "/lib/trino-docs.typ": *

#anchor("doc-security-salesforce")
= Salesforce authentication

Trino can be configured to enable frontend password authentication over HTTPS for clients, such as the CLI, or the JDBC and ODBC drivers. The username and password \(or password and #link("#security-token")[security token] concatenation\) are validated by having the Trino coordinator perform a login to Salesforce.

This allows you to enable users to authenticate to Trino via their Salesforce basic credentials. This can also be used to secure the #link(label("ref-web-ui-authentication"))[Web UI].

#note[
This is #emph[not] a Salesforce connector, and does not allow users to query Salesforce data. Salesforce authentication is simply a means by which users can authenticate to Trino, similar to ldap or password-file.
]

Using TLS and #link(label("doc-security-internal-communication"))[a configured shared secret] is required for Salesforce authentication.

== Salesforce authenticator configuration

To enable Salesforce authentication, set the password authentication type in #raw("etc/config.properties"):

#code-block("properties", "http-server.authentication.type=PASSWORD")

In addition, create a #raw("etc/password-authenticator.properties") file on the coordinator with the #raw("salesforce") authenticator name:

#code-block("properties", "password-authenticator.name=salesforce
salesforce.allowed-organizations=<allowed-org-ids or all>")

The following configuration properties are available:

#list-table((
  ([Property], [Description],),
  ([#raw("salesforce.allowed-organizations")], [Comma separated list of 18 character Salesforce.com Organization IDs for a second, simple layer of security. This option can be explicitly ignored using #raw("all"), which bypasses any  of the authenticated user's Salesforce.com Organization ID.],),
  ([#raw("salesforce.cache-size")], [Maximum number of cached authenticated users. Defaults to #raw("4096").],),
  ([#raw("salesforce.cache-expire-duration")], [How long a cached authentication should be considered valid. Defaults to #raw("2m").],)
), header-rows: 1)

== Salesforce concepts

There are two Salesforce specific aspects to this authenticator. They are the use of the Salesforce security token, and configuration of one or more Salesforce.com Organization IDs.

#anchor("ref-security-token")

=== Security token

Credentials are a user's Salesforce username and password if Trino is connecting from a whitelisted IP, or username and password\/#link("https://help.salesforce.com/articleView?id=user_security_token.htm&type=5")[security token] concatenation otherwise. For example, if Trino is #emph[not] whitelisted, and your password is #raw("password") and security token is #raw("token"), use #raw("passwordtoken") to authenticate.

You can configure a public IP for Trino as a trusted IP by #link("https://help.salesforce.com/articleView?id=security_networkaccess.htm&type=5")[whitelisting an IP range].

=== Salesforce.com organization IDs

You can configure one or more Salesforce Organization IDs for additional security. When the user authenticates, the Salesforce API returns the #emph[18 character] Salesforce.com Organization ID for the user. The Trino Salesforce authenticator ensures that the ID matches one of the IDs configured in #raw("salesforce.allowed-organizations").

Optionally, you can configure #raw("all") to explicitly ignore this layer of security.

Admins can find their Salesforce.com Organization ID using the #link("https://help.salesforce.com/articleView?id=000325251&type=1&mode=1")[Salesforce Setup UI]. This 15 character ID can be #link("https://sf1518.click/")[converted to the 18 character ID].
