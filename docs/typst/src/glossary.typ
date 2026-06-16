#import "/lib/trino-docs.typ": *

#anchor("doc-glossary")
= Glossary

The glossary contains a list of key Trino terms and definitions.

#anchor("ref-glosscatalog")

/ Catalog: Catalogs define and name a configuration for connecting to a data source, allowing users to query the connected data. Each catalog's configuration specifies a connector to define which data source the catalog connects to. For more information about catalogs, see #link(label("ref-trino-concept-catalog"))[trino-concept-catalog].

#anchor("ref-glosscert")

/ Certificate: A public key #link("https://wikipedia.org/wiki/Public_key_certificate")[certificate] issued by a CA, sometimes abbreviated as cert, that verifies the ownership of a server's private keys. Certificate format is specified in the #link("https://wikipedia.org/wiki/X.509")[X.509] standard.

#anchor("ref-glossca")

/ Certificate Authority \(CA\): A trusted organization that signs and issues certificates. Its signatures can be used to verify the validity of certificates.
/ Cluster: A Trino cluster provides the resources to run queries against numerous data sources. Clusters define the number of nodes, the configuration for the JVM runtime, configured data sources, and others aspects. For more information, see #link(label("ref-trino-concept-cluster"))[trino-concept-cluster].

#anchor("ref-glossconnector")

/ Connector: Translates data from a data source into Trino schemas, tables, columns, rows, and data types. A #link(label("doc-connector"))[connector] is specific to a data source, and is used in catalog configurations to define what data source the catalog connects to. A connector is one of many types of plugins

#anchor("ref-glosscontainer")

/ Container: A lightweight virtual package of software that contains libraries, binaries, code, configuration files, and other dependencies needed to deploy an application. A running container does not include an operating system, instead using the operating system of the host machine. To learn more, read about #link("https://kubernetes.io/docs/concepts/containers/")[containers] in the Kubernetes documentation.

#anchor("ref-glossdatasource")

/ Data source: A system from which data is retrieved - for example, PostgreSQL or Iceberg on S3 data. In Trino, users query data sources with catalogs that connect to each source. See #link(label("ref-trino-concept-data-source"))[trino-concept-data-source] for more information.

#anchor("ref-glossdatavirtualization")

/ Data virtualization: #link("https://wikipedia.org/wiki/Data_virtualization")[Data virtualization] is a method of abstracting an interaction with multiple heterogeneous data sources, without needing to know the distributed nature of the data, its format, or any other technical details involved in presenting the data.

#anchor("ref-glossgzip")

/ gzip: #link("https://wikipedia.org/wiki/Gzip")[gzip] is a compression format and software that compresses and decompresses files. This format is used several ways in Trino, including deployment and compressing files in object storage. The most common extension for gzip-compressed files is #raw(".gz").

#anchor("ref-glosshdfs")

/ HDFS: #link("https://wikipedia.org/wiki/Apache_Hadoop#HDFS")[Hadoop Distributed Filesystem \(HDFS\)] is a scalable open source filesystem that was one of the earliest distributed big data systems created to store large amounts of data for the #link("https://wikipedia.org/wiki/Apache_Hadoop")[Hadoop ecosystem].

#anchor("ref-glossjks")

/ Java KeyStore \(JKS\): The system of public key cryptography supported as one part of the Java security APIs. The legacy JKS system recognizes keys and certificates stored in #emph[keystore] files, typically with the #raw(".jks") extension, and by default relies on a system-level list of CAs in #emph[truststore] files installed as part of the current Java installation.
/ Key: A cryptographic key specified as a pair of public and private strings generally used in the context of TLS to secure public network traffic.

#anchor("ref-glosslb")

/ Load Balancer \(LB\): Software or a hardware device that sits on a network edge and accepts network connections on behalf of servers behind that wall, distributing traffic across network and server infrastructure to balance the load on networked services.

#anchor("ref-glossobjectstorage")

/ Object storage: #link("https://en.wikipedia.org/wiki/Object_storage")[Object storage] is a file storage mechanism. Examples of compatible object stores include the following:  - #link("https://aws.amazon.com/s3")[Amazon S3] - #link("https://cloud.google.com/storage")[Google Cloud Storage] - #link("https://azure.microsoft.com/en-us/products/storage/blobs")[Azure Blob Storage] - #link("https://min.io/")[MinIO] and other S3-compatible stores - HDFS

#anchor("ref-glossopensource")

/ Open-source: Typically refers to #link("https://wikipedia.org/wiki/Open-source_software")[open-source software]. which is software that has the source code made available for others to see, use, and contribute to. Allowed usage varies depending on the license that the software is licensed under. Trino is licensed under the #link("https://wikipedia.org/wiki/Apache_License")[Apache license], and is therefore maintained by a community of contributors from all across the globe.

#anchor("ref-glosspem")

/ PEM file format: A format for storing and sending cryptographic keys and certificates. PEM format can contain both a key and its certificate, plus the chain of certificates from authorities back to the root CA, or back to a CA vendor's intermediate CA.

#anchor("ref-glosspkcs12")

/ PKCS \#12: A binary archive used to store keys and certificates or certificate chains that validate a key. #link("https://wikipedia.org/wiki/PKCS_12")[PKCS \#12] files have #raw(".p12") or #raw(".pfx") extensions. This format is a less popular alternative to PEM.

#anchor("ref-glossplugin")

/ Plugin: A bundle of code implementing the Trino #link(label("doc-develop-spi-overview"))[Service Provider Interface \(SPI\)]. that is used to add new functionality. More information is available in #link(label("doc-installation-plugins"))[Plugins].
/ Presto and PrestoSQL: The old name for Trino. To learn more about the name change to Trino, read #link("https://wikipedia.org/wiki/Trino_(SQL_query_engine)#History")[the history].
/ Query federation: A type of data virtualization that provides a common access point and data model across two or more heterogeneous data sources. A popular data model used by many query federation engines is translating different data sources to SQL tables.

#anchor("ref-glossssl")

/ Secure Sockets Layer \(SSL\): Now superseded by TLS, but still recognized as the term for what TLS does.

#anchor("ref-glosssql")

/ Structured Query Language \(SQL\): The standard language used with relational databases. For more information, see #link(label("doc-language"))[SQL].

#anchor("ref-glosstarball")

/ Tarball: A common abbreviation for #link("https://wikipedia.org/wiki/Tar_(computing)")[TAR file], which is a common software distribution mechanism. This file format is a collection of multiple files distributed as a single file, commonly compressed using gzip compression.

#anchor("ref-glosstls")

/ Transport Layer Security \(TLS\): #link("https://wikipedia.org/wiki/Transport_Layer_Security")[TLS] is a security protocol designed to provide secure communications over a network. It is the successor to SSL, and used in many applications like HTTPS, email, and Trino. These security topics use the term TLS to refer to both TLS and SSL.
