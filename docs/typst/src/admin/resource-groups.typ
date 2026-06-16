#import "/lib/trino-docs.typ": *

#anchor("doc-admin-resource-groups")
= Resource groups

Resource groups place limits on resource usage, and can enforce queueing policies on queries that run within them, or divide their resources among sub-groups. A query belongs to a single resource group, and consumes resources from that group \(and its ancestors\). Except for the limit on queued queries, when a resource group runs out of a resource it does not cause running queries to fail; instead new queries become queued. A resource group may have sub-groups or may accept queries, but may not do both.

The resource groups and associated selection rules are configured by a manager, which is pluggable.

You can use a file-based or a database-based resource group manager:

- Add a file #raw("etc/resource-groups.properties")
- Set the #raw("resource-groups.configuration-manager") property to #raw("file") or #raw("db")
- Add further configuration properties for the desired manager.

== File resource group manager

The file resource group manager reads a JSON configuration file, specified with #raw("resource-groups.config-file"):

#code-block("text", "resource-groups.configuration-manager=file
resource-groups.config-file=etc/resource-groups.json")

The path to the JSON file can be an absolute path, or a path relative to the Trino data directory. The JSON file only needs to be present on the coordinator.

#anchor("ref-db-resource-group-manager")

== Database resource group manager

The database resource group manager loads the configuration from a relational database. The supported databases are MySQL, PostgreSQL, and Oracle.

#code-block("text", "resource-groups.configuration-manager=db
resource-groups.config-db-url=jdbc:mysql://localhost:3306/resource_groups
resource-groups.config-db-user=username
resource-groups.config-db-password=password")

The resource group configuration must be populated through tables #raw("resource_groups_global_properties"), #raw("resource_groups"), and #raw("selectors"). If any of the tables do not exist when Trino starts, they will be created automatically.

The rules in the #raw("selectors") table are processed in descending order of the values in the #raw("priority") field.

The #raw("resource_groups") table also contains an #raw("environment") field which is matched with the value contained in the #raw("node.environment") property in #link(label("ref-node-properties"))[node-properties]. This allows the resource group configuration for different Trino clusters to be stored in the same database if required.

The configuration is reloaded from the database every second, and the changes are reflected automatically for incoming queries.

#list-table((
  ([Property name], [Description], [Default value],),
  ([#raw("resource-groups.config-db-url")], [Database URL to load configuration from.], [#raw("none")],),
  ([#raw("resource-groups.config-db-user")], [Database user to connect with.], [#raw("none")],),
  ([#raw("resource-groups.config-db-password")], [Password for database user to connect with.], [#raw("none")],),
  ([#raw("resource-groups.max-refresh-interval")], [The maximum time period for which the cluster will continue to accept queries after refresh failures, causing configuration to become stale.], [#raw("1h")],),
  ([#raw("resource-groups.refresh-interval")], [How often the cluster reloads from the database], [#raw("1s")],),
  ([#raw("resource-groups.exact-match-selector-enabled")], [Setting this flag enables usage of an additional #raw("exact_match_source_selectors") table to configure resource group selection rules defined exact name based matches for source, environment and query type. By default, the rules are only loaded from the #raw("selectors") table, with a regex-based filter for #raw("source"), among other filters.], [#raw("false")],)
), header-rows: 1, title: "Database resource group manager properties")

== Resource group properties

- #raw("name") \(required\): name of the group. May be a template \(see below\).
- #raw("maxQueued") \(required\): maximum number of queued queries. Once this limit is reached new queries are rejected.
- #raw("softConcurrencyLimit") \(optional\): number of concurrently running queries after which new queries will only run if all peer resource groups below their soft limits are ineligible or if all eligible peers are above soft limits.
- #raw("hardConcurrencyLimit") \(required\): maximum number of running queries.
- #raw("softMemoryLimit") \(optional\): maximum amount of distributed memory this group may use, before new queries become queued. May be specified as an absolute value \(i.e. #raw("1GB")\) or as a percentage \(i.e. #raw("10%")\) of the cluster's memory.
- #raw("softCpuLimit") \(optional\): maximum amount of CPU time this group may use in a period \(see #raw("cpuQuotaPeriod")\), before a penalty is applied to the maximum number of running queries. #raw("hardCpuLimit") must also be specified.
- #raw("hardCpuLimit") \(optional\): maximum amount of CPU time this group may use in a period.
- #raw("hardPhysicalDataScanLimit") \(optional\): maximum amount of data this group can scan in a period before new queries become queued. Must be specified as an absolute value \(i.e. #raw("1GB")\).
- #raw("schedulingPolicy") \(optional\): specifies how queued queries are selected to run, and how sub-groups become eligible to start their queries. May be one of three values:
  
  - #raw("fair") \(default\): queued queries are processed first-in-first-out, and sub-groups must take turns starting new queries, if they have any queued.
  - #raw("weighted_fair"): sub-groups are selected based on their #raw("schedulingWeight") and the number of queries they are already running concurrently. The expected share of running queries for a sub-group is computed based on the weights for all currently eligible sub-groups. The sub-group with the least concurrency relative to its share is selected to start the next query.
  - #raw("weighted"): queued queries are selected stochastically in proportion to their priority, specified via the #raw("query_priority") #link(label("doc-sql-set-session"))[session property]. Sub groups are selected to start new queries in proportion to their #raw("schedulingWeight").
  - #raw("query_priority"): all sub-groups must also be configured with #raw("query_priority"). Queued queries are selected strictly according to their priority.
- #raw("schedulingWeight") \(optional\): weight of this sub-group used in #raw("weighted") and the #raw("weighted_fair") scheduling policy. Defaults to #raw("1"). See #link(label("ref-scheduleweight-example"))[scheduleweight-example].
- #raw("jmxExport") \(optional\): If true, group statistics are exported to JMX for monitoring. Defaults to #raw("false").
- #raw("subGroups") \(optional\): list of sub-groups.

#anchor("ref-scheduleweight-example")

=== Scheduling weight example

Schedule weighting is a method of assigning a priority to a resource. Sub-groups with a higher scheduling weight are given higher priority. For example, to ensure timely execution of scheduled pipelines queries, weight them higher than adhoc queries.

In the following example, pipeline queries are weighted with a value of #raw("350"), which is higher than the adhoc queries that have a scheduling weight of #raw("150"). This means that approximately 70% \(350 out of 500 queries\) of your queries come from the pipeline sub-group, and 30% \(150 out of 500 queries\) come from the adhoc sub-group in a given timeframe. Alternatively, if you set each sub-group value to #raw("1"), the weight of the queries for the pipeline and adhoc sub-groups are split evenly and each receive 50% of the queries in a given timeframe.

#code-block("text", "{
  {
    \"name\": \"pipeline\",
    \"schedulingWeight\": 350,
  },
  {
    \"name\": \"adhoc\",
    \"schedulingWeight\": 150
  }
}")

== Selector rules

The selector rules for pattern matching use Java's regular expression capabilities. Java implements regular expressions through the #raw("java.util.regex") package. For more information, see the #link("https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/regex/Pattern.html")[Java documentation].

- #raw("user") \(optional\): Java regex to match against username.
- #raw("originalUser") \(optional\): Java regex to match against the #emph[original] username, i.e. before any changes to the session user. For example, if user "foo" runs #raw("SET SESSION AUTHORIZATION 'bar'"), #raw("originalUser") is "foo", while #raw("user") is "bar".
- #raw("authenticatedUser") \(optional\): Java regex to match against the #emph[authenticated] username, which will always refer to the user that authenticated with the system, regardless of any changes made to the session user.
- #raw("userGroup") \(optional\): Java regex to match against every user group the user belongs to.
- #raw("source") \(optional\): Java regex to match against source string.
- #raw("queryText") \(optional\): regex to match against the SQL query string.
- #raw("queryType") \(optional\): string to match against the type of the query submitted:
  
  - #raw("SELECT"): #link(label("doc-sql-select"))[SELECT] queries.
  - #raw("EXPLAIN"): #link(label("doc-sql-explain"))[EXPLAIN] queries, but not #link(label("doc-sql-explain-analyze"))[EXPLAIN ANALYZE] queries.
  - #raw("DESCRIBE"): #link(label("doc-sql-describe"))[DESCRIBE], #link(label("doc-sql-describe-input"))[DESCRIBE INPUT], #link(label("doc-sql-describe-output"))[DESCRIBE OUTPUT], and #raw("SHOW") queries such as #link(label("doc-sql-show-catalogs"))[SHOW CATALOGS], #link(label("doc-sql-show-schemas"))[SHOW SCHEMAS], and #link(label("doc-sql-show-tables"))[SHOW TABLES].
  - #raw("INSERT"): #link(label("doc-sql-insert"))[INSERT], #link(label("doc-sql-create-table-as"))[CREATE TABLE AS], and #link(label("doc-sql-refresh-materialized-view"))[REFRESH MATERIALIZED VIEW] queries.
  - #raw("UPDATE"): #link(label("doc-sql-update"))[UPDATE] queries.
  - #raw("MERGE"): #link(label("doc-sql-merge"))[MERGE] queries.
  - #raw("DELETE"): #link(label("doc-sql-delete"))[DELETE] queries.
  - #raw("ANALYZE"): #link(label("doc-sql-analyze"))[ANALYZE] queries.
  - #raw("DATA_DEFINITION"): Queries that affect the data definition. These include #raw("CREATE"), #raw("ALTER"), and #raw("DROP") statements for schemas, tables, views, and materialized views, as well as statements that manage prepared statements, privileges, sessions, and transactions. When external clients need access to the #raw("system.runtime.kill_query()") procedure to stop running or queued queries, this #raw("queryType") must be used to make sure the #raw("kill_query()") is executed directly and isn't queued to wait for the initial query to finish.
  - #raw("ALTER_TABLE_EXECUTE"): Queries that execute table procedures with #link(label("ref-alter-table-execute"))[ALTER TABLE EXECUTE].
- #raw("clientTags") \(optional\): list of tags. To match, every tag in this list must be in the list of client-provided tags associated with the query.
- #raw("group") \(required\): the group these queries will run in.

All rules within a single selector are combined using a logical #raw("AND"). Therefore all rules must match for a selector to be applied.

Selectors are processed sequentially and the first one that matches will be used.

== Global properties

- #raw("cpuQuotaPeriod") \(optional\): the period in which cpu quotas are enforced.
- #raw("physicalDataScanQuotaPeriod") \(optional\): the period in which physical data scan quotas are enforced.

== Providing selector properties

The source name can be set as follows:

- CLI: use the #raw("--source") option.
- JDBC driver when used in client apps: add the #raw("source") property to the connection configuration and set the value when using a Java application that uses the JDBC Driver.
- JDBC driver used with Java programs: add a property with the key #raw("source") and the value on the #raw("Connection") instance as shown in #link(label("ref-jdbc-java-connection"))[the example].

Client tags can be set as follows:

- CLI: use the #raw("--client-tags") option.
- JDBC driver when used in client apps: add the #raw("clientTags") property to the connection configuration and set the value when using a Java application that uses the JDBC Driver.
- JDBC driver used with Java programs: add a property with the key #raw("clientTags") and the value on the #raw("Connection") instance as shown in #link(label("ref-jdbc-parameter-reference"))[the example].

== Example

In the example configuration below, there are several resource groups, some of which are templates. Templates allow administrators to construct resource group trees dynamically. For example, in the #raw("pipeline_${USER}") group, #raw("${USER}") is expanded to the name of the user that submitted the query. #raw("${SOURCE}") is also supported, which is expanded to the source that submitted the query. You may also use custom named variables in the regular expressions for #raw("user"), #raw("source"), #raw("originalUser"), #raw("authenticatedUser") and #raw("queryText").

There are six selectors, that define which queries run in which resource group:

- The first selector matches queries from #raw("bob") and places them in the admin group.
- The next selector matches queries with an #emph[original] user of #raw("bob") and places them in the admin group.
- The next selector matches queries with an #emph[authenticated] user of #raw("bob") and places them in the admin group.
- The next selector matches queries from #raw("admin") user group and places them in the admin group.
- The next selector matches all data definition \(DDL\) queries from a source name that includes #raw("pipeline") and places them in the #raw("global.data_definition") group. This could help reduce queue times for this class of queries, since they are expected to be fast.
- The next selector matches queries from a source name that includes #raw("pipeline"), and places them in a dynamically-created per-user pipeline group under the #raw("global.pipeline") group.
- The next selector matches queries that come from BI tools which have a source matching the regular expression #raw("jdbc#(?<toolname>.*)") and have client provided tags that are a superset of #raw("hipri"). These are placed in a dynamically-created sub-group under the #raw("global.adhoc") group. The dynamic sub-groups are created based on the values of named variables #raw("toolname") and #raw("user"). The values are derived from the source regular expression and the query user respectively. Consider a query with a source #raw("jdbc#powerfulbi"), user #raw("kayla"), and client tags #raw("hipri") and #raw("fast"). This query is routed to the #raw("global.adhoc.bi-powerfulbi.kayla") resource group.
- The last selector is a catch-all, which places all queries that have not yet been matched into a per-user adhoc group.

Together, these selectors implement the following policy:

- The user #raw("bob") and any user belonging to user group #raw("admin") is an admin and can run up to 50 concurrent queries. #raw("bob") will be treated as an admin even if they have changed their session user to a different user \(i.e. via a #raw("SET SESSION AUTHORIZATION") statement or the #raw("X-Trino-User") request header\). Queries will be run based on user-provided priority.

For the remaining users:

- No more than 100 total queries may run concurrently.
- Up to 5 concurrent DDL queries with a source #raw("pipeline") can run. Queries are run in FIFO order.
- Non-DDL queries will run under the #raw("global.pipeline") group, with a total concurrency of 45, and a per-user concurrency of 5. Queries are run in FIFO order.
- For BI tools, each tool can run up to 10 concurrent queries, and each user can run up to 3. If the total demand exceeds the limit of 10, the user with the fewest running queries gets the next concurrency slot. This policy results in fairness when under contention.
- All remaining queries are placed into a per-user group under #raw("global.adhoc.other") that behaves similarly.

=== File resource group manager

#code-block("json", "{
  \"rootGroups\": [
    {
      \"name\": \"global\",
      \"softMemoryLimit\": \"80%\",
      \"hardPhysicalDataScanLimit\": \"50TB\",
      \"hardConcurrencyLimit\": 100,
      \"maxQueued\": 1000,
      \"schedulingPolicy\": \"weighted\",
      \"jmxExport\": true,
      \"subGroups\": [
        {
          \"name\": \"data_definition\",
          \"softMemoryLimit\": \"10%\",
          \"hardConcurrencyLimit\": 5,
          \"maxQueued\": 100,
          \"schedulingWeight\": 1
        },
        {
          \"name\": \"adhoc\",
          \"softMemoryLimit\": \"10%\",
          \"hardConcurrencyLimit\": 50,
          \"maxQueued\": 1,
          \"schedulingWeight\": 10,
          \"subGroups\": [
            {
              \"name\": \"other\",
              \"softMemoryLimit\": \"10%\",
              \"hardConcurrencyLimit\": 2,
              \"maxQueued\": 1,
              \"schedulingWeight\": 10,
              \"schedulingPolicy\": \"weighted_fair\",
              \"subGroups\": [
                {
                  \"name\": \"${USER}\",
                  \"softMemoryLimit\": \"10%\",
                  \"hardConcurrencyLimit\": 1,
                  \"maxQueued\": 100,
                  \"hardPhysicalDataScanLimit\": \"10GB\"
                }
              ]
            },
            {
              \"name\": \"bi-${toolname}\",
              \"softMemoryLimit\": \"10%\",
              \"hardConcurrencyLimit\": 10,
              \"maxQueued\": 100,
              \"schedulingWeight\": 10,
              \"schedulingPolicy\": \"weighted_fair\",
              \"subGroups\": [
                {
                  \"name\": \"${USER}\",
                  \"softMemoryLimit\": \"10%\",
                  \"hardConcurrencyLimit\": 3,
                  \"maxQueued\": 10
                }
              ]
            }
          ]
        },
        {
          \"name\": \"pipeline\",
          \"softMemoryLimit\": \"80%\",
          \"hardConcurrencyLimit\": 45,
          \"maxQueued\": 100,
          \"schedulingWeight\": 1,
          \"jmxExport\": true,
          \"subGroups\": [
            {
              \"name\": \"pipeline_${USER}\",
              \"softMemoryLimit\": \"50%\",
              \"hardConcurrencyLimit\": 5,
              \"maxQueued\": 100
            }
          ]
        }
      ]
    },
    {
      \"name\": \"admin\",
      \"softMemoryLimit\": \"100%\",
      \"hardConcurrencyLimit\": 50,
      \"maxQueued\": 100,
      \"schedulingPolicy\": \"query_priority\",
      \"jmxExport\": true
    }
  ],
  \"selectors\": [
    {
      \"user\": \"bob\",
      \"group\": \"admin\"
    },
    {
      \"originalUser\": \"bob\",
      \"group\": \"admin\"
    },
    {
      \"authenticatedUser\": \"bob\",
      \"group\": \"admin\"
    },
    {
      \"userGroup\": \"admin\",
      \"group\": \"admin\"
    },
    {
      \"source\": \".*pipeline.*\",
      \"queryType\": \"DATA_DEFINITION\",
      \"group\": \"global.data_definition\"
    },
    {
      \"source\": \".*pipeline.*\",
      \"group\": \"global.pipeline.pipeline_${USER}\"
    },
    {
      \"source\": \"jdbc#(?<toolname>.*)\",
      \"clientTags\": [\"hipri\"],
      \"group\": \"global.adhoc.bi-${toolname}.${USER}\"
    },
    {
      \"group\": \"global.adhoc.other.${USER}\"
    }
  ],
  \"cpuQuotaPeriod\": \"1h\",
  \"physicalDataScanQuotaPeriod\": \"1h\"
}")

=== Database resource group manager

This example is for a MySQL database.

#code-block("sql", "-- global properties
INSERT INTO resource_groups_global_properties (name, value) VALUES ('cpu_quota_period', '1h');

-- Every row in resource_groups table indicates a resource group.
-- The enviroment name is 'test_environment', make sure it matches `node.environment` in your cluster.
-- The parent-child relationship is indicated by the ID in 'parent' column.

-- create a root group 'global' with NULL parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_physical_data_scan_limit, hard_concurrency_limit, max_queued, scheduling_policy, jmx_export, environment) VALUES ('global', '80%', '50TB', 100, 1000, 'weighted', true, 'test_environment');

-- get ID of 'global' group
SELECT resource_group_id FROM resource_groups WHERE name = 'global';  -- 1
-- create two new groups with 'global' as parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued, scheduling_weight, environment, parent) VALUES ('data_definition', '10%', 5, 100, 1, 'test_environment', 1);
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued, scheduling_weight, environment, parent) VALUES ('adhoc', '10%', 50, 1, 10, 'test_environment', 1);

-- get ID of 'adhoc' group
SELECT resource_group_id FROM resource_groups WHERE name = 'adhoc';   -- 3
-- create 'other' group with 'adhoc' as parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued, scheduling_weight, scheduling_policy, environment, parent) VALUES ('other', '10%', 2, 1, 10, 'weighted_fair', 'test_environment', 3);

-- get ID of 'other' group
SELECT resource_group_id FROM resource_groups WHERE name = 'other';  -- 4
-- create '${USER}' group with 'other' as parent.
INSERT INTO resource_groups (name, soft_memory_limit, hard_physical_data_scan_limit, hard_concurrency_limit, max_queued, environment, parent) VALUES ('${USER}', '10%', '10GB', 1, 100, 'test_environment', 4);

-- create 'bi-${toolname}' group with 'adhoc' as parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued, scheduling_weight, scheduling_policy, environment, parent) VALUES ('bi-${toolname}', '10%', 10, 100, 10, 'weighted_fair', 'test_environment', 3);

-- get ID of 'bi-${toolname}' group
SELECT resource_group_id FROM resource_groups WHERE name = 'bi-${toolname}';  -- 6
-- create '${USER}' group with 'bi-${toolname}' as parent. This indicates
-- nested group 'global.adhoc.bi-${toolname}.${USER}', and will have a
-- different ID than 'global.adhoc.other.${USER}' created above.
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued,  environment, parent) VALUES ('${USER}', '10%', 3, 10, 'test_environment', 6);

-- create 'pipeline' group with 'global' as parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued, scheduling_weight, jmx_export, environment, parent) VALUES ('pipeline', '80%', 45, 100, 1, true, 'test_environment', 1);

-- get ID of 'pipeline' group
SELECT resource_group_id FROM resource_groups WHERE name = 'pipeline'; -- 8
-- create 'pipeline_${USER}' group with 'pipeline' as parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued,  environment, parent) VALUES ('pipeline_${USER}', '50%', 5, 100, 'test_environment', 8);

-- create a root group 'admin' with NULL parent
INSERT INTO resource_groups (name, soft_memory_limit, hard_concurrency_limit, max_queued, scheduling_policy, environment, jmx_export) VALUES ('admin', '100%', 50, 100, 'query_priority', 'test_environment', true);


-- Selectors

-- use ID of 'admin' resource group for selector
INSERT INTO selectors (resource_group_id, user_regex, priority) VALUES ((SELECT resource_group_id FROM resource_groups WHERE name = 'admin'), 'bob', 6);

-- use ID of 'admin' resource group for selector
INSERT INTO selectors (resource_group_id, user_group_regex, priority) VALUES ((SELECT resource_group_id FROM resource_groups WHERE name = 'admin'), 'admin', 5);

-- use ID of 'global.data_definition' resource group for selector
INSERT INTO selectors (resource_group_id, source_regex, query_type, priority) VALUES ((SELECT resource_group_id FROM resource_groups WHERE name = 'data_definition'), '.*pipeline.*', 'DATA_DEFINITION', 4);

-- use ID of 'global.pipeline.pipeline_${USER}' resource group for selector
INSERT INTO selectors (resource_group_id, source_regex, priority) VALUES ((SELECT resource_group_id FROM resource_groups WHERE name = 'pipeline_${USER}'), '.*pipeline.*', 3);

-- get ID of 'global.adhoc.bi-${toolname}.${USER}' resource group by disambiguating group name using parent ID
SELECT A.resource_group_id self_id, B.resource_group_id parent_id, concat(B.name, '.', A.name) name_with_parent
FROM resource_groups A JOIN resource_groups B ON A.parent = B.resource_group_id
WHERE A.name = '${USER}' AND B.name = 'bi-${toolname}';
--  7 |         6 | bi-${toolname}.${USER}
INSERT INTO selectors (resource_group_id, source_regex, client_tags, priority) VALUES (7, 'jdbc#(?<toolname>.*)', '[\"hipri\"]', 2);

-- get ID of 'global.adhoc.other.${USER}' resource group for by disambiguating group name using parent ID
SELECT A.resource_group_id self_id, B.resource_group_id parent_id, concat(B.name, '.', A.name) name_with_parent
FROM resource_groups A JOIN resource_groups B ON A.parent = B.resource_group_id
WHERE A.name = '${USER}' AND B.name = 'other';
-- |       5 |         4 | other.${USER}    |
INSERT INTO selectors (resource_group_id, priority) VALUES (5, 1);")
