#import "/lib/trino-docs.typ": *

#anchor("doc-sql-alter-table")
= ALTER TABLE

== Synopsis

#code-block("text", "ALTER TABLE [ IF EXISTS ] name RENAME TO new_name
ALTER TABLE [ IF EXISTS ] name ADD COLUMN [ IF NOT EXISTS ] column_name data_type
  [ DEFAULT default ] [ NOT NULL ] [ COMMENT comment ]
  [ WITH ( property_name = expression [, ...] ) ]
  [ FIRST | LAST | AFTER after_column_name ]
ALTER TABLE [ IF EXISTS ] name DROP COLUMN [ IF EXISTS ] column_name
ALTER TABLE [ IF EXISTS ] name RENAME COLUMN [ IF EXISTS ] old_name TO new_name
ALTER TABLE [ IF EXISTS ] name ALTER COLUMN column_name SET DEFAULT expression
ALTER TABLE [ IF EXISTS ] name ALTER COLUMN column_name DROP DEFAULT
ALTER TABLE [ IF EXISTS ] name ALTER COLUMN column_name SET DATA TYPE new_type
ALTER TABLE [ IF EXISTS ] name ALTER COLUMN column_name DROP NOT NULL
ALTER TABLE name SET AUTHORIZATION ( user | USER user | ROLE role )
ALTER TABLE name SET PROPERTIES property_name = expression [, ...]
ALTER TABLE name EXECUTE command [ ( parameter => expression [, ... ] ) ]
    [ WHERE expression ]")

== Description

Change the definition of an existing table.

The optional #raw("IF EXISTS") clause, when used before the table name, causes the error to be suppressed if the table does not exist.

The optional #raw("IF EXISTS") clause, when used before the column name, causes the error to be suppressed if the column does not exist.

The optional #raw("IF NOT EXISTS") clause causes the error to be suppressed if the column already exists.

#anchor("ref-alter-table-set-properties")

=== SET PROPERTIES

The #raw("ALTER TABLE SET PROPERTIES")  statement followed by a number of #raw("property_name") and #raw("expression") pairs applies the specified properties and values to a table. Omitting an already-set property from this statement leaves that property unchanged in the table.

A property in a #raw("SET PROPERTIES") statement can be set to #raw("DEFAULT"), which reverts its value back to the default in that table.

Support for #raw("ALTER TABLE SET PROPERTIES") varies between connectors, as not all connectors support modifying table properties.

#anchor("ref-alter-table-execute")

=== EXECUTE

The #raw("ALTER TABLE EXECUTE") statement followed by a #raw("command") and #raw("parameters") modifies the table according to the specified command and parameters. #raw("ALTER TABLE EXECUTE") supports different commands on a per-connector basis.

You can use the #raw("=>") operator for passing named parameter values. The left side is the name of the parameter, the right side is the value being passed.

Executable commands are contributed by connectors, such as the #raw("optimize") command provided by the #link(label("ref-hive-alter-table-execute"))[Hive], #link(label("ref-delta-lake-alter-table-execute"))[Delta Lake], and #link(label("ref-iceberg-alter-table-execute"))[Iceberg] connectors. For example, a user observing many small files in the storage of a table called #raw("test_table") in the #raw("test") schema of the #raw("example") catalog, can use the #raw("optimize") command to merge all files below the #raw("file_size_threshold") value. The result is fewer, but larger files, which typically results in higher query performance on the data in the files:

#code-block(none, "ALTER TABLE example.test.test_table EXECUTE optimize(file_size_threshold => '16MB')")

== Examples

Rename table #raw("users") to #raw("people"):

#code-block(none, "ALTER TABLE users RENAME TO people;")

Rename table #raw("users") to #raw("people") if table #raw("users") exists:

#code-block(none, "ALTER TABLE IF EXISTS users RENAME TO people;")

Add column #raw("zip") to the #raw("users") table:

#code-block(none, "ALTER TABLE users ADD COLUMN zip varchar;")

Add column #raw("zip") to the #raw("users") table with default value of #raw("90210"):

#code-block("sql", "ALTER TABLE users ADD COLUMN zip varchar DEFAULT '90210';")

Add column #raw("zip") to the #raw("users") table if table #raw("users") exists and column #raw("zip") not already exists:

#code-block(none, "ALTER TABLE IF EXISTS users ADD COLUMN IF NOT EXISTS zip varchar;")

Add column #raw("id") as the first column to the #raw("users") table:

#code-block(none, "ALTER TABLE users ADD COLUMN id varchar FIRST;")

Add column #raw("zip") after column #raw("country") to the #raw("users") table:

#code-block(none, "ALTER TABLE users ADD COLUMN zip varchar AFTER country;")

Drop column #raw("zip") from the #raw("users") table:

#code-block(none, "ALTER TABLE users DROP COLUMN zip;")

Drop column #raw("zip") from the #raw("users") table if table #raw("users") and column #raw("zip") exists:

#code-block(none, "ALTER TABLE IF EXISTS users DROP COLUMN IF EXISTS zip;")

Rename column #raw("id") to #raw("user_id") in the #raw("users") table:

#code-block(none, "ALTER TABLE users RENAME COLUMN id TO user_id;")

Rename column #raw("id") to #raw("user_id") in the #raw("users") table if table #raw("users") and column #raw("id") exists:

#code-block(none, "ALTER TABLE IF EXISTS users RENAME column IF EXISTS id to user_id;")

Change type of column #raw("id") to #raw("bigint") in the #raw("users") table:

#code-block(none, "ALTER TABLE users ALTER COLUMN id SET DATA TYPE bigint;")

Drop a not null constraint on #raw("id") column in the #raw("users") table:

#code-block(none, "ALTER TABLE users ALTER COLUMN id DROP NOT NULL;")

Change owner of table #raw("people") to user #raw("alice"):

#code-block(none, "ALTER TABLE people SET AUTHORIZATION alice")

Allow everyone with role public to drop and alter table #raw("people"):

#code-block(none, "ALTER TABLE people SET AUTHORIZATION ROLE PUBLIC")

Set table properties \(#raw("x = y")\) in table #raw("people"):

#code-block(none, "ALTER TABLE people SET PROPERTIES x = 'y';")

Set multiple table properties \(#raw("foo = 123") and #raw("foo bar = 456")\) in table #raw("people"):

#code-block(none, "ALTER TABLE people SET PROPERTIES foo = 123, \"foo bar\" = 456;")

Set table property #raw("x") to its default value in table\`\`people\`\`:

#code-block(none, "ALTER TABLE people SET PROPERTIES x = DEFAULT;")

== See also

create-table
