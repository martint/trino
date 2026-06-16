#import "/lib/trino-docs.typ": *

#anchor("doc-security-group-mapping")
= Group mapping

Group providers in Trino map usernames onto groups for easier access control and resource group management.

Configure a group provider by creating an #raw("etc/group-provider.properties") file on the coordinator:

#code-block("properties", "group-provider.name=file")

The value for #raw("group-provider.name") must be either #raw("file") or #raw("ldap") and the configuration of the chosen group provider must be included in the same file.

#list-table((
  ([Property name], [Description],),
  ([#raw("group-provider.name")], [Name of the group provider to use. Supported values are:

- #raw("file"): #link(label("ref-file-group-provider"))[See configuration]
- #raw("ldap"): #link(label("ref-ldap-group-provider"))[See configuration]],),
  ([#raw("group-provider.group-case")], [Optional transformation of the case of the group name. Supported values are:

- #raw("keep"): default, no conversion
- #raw("upper"): convert group name to #emph[UPPERCASE]
- #raw("lower"): converts the group name to #emph[lowercase]

Defaults to #raw("keep").],)
), header-rows: 1, title: "Group provider configuration")

== Integration with access control

Groups resolved by the group provider are passed to Trino’s system access control engine. Access control rules can reference these group names to grant or restrict permissions.

#anchor("ref-file-group-provider")

== File group provider

The file group provider resolves group memberships with the configuration in the group-provider.properties file on the coordinator.

=== Configuration

Enable the file group provider by creating an #raw("etc/group-provider.properties") file on the coordinator:

#code-block("properties", "group-provider.name=file
file.group-file=/path/to/group.txt")

The following configuration properties are available:

#list-table((
  ([Property name], [Description],),
  ([#raw("file.group-file")], [Path of the group file.],),
  ([#raw("file.refresh-period")], [#link(label("ref-prop-type-duration"))[Duration] between refreshing the group mapping configuration from the file. Defaults to #raw("5s").],)
), header-rows: 1, title: "File group provider configuration")

=== Group file format

The group file contains a list of groups and members, one per line, separated by a colon. Users are separated by a comma.

#code-block("text", "group_name:user_1,user_2,user_3")

#anchor("ref-ldap-group-provider")

== LDAP group provider

The LDAP group provider resolves user group memberships from configuration retrieved from an LDAP server. This allows access rules to be defined based on LDAP groups instead of individual users.

=== Configuration

Enable LDAP group provider by creating an #raw("etc/group-provider.properties") file on the coordinator and add further configuration for the LDAP server connections and other information as detailed in the following sections.

#code-block("properties", "group-provider.name=ldap")

#list-table((
  ([Property name], [Description],),
  ([#raw("ldap.url")], [LDAP server URI.  For example, #raw("ldap://host:389") or #raw("ldaps://host:636").],),
  ([#raw("ldap.allow-insecure")], [Allow insecure connection to the LDAP server. Defaults to #raw("false").],),
  ([#raw("ldap.ssl.keystore.path")], [Path to the PEM or JKS key store.],),
  ([#raw("ldap.ssl.keystore.password")], [Password for the key store.],),
  ([#raw("ldap.ssl.truststore.path")], [Path to the PEM or JKS trust store.],),
  ([#raw("ldap.ssl.truststore.password")], [Password for the trust store.],),
  ([#raw("ldap.ignore-referrals")], [Referrals allow finding entries across multiple LDAP servers. Ignore them to only search within one LDAP server. Defaults to #raw("false").],),
  ([#raw("ldap.timeout.connect")], [Timeout #link(label("ref-prop-type-duration"))[duration] for establishing a connection. Defaults to #raw("1m").],),
  ([#raw("ldap.timeout.read")], [Timeout #link(label("ref-prop-type-duration"))[duration] for reading data from LDAP. Defaults to #raw("1m").],),
  ([#raw("ldap.admin-user")], [Bind distinguished name for admin user. For example, #raw("CN=UserName,OU=City,OU=State,DC=domain,DC=domain_root")],),
  ([#raw("ldap.admin-password")], [Bind password used for the admin user.],),
  ([#raw("ldap.user-base-dn")], [Base distinguished name for users. For example, #raw("dc=example,dc=com").],),
  ([#raw("ldap.user-search-filter")], [LDAP filter to find user entries; #raw("{0}") is replaced with the Trino username. For example, #raw("(cn={0})")],),
  ([#raw("ldap.group-name-attribute")], [Attribute to extract group name from group entry. For example, #raw("cn").],),
  ([#raw("ldap.use-group-filter")], [Whether to use search-based group resolution. Defaults to #raw("true"). When #raw("false"), Trino uses the attribute-based method.],)
), header-rows: 1, title: "Generic LDAP properties")

Group resolution behavior is controlled by the #raw("ldap.use-group-filter") property. With search-based group resolution, Trino searches for group entries that include the user DN. This requires the following properties:

#list-table((
  ([Property name], [Description],),
  ([#raw("ldap.group-base-dn")], [Base distinguished name for groups. For example, #raw("dc=example,dc=com").],),
  ([#raw("ldap.group-search-filter")], [Search filter for group documents. For example, #raw("(cn=trino_*)").],),
  ([#raw("ldap.group-search-member-attribute")], [Attribute from group documents used for filtering by member. For example, #raw("cn").],)
), header-rows: 1, title: "Search-based group resolution")

In case of attribute-based group resolution, Trino reads the group list directly from a user attribute. This requires the following property:

#list-table((
  ([Property name], [Description],),
  ([#raw("ldap.user-member-of-attribute")], [Group membership attribute in user documents. For example, #raw("memberOf").],)
), header-rows: 1, title: "Attribute-based (single query) group resolution")

=== Example configurations

The following configuration is an example for an OpenLDAP \(search-based\) group provider:

#code-block("properties", "group-provider.name=ldap
group-provider.group-case=lower

ldap.url=ldap://ldap.example.com:389
ldap.admin-user=cn=admin,dc=example,dc=com
ldap.admin-password=your_password
ldap.group-name-attribute=cn
ldap.user-base-dn=ou=users,dc=example,dc=com
ldap.user-search-filter=(uid={0})
ldap.use-group-filter=true

ldap.group-base-dn=ou=groups,dc=example,dc=com
ldap.group-search-filter=(cn=trino_*)
ldap.group-search-member-attribute=member")

The following configuration is an example for an Active Directory \(single query, attribute-based\) group provider:

#code-block("properties", "group-provider.name=ldap
group-provider.group-case=lower

ldap.url=ldaps://ad.example.com:636
ldap.admin-user=cn=admin,dc=example,dc=com
ldap.admin-password=your_password
ldap.group-name-attribute=cn
ldap.user-base-dn=ou=users,dc=example,dc=com
ldap.user-search-filter=(sAMAccountName={0})
ldap.use-group-filter=false

ldap.user-member-of-attribute=memberOf")
