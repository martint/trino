#import "/lib/trino-docs.typ": *

#anchor("doc-develop")
= Developer guide

This guide is intended for Trino contributors and plugin developers.

Important information on processes, code style, reviews, and other details are available on the #link("https://trino.io/development/")[development section of the Trino website] and in the #link("https://github.com/trinodb/trino/blob/master/.github/DEVELOPMENT.md")[development documentation in the Trino source code].

- #link(label("doc-develop-spi-overview"))[SPI overview]
- #link(label("doc-develop-tests"))[Test writing guidelines]
- #link(label("doc-develop-connectors"))[Connectors]
- #link(label("doc-develop-example-http"))[Example HTTP connector]
- #link(label("doc-develop-example-jdbc"))[Example JDBC connector]
- #link(label("doc-develop-insert"))[Supporting INSERT and CREATE TABLE AS]
- #link(label("doc-develop-supporting-merge"))[Supporting MERGE]
- #link(label("doc-develop-types"))[Types]
- #link(label("doc-develop-functions"))[Functions]
- #link(label("doc-develop-table-functions"))[Table functions]
- #link(label("doc-develop-system-access-control"))[System access control]
- #link(label("doc-develop-password-authenticator"))[Password authenticator]
- #link(label("doc-develop-certificate-authenticator"))[Certificate authenticator]
- #link(label("doc-develop-header-authenticator"))[Header authenticator]
- #link(label("doc-develop-group-provider"))[Group provider]
- #link(label("doc-develop-event-listener"))[Event listener]
- #link(label("doc-develop-client-protocol"))[Trino client REST API]
