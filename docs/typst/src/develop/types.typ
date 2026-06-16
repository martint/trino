#import "/lib/trino-docs.typ": *

#anchor("doc-develop-types")
= Types

The #raw("Type") interface in Trino is used to implement a type in the SQL language. Trino ships with a number of built-in types, like #raw("VarcharType") and #raw("BigintType"). The #raw("ParametricType") interface is used to provide type parameters for types, to allow types like #raw("VARCHAR(10)") or #raw("DECIMAL(22, 5)"). A #raw("Plugin") can provide new #raw("Type") objects by returning them from #raw("getTypes()") and new #raw("ParametricType") objects by returning them from #raw("getParametricTypes()").

Below is a high level overview of the #raw("Type") interface. For more details, see the JavaDocs for #raw("Type").

== Native container type

All types define the #raw("getJavaType()") method, frequently referred to as the "native container type". This is the Java type used to hold values during execution and to store them in a #raw("Block"). For example, this is the type used in the Java code that implements functions that produce or consume this #raw("Type").

== Native encoding

The interpretation of a value in its native container type form is defined by its #raw("Type"). For some types, such as #raw("BigintType"), it matches the Java interpretation of the native container type \(64bit 2's complement\). However, for other types such as #raw("TimestampWithTimeZoneType"), which also uses #raw("long") for its native container type, the value stored in the #raw("long") is a 8byte binary value combining the timezone and the milliseconds since the unix epoch. In particular, this means that you cannot compare two native values and expect a meaningful result, without knowing the native encoding.

== Type descriptor

A type's descriptor \(#raw("TypeDescriptor")\) defines its identity, and also encodes some general information about the type, such as its type parameters \(if it's parametric\) and its literal parameters. The literal parameters are used in types like #raw("VARCHAR(10)"). A descriptor is always #emph[ground]: it denotes one concrete type, such as #raw("varchar(10)") or #raw("array(bigint)").

== Type template

Where a #raw("TypeDescriptor") denotes one concrete type, a #raw("TypeTemplate") denotes a #emph[family] of types parameterized by variables — it is the open counterpart of the ground descriptor. Function signatures \(#raw("Signature")\) carry their argument and return types as templates: #raw("array(E)") has a type variable #raw("E"), and #raw("decimal(p, s)") has numeric variables #raw("p") and #raw("s").

Binding a template's variables against a call site — see #raw("SignatureBinder") — substitutes the bound types and evaluates any calculated numeric expressions \(for example the #raw("x + y") in #raw("char(x + y)")\), producing a ground #raw("TypeDescriptor"). The reverse, lifting a variable-free #raw("TypeDescriptor") into a #raw("TypeTemplate"), is also supported. A #raw("Signature") therefore declares its type and numeric variables once and expresses every argument and return position as a template over them.

== Type id

A #raw("TypeId") is the opaque identifier under which a type is persisted, for example in the catalog properties of a materialized view. It wraps the rendered form of the type's descriptor but guarantees nothing about its structure: where a #raw("TypeDescriptor") is structural identity that can be inspected and compared piecewise, a #raw("TypeId") is only ever compared for equality and resolved back to a type through #raw("TypeManager").
