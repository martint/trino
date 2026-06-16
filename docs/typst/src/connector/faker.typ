#import "/lib/trino-docs.typ": *

#anchor("doc-connector-faker")
= Faker connector

The Faker connector generates random data matching a defined structure. It uses the #link("https://www.datafaker.net/")[Datafaker] library to make the generated data more realistic.

Use the connector to test and learn SQL queries without the need for a fixed, imported dataset, or to populate another data source with large and realistic test data. This allows testing the performance of applications processing data, including Trino itself, and application user interfaces accessing the data.

== Configuration

Create a catalog properties file that specifies the Faker connector by setting the #raw("connector.name") to #raw("faker").

For example, to generate data in the #raw("generator") catalog, create the file #raw("etc/catalog/generator.properties").

#code-block("text", "connector.name=faker
faker.null-probability=0.1
faker.default-limit=1000
faker.locale=pl")

Create tables in the #raw("default") schema, or create different schemas first. Tables in the catalog only exist as definition and do not hold actual data. Any query reading from tables returns random, but deterministic data. As a result, repeated invocation of a query returns identical data. See #link(label("ref-faker-usage"))[Faker connector] for more examples.

Schemas, tables, and views in a catalog are not persisted, and are stored in the memory of the coordinator only. They need to be recreated every time after restarting the coordinator.

The following table details all general configuration properties:

#list-table((
  ([Property name], [Description],),
  ([#raw("faker.null-probability")], [Default probability of a value created as #raw("null") for any column in any table that allows them. Defaults to #raw("0.5").],),
  ([#raw("faker.default-limit")], [Default number of rows in a table. Defaults to #raw("1000").],),
  ([#raw("faker.locale")], [Default locale for generating character-based data, specified as an IETF BCP 47 language tag string. Defaults to #raw("en").],),
  ([#raw("faker.sequence-detection-enabled")], [If true, when creating a table using existing data, columns with the number of distinct values close to the number of rows are treated as sequences. Defaults to #raw("true").],),
  ([#raw("faker.dictionary-detection-enabled")], [If true, when creating a table using existing data, columns with a low number of distinct values are treated as dictionaries, and get the #raw("allowed_values") column property populated with random values. Defaults to #raw("true").],)
), header-rows: 1, title: "Faker configuration properties")

The following table details all supported schema properties. If they're not set, values from corresponding configuration properties are used.

#list-table((
  ([Property name], [Description],),
  ([#raw("null_probability")], [Default probability of a value created as #raw("null") in any column that allows them, in any table of this schema.],),
  ([#raw("default_limit")], [Default number of rows in a table.],),
  ([#raw("sequence_detection_enabled")], [If true, when creating a table using existing data, columns with the number of distinct values close to the number of rows are treated as sequences. Defaults to #raw("true").],),
  ([#raw("dictionary_detection_enabled")], [If true, when creating a table using existing data, columns with a low number of distinct values are treated as dictionaries, and get the #raw("allowed_values") column property populated with random values. Defaults to #raw("true").],)
), header-rows: 1, title: "Faker schema properties")

The following table details all supported table properties. If they're not set, values from corresponding schema properties are used.

#list-table((
  ([Property name], [Description],),
  ([#raw("null_probability")], [Default probability of a value created as #raw("null") in any column that allows #raw("null") in the table.],),
  ([#raw("default_limit")], [Default number of rows in the table.],),
  ([#raw("sequence_detection_enabled")], [If true, when creating a table using existing data, columns with the number of distinct values close to the number of rows are treated as sequences. Defaults to #raw("true").],),
  ([#raw("dictionary_detection_enabled")], [If true, when creating a table using existing data, columns with a low number of distinct values are treated as dictionaries, and get the #raw("allowed_values") column property populated with random values. Defaults to #raw("true").],)
), header-rows: 1, title: "Faker table properties")

The following table details all supported column properties.

#list-table((
  ([Property name], [Description],),
  ([#raw("null_probability")], [Default probability of a value created as #raw("null") in the column. Defaults to the #raw("null_probability") table or schema property, if set, or the #raw("faker.null-probability") configuration property.],),
  ([#raw("generator")], [Name of the Faker library generator used to generate data for the column. Only valid for columns of a character-based type. Defaults to a 3 to 40 word sentence from the #link("https://javadoc.io/doc/net.datafaker/datafaker/latest/net/datafaker/providers/base/Lorem.html")[Lorem] provider.],),
  ([#raw("min")], [Minimum generated value \(inclusive\). Cannot be set for character-based type columns.],),
  ([#raw("max")], [Maximum generated value \(inclusive\). Cannot be set for character-based type columns.],),
  ([#raw("allowed_values")], [List of allowed values. Cannot be set together with the #raw("min"), or #raw("max") properties.],),
  ([#raw("step")], [If set, generate sequential values with this step. For date and time columns set this to a duration. Cannot be set for character-based type columns.],)
), header-rows: 1, title: "Faker column properties")

=== Character types

Faker supports the following character types:

- #raw("CHAR")
- #raw("VARCHAR")
- #raw("VARBINARY")

Columns of those types use a generator producing the #link("https://en.wikipedia.org/wiki/Lorem_ipsum")[Lorem ipsum] placeholder text. Unbounded columns return a random sentence with 3 to 40 words.

To have more control over the format of the generated data, use the #raw("generator") column property. Some examples of valid generator expressions:

- #raw("#{regexify '(a|b){2,3}'}")
- #raw("#{regexify '\\\\.\\\\*\\\\?\\\\+'}")
- #raw("#{bothify '????','false'}")
- #raw("#{Name.first_name} #{Name.first_name} #{Name.last_name}")
- #raw("#{number.number_between '1','10'}")

See the Datafaker's documentation for more information about #link("https://www.datafaker.net/documentation/expressions/")[the expression] syntax and #link("https://www.datafaker.net/documentation/providers/")[available providers].

#function-def("fn-random-string", "random_string(expression_string)", "string")[
Create a random output #raw("string") with the provided input #raw("expression_string"). The expression must use the #link("https://www.datafaker.net/documentation/expressions/")[syntax from Datafaker].

Use the #raw("random_string") function from the #raw("default") schema of the #raw("generator") catalog to test a generator expression:

#code-block("sql", "SELECT generator.default.random_string('#{Name.first_name}');")
]

=== Non-character types

Faker supports the following non-character types:

- #raw("BIGINT")
- #raw("INTEGER") or #raw("INT")
- #raw("SMALLINT")
- #raw("TINYINT")
- #raw("BOOLEAN")
- #raw("DATE")
- #raw("DECIMAL")
- #raw("REAL")
- #raw("DOUBLE")
- #raw("INTERVAL DAY TO SECOND")
- #raw("INTERVAL YEAR TO MONTH")
- #raw("TIMESTAMP") and #raw("TIMESTAMP(P)")
- #raw("TIMESTAMP WITH TIME ZONE") and #raw("TIMESTAMP(P) WITH TIME ZONE")
- #raw("TIME") and #raw("TIME(P)")
- #raw("TIME WITH TIME ZONE") and #raw("TIME(P) WITH TIME ZONE")
- #raw("ROW")
- #raw("IPADDRESS")
- #raw("UUID")

You can not use generator expressions for non-character-based columns. To limit their data range, set the #raw("min") and #raw("max") column properties - see #link(label("ref-faker-usage"))[Faker connector].

=== Unsupported types

Faker does not support the following data types:

- Structural types #raw("ARRAY") and #raw("MAP")
- #raw("JSON")
- Geometry
- HyperLogLog and all digest types

To generate data using these complex types, data from column of primitive types can be combined, like in the following example:

#code-block("sql", "CREATE TABLE faker.default.prices (
  currency VARCHAR NOT NULL WITH (generator = '#{Currency.code}'),
  price DECIMAL(8,2) NOT NULL WITH (min = '0')
);

SELECT JSON_OBJECT(KEY currency VALUE price) AS complex
FROM faker.default.prices
LIMIT 3;")

Running the queries returns data similar to the following result:

#code-block("text", "      complex
-------------------
 {\"TTD\":924657.82}
 {\"MRO\":968292.49}
 {\"LTL\":357773.63}
(3 rows)")

=== Number of generated rows

By default, the connector generates 1000 rows for every table. To control how many rows are generated for a table, use the #raw("LIMIT") clause in the query. A default limit can be set using the #raw("default_limit") table, or schema property or in the connector configuration file, using the #raw("faker.default-limit") property. Use a limit value higher than the configured default to return more rows.

=== Null values

For columns without a #raw("NOT NULL") constraint, #raw("null") values are generated using the default probability of 50%. It can be modified using the #raw("null_probability") property set for a column, table, or schema. The default value of 0.5 can be also modified in the catalog configuration file, by using the #raw("faker.null-probability") property.

#anchor("ref-faker-type-mapping")

== Type mapping

The Faker connector generates data itself, so no mapping is required.

#anchor("ref-faker-sql-support")

== SQL support

The connector provides #link(label("ref-sql-globally-available"))[globally available] and #link(label("ref-sql-read-operations"))[read operation] statements to generate data.

To define the schema for generating data, it supports the following features:

- #link(label("doc-sql-create-table"))[CREATE TABLE]
- #link(label("doc-sql-create-table-as"))[CREATE TABLE AS], see also #link(label("ref-faker-statistics"))[Faker connector]
- #link(label("doc-sql-drop-table"))[DROP TABLE]
- #link(label("doc-sql-create-schema"))[CREATE SCHEMA]
- #link(label("doc-sql-drop-schema"))[DROP SCHEMA]
- #link(label("ref-sql-view-management"))[SQL statement support]

#anchor("ref-faker-usage")

== Usage

Faker generates data when reading from a table created in a catalog using this connector. This makes it easy to fill an existing schema with random data, by copying only the schema into a Faker catalog, and inserting the data back into the original tables.

Using the catalog definition from Configuration you can proceed with the following steps.

Create a table with the same columns as in the table to populate with random data. Exclude all properties, because the Faker connector doesn't support the same table properties as other connectors.

#code-block("sql", "CREATE TABLE generator.default.customer (LIKE production.public.customer EXCLUDING PROPERTIES);")

Insert random data into the original table, by selecting it from the #raw("generator") catalog. Data generated by the Faker connector for columns of non-character types cover the whole range of that data type. Set the #raw("min") and #raw("max") column properties, to adjust the generated data as desired. The following example ensures that date of birth and age in years are related and realistic values.

Start with getting the complete definition of a table:

#code-block("sql", "SHOW CREATE TABLE production.public.customers;")

Modify the output of the previous query and add some column properties.

#code-block("sql", "CREATE TABLE generator.default.customer (
  id UUID NOT NULL,
  name VARCHAR NOT NULL,
  address VARCHAR NOT NULL,
  born_at DATE WITH (min = '1900-01-01', max = '2025-01-01'),
  age_years INTEGER WITH (min = '0', max = '150'),
  group_id INTEGER WITH (allowed_values = ARRAY['10', '32', '81'])
);")

#code-block("sql", "INSERT INTO production.public.customers
SELECT *
FROM generator.default.customers
LIMIT 100;")

To generate even more realistic data, choose specific generators by setting the #raw("generator") property on columns.

#code-block("sql", "CREATE TABLE generator.default.customer (
  id UUID NOT NULL,
  name VARCHAR NOT NULL WITH (generator = '#{Name.first_name} #{Name.last_name}'),
  address VARCHAR NOT NULL WITH (generator = '#{Address.fullAddress}'),
  born_at DATE WITH (min = '1900-01-01', max = '2025-01-01'),
  age_years INTEGER WITH (min = '0', max = '150'),
  group_id INTEGER WITH (allowed_values = ARRAY['10', '32', '81'])
);")

#anchor("ref-faker-statistics")

=== Using existing data statistics

The Faker connector automatically sets the #raw("default_limit") table property, and the #raw("min"), #raw("max"), and #raw("null_probability") column properties, based on statistics collected by scanning existing data read by Trino from the data source. The connector uses these statistics to be able to generate data that is more similar to the original data set, without using any of that data:

#code-block("sql", "CREATE TABLE generator.default.customer AS
SELECT *
FROM production.public.customer
WHERE created_at > CURRENT_DATE - INTERVAL '1' YEAR;")

Instead of using range, or other predicates, tables can be sampled, see #link(label("ref-tablesample"))[SELECT].

When the #raw("SELECT") statement doesn't contain a #raw("WHERE") clause, a shorter notation can be used:

#code-block("sql", "CREATE TABLE generator.default.customer AS TABLE production.public.customer;")

The Faker connector detects sequence columns, which are integer column with the number of distinct values almost equal to the number of rows in the table. For such columns, Faker sets the #raw("step") column property to 1.

Sequence detection can be turned off using the #raw("sequence_detection_enabled") table, or schema property or in the connector configuration file, using the #raw("faker.sequence-detection-enabled") property.

The Faker connector detects dictionary columns, which are columns of non-character types with the number of distinct values lower or equal to 1000. For such columns, Faker generates a list of random values to choose from, and saves it in the #raw("allowed_values") column property.

Dictionary detection can be turned off using the #raw("dictionary_detection_enabled") table, or schema property or in the connector configuration file, using the #raw("faker.dictionary-detection-enabled") property.

For example, copy the #raw("orders") table from the TPC-H connector with statistics, using the following query:

#code-block("sql", "CREATE TABLE generator.default.orders AS TABLE tpch.tiny.orders;")

Inspect the schema of the table created by the Faker connector:

#code-block("sql", "SHOW CREATE TABLE generator.default.orders;")

The table schema should contain additional column and table properties.

#code-block(none, "CREATE TABLE generator.default.orders (
   orderkey bigint WITH (max = '60000', min = '1', null_probability = 0E0, step = '1'),
   custkey bigint WITH (allowed_values = ARRAY['153','662','1453','63','784', ..., '1493','657'], null_probability = 0E0),
   orderstatus varchar(1),
   totalprice double WITH (max = '466001.28', min = '874.89', null_probability = 0E0),
   orderdate date WITH (max = '1998-08-02', min = '1992-01-01', null_probability = 0E0),
   orderpriority varchar(15),
   clerk varchar(15),
   shippriority integer WITH (allowed_values = ARRAY['0'], null_probability = 0E0),
   comment varchar(79)
)
WITH (
   default_limit = 15000
)")
