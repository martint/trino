#import "/lib/trino-docs.typ": *

#anchor("doc-sql-update")
= UPDATE

== Synopsis

#code-block("text", "UPDATE table_name [ @ branch_name ]
SET [ ( column = expression [, ... ] ) ] [ WHERE condition ]")

== Description

Update selected columns values in existing rows in a table.

The columns named in the #raw("column = expression") assignments will be updated for all rows that match the #raw("WHERE") condition.  The values of all column update expressions for a matching row are evaluated before any column value is changed. When the type of the expression and the type of the column differ, the usual implicit CASTs, such as widening numeric fields, are applied to the #raw("UPDATE") expression values.

== Examples

Update the status of all purchases that haven't been assigned a ship date:

#code-block(none, "UPDATE
  purchases
SET
  status = 'OVERDUE'
WHERE
  ship_date IS NULL;")

Update the account manager and account assign date for all customers:

#code-block(none, "UPDATE
  customers
SET
  account_manager = 'John Henry',
  assign_date = now();")

Update the manager to be the name of the employee who matches the manager ID:

#code-block(none, "UPDATE
  new_hires
SET
  manager = (
    SELECT
      e.name
    FROM
      employees e
    WHERE
      e.employee_id = new_hires.manager_id
  );")

Update the status of all purchases that haven't been assigned a ship date in the #raw("audit") branch:

#code-block("sql", "UPDATE
  purchases @ audit
SET
  status = 'OVERDUE'
WHERE
  ship_date IS NULL;")

== Limitations

Some connectors have limited or no support for #raw("UPDATE"). See connector documentation for more details.
