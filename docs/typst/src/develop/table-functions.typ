#import "/lib/trino-docs.typ": *

#anchor("doc-develop-table-functions")
= Table functions

Table functions return tables. They allow users to dynamically invoke custom logic from within the SQL query. They are invoked in the #raw("FROM") clause of a query, and the calling convention is similar to a scalar function call. For description of table functions usage, see #link(label("doc-functions-table"))[table functions].

Trino supports adding custom table functions. They are declared by connectors through implementing dedicated interfaces.

== Table function declaration

To declare a table function, you need to implement #raw("ConnectorTableFunction"). Subclassing #raw("AbstractConnectorTableFunction") is a convenient way to do it. The connector's #raw("getTableFunctions()") method must return a set of your implementations.

=== The constructor

#code-block("java", "public class MyFunction
        extends AbstractConnectorTableFunction
{
    public MyFunction()
    {
        super(
                \"system\",
                \"my_function\",
                List.of(
                        ScalarArgumentSpecification.builder()
                                .name(\"COLUMN_COUNT\")
                                .type(INTEGER)
                                .defaultValue(2)
                                .build(),
                        ScalarArgumentSpecification.builder()
                                .name(\"ROW_COUNT\")
                                .type(INTEGER)
                                .build()),
                GENERIC_TABLE);
    }
}")

The constructor takes the following arguments:

- #strong[schema name]

The schema name helps you organize functions, and it is used for function resolution. When a table function is invoked, the right implementation is identified by the catalog name, the schema name, and the function name.

The function can use the schema name, for example to use data from the indicated schema, or ignore it.

- #strong[function name]
- #strong[list of expected arguments]

Three different types of arguments are supported: scalar arguments, descriptor arguments, and table arguments. See #link(label("ref-tf-argument-types"))[tf-argument-types] for details. You can specify default values for scalar and descriptor arguments. The arguments with specified default can be skipped during table function invocation.

- #strong[returned row type]

It describes the row type produced by the table function.

If a table function takes table arguments, it can additionally pass the columns of the input tables to output using the #emph[pass-through mechanism]. The returned row type is supposed to describe only the columns produced by the function, as opposed to the pass-through columns.

In the example, the returned row type is #raw("GENERIC_TABLE"), which means that the row type is not known statically, and it is determined dynamically based on the passed arguments.

When the returned row type is known statically, you can declare it using:

#code-block("java", "new DescribedTable(descriptor)")

If a table function does not produce any columns, and it only outputs the pass-through columns, use #raw("ONLY_PASS_THROUGH") as the returned row type.

#note[
A table function must return at least one column. It can either be a proper column, i.e. produced by the function, or a pass-through column.
]

#anchor("ref-tf-argument-types")

=== Argument types

Table functions take three types of arguments: #link(label("ref-tf-scalar-arguments"))[scalar arguments], #link(label("ref-tf-descriptor-arguments"))[descriptor arguments], and #link(label("ref-tf-table-arguments"))[table arguments].

#anchor("ref-tf-scalar-arguments")

==== Scalar arguments

They can be of any supported data type. You can specify a default value.

#code-block("java", "ScalarArgumentSpecification.builder()
        .name(\"COLUMN_COUNT\")
        .type(INTEGER)
        .defaultValue(2)
        .build()")

#code-block("java", "ScalarArgumentSpecification.builder()
        .name(\"ROW_COUNT\")
        .type(INTEGER)
        .build()")

#anchor("ref-tf-descriptor-arguments")

==== Descriptor arguments

Descriptors consist of fields with names and optional data types. They are a convenient way to pass the required result row type to the function, or for example inform the function which input columns it should use. You can specify default values for descriptor arguments. Descriptor argument can be #raw("null").

#code-block("java", "DescriptorArgumentSpecification.builder()
        .name(\"SCHEMA\")
        .defaultValue(null)
        .build()")

#anchor("ref-tf-table-arguments")

==== Table arguments

A table function can take any number of input relations. It allows you to process multiple data sources simultaneously.

When declaring a table argument, you must specify characteristics to determine how the input table is processed. Also note that you cannot specify a default value for a table argument.

#code-block("java", "TableArgumentSpecification.builder()
        .name(\"INPUT\")
        .rowSemantics()
        .pruneWhenEmpty()
        .passThroughColumns()
        .build()")

#anchor("ref-tf-set-or-row-semantics")

===== Set or row semantics

Set semantics is the default for table arguments. A table argument with set semantics is processed on a partition-by-partition basis. During function invocation, the user can specify partitioning and ordering for the argument. If no partitioning is specified, the argument is processed as a single partition.

A table argument with row semantics is processed on a row-by-row basis. Partitioning or ordering is not applicable.

===== Prune or keep when empty

The #emph[prune when empty] property indicates that if the given table argument is empty, the function returns empty result. This property is used to optimize queries involving table functions. The #emph[keep when empty] property indicates that the function should be executed even if the table argument is empty. The user can override this property when invoking the function. Using the #emph[keep when empty] property can negatively affect performance when the table argument is not empty.

===== Pass-through columns

If a table argument has #emph[pass-through columns], all of its columns are passed on output. For a table argument without this property, only the partitioning columns are passed on output.

=== The #raw("analyze()") method

In order to provide all the necessary information to the Trino engine, the class must implement the #raw("analyze()") method. This method is called by the engine during the analysis phase of query processing. The #raw("analyze()") method is also the place to perform custom checks on the arguments:

#code-block("java", "@Override
public TableFunctionAnalysis analyze(ConnectorSession session, ConnectorTransactionHandle transaction, Map<String, Argument> arguments)
{
    long columnCount = (long) ((ScalarArgument) arguments.get(\"COLUMN_COUNT\")).getValue();
    long rowCount = (long) ((ScalarArgument) arguments.get(\"ROW_COUNT\")).getValue();

    // custom validation of arguments
    if (columnCount < 1 || columnCount > 3) {
         throw new TrinoException(INVALID_FUNCTION_ARGUMENT, \"column_count must be in range [1, 3]\");
    }

    if (rowCount < 1) {
        throw new TrinoException(INVALID_FUNCTION_ARGUMENT, \"row_count must be positive\");
    }

    // determine the returned row type
    List<Descriptor.Field> fields = List.of(\"col_a\", \"col_b\", \"col_c\").subList(0, (int) columnCount).stream()
            .map(name -> new Descriptor.Field(name, Optional.of(BIGINT)))
            .collect(toList());

    Descriptor returnedType = new Descriptor(fields);

    return TableFunctionAnalysis.builder()
            .returnedType(returnedType)
            .handle(new MyHandle(columnCount, rowCount))
            .build();
}")

The #raw("analyze()") method returns a #raw("TableFunctionAnalysis") object, which comprises all the information required by the engine to analyze, plan, and execute the table function invocation:

- The returned row type, specified as an optional #raw("Descriptor"). It should be passed if and only if the table function is declared with the #raw("GENERIC_TABLE") returned type.
- Required columns from the table arguments, specified as a map of table argument names to lists of column indexes.
- Any information gathered during analysis that is useful during planning or execution, in the form of a #raw("ConnectorTableFunctionHandle"). #raw("ConnectorTableFunctionHandle") is a marker interface intended to carry information throughout subsequent phases of query processing in a manner that is opaque to the engine.

== Table function execution

There are two paths of execution available for table functions.

+ Pushdown to the connector

The connector that provides the table function implements the #raw("applyTableFunction()") method. This method is called during the optimization phase of query processing. It returns a #raw("ConnectorTableHandle") and a list of #raw("ColumnHandle") s representing the table function result. The table function invocation is then replaced with a #raw("TableScanNode").

This execution path is convenient for table functions whose results are easy to represent as a #raw("ConnectorTableHandle"), for example query pass-through. It only supports scalar and descriptor arguments.

+ Execution by operator

Trino has a dedicated operator for table functions. It can handle table functions with any number of table arguments as well as scalar and descriptor arguments. To use this execution path, you provide an implementation of a processor.

If your table function has one or more table arguments, you must implement #raw("TableFunctionDataProcessor"). It processes pages of input data.

If your table function is a source operator \(it does not have table arguments\), you must implement #raw("TableFunctionSplitProcessor"). It processes splits. The connector that provides the function must provide a #raw("ConnectorSplitSource") for the function. With splits, the task can be divided so that each split represents a subtask.

== Access control

The access control for table functions can be provided both on system and connector level. It is based on the fully qualified table function name, which consists of the catalog name, the schema name, and the function name, in the syntax of #raw("catalog.schema.function").
