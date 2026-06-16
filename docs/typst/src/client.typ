#import "/lib/trino-docs.typ": *

#anchor("doc-client")
= Clients

A #link(label("ref-trino-concept-client"))[client] is used to send SQL queries to Trino, and therefore any #link(label("ref-trino-concept-data-source"))[connected data sources], and receive results.

== Client drivers

Client drivers, also called client libraries, provide a mechanism for other applications to connect to Trino. The application are called client application and include your own custom applications or scripts. The Trino project maintains the following client drivers:

- #link(label("doc-client-jdbc"))[Trino JDBC driver]
- #link("https://github.com/trinodb/trino-go-client")[trino-go-client]
- #link("https://github.com/trinodb/trino-js-client")[trino-js-client]
- #link("https://github.com/trinodb/trino-python-client")[trino-python-client]
- #link("https://github.com/trinodb/trino-csharp-client")[trino-csharp-client]

Other communities and vendors provide #link("https://trino.io/ecosystem/client-driver#other-client-drivers")[other client drivers].

== Client applications

Client applications provide a user interface and other user-facing features to run queries with Trino. You can inspect the results, perform analytics with further queries, and create visualizations. Client applications typically use a client driver.

The Trino project maintains the #link(label("doc-client-cli"))[Trino command line interface] and the #link("https://github.com/trinodb/grafana-trino")[Trino Grafana Data Source Plugin] as a client application.

Other communities and vendors provide #link("https://trino.io/ecosystem/client-application#other-client-applications")[numerous other client applications]

== Client protocol

All client drivers and client applications communicate with the Trino coordinator using the #link(label("doc-client-client-protocol"))[client protocol].

Configure support for the #link(label("ref-protocol-spooling"))[spooling protocol] on the cluster to improve throughput for client interactions with higher data transfer demands.

- #link(label("doc-client-client-protocol"))[Client protocol]
- #link(label("doc-client-cli"))[Command line interface]
- #link(label("doc-client-jdbc"))[JDBC driver]
