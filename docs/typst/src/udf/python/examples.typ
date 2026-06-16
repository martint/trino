#import "/lib/trino-docs.typ": *

#anchor("doc-udf-python-examples")
= Example Python UDFs

After learning about #link(label("doc-udf-python"))[Python user-defined functions], the following sections show examples of valid Python UDFs.

The UDFs are suitable as #link(label("ref-udf-inline"))[Introduction to UDFs] or #link(label("ref-udf-catalog"))[Introduction to UDFs], after adjusting the name and the example invocations.

== Inline and catalog Python UDFs

The following section shows the differences in usage with inline and catalog UDFs with a simple Python UDF example. The same pattern applies to all other following sections.

A very simple Python UDF that returns the static int value #raw("42") without requiring any input:

#code-block("text", "FUNCTION answer()
LANGUAGE PYTHON
RETURNS int
WITH (handler='theanswer')
AS $$
def theanswer():
    return 42
$$")

A full example of this UDF as inline UDF and usage in a string concatenation with a cast:

#code-block("text", "WITH
  FUNCTION answer()
  RETURNS int
  LANGUAGE PYTHON
  WITH (handler='theanswer')
  AS $$
  def theanswer():
      return 42
  $$
SELECT 'The answer is ' || CAST(answer() as varchar);
-- The answer is 42")

Provided the catalog #raw("example") supports UDF storage in the #raw("default") schema, you can use the following:

#code-block("text", "CREATE FUNCTION example.default.answer()
  RETURNS int
  LANGUAGE PYTHON
  WITH (handler='theanswer')
  AS $$
  def theanswer():
      return 42
  $$;")

With the UDF stored in the catalog, you can run the UDF multiple times without repeated definition:

#code-block("sql", "SELECT example.default.answer() + 1; -- 43
SELECT 'The answer is ' || CAST(example.default.answer() as varchar); -- The answer is 42")

Alternatively, you can configure the SQL PATH in the #link(label("ref-config-properties"))[Deploying Trino] to a catalog and schema that support UDF storage:

#code-block("properties", "sql.default-function-catalog=example
sql.default-function-schema=default
sql.path=example.default")

Now you can manage UDFs without the full path:

#code-block("text", "CREATE FUNCTION answer()
  RETURNS int
  LANGUAGE PYTHON
  WITH (handler='theanswer')
  AS $$
  def theanswer():
      return 42
  $$;")

UDF invocation works without the full path:

#code-block("sql", "SELECT answer() + 5; -- 47")

== XOR

The following example implements a #raw("xor") function for a logical Exclusive OR operation on two boolean input parameters and tests it with two invocations:

#code-block("text", "WITH FUNCTION xor(a boolean, b boolean)
RETURNS boolean
LANGUAGE PYTHON
WITH (handler = 'bool_xor')
AS $$
import operator
def bool_xor(a, b):
    return operator.xor(a, b)
$$
SELECT xor(true, false), xor(false, true);")

Result of the query:

#code-block(none, " true  | true")

== reverse\_words

The following example uses a more elaborate Python script to reverse the characters in each word of the input string #raw("s") of type #raw("varchar") and tests the function.

#code-block("text", "WITH FUNCTION reverse_words(s varchar)
RETURNS varchar
LANGUAGE PYTHON
WITH (handler = 'reverse_words')
AS $$
import re

def reverse(s):
    str = \"\"
    for i in s:
        str = i + str
    return str

pattern = re.compile(r\"\\w+[.,'!?\\\"]\\w*\")

def process_word(word):
    # Reverse only words without non-letter signs
    return word if pattern.match(word) else reverse(word)

def reverse_words(payload):
    text_words = payload.split(' ')
    return ' '.join([process_word(w) for w in text_words])
$$
SELECT reverse_words('Civic, level, dna racecar era semordnilap');")

Result of the query:

#code-block(none, "Civic, level, and racecar are palindromes")
