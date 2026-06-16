#import "/lib/trino-docs.typ": *

#anchor("doc-security-jwt")
= JWT authentication

Trino can be configured to authenticate client access using #link("https://wikipedia.org/wiki/JSON_Web_Token")[JSON web tokens]. A JWT is a small, web-safe JSON file that contains cryptographic information similar to a certificate, including:

- Subject
- Valid time period
- Signature

A JWT is designed to be passed between servers as proof of prior authentication in a workflow like the following:

+ An end user logs into a client application and requests access to a server.
+ The server sends the user's credentials to a separate authentication service that:
  
  - validates the user
  - generates a JWT as proof of validation
  - returns the JWT to the requesting server
+ The same JWT can then be forwarded to other services to maintain the user's validation without further credentials.

#important[
If you are trying to configure OAuth2 or OIDC, there is a dedicated system for that in Trino, as described in #link(label("doc-security-oauth2"))[OAuth 2.0 authentication]. When using OAuth2 authentication, you do not need to configure JWT authentication, because JWTs are handled automatically by the OAuth2 code.

A typical use for JWT authentication is to support administrators at large sites who are writing their own single sign-on or proxy system to stand between users and the Trino coordinator, where their new system submits queries on behalf of users.
]

Using TLS and #link(label("doc-security-internal-communication"))[a configured shared secret] is required for JWT authentication.

== Using JWT authentication

Trino supports Base64 encoded JWTs, but not encrypted JWTs.

There are two ways to get the encryption key necessary to validate the JWT signature:

- Load the key from a JSON web key set \(JWKS\) endpoint service \(the typical case\)
- Load the key from the local file system on the Trino coordinator

A JWKS endpoint is a read-only service that contains public key information in #link("https://datatracker.ietf.org/doc/html/rfc7517")[JWK] format. These public keys are the counterpart of the private keys that sign JSON web tokens.

== JWT authentication configuration

Enable JWT authentication by setting the JWT authentication type in #link(label("ref-config-properties"))[etc\/config.properties], and specifying a URL or path to a key file:

#code-block("properties", "http-server.authentication.type=JWT
http-server.authentication.jwt.key-file=https://cluster.example.net/.well-known/jwks.json")

JWT authentication is typically used in addition to other authentication methods:

#code-block("properties", "http-server.authentication.type=PASSWORD,JWT
http-server.authentication.jwt.key-file=https://cluster.example.net/.well-known/jwks.json")

The following configuration properties are available:

#list-table((
  ([Property], [Description],),
  ([#raw("http-server.authentication.jwt.key-file")], [Required. Specifies either the URL to a JWKS service or the path to a PEM or HMAC file, as described below this table.],),
  ([#raw("http-server.authentication.jwt.required-issuer")], [Specifies a string that must match the value of the JWT's issuer \(#raw("iss")\) field in order to consider this JWT valid. The #raw("iss") field in the JWT identifies the principal that issued the JWT.],),
  ([#raw("http-server.authentication.jwt.required-audience")], [Specifies a string that must match the value of the JWT's Audience \(#raw("aud")\) field in order to consider this JWT valid. The #raw("aud") field in the JWT identifies the recipients that the JWT is intended for.],),
  ([#raw("http-server.authentication.jwt.principal-field")], [String to identify the field in the JWT that identifies the subject of the JWT. The default value is #raw("sub"). This field is used to create the Trino principal.],),
  ([#raw("http-server.authentication.jwt.user-mapping.pattern")], [A regular expression pattern to #link(label("doc-security-user-mapping"))[map all user names] for this authentication system to the format expected by the Trino server.],),
  ([#raw("http-server.authentication.jwt.user-mapping.file")], [The path to a JSON file that contains a set of #link(label("doc-security-user-mapping"))[user mapping rules] for this authentication system.],)
), header-rows: 1, title: "Configuration properties for JWT authentication")

Use the #raw("http-server.authentication.jwt.key-file") property to specify either:

- The URL to a JWKS endpoint service, where the URL begins with #raw("https://"). The JWKS service must be reachable from the coordinator. If the coordinator is running in a secured or firewalled network, the administrator #emph[may] have to open access to the JWKS server host.
  
  #caution[
  The Trino server also accepts JWKS URLs that begin with #raw("http://"), but using this protocol results in a severe security risk. Only use this protocol for short-term testing during development of your cluster.
  ]
- The path to a local file in #link(label("doc-security-inspect-pem"))[PEM] or #link("https://wikipedia.org/wiki/HMAC")[HMAC] format that contains a single key. If the file path contains #raw("${KID}"), then Trino interpolates the #raw("kid") from the JWT header into the file path before loading this key. This enables support for setups with multiple keys.

== Using JWTs with clients

When using the Trino #link(label("doc-client-cli"))[CLI], specify a JWT as described in #link(label("ref-cli-jwt-auth"))[cli-jwt-auth].

When using the Trino JDBC driver, specify a JWT with the #raw("accessToken") #link(label("ref-jdbc-parameter-reference"))[parameter].

== Resources

The following resources may prove useful in your work with JWTs and JWKs.

- #link("https://jwt.io")[jwt.io] helps you decode and verify a JWT.
- #link("https://auth0.com/blog/navigating-rs256-and-jwks/")[An article on using RS256] to sign and verify your JWTs.
- An #link("https://mkjwk.org")[online JSON web key] generator.
- A #link("https://connect2id.com/products/nimbus-jose-jwt/generator")[command line JSON web key] generator.
