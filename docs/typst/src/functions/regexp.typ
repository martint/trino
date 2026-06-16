#import "/lib/trino-docs.typ": *

#anchor("doc-functions-regexp")
= Regular expression functions

All the regular expression functions use the #link("https://docs.oracle.com/en/java/javase/23/docs/api/java.base/java/util/regex/Pattern.html")[Java pattern] syntax, with a few notable exceptions:

- When using multi-line mode \(enabled via the #raw("(?m)") flag\), only #raw("\\n") is recognized as a line terminator. Additionally, the #raw("(?d)") flag is not supported and must not be used.
- Case-insensitive matching \(enabled via the #raw("(?i)") flag\) is always performed in a Unicode-aware manner. However, context-sensitive and local-sensitive matching is not supported. Additionally, the #raw("(?u)") flag is not supported and must not be used.
- Surrogate pairs are not supported. For example, #raw("\\uD800\\uDC00") is not treated as #raw("U+10000") and must be specified as #raw("\\x{10000}").
- Boundaries \(#raw("\\b")\) are incorrectly handled for a non-spacing mark without a base character.
- #raw("\\Q") and #raw("\\E") are not supported in character classes \(such as #raw("[A-Z123]")\) and are instead treated as literals.
- Unicode character classes \(#raw("\\p{prop}")\) are supported with the following differences:
  
  - All underscores in names must be removed. For example, use #raw("OldItalic") instead of #raw("Old_Italic").
  - Scripts must be specified directly, without the #raw("Is"), #raw("script=") or #raw("sc=") prefixes. Example: #raw("\\p{Hiragana}")
  - Blocks must be specified with the #raw("In") prefix. The #raw("block=") and #raw("blk=") prefixes are not supported. Example: #raw("\\p{Mongolian}")
  - Categories must be specified directly, without the #raw("Is"), #raw("general_category=") or #raw("gc=") prefixes. Example: #raw("\\p{L}")
  - Binary properties must be specified directly, without the #raw("Is"). Example: #raw("\\p{NoncharacterCodePoint}")

#function-def("fn-regexp-count", "regexp_count(string, pattern)", "bigint")[
Returns the number of occurrence of #raw("pattern") in #raw("string"):

#code-block(none, "SELECT regexp_count('1a 2b 14m', '\\s*[a-z]+\\s*'); -- 3")
]

#function-def("fn-regexp-extract-all", "regexp_extract_all(string, pattern)", "array(varchar)")[
Returns the substring\(s\) matched by the regular expression #raw("pattern") in #raw("string"):

#code-block(none, "SELECT regexp_extract_all('1a 2b 14m', '\\d+'); -- [1, 2, 14]")
]

#function-def("fn-regexp-extract-all-2", "regexp_extract_all(string, pattern, group)", "array(varchar)", ref: false)[
Finds all occurrences of the regular expression #raw("pattern") in #raw("string") and returns the \[capturing group number\] #raw("group"):

#code-block(none, "SELECT regexp_extract_all('1a 2b 14m', '(\\d+)([a-z]+)', 2); -- ['a', 'b', 'm']")
]

#function-def("fn-regexp-extract", "regexp_extract(string, pattern)", "varchar")[
Returns the first substring matched by the regular expression #raw("pattern") in #raw("string"):

#code-block(none, "SELECT regexp_extract('1a 2b 14m', '\\d+'); -- 1")
]

#function-def("fn-regexp-extract-2", "regexp_extract(string, pattern, group)", "varchar", ref: false)[
Finds the first occurrence of the regular expression #raw("pattern") in #raw("string") and returns the \[capturing group number\] #raw("group"):

#code-block(none, "SELECT regexp_extract('1a 2b 14m', '(\\d+)([a-z]+)', 2); -- 'a'")
]

#function-def("fn-regexp-like", "regexp_like(string, pattern)", "boolean")[
Evaluates the regular expression #raw("pattern") and determines if it is contained within #raw("string").

The #raw("pattern") only needs to be contained within #raw("string"), rather than needing to match all of #raw("string"). In other words, this performs a #emph[contains] operation rather than a #emph[match] operation. You can match the entire string by anchoring the pattern using #raw("^") and #raw("$"):

#code-block(none, "SELECT regexp_like('1a 2b 14m', '\\d+b'); -- true")
]

#function-def("fn-regexp-position", "regexp_position(string, pattern)", "integer")[
Returns the index of the first occurrence \(counting from 1\) of #raw("pattern") in #raw("string"). Returns -1 if not found:

#code-block(none, "SELECT regexp_position('I have 23 apples, 5 pears and 13 oranges', '\\b\\d+\\b'); -- 8")
]

#function-def("fn-regexp-position-2", "regexp_position(string, pattern, start)", "integer", ref: false)[
Returns the index of the first occurrence of #raw("pattern") in #raw("string"), starting from #raw("start") \(include #raw("start")\). Returns -1 if not found:

#code-block(none, "SELECT regexp_position('I have 23 apples, 5 pears and 13 oranges', '\\b\\d+\\b', 5); -- 8
SELECT regexp_position('I have 23 apples, 5 pears and 13 oranges', '\\b\\d+\\b', 12); -- 19")
]

#function-def("fn-regexp-position-3", "regexp_position(string, pattern, start, occurrence)", "integer", ref: false)[
Returns the index of the nth #raw("occurrence") of #raw("pattern") in #raw("string"), starting from #raw("start") \(include #raw("start")\). Returns -1 if not found:

#code-block(none, "SELECT regexp_position('I have 23 apples, 5 pears and 13 oranges', '\\b\\d+\\b', 12, 1); -- 19
SELECT regexp_position('I have 23 apples, 5 pears and 13 oranges', '\\b\\d+\\b', 12, 2); -- 31
SELECT regexp_position('I have 23 apples, 5 pears and 13 oranges', '\\b\\d+\\b', 12, 3); -- -1")
]

#function-def("fn-regexp-replace", "regexp_replace(string, pattern)", "varchar")[
Removes every instance of the substring matched by the regular expression #raw("pattern") from #raw("string"):

#code-block(none, "SELECT regexp_replace('1a 2b 14m', '\\d+[ab] '); -- '14m'")
]

#function-def("fn-regexp-replace-2", "regexp_replace(string, pattern, replacement)", "varchar", ref: false)[
Replaces every instance of the substring matched by the regular expression #raw("pattern") in #raw("string") with #raw("replacement"). \[Capturing groups\] can be referenced in #raw("replacement") using #raw("$g") for a numbered group or #raw("${name}") for a named group. A dollar sign \(#raw("$")\) may be included in the replacement by escaping it with a backslash \(#raw("\\$")\):

#code-block(none, "SELECT regexp_replace('1a 2b 14m', '(\\d+)([ab]) ', '3c$2 '); -- '3ca 3cb 14m'")
]

#function-def("fn-regexp-replace-3", "regexp_replace(string, pattern, function)", "varchar", ref: false)[
Replaces every instance of the substring matched by the regular expression #raw("pattern") in #raw("string") using #raw("function"). The lambda expression #raw("function") is invoked for each match with the \[capturing groups\] passed as an array. Capturing group numbers start at one; there is no group for the entire match \(if you need this, surround the entire expression with parenthesis\).

#code-block(none, "SELECT regexp_replace('new york', '(\\w)(\\w*)', x -> upper(x[1]) || lower(x[2])); --'New York'")
]

#function-def("fn-regexp-split", "regexp_split(string, pattern)", "array(varchar)")[
Splits #raw("string") using the regular expression #raw("pattern") and returns an array. Trailing empty strings are preserved:

#code-block(none, "SELECT regexp_split('1a 2b 14m', '\\s*[a-z]+\\s*'); -- [1, 2, 14, ]")
]
