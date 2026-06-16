#import "/lib/trino-docs.typ": *

#anchor("doc-functions-datetime")
= Date and time functions and operators

These functions and operators operate on #link(label("ref-date-time-data-types"))[date and time data types].

== Date and time operators

#list-table((
  ([Operator], [Example], [Result],),
  ([#raw("+")], [#raw("date '2012-08-08' + interval '2' day")], [#raw("2012-08-10")],),
  ([#raw("+")], [#raw("time '01:00' + interval '3' hour")], [#raw("04:00:00.000")],),
  ([#raw("+")], [#raw("timestamp '2012-08-08 01:00' + interval '29' hour")], [#raw("2012-08-09 06:00:00.000")],),
  ([#raw("+")], [#raw("timestamp '2012-10-31 01:00' + interval '1' month")], [#raw("2012-11-30 01:00:00.000")],),
  ([#raw("+")], [#raw("interval '2' day + interval '3' hour")], [#raw("2 03:00:00.000")],),
  ([#raw("+")], [#raw("interval '3' year + interval '5' month")], [#raw("3-5")],),
  ([#raw("-")], [#raw("date '2012-08-08' - interval '2' day")], [#raw("2012-08-06")],),
  ([#raw("-")], [#raw("time '01:00' - interval '3' hour")], [#raw("22:00:00.000")],),
  ([#raw("-")], [#raw("timestamp '2012-08-08 01:00' - interval '29' hour")], [#raw("2012-08-06 20:00:00.000")],),
  ([#raw("-")], [#raw("timestamp '2012-10-31 01:00' - interval '1' month")], [#raw("2012-09-30 01:00:00.000")],),
  ([#raw("-")], [#raw("interval '2' day - interval '3' hour")], [#raw("1 21:00:00.000")],),
  ([#raw("-")], [#raw("interval '3' year - interval '5' month")], [#raw("2-7")],)
), header-rows: 1)

#anchor("ref-at-time-zone-operator")

== Time zone conversion

The #raw("AT TIME ZONE") operator sets the time zone of a timestamp:

#code-block(none, "SELECT timestamp '2012-10-31 01:00 UTC';
-- 2012-10-31 01:00:00.000 UTC

SELECT timestamp '2012-10-31 01:00 UTC' AT TIME ZONE 'America/Los_Angeles';
-- 2012-10-30 18:00:00.000 America/Los_Angeles")

The #raw("AT LOCAL") operator renders a datetime in the current session time zone:

#code-block(none, "SELECT timestamp '2012-10-31 01:00 UTC' AT LOCAL;
-- 2012-10-30 18:00:00.000 America/Los_Angeles  (session zone)")

== Date and time functions

#function-def("fn-current-date", "current_date", none)[
Returns the current date as of the start of the query.
]

#function-def("fn-current-time", "current_time", none)[
Returns the current time with time zone as of the start of the query.
]

#function-def("fn-current-timestamp", "current_timestamp", none)[
Returns the current timestamp with time zone as of the start of the query, with #raw("3") digits of subsecond precision,
]

#function-def("fn-current-timestamp-2", "current_timestamp(p)", none, ref: false)[
Returns the current #link(label("ref-timestamp-with-time-zone-data-type"))[timestamp with time zone] as of the start of the query, with #raw("p") digits of subsecond precision:

#code-block(none, "SELECT current_timestamp(6);
-- 2020-06-24 08:25:31.759993 America/Los_Angeles")
]

#function-def("fn-current-timezone", "current_timezone()", "varchar")[
Returns the current time zone in the format defined by IANA \(e.g., #raw("America/Los_Angeles")\) or as fixed offset from UTC \(e.g., #raw("+08:35")\)
]

#function-def("fn-date", "date(x)", "date")[
This is an alias for #raw("CAST(x AS date)").
]

#function-def("fn-last-day-of-month", "last_day_of_month(x)", "date")[
Returns the last day of the month.
]

#function-def("fn-from-iso8601-timestamp", "from_iso8601_timestamp(string)", "timestamp(3) with time zone")[
Parses the ISO 8601 formatted date #raw("string"), optionally with time and time zone, into a #raw("timestamp(3) with time zone"). The time defaults to #raw("00:00:00.000"), and the time zone defaults to the session time zone:

#code-block(none, "SELECT from_iso8601_timestamp('2020-05-11');
-- 2020-05-11 00:00:00.000 America/Vancouver

SELECT from_iso8601_timestamp('2020-05-11T11:15:05');
-- 2020-05-11 11:15:05.000 America/Vancouver

SELECT from_iso8601_timestamp('2020-05-11T11:15:05.055+01:00');
-- 2020-05-11 11:15:05.055 +01:00")
]

#function-def("fn-from-iso8601-timestamp-nanos", "from_iso8601_timestamp_nanos(string)", "timestamp(9) with time zone")[
Parses the ISO 8601 formatted date and time #raw("string"). The time zone defaults to the session time zone:

#code-block(none, "SELECT from_iso8601_timestamp_nanos('2020-05-11T11:15:05');
-- 2020-05-11 11:15:05.000000000 America/Vancouver

SELECT from_iso8601_timestamp_nanos('2020-05-11T11:15:05.123456789+01:00');
-- 2020-05-11 11:15:05.123456789 +01:00")
]

#function-def("fn-from-iso8601-date", "from_iso8601_date(string)", "date")[
Parses the ISO 8601 formatted date #raw("string") into a #raw("date"). The date can be a calendar date, a week date using ISO week numbering, or year and day of year combined:

#code-block(none, "SELECT from_iso8601_date('2020-05-11');
-- 2020-05-11

SELECT from_iso8601_date('2020-W10');
-- 2020-03-02

SELECT from_iso8601_date('2020-123');
-- 2020-05-02")
]

#function-def("fn-at-timezone", "at_timezone(timestamp(p) with time zone, zone)", "timestamp(p) with time zone")[
Converts a #raw("timestamp(p) with time zone") to a time zone specified in #raw("zone").

In the following example, the input timezone is #raw("GMT"), which is seven hours ahead of #raw("America/Los_Angeles") in November 2022:

#code-block("sql", "SELECT at_timezone(TIMESTAMP '2022-11-01 09:08:07.321 GMT', 'America/Los_Angeles')
-- 2022-11-01 02:08:07.321 America/Los_Angeles")
]

#function-def("fn-with-timezone", "with_timezone(timestamp(p), zone)", "timestamp(p) with time zone")[
Returns the timestamp specified in #raw("timestamp") with the time zone specified in #raw("zone") with precision #raw("p"):

#code-block(none, "SELECT current_timezone()
-- America/New_York

SELECT with_timezone(TIMESTAMP '2022-11-01 09:08:07.321', 'America/Los_Angeles')
-- 2022-11-01 09:08:07.321 America/Los_Angeles")
]

#function-def("fn-from-unixtime", "from_unixtime(unixtime)", "timestamp(3) with time zone")[
Returns the UNIX timestamp #raw("unixtime") as a timestamp with time zone. #raw("unixtime") is the number of seconds since #raw("1970-01-01 00:00:00 UTC").
]

#function-def("fn-from-unixtime-2", "from_unixtime(unixtime, zone)", "timestamp(3) with time zone", ref: false)[
Returns the UNIX timestamp #raw("unixtime") as a timestamp with time zone using #raw("zone") for the time zone. #raw("unixtime") is the number of seconds since #raw("1970-01-01 00:00:00 UTC").
]

#function-def("fn-from-unixtime-3", "from_unixtime(unixtime, hours, minutes)", "timestamp(3) with time zone", ref: false)[
Returns the UNIX timestamp #raw("unixtime") as a timestamp with time zone using #raw("hours") and #raw("minutes") for the time zone offset. #raw("unixtime") is the number of seconds since #raw("1970-01-01 00:00:00") in #raw("double") data type.
]

#function-def("fn-from-unixtime-nanos", "from_unixtime_nanos(unixtime)", "timestamp(9) with time zone")[
Returns the UNIX timestamp #raw("unixtime") as a timestamp with time zone. #raw("unixtime") is the number of nanoseconds since #raw("1970-01-01 00:00:00.000000000 UTC"):

#code-block(none, "SELECT from_unixtime_nanos(100);
-- 1970-01-01 00:00:00.000000100 UTC

SELECT from_unixtime_nanos(DECIMAL '1234');
-- 1970-01-01 00:00:00.000001234 UTC

SELECT from_unixtime_nanos(DECIMAL '1234.499');
-- 1970-01-01 00:00:00.000001234 UTC

SELECT from_unixtime_nanos(DECIMAL '-1234');
-- 1969-12-31 23:59:59.999998766 UTC")
]

#function-def("fn-localtime", "localtime", none)[
Returns the current time as of the start of the query.
]

#function-def("fn-localtimestamp", "localtimestamp", none)[
Returns the current timestamp as of the start of the query, with #raw("3") digits of subsecond precision.
]

#function-def("fn-localtimestamp-2", "localtimestamp(p)", none, ref: false)[
Returns the current #link(label("ref-timestamp-data-type"))[timestamp] as of the start of the query, with #raw("p") digits of subsecond precision:

#code-block(none, "SELECT localtimestamp(6);
-- 2020-06-10 15:55:23.383628")
]

#function-def("fn-now", "now()", "timestamp(3) with time zone")[
This is an alias for #raw("current_timestamp").
]

#function-def("fn-to-iso8601", "to_iso8601(x)", "varchar")[
Formats #raw("x") as an ISO 8601 string. #raw("x") can be date, timestamp, or timestamp with time zone.
]

#function-def("fn-to-milliseconds", "to_milliseconds(interval)", "bigint")[
Returns the day-to-second #raw("interval") as milliseconds.
]

#function-def("fn-to-unixtime", "to_unixtime(timestamp)", "double")[
Returns #raw("timestamp") as a UNIX timestamp.
]

#note[
The following SQL-standard functions do not use parenthesis:

- #raw("current_date")
- #raw("current_time")
- #raw("current_timestamp")
- #raw("localtime")
- #raw("localtimestamp")
]

== Truncation function

The #raw("date_trunc") function supports the following units:

#list-table((
  ([Unit], [Example Truncated Value],),
  ([#raw("millisecond")], [#raw("2001-08-22 03:04:05.321")],),
  ([#raw("second")], [#raw("2001-08-22 03:04:05.000")],),
  ([#raw("minute")], [#raw("2001-08-22 03:04:00.000")],),
  ([#raw("hour")], [#raw("2001-08-22 03:00:00.000")],),
  ([#raw("day")], [#raw("2001-08-22 00:00:00.000")],),
  ([#raw("week")], [#raw("2001-08-20 00:00:00.000")],),
  ([#raw("month")], [#raw("2001-08-01 00:00:00.000")],),
  ([#raw("quarter")], [#raw("2001-07-01 00:00:00.000")],),
  ([#raw("year")], [#raw("2001-01-01 00:00:00.000")],)
), header-rows: 1)

The above examples use the timestamp #raw("2001-08-22 03:04:05.321") as the input.

#function-def("fn-date-trunc", "date_trunc(unit, x)", "[same as input]")[
Returns #raw("x") truncated to #raw("unit"):

#code-block(none, "SELECT date_trunc('day' , TIMESTAMP '2022-10-20 05:10:00');
-- 2022-10-20 00:00:00.000

SELECT date_trunc('month' , TIMESTAMP '2022-10-20 05:10:00');
-- 2022-10-01 00:00:00.000

SELECT date_trunc('year', TIMESTAMP '2022-10-20 05:10:00');
-- 2022-01-01 00:00:00.000")
]

#anchor("ref-datetime-interval-functions")

== Interval functions

The functions in this section support the following interval units:

#list-table((
  ([Unit], [Description],),
  ([#raw("millisecond")], [Milliseconds],),
  ([#raw("second")], [Seconds],),
  ([#raw("minute")], [Minutes],),
  ([#raw("hour")], [Hours],),
  ([#raw("day")], [Days],),
  ([#raw("week")], [Weeks],),
  ([#raw("month")], [Months],),
  ([#raw("quarter")], [Quarters of a year],),
  ([#raw("year")], [Years],)
), header-rows: 1)

#function-def("fn-date-add", "date_add(unit, value, timestamp)", "[same as input]")[
Adds an interval #raw("value") of type #raw("unit") to #raw("timestamp"). Subtraction can be performed by using a negative value:

#code-block(none, "SELECT date_add('second', 86, TIMESTAMP '2020-03-01 00:00:00');
-- 2020-03-01 00:01:26.000

SELECT date_add('hour', 9, TIMESTAMP '2020-03-01 00:00:00');
-- 2020-03-01 09:00:00.000

SELECT date_add('day', -1, TIMESTAMP '2020-03-01 00:00:00 UTC');
-- 2020-02-29 00:00:00.000 UTC")
]

#function-def("fn-date-diff", "date_diff(unit, timestamp1, timestamp2)", "bigint")[
Returns #raw("timestamp2 - timestamp1") expressed in terms of #raw("unit"):

#code-block(none, "SELECT date_diff('second', TIMESTAMP '2020-03-01 00:00:00', TIMESTAMP '2020-03-02 00:00:00');
-- 86400

SELECT date_diff('hour', TIMESTAMP '2020-03-01 00:00:00 UTC', TIMESTAMP '2020-03-02 00:00:00 UTC');
-- 24

SELECT date_diff('day', DATE '2020-03-01', DATE '2020-03-02');
-- 1

SELECT date_diff('second', TIMESTAMP '2020-06-01 12:30:45.000000000', TIMESTAMP '2020-06-02 12:30:45.123456789');
-- 86400

SELECT date_diff('millisecond', TIMESTAMP '2020-06-01 12:30:45.000000000', TIMESTAMP '2020-06-02 12:30:45.123456789');
-- 86400123")
]

== Duration function

The #raw("parse_duration") function supports the following units:

#list-table((
  ([Unit], [Description],),
  ([#raw("ns")], [Nanoseconds],),
  ([#raw("us")], [Microseconds],),
  ([#raw("ms")], [Milliseconds],),
  ([#raw("s")], [Seconds],),
  ([#raw("m")], [Minutes],),
  ([#raw("h")], [Hours],),
  ([#raw("d")], [Days],)
), header-rows: 1)

#function-def("fn-parse-duration", "parse_duration(string)", "interval")[
Parses #raw("string") of format #raw("value unit") into an interval, where #raw("value") is fractional number of #raw("unit") values:

#code-block(none, "SELECT parse_duration('42.8ms');
-- 0 00:00:00.043

SELECT parse_duration('3.81 d');
-- 3 19:26:24.000

SELECT parse_duration('5m');
-- 0 00:05:00.000")
]

#function-def("fn-human-readable-seconds", "human_readable_seconds(double)", "varchar")[
Formats the double value of #raw("seconds") into a human-readable string containing #raw("weeks"), #raw("days"), #raw("hours"), #raw("minutes"), and #raw("seconds"):

#code-block(none, "SELECT human_readable_seconds(96);
-- 1 minute, 36 seconds

SELECT human_readable_seconds(3762);
-- 1 hour, 2 minutes, 42 seconds

SELECT human_readable_seconds(56363463);
-- 93 weeks, 1 day, 8 hours, 31 minutes, 3 seconds")
]

== MySQL date functions

The functions in this section use a format string that is compatible with the MySQL #raw("date_parse") and #raw("str_to_date") functions. The following table, based on the MySQL manual, describes the format specifiers:

#list-table((
  ([Specifier], [Description],),
  ([#raw("%a")], [Abbreviated weekday name \(#raw("Sun") .. #raw("Sat")\)],),
  ([#raw("%b")], [Abbreviated month name \(#raw("Jan") .. #raw("Dec")\)],),
  ([#raw("%c")], [Month, numeric \(#raw("1") .. #raw("12")\), this specifier does not support #raw("0") as a month.],),
  ([#raw("%D")], [Day of the month with English suffix \(#raw("0th"), #raw("1st"), #raw("2nd"), #raw("3rd"), ...\)],),
  ([#raw("%d")], [Day of the month, numeric \(#raw("01") .. #raw("31")\), this specifier does not support #raw("0") as a month or day.],),
  ([#raw("%e")], [Day of the month, numeric \(#raw("1") .. #raw("31")\), this specifier does not support #raw("0") as a day.],),
  ([#raw("%f")], [Fraction of second \(6 digits for printing: #raw("000000") .. #raw("999000"); 1 - 9 digits for parsing: #raw("0") .. #raw("999999999")\), timestamp is truncated to milliseconds.],),
  ([#raw("%H")], [Hour \(#raw("00") .. #raw("23")\)],),
  ([#raw("%h")], [Hour \(#raw("01") .. #raw("12")\)],),
  ([#raw("%I")], [Hour \(#raw("01") .. #raw("12")\)],),
  ([#raw("%i")], [Minutes, numeric \(#raw("00") .. #raw("59")\)],),
  ([#raw("%j")], [Day of year \(#raw("001") .. #raw("366")\)],),
  ([#raw("%k")], [Hour \(#raw("0") .. #raw("23")\)],),
  ([#raw("%l")], [Hour \(#raw("1") .. #raw("12")\)],),
  ([#raw("%M")], [Month name \(#raw("January") .. #raw("December")\)],),
  ([#raw("%m")], [Month, numeric \(#raw("01") .. #raw("12")\), this specifier does not support #raw("0") as a month.],),
  ([#raw("%p")], [#raw("AM") or #raw("PM")],),
  ([#raw("%r")], [Time of day, 12-hour \(equivalent to #raw("%h:%i:%s %p")\)],),
  ([#raw("%S")], [Seconds \(#raw("00") .. #raw("59")\)],),
  ([#raw("%s")], [Seconds \(#raw("00") .. #raw("59")\)],),
  ([#raw("%T")], [Time of day, 24-hour \(equivalent to #raw("%H:%i:%s")\)],),
  ([#raw("%U")], [Week \(#raw("00") .. #raw("53")\), where Sunday is the first day of the week],),
  ([#raw("%u")], [Week \(#raw("00") .. #raw("53")\), where Monday is the first day of the week],),
  ([#raw("%V")], [Week \(#raw("01") .. #raw("53")\), where Sunday is the first day of the week; used with #raw("%X")],),
  ([#raw("%v")], [Week \(#raw("01") .. #raw("53")\), where Monday is the first day of the week; used with #raw("%x")],),
  ([#raw("%W")], [Weekday name \(#raw("Sunday") .. #raw("Saturday")\)],),
  ([#raw("%w")], [Day of the week \(#raw("0") .. #raw("6")\), where Sunday is the first day of the week, this specifier is not supported,consider using #link(label("fn-day-of-week"), raw("day_of_week")) \(it uses #raw("1-7") instead of #raw("0-6")\).],),
  ([#raw("%X")], [Year for the week where Sunday is the first day of the week, numeric, four digits; used with #raw("%V")],),
  ([#raw("%x")], [Year for the week, where Monday is the first day of the week, numeric, four digits; used with #raw("%v")],),
  ([#raw("%Y")], [Year, numeric, four digits],),
  ([#raw("%y")], [Year, numeric \(two digits\), when parsing, two-digit year format assumes range #raw("1970") .. #raw("2069"), so "70" will result in year #raw("1970") but "69" will produce #raw("2069").],),
  ([#raw("%%")], [A literal #raw("%") character],),
  ([#raw("%x")], [#raw("x"), for any #raw("x") not listed above],)
), header-rows: 1)

#warning[
The following specifiers are not currently supported: #raw("%D %U %u %V %w %X")
]

#function-def("fn-date-format", "date_format(timestamp, format)", "varchar")[
Formats #raw("timestamp") as a string using #raw("format"):

#code-block(none, "SELECT date_format(TIMESTAMP '2022-10-20 05:10:00', '%m-%d-%Y %H');
-- 10-20-2022 05")
]

#code-block("{js:function}", "Parses `string` into a timestamp using `format`:

```sql
SELECT date_parse('2022/10/20/05', '%Y/%m/%d/%H');
-- 2022-10-20 05:00:00.000
```")

== Java date functions

The functions in this section use a format string that is compatible with JodaTime's #link("http://joda-time.sourceforge.net/apidocs/org/joda/time/format/DateTimeFormat.html")[DateTimeFormat] pattern format.

#function-def("fn-format-datetime", "format_datetime(timestamp, format)", "varchar")[
Formats #raw("timestamp") as a string using #raw("format").
]

#function-def("fn-parse-datetime", "parse_datetime(string, format)", "timestamp with time zone")[
Parses #raw("string") into a timestamp with time zone using #raw("format").
]

== Extraction function

The #raw("extract") function supports the following fields:

#list-table((
  ([Field], [Description],),
  ([#raw("YEAR")], [#link(label("fn-year"), raw("year"))],),
  ([#raw("QUARTER")], [#link(label("fn-quarter"), raw("quarter"))],),
  ([#raw("MONTH")], [#link(label("fn-month"), raw("month"))],),
  ([#raw("WEEK")], [#link(label("fn-week"), raw("week"))],),
  ([#raw("DAY")], [#link(label("fn-day"), raw("day"))],),
  ([#raw("DAY_OF_MONTH")], [#link(label("fn-day"), raw("day"))],),
  ([#raw("DAY_OF_WEEK")], [#link(label("fn-day-of-week"), raw("day_of_week"))],),
  ([#raw("DOW")], [#link(label("fn-day-of-week"), raw("day_of_week"))],),
  ([#raw("DAY_OF_YEAR")], [#link(label("fn-day-of-year"), raw("day_of_year"))],),
  ([#raw("DOY")], [#link(label("fn-day-of-year"), raw("day_of_year"))],),
  ([#raw("YEAR_OF_WEEK")], [#link(label("fn-year-of-week"), raw("year_of_week"))],),
  ([#raw("YOW")], [#link(label("fn-year-of-week"), raw("year_of_week"))],),
  ([#raw("HOUR")], [#link(label("fn-hour"), raw("hour"))],),
  ([#raw("MINUTE")], [#link(label("fn-minute"), raw("minute"))],),
  ([#raw("SECOND")], [#link(label("fn-second"), raw("second"))],),
  ([#raw("TIMEZONE_HOUR")], [#link(label("fn-timezone-hour"), raw("timezone_hour"))],),
  ([#raw("TIMEZONE_MINUTE")], [#link(label("fn-timezone-minute"), raw("timezone_minute"))],)
), header-rows: 1)

The types supported by the #raw("extract") function vary depending on the field to be extracted. Most fields support all date and time types.

#function-def("fn-extract", "extract(field FROM x)", "bigint")[
Returns #raw("field") from #raw("x"):

#code-block(none, "SELECT extract(YEAR FROM TIMESTAMP '2022-10-20 05:10:00');
-- 2022")

#note[
This SQL-standard function uses special syntax for specifying the arguments.
]
]

== Convenience extraction functions

#function-def("fn-day", "day(x)", "bigint")[
Returns the day of the month from #raw("x").
]

#function-def("fn-day-of-month", "day_of_month(x)", "bigint")[
This is an alias for #link(label("fn-day"), raw("day")).
]

#function-def("fn-day-of-week", "day_of_week(x)", "bigint")[
Returns the ISO day of the week from #raw("x"). The value ranges from #raw("1") \(Monday\) to #raw("7") \(Sunday\).
]

#function-def("fn-day-of-year", "day_of_year(x)", "bigint")[
Returns the day of the year from #raw("x"). The value ranges from #raw("1") to #raw("366").
]

#function-def("fn-dow", "dow(x)", "bigint")[
This is an alias for #link(label("fn-day-of-week"), raw("day_of_week")).
]

#function-def("fn-doy", "doy(x)", "bigint")[
This is an alias for #link(label("fn-day-of-year"), raw("day_of_year")).
]

#function-def("fn-hour", "hour(x)", "bigint")[
Returns the hour of the day from #raw("x"). The value ranges from #raw("0") to #raw("23").
]

#function-def("fn-millisecond", "millisecond(x)", "bigint")[
Returns the millisecond of the second from #raw("x").
]

#function-def("fn-minute", "minute(x)", "bigint")[
Returns the minute of the hour from #raw("x").
]

#function-def("fn-month", "month(x)", "bigint")[
Returns the month of the year from #raw("x").
]

#function-def("fn-quarter", "quarter(x)", "bigint")[
Returns the quarter of the year from #raw("x"). The value ranges from #raw("1") to #raw("4").
]

#function-def("fn-second", "second(x)", "bigint")[
Returns the second of the minute from #raw("x").
]

#function-def("fn-timezone-hour", "timezone_hour(timestamp)", "bigint")[
Returns the hour of the time zone offset from #raw("timestamp").
]

#function-def("fn-timezone-minute", "timezone_minute(timestamp)", "bigint")[
Returns the minute of the time zone offset from #raw("timestamp").
]

#function-def("fn-week", "week(x)", "bigint")[
Returns the \[ISO week\] of the year from #raw("x"). The value ranges from #raw("1") to #raw("53").
]

#function-def("fn-week-of-year", "week_of_year(x)", "bigint")[
This is an alias for #link(label("fn-week"), raw("week")).
]

#function-def("fn-year", "year(x)", "bigint")[
Returns the year from #raw("x").
]

#function-def("fn-year-of-week", "year_of_week(x)", "bigint")[
Returns the year of the \[ISO week\] from #raw("x").
]

#function-def("fn-yow", "yow(x)", "bigint")[
This is an alias for #link(label("fn-year-of-week"), raw("year_of_week")).
]

#function-def("fn-timezone", "timezone(timestamp(p) with time zone)", "varchar")[
Returns the timezone identifier from #raw("timestamp(p) with time zone"). The format of the returned identifier is identical to the #link(label("ref-timestamp-p-with-time-zone-data-type"))[format used in the input timestamp]:

#code-block("sql", "SELECT timezone(TIMESTAMP '2024-01-01 12:00:00 Asia/Tokyo'); -- Asia/Tokyo
SELECT timezone(TIMESTAMP '2024-01-01 12:00:00 +01:00'); -- +01:00
SELECT timezone(TIMESTAMP '2024-02-29 12:00:00 UTC'); -- UTC")
]

#function-def("fn-timezone-2", "timezone(time(p) with time zone)", "varchar", ref: false)[
Returns the timezone identifier from a #raw("time(p) with time zone"). The format of the returned identifier is identical to the #link(label("ref-time-with-time-zone-data-type"))[format used in the input time]:

#code-block("sql", "SELECT timezone(TIME '12:00:00+09:00'); -- +09:00")
]
