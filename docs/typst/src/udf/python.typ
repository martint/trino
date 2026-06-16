#import "/lib/trino-docs.typ": *

#anchor("doc-udf-python")
= Python user-defined functions

A Python user-defined function is a #link(label("doc-udf"))[user-defined function] that uses the #link(label("ref-python-udf-lang"))[Python programming language and statements] for the definition of the function.

== Python UDF declaration

Declare a Python UDF as #link(label("ref-udf-inline"))[inline] or #link(label("ref-udf-catalog"))[catalog UDF] with the following steps:

- Use the #link(label("doc-udf-function"))[FUNCTION] keyword to declare the UDF name and parameters.
- Add the #raw("RETURNS") declaration to specify the data type of the result.
- Set the #raw("LANGUAGE") to #raw("PYTHON").
- Declare the name of the Python function to call with the #raw("handler") property in the #raw("WITH") block.
- Use #raw("$$") to enclose the Python code after the #raw("AS") keyword.
- Add the function from the handler property and ensure it returns the declared data type.
- Expand your Python code section to implement the function using the available #link(label("ref-python-udf-lang"))[Python language].

The following snippet shows pseudo-code:

#code-block("text", "FUNCTION python_udf_name(input_parameter data_type)
  RETURNS result_data_type
  LANGUAGE PYTHON
  WITH (handler = 'python_function')
  AS $$
  ...
  def python_function(input):
      return ...
  ...
  $$")

A minimal example declares the UDF #raw("doubleup") that returns the input integer value #raw("x") multiplied by two. The example shows declaration as #link(label("ref-udf-inline"))[Introduction to UDFs] and invocation with the value #raw("21") to yield the result #raw("42").

Set the language to #raw("PYTHON") to override the default #raw("SQL") for #link(label("doc-udf-sql"))[SQL user-defined functions]. The Python code is enclosed with #raw("$$") and must use valid formatting.

#code-block("text", "WITH
  FUNCTION doubleup(x integer)
    RETURNS integer
    LANGUAGE PYTHON
    WITH (handler = 'twice')
    AS $$
    def twice(a):
        return a * 2
    $$
SELECT doubleup(21);
-- 42")

The same UDF can also be declared as #link(label("ref-udf-catalog"))[Introduction to UDFs].

Refer to the #link(label("doc-udf-python-examples"))[Example Python UDFs] for more complex use cases and examples.

- \/udf\/python\/examples

#anchor("ref-python-udf-lang")

== Python language details

The Trino Python UDF integrations uses Python 3.13.0 in a sandboxed environment. Python code runs within a WebAssembly \(WASM\) runtime within the Java virtual machine running Trino.

Python language rules including indents must be observed.

Python UDFs therefore only have access to the Python language and core libraries included in the sandboxed runtime. Access to external resources with network or file system operations is not supported. Usage of other Python libraries as well as command line tools or package managers is not supported.

The following libraries are explicitly removed from the runtime and therefore not available within a Python UDF:

- #raw("bdb")
- #raw("concurrent")
- #raw("curses")
- #raw("ensurepip")
- #raw("doctest")
- #raw("idlelib")
- #raw("multiprocessing")
- #raw("pdb")
- #raw("pydoc")
- #raw("socketserver")
- #raw("sqlite3")
- #raw("ssl")
- #raw("subprocess")
- #raw("tkinter")
- #raw("turtle")
- #raw("unittest")
- #raw("venv")
- #raw("webbrowser")
- #raw("wsgiref")
- #raw("xmlrpc")

The following libraries are explicitly added to the runtime and therefore available within a Python UDF:

- #raw("attrs")
- #raw("bleach")
- #raw("charset-normalizer")
- #raw("defusedxml")
- #raw("idna")
- #raw("jmespath")
- #raw("jsonschema")
- #raw("pyasn1")
- #raw("pyparsing")
- #raw("python-dateutil")
- #raw("rsa")
- #raw("tomli")
- #raw("ua-parser")

== Type mapping

The following table shows supported Trino types and their corresponding Python types for input and output values of a Python UDF:

#list-table((
  ([Trino type], [Python type],),
  ([#raw("ROW")], [#raw("tuple")],),
  ([#raw("ARRAY")], [#raw("list")],),
  ([#raw("MAP")], [#raw("dict")],),
  ([#raw("BOOLEAN")], [#raw("bool")],),
  ([#raw("TINYINT")], [#raw("int")],),
  ([#raw("SMALLINT")], [#raw("int")],),
  ([#raw("INTEGER")], [#raw("int")],),
  ([#raw("BIGINT")], [#raw("int")],),
  ([#raw("REAL")], [#raw("float")],),
  ([#raw("DOUBLE")], [#raw("float")],),
  ([#raw("DECIMAL")], [#raw("decimal.Decimal")],),
  ([#raw("VARCHAR")], [#raw("str")],),
  ([#raw("VARBINARY")], [#raw("bytes")],),
  ([#raw("DATE")], [#raw("datetime.date")],),
  ([#raw("TIME")], [#raw("datetime.time")],),
  ([#raw("TIME WITH TIME ZONE")], [#raw("datetime.time") with #raw("datetime.tzinfo")],),
  ([#raw("TIMESTAMP")], [#raw("datetime.datetime")],),
  ([#raw("TIMESTAMP WITH TIME ZONE")], [#raw("datetime.datetime") with #raw("datetime.tzinfo")],),
  ([#raw("INTERVAL YEAR TO MONTH")], [#raw("int") as the number of months],),
  ([#raw("INTERVAL DAY TO SECOND")], [#raw("datetime.timedelta")],),
  ([#raw("JSON")], [#raw("str")],),
  ([#raw("UUID")], [#raw("uuid.UUID")],),
  ([#raw("IPADDRESS")], [#raw("ipaddress.IPv4Address") or #raw("ipaddress.IPv6Address")],)
), header-rows: 1)

=== Time and timestamp

Python #raw("datetime") and #raw("time") objects only support microsecond precision. Trino argument values with greater precision are rounded when converted to Python values, and Python return values are rounded if the Trino return type has less than microsecond precision.

=== Timestamp with time zone

Only fixed offset time zones are supported. Timestamps with political time zones have the zone converted to the zone's offset for the timestamp's instant.
