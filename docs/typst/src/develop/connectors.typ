#import "/lib/trino-docs.typ": *

#anchor("doc-develop-connectors")
= Connectors

Connectors are the source of all data for queries in Trino. Even if your data source doesn't have underlying tables backing it, as long as you adapt your data source to the API expected by Trino, you can write queries against this data.

== ConnectorFactory

Instances of your connector are created by a #raw("ConnectorFactory") instance which is created when Trino calls #raw("getConnectorFactory()") on the plugin. The connector factory is a simple interface responsible for providing the connector name and creating an instance of a #raw("Connector") object. A basic connector implementation that only supports reading, but not writing data, should return instances of the following services:

- #link(label("ref-connector-metadata"))[connector-metadata]
- #link(label("ref-connector-split-manager"))[connector-split-manager]
- #link(label("ref-connector-record-set-provider"))[connector-record-set-provider] or #link(label("ref-connector-page-source-provider"))[connector-page-source-provider]

=== Configuration

The #raw("create()") method of the connector factory receives a #raw("config") map, containing all properties from the catalog properties file. It can be used to configure the connector, but because all the values are strings, they might require additional processing if they represent other data types. It also doesn't validate if all the provided properties are known. This can lead to the connector behaving differently than expected when a connector ignores a property due to the user making a mistake in typing the name of the property.

To make the configuration more robust, define a Configuration class. This class describes all the available properties, their types, and additional validation rules.

#code-block("java", "import io.airlift.configuration.Config;
import io.airlift.configuration.ConfigDescription;
import io.airlift.configuration.ConfigSecuritySensitive;
import io.airlift.units.Duration;
import io.airlift.units.MaxDuration;
import io.airlift.units.MinDuration;

import javax.validation.constraints.NotNull;

public class ExampleConfig
{
    private String secret;
    private Duration timeout = Duration.succinctDuration(10, TimeUnit.SECONDS);

    public String getSecret()
    {
        return secret;
    }

    @Config(\"secret\")
    @ConfigDescription(\"Secret required to access the data source\")
    @ConfigSecuritySensitive
    public ExampleConfig setSecret(String secret)
    {
        this.secret = secret;
        return this;
    }

    @NotNull
    @MaxDuration(\"10m\")
    @MinDuration(\"1ms\")
    public Duration getTimeout()
    {
        return timeout;
    }

    @Config(\"timeout\")
    public ExampleConfig setTimeout(Duration timeout)
    {
        this.timeout = timeout;
        return this;
    }
}")

The preceding example defines two configuration properties and makes the connector more robust by:

- defining all supported properties, which allows detecting spelling mistakes in the configuration on server startup
- defining a default timeout value, to prevent connections getting stuck indefinitely
- preventing invalid timeout values, like 0 ms, that would make all requests fail
- parsing timeout values in different units, detecting invalid values
- preventing logging the secret value in plain text

The configuration class needs to be bound in a Guice module:

#code-block("java", "import com.google.inject.Binder;
import com.google.inject.Module;

import static io.airlift.configuration.ConfigBinder.configBinder;

public class ExampleModule
        implements Module
{
    public ExampleModule()
    {
    }

    @Override
    public void configure(Binder binder)
    {
        configBinder(binder).bindConfig(ExampleConfig.class);
    }
}")

And then the module needs to be initialized in the connector factory, when creating a new instance of the connector:

#code-block("java", "@Override
public Connector create(String catalogName, Map<String, String> config, ConnectorContext context)
{
    requireNonNull(config, \"config is null\");
    Bootstrap app = new Bootstrap(\"io.trino.bootstrap.catalog.\" + catalogName, new ExampleModule());
    Injector injector = app
            .doNotInitializeLogging()
            .setRequiredConfigurationProperties(config)
            .initialize();

    return injector.getInstance(ExampleConnector.class);
}")

#note[
Environment variables in the catalog properties file \(ex. #raw("secret=${ENV:SECRET}")\) are resolved only when using the #raw("io.airlift.bootstrap.Bootstrap") class to initialize the module. See #link(label("doc-security-secrets"))[Secrets] for more information.
]

If you end up needing to define multiple catalogs using the same connector just to change one property, consider adding support for schema and\/or table properties. That would allow a more fine-grained configuration. If a connector doesn't support managing the schema, query predicates for selected columns could be used as a way of passing the required configuration at run time.

For example, when building a connector to read commits from a Git repository, the repository URL could be a configuration property. But this would result in a catalog being able to return data only from a single repository. Alternatively, it can be a column, where every select query would require a predicate for it:

#code-block("sql", "SELECT *
FROM git.default.commits
WHERE url = 'https://github.com/trinodb/trino.git'")

#anchor("ref-connector-metadata")

== ConnectorMetadata

The connector metadata interface allows Trino to get a lists of schemas, tables, columns, and other metadata about a particular data source.

A basic read-only connector should implement the following methods:

- #raw("listSchemaNames")
- #raw("listTables")
- #raw("streamTableColumns")
- #raw("getTableHandle")
- #raw("getTableMetadata")
- #raw("getColumnHandles")
- #raw("getColumnMetadata")

If you are interested in seeing strategies for implementing more methods, look at the example-http and the Cassandra connector. If your underlying data source supports schemas, tables, and columns, this interface should be straightforward to implement. If you are attempting to adapt something that isn't a relational database, as the Example HTTP connector does, you may need to get creative about how you map your data source to Trino's schema, table, and column concepts.

The connector metadata interface allows to also implement other connector features, like:

- Schema management, which is creating, altering and dropping schemas, tables, table columns, views, and materialized views.
- Support for table and column comments, and properties.
- Schema, table and view authorization.
- Executing table-functions.
- Providing table statistics used by the Cost Based Optimizer \(CBO\) and collecting statistics during writes and when analyzing selected tables.
- Data modification, which is:
  
  - inserting, updating, and deleting rows in tables,
  - refreshing materialized views,
  - truncating whole tables,
  - and creating tables from query results.
- Role and grant management.
- Pushing down:
  
  - #link(label("ref-connector-limit-pushdown"))[Limit and Top N - limit with sort items]
  - #link(label("ref-dev-predicate-pushdown"))[Predicates]
  - Projections
  - Sampling
  - Aggregations
  - Joins
  - Table function invocation

Note that data modification also requires implementing a #link(label("ref-connector-page-sink-provider"))[connector-page-sink-provider].

When Trino receives a #raw("SELECT") query, it parses it into an Intermediate Representation \(IR\). Then, during optimization, it checks if connectors can handle operations related to SQL clauses by calling one of the following methods of the #raw("ConnectorMetadata") service:

- #raw("applyLimit")
- #raw("applyTopN")
- #raw("applyFilter")
- #raw("applyProjection")
- #raw("applySample")
- #raw("applyAggregation")
- #raw("applyJoin")
- #raw("applyTableFunction")
- #raw("applyTableScanRedirect")

Connectors can indicate that they don't support a particular pushdown or that the action had no effect by returning #raw("Optional.empty()"). Connectors should expect these methods to be called multiple times during the optimization of a given query.

#warning[
It's critical for connectors to return #raw("Optional.empty()") if calling this method has no effect for that invocation, even if the connector generally supports a particular pushdown. Doing otherwise can cause the optimizer to loop indefinitely.
]

Otherwise, these methods return a result object containing a new table handle. The new table handle represents the virtual table derived from applying the operation \(filter, project, limit, etc.\) to the table produced by the table scan node. Once the query actually runs, #raw("ConnectorRecordSetProvider") or #raw("ConnectorPageSourceProvider") can use whatever optimizations were pushed down to #raw("ConnectorTableHandle").

The returned table handle is later passed to other services that the connector implements, like the #raw("ConnectorRecordSetProvider") or #raw("ConnectorPageSourceProvider").

#anchor("ref-connector-limit-pushdown")

=== Limit and top-N pushdown

When executing a #raw("SELECT") query with #raw("LIMIT") or #raw("ORDER BY") clauses, the query plan may contain a #raw("Sort") or #raw("Limit") operations.

When the plan contains a #raw("Sort") and #raw("Limit") operations, the engine tries to push down the limit into the connector by calling the #raw("applyTopN") method of the connector metadata service. If there's no #raw("Sort") operation, but only a #raw("Limit"), the #raw("applyLimit") method is called, and the connector can return results in an arbitrary order.

If the connector could benefit from the information passed to these methods but can't guarantee that it'd be able to produce fewer rows than the provided limit, it should return a non-empty result containing a new handle for the derived table and the #raw("limitGuaranteed") \(in #raw("LimitApplicationResult")\) or #raw("topNGuaranteed") \(in #raw("TopNApplicationResult")\) flag set to false.

If the connector can guarantee to produce fewer rows than the provided limit, it should return a non-empty result with the "limit guaranteed" or "topN guaranteed" flag set to true.

#note[
The #raw("applyTopN") is the only method that receives sort items from the #raw("Sort") operation.
]

In a query, the #raw("ORDER BY") section can include any column with any order. But the data source for the connector might only support limited combinations. Plugin authors have to decide if the connector should ignore the pushdown, return all the data and let the engine sort it, or throw an exception to inform the user that particular order isn't supported, if fetching all the data would be too expensive or time consuming. When throwing an exception, use the #raw("TrinoException") class with the #raw("INVALID_ORDER_BY") error code and an actionable message, to let users know how to write a valid query.

#anchor("ref-dev-predicate-pushdown")

=== Predicate pushdown

When executing a query with a #raw("WHERE") clause, the query plan can contain a #raw("ScanFilterProject") plan node\/node with a predicate constraint.

A predicate constraint is a description of the constraint imposed on the results of the stage\/fragment as expressed in the #raw("WHERE") clause. For example, #raw("WHERE x > 5 AND y = 3") translates into a constraint where the #raw("summary") field means the #raw("x") column's domain must be greater than #raw("5") and the #raw("y") column domain equals #raw("3").

When the query plan contains a #raw("ScanFilterProject") operation, Trino tries to optimize the query by pushing down the predicate constraint into the connector by calling the #raw("applyFilter") method of the connector metadata service. This method receives a table handle with all optimizations applied thus far, and returns either #raw("Optional.empty()") or a response with a new table handle derived from the old one.

The query optimizer may call #raw("applyFilter") for a single query multiple times, as it searches for an optimal query plan. Connectors must return #raw("Optional.empty()") from #raw("applyFilter") if they cannot apply the constraint for this invocation, even if they support #raw("ScanFilterProject") pushdown in general. Connectors must also return #raw("Optional.empty()") if the constraint has already been applied.

A constraint contains the following elements:

- A #raw("TupleDomain") defining the mapping between columns and their domains. A #raw("Domain") is either a list of possible values, or a list of ranges, and also contains information about nullability.
- Expression for pushing down function calls.
- Map of assignments from variables in the expression to columns.
- \(optional\) Predicate which tests a map of columns and their values; it cannot be held on to after the #raw("applyFilter") call returns.
- \(optional\) Set of columns the predicate depends on; must be present if predicate is present.

If both a predicate and a summary are available, the predicate is guaranteed to be more strict in filtering of values, and can provide a significant boost to query performance if used.

However it is not possible to store a predicate in the table handle and use it later, as the predicate cannot be held on to after the #raw("applyFilter") call returns. It is used for filtering of entire partitions, and is not pushed down. The summary can be pushed down instead by storing it in the table handle.

This overlap between the predicate and summary is due to historical reasons, as simple comparison pushdown was implemented first via summary, and more complex filters such as #raw("LIKE") which required more expressive predicates were added later.

If a constraint can only be partially pushed down, for example when a connector for a database that does not support range matching is used in a query with #raw("WHERE x = 2 AND y > 5"), the #raw("y") column constraint must be returned in the #raw("ConstraintApplicationResult") from #raw("applyFilter"). In this case the #raw("y > 5") condition is applied in Trino, and not pushed down.

The following is a simple example which only looks at #raw("TupleDomain"):

#code-block("java", "@Override
public Optional<ConstraintApplicationResult<ConnectorTableHandle>> applyFilter(
        ConnectorSession session,
        ConnectorTableHandle tableHandle,
        Constraint constraint)
{
    ExampleTableHandle handle = (ExampleTableHandle) tableHandle;

    TupleDomain<ColumnHandle> oldDomain = handle.getConstraint();
    TupleDomain<ColumnHandle> newDomain = oldDomain.intersect(constraint.getSummary());
    if (oldDomain.equals(newDomain)) {
        // Nothing has changed, return empty Option
        return Optional.empty();
    }

    handle = new ExampleTableHandle(newDomain);
    return Optional.of(new ConstraintApplicationResult<>(handle, TupleDomain.all(), false));
}")

The #raw("TupleDomain") from the constraint is intersected with the #raw("TupleDomain") already applied to the #raw("TableHandle") to form #raw("newDomain"). If filtering has not changed, an #raw("Optional.empty()") result is returned to notify the planner that this optimization path has reached its end.

In this example, the connector pushes down the #raw("TupleDomain") with all Trino data types supported with same semantics in the data source. As a result, no filters are needed in Trino, and the #raw("ConstraintApplicationResult") sets #raw("remainingFilter") to #raw("TupleDomain.all()").

This pushdown implementation is quite similar to many Trino connectors, including  #raw("MongoMetadata"), #raw("BigQueryMetadata"), #raw("KafkaMetadata").

The following, more complex example shows data types from Trino that are not available directly in the underlying data source, and must be mapped:

#code-block("java", "@Override
public Optional<ConstraintApplicationResult<ConnectorTableHandle>> applyFilter(
        ConnectorSession session,
        ConnectorTableHandle table,
        Constraint constraint)
{
    JdbcTableHandle handle = (JdbcTableHandle) table;

    TupleDomain<ColumnHandle> oldDomain = handle.getConstraint();
    TupleDomain<ColumnHandle> newDomain = oldDomain.intersect(constraint.getSummary());
    TupleDomain<ColumnHandle> remainingFilter;
    if (newDomain.isNone()) {
        newConstraintExpressions = ImmutableList.of();
        remainingFilter = TupleDomain.all();
        remainingExpression = Optional.of(Constant.TRUE);
    }
    else {
        // We need to decide which columns to push down.
        // Since this is a base class for many JDBC-based connectors, each
        // having different Trino type mappings and comparison semantics
        // it needs to be flexible.

        Map<ColumnHandle, Domain> domains = newDomain.getDomains().orElseThrow();
        List<JdbcColumnHandle> columnHandles = domains.keySet().stream()
                .map(JdbcColumnHandle.class::cast)
                .collect(toImmutableList());

        // Get information about how to push down every column based on its
        // JDBC data type
        List<ColumnMapping> columnMappings = jdbcClient.toColumnMappings(
                session,
                columnHandles.stream()
                        .map(JdbcColumnHandle::getJdbcTypeHandle)
                        .collect(toImmutableList()));

        // Calculate the domains which can be safely pushed down (supported)
        // and those which need to be filtered in Trino (unsupported)
        Map<ColumnHandle, Domain> supported = new HashMap<>();
        Map<ColumnHandle, Domain> unsupported = new HashMap<>();
        for (int i = 0; i < columnHandles.size(); i++) {
            JdbcColumnHandle column = columnHandles.get(i);
            DomainPushdownResult pushdownResult =
                columnMappings.get(i).getPredicatePushdownController().apply(
                    session,
                    domains.get(column));
            supported.put(column, pushdownResult.getPushedDown());
            unsupported.put(column, pushdownResult.getRemainingFilter());
        }

        newDomain = TupleDomain.withColumnDomains(supported);
        remainingFilter = TupleDomain.withColumnDomains(unsupported);
    }

    // Return empty Optional if nothing changed in filtering
    if (oldDomain.equals(newDomain)) {
        return Optional.empty();
    }

    handle = new JdbcTableHandle(
            handle.getRelationHandle(),
            newDomain,
            ...);

    return Optional.of(
            new ConstraintApplicationResult<>(
                handle,
                remainingFilter));
}")

This example illustrates implementing a base class for many JDBC connectors while handling the specific requirements of multiple JDBC-compliant data sources. It ensures that if a constraint gets pushed down, it works exactly the same in the underlying data source, and produces the same results as it would in Trino. For example, in databases where string comparisons are case-insensitive, pushdown does not work, as string comparison operations in Trino are case-sensitive.

The #raw("PredicatePushdownController") interface determines if a column domain can be pushed down in JDBC-compliant data sources. In the preceding example, it is called from a #raw("JdbcClient") implementation specific to that database. In non-JDBC-compliant data sources, type-based push downs are implemented directly, without going through the #raw("PredicatePushdownController") interface.

The following example adds expression pushdown enabled by a session flag:

#code-block("java", "@Override
public Optional<ConstraintApplicationResult<ConnectorTableHandle>> applyFilter(
        ConnectorSession session,
        ConnectorTableHandle table,
        Constraint constraint)
{
    JdbcTableHandle handle = (JdbcTableHandle) table;

    TupleDomain<ColumnHandle> oldDomain = handle.getConstraint();
    TupleDomain<ColumnHandle> newDomain = oldDomain.intersect(constraint.getSummary());
    List<String> newConstraintExpressions;
    TupleDomain<ColumnHandle> remainingFilter;
    Optional<ConnectorExpression> remainingExpression;
    if (newDomain.isNone()) {
        newConstraintExpressions = ImmutableList.of();
        remainingFilter = TupleDomain.all();
        remainingExpression = Optional.of(Constant.TRUE);
    }
    else {
        // We need to decide which columns to push down.
        // Since this is a base class for many JDBC-based connectors, each
        // having different Trino type mappings and comparison semantics
        // it needs to be flexible.

        Map<ColumnHandle, Domain> domains = newDomain.getDomains().orElseThrow();
        List<JdbcColumnHandle> columnHandles = domains.keySet().stream()
                .map(JdbcColumnHandle.class::cast)
                .collect(toImmutableList());

        // Get information about how to push down every column based on its
        // JDBC data type
        List<ColumnMapping> columnMappings = jdbcClient.toColumnMappings(
                session,
                columnHandles.stream()
                        .map(JdbcColumnHandle::getJdbcTypeHandle)
                        .collect(toImmutableList()));

        // Calculate the domains which can be safely pushed down (supported)
        // and those which need to be filtered in Trino (unsupported)
        Map<ColumnHandle, Domain> supported = new HashMap<>();
        Map<ColumnHandle, Domain> unsupported = new HashMap<>();
        for (int i = 0; i < columnHandles.size(); i++) {
            JdbcColumnHandle column = columnHandles.get(i);
            DomainPushdownResult pushdownResult =
                columnMappings.get(i).getPredicatePushdownController().apply(
                    session,
                    domains.get(column));
            supported.put(column, pushdownResult.getPushedDown());
            unsupported.put(column, pushdownResult.getRemainingFilter());
        }

        newDomain = TupleDomain.withColumnDomains(supported);
        remainingFilter = TupleDomain.withColumnDomains(unsupported);

        // Do we want to handle expression pushdown?
        if (isComplexExpressionPushdown(session)) {
            List<String> newExpressions = new ArrayList<>();
            List<ConnectorExpression> remainingExpressions = new ArrayList<>();
            // Each expression can be broken down into a list of conjuncts
            // joined with AND. We handle each conjunct separately.
            for (ConnectorExpression expression : extractConjuncts(constraint.getExpression())) {
                // Try to convert the conjunct into something which is
                // understood by the underlying JDBC data source
                Optional<String> converted = jdbcClient.convertPredicate(
                    session,
                    expression,
                    constraint.getAssignments());
                if (converted.isPresent()) {
                    newExpressions.add(converted.get());
                }
                else {
                    remainingExpressions.add(expression);
                }
            }
            // Calculate which parts of the expression can be pushed down
            // and which need to be calculated in Trino engine
            newConstraintExpressions = ImmutableSet.<String>builder()
                    .addAll(handle.getConstraintExpressions())
                    .addAll(newExpressions)
                    .build().asList();
            remainingExpression = Optional.of(and(remainingExpressions));
        }
        else {
            newConstraintExpressions = ImmutableList.of();
            remainingExpression = Optional.empty();
        }
    }

    // Return empty Optional if nothing changed in filtering
    if (oldDomain.equals(newDomain) &&
            handle.getConstraintExpressions().equals(newConstraintExpressions)) {
        return Optional.empty();
    }

    handle = new JdbcTableHandle(
            handle.getRelationHandle(),
            newDomain,
            newConstraintExpressions,
            ...);

    return Optional.of(
            remainingExpression.isPresent()
                    ? new ConstraintApplicationResult<>(
                        handle,
                        remainingFilter,
                        remainingExpression.get())
                    : new ConstraintApplicationResult<>(
                        handle,
                        remainingFilter));
}")

#raw("ConnectorExpression") is split similarly to #raw("TupleDomain"). Each expression can be broken down into independent #emph[conjuncts]. Conjuncts are smaller expressions which, if joined together using an #raw("AND") operator, are equivalent to the original expression. Every conjunct can be handled individually. Each one is converted using connector-specific rules, as defined by the #raw("JdbcClient") implementation, to be more flexible. Unconverted conjuncts are returned as #raw("remainingExpression") and are evaluated by the Trino engine.

#anchor("ref-connector-split-manager")

== ConnectorSplitManager

The split manager partitions the data for a table into the individual chunks that Trino distributes to workers for processing. For example, the Hive connector lists the files for each Hive partition and creates one or more splits per file. For data sources that don't have partitioned data, a good strategy here is to simply return a single split for the entire table. This is the strategy employed by the Example HTTP connector.

#anchor("ref-connector-record-set-provider")

== ConnectorRecordSetProvider

Given a split, a table handle, and a list of columns, the record set provider is responsible for delivering data to the Trino execution engine.

The table and column handles represent a virtual table. They're created by the connector's metadata service, called by Trino during query planning and optimization. Such a virtual table doesn't have to map directly to a single collection in the connector's data source. If the connector supports pushdowns, there can be multiple virtual tables derived from others, presenting a different view of the underlying data.

The provider creates a #raw("RecordSet"), which in turn creates a #raw("RecordCursor") that's used by Trino to read the column values for each row.

The provided record set must only include requested columns in the order matching the list of column handles passed to the #raw("ConnectorRecordSetProvider.getRecordSet()") method. The record set must return all the rows contained in the "virtual table" represented by the TableHandle associated with the TableScan operation.

For simple connectors, where performance isn't critical, the record set provider can return an instance of #raw("InMemoryRecordSet"). The in-memory record set can be built using lists of values for every row, which can be simpler than implementing a #raw("RecordCursor").

A #raw("RecordCursor") implementation needs to keep track of the current record. It returns values for columns by a numerical position, in the data type matching the column definition in the table. When the engine is done reading the current record it calls #raw("advanceNextPosition") on the cursor.

=== Type mapping

The built-in SQL data types use different Java types as carrier types.

#list-table((
  ([SQL type], [Java type],),
  ([#raw("BOOLEAN")], [#raw("boolean")],),
  ([#raw("TINYINT")], [#raw("long")],),
  ([#raw("SMALLINT")], [#raw("long")],),
  ([#raw("INTEGER")], [#raw("long")],),
  ([#raw("BIGINT")], [#raw("long")],),
  ([#raw("REAL")], [#raw("long")],),
  ([#raw("DOUBLE")], [#raw("double")],),
  ([#raw("DECIMAL")], [#raw("long") for precision up to 19, inclusive; #raw("Int128") for precision greater than 19],),
  ([#raw("VARCHAR")], [#raw("Slice")],),
  ([#raw("CHAR")], [#raw("Slice")],),
  ([#raw("VARBINARY")], [#raw("Slice")],),
  ([#raw("JSON")], [#raw("Slice")],),
  ([#raw("DATE")], [#raw("long")],),
  ([#raw("TIME(P)")], [#raw("long")],),
  ([#raw("TIME WITH TIME ZONE")], [#raw("long") for precision up to 9; #raw("LongTimeWithTimeZone") for precision greater than 9],),
  ([#raw("TIMESTAMP(P)")], [#raw("long") for precision up to 6; #raw("LongTimestamp") for precision greater than 6],),
  ([#raw("TIMESTAMP(P) WITH TIME ZONE")], [#raw("long") for precision up to 3; #raw("LongTimestampWithTimeZone") for precision greater than 3],),
  ([#raw("INTERVAL YEAR TO MONTH")], [#raw("long")],),
  ([#raw("INTERVAL DAY TO SECOND")], [#raw("long")],),
  ([#raw("ARRAY")], [#raw("Block")],),
  ([#raw("MAP")], [#raw("Block")],),
  ([#raw("ROW")], [#raw("Block")],),
  ([#raw("IPADDRESS")], [#raw("Slice")],),
  ([#raw("UUID")], [#raw("Slice")],),
  ([#raw("HyperLogLog")], [#raw("Slice")],),
  ([#raw("P4HyperLogLog")], [#raw("Slice")],),
  ([#raw("SetDigest")], [#raw("Slice")],),
  ([#raw("QDigest")], [#raw("Slice")],),
  ([#raw("TDigest")], [#raw("TDigest")],)
), header-rows: 1, title: "SQL type to carrier type mapping")

The #raw("RecordCursor.getType(int field)") method returns the SQL type for a field and the field value is returned by one of the following methods, matching the carrier type:

- #raw("getBoolean(int field)")
- #raw("getLong(int field)")
- #raw("getDouble(int field)")
- #raw("getSlice(int field)")
- #raw("getObject(int field)")

Values for the #raw("real") type are encoded into #raw("long") using the IEEE 754 floating-point "single format" bit layout, with NaN preservation. This can be accomplished using the #raw("java.lang.Float.floatToRawIntBits") static method.

Values for the #raw("timestamp(p) with time zone") and #raw("time(p) with time zone") types of regular precision can be converted into #raw("long") using static methods from the #raw("io.trino.spi.type.DateTimeEncoding") class, like #raw("pack()") or #raw("packDateTimeWithZone()").

UTF-8 encoded strings can be converted to Slices using the #raw("Slices.utf8Slice()") static method.

#note[
The #raw("Slice") class is provided by the #raw("io.airlift:slice") package.
]

#raw("Int128") objects can be created using the #raw("Int128.valueOf()") method.

The following example creates a block for an #raw("array(varchar)")  column:

#code-block("java", "private Block encodeArray(List<String> names)
{
    BlockBuilder builder = VARCHAR.createBlockBuilder(null, names.size());
    blockBuilder.buildEntry(elementBuilder -> names.forEach(name -> {
        if (name == null) {
            elementBuilder.appendNull();
        }
        else {
            VARCHAR.writeString(elementBuilder, name);
        }
    }));
    return builder.build();
}")

The following example creates a SqlMap object for a #raw("map(varchar, varchar)") column:

#code-block("java", "private SqlMap encodeMap(Map<String, ?> map)
{
    MapType mapType = typeManager.getType(TypeDescriptor.mapType(
                            VARCHAR.getTypeDescriptor(),
                            VARCHAR.getTypeDescriptor()));
    MapBlockBuilder values = mapType.createBlockBuilder(null, map != null ? map.size() : 0);
    if (map == null) {
        values.appendNull();
        return values.build().getObject(0, Block.class);
    }
    values.buildEntry((keyBuilder, valueBuilder) -> map.foreach((key, value) -> {
        VARCHAR.writeString(keyBuilder, key);
        if (value == null) {
            valueBuilder.appendNull();
        }
        else {
            VARCHAR.writeString(valueBuilder, value.toString());
        }
    }));
    return values.build().getObject(0, SqlMap.class);
}")

#anchor("ref-connector-page-source-provider")

== ConnectorPageSourceProvider

Given a split, a table handle, and a list of columns, the page source provider is responsible for delivering data to the Trino execution engine. It creates a #raw("ConnectorPageSource"), which in turn creates #raw("Page") objects that are used by Trino to read the column values.

If not implemented, a default #raw("RecordPageSourceProvider") is used. Given a record set provider, it returns an instance of #raw("RecordPageSource") that builds #raw("Page") objects from records in a record set.

A connector should implement a page source provider instead of a record set provider when it's possible to create pages directly. The conversion of individual records from a record set provider into pages adds overheads during query execution.

#anchor("ref-connector-page-sink-provider")

== ConnectorPageSinkProvider

Given an insert table handle, the page sink provider is responsible for consuming data from the Trino execution engine. It creates a #raw("ConnectorPageSink"), which in turn accepts #raw("Page") objects that contains the column values.

Example that shows how to iterate over the page to access single values:

#code-block("java", "@Override
public CompletableFuture<?> appendPage(Page page)
{
    for (int channel = 0; channel < page.getChannelCount(); channel++) {
        Block block = page.getBlock(channel);
        for (int position = 0; position < page.getPositionCount(); position++) {
            if (block.isNull(position)) {
                // or handle this differently
                continue;
            }

            // channel should match the column number in the table
            // use it to determine the expected column type
            String value = VARCHAR.getSlice(block, position).toStringUtf8();
            // TODO do something with the value
        }
    }
    return NOT_BLOCKED;
}")

#note[
When packaging the connector with Trino as a new dependency, register the artifact in #raw("core/trino-server/src/main/provisio/trino.xml")
]
