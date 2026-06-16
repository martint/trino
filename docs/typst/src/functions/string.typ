#import "/lib/trino-docs.typ": *

#anchor("doc-functions-string")
= String functions and operators

== String operators

The #raw("||") operator performs concatenation.

The #raw("LIKE") statement can be used for pattern matching and is documented in #link(label("ref-like-operator"))[like-operator].

== String functions

#note[
These functions assume that the input strings contain valid UTF-8 encoded Unicode code points.  There are no explicit checks for valid UTF-8 and the functions may return incorrect results on invalid UTF-8. Invalid UTF-8 data can be corrected with #link(label("fn-from-utf8"), raw("from_utf8")).

Additionally, the functions operate on Unicode code points and not user visible #emph[characters] \(or #emph[grapheme clusters]\).  Some languages combine multiple code points into a single user-perceived #emph[character], the basic unit of a writing system for a language, but the functions will treat each code point as a separate unit.

The #link(label("fn-lower"), raw("lower")) and #link(label("fn-upper"), raw("upper")) functions do not perform locale-sensitive, context-sensitive, or one-to-many mappings required for some languages. Specifically, this will return incorrect results for Lithuanian, Turkish and Azeri.
]

#function-def("fn-chr", "chr(n)", "varchar")[
Returns the Unicode code point #raw("n") as a single character string.
]

#function-def("fn-codepoint", "codepoint(string)", "integer")[
Returns the Unicode code point of the only character of #raw("string").
]

#function-def("fn-concat-3", "concat(string1, ..., stringN)", "varchar", ref: false)[
Returns the concatenation of #raw("string1"), #raw("string2"), #raw("..."), #raw("stringN"). This function provides the same functionality as the SQL-standard concatenation operator \(#raw("||")\).
]

#function-def("fn-concat-ws", "concat_ws(separator, string1, ..., stringN)", "varchar")[
Returns the concatenation of #raw("string1"), #raw("string2"), #raw("..."), #raw("stringN") using #raw("separator") to join the values. If #raw("separator") is null, then the return value is null. Any null values provided in the arguments after the separator are skipped.
]

#function-def("fn-concat-ws-2", "concat_ws(string0, array(varchar))", "varchar", ref: false)[
Returns the concatenation of elements in the array using #raw("string0") as a separator. If #raw("string0") is null, then the return value is null. Any null values in the array are skipped.
]

#function-def("fn-format-2", "format(format, args...)", "varchar", ref: false)[
See #link(label("fn-format"), raw("format")).
]

#function-def("fn-hamming-distance", "hamming_distance(string1, string2)", "bigint")[
Returns the Hamming distance of #raw("string1") and #raw("string2"), i.e. the number of positions at which the corresponding characters are different. Note that the two strings must have the same length.
]

#function-def("fn-length-2", "length(string)", "bigint", ref: false)[
Returns the length of #raw("string") in characters.
]

#function-def("fn-levenshtein-distance", "levenshtein_distance(string1, string2)", "bigint")[
Returns the Levenshtein edit distance of #raw("string1") and #raw("string2"), i.e. the minimum number of single-character edits \(insertions, deletions or substitutions\) needed to change #raw("string1") into #raw("string2").
]

#function-def("fn-lower", "lower(string)", "varchar")[
Converts #raw("string") to lowercase.
]

#function-def("fn-lpad-2", "lpad(string, size, padstring)", "varchar", ref: false)[
Left pads #raw("string") to #raw("size") characters with #raw("padstring"). If #raw("size") is less than the length of #raw("string"), the result is truncated to #raw("size") characters. #raw("size") must not be negative and #raw("padstring") must be non-empty.
]

#function-def("fn-ltrim", "ltrim(string)", "varchar")[
Removes leading whitespace from #raw("string").
]

#function-def("fn-luhn-check", "luhn_check(string)", "boolean")[
Tests whether a #raw("string") of digits is valid according to the #link("https://wikipedia.org/wiki/Luhn_algorithm")[Luhn algorithm].

This checksum function, also known as #raw("modulo 10") or #raw("mod 10"), is widely applied on credit card numbers and government identification numbers to distinguish valid numbers from mistyped, incorrect numbers.

Valid identification number:

#code-block(none, "select luhn_check('79927398713');
-- true")

Invalid identification number:

#code-block(none, "select luhn_check('79927398714');
-- false")
]

#function-def("fn-position", "position(substring IN string)", "bigint")[
Returns the starting position of the first instance of #raw("substring") in #raw("string"). Positions start with #raw("1"). If not found, #raw("0") is returned.

#note[
This SQL-standard function has special syntax and uses the #raw("IN") keyword for the arguments. See also #link(label("fn-strpos"), raw("strpos")).
]
]

#function-def("fn-replace", "replace(string, search)", "varchar")[
Removes all instances of #raw("search") from #raw("string").
]

#function-def("fn-replace-2", "replace(string, search, replace)", "varchar", ref: false)[
Replaces all instances of #raw("search") with #raw("replace") in #raw("string").
]

#function-def("fn-reverse-3", "reverse(string)", "varchar", ref: false)[
Returns #raw("string") with the characters in reverse order.
]

#function-def("fn-rpad-2", "rpad(string, size, padstring)", "varchar", ref: false)[
Right pads #raw("string") to #raw("size") characters with #raw("padstring"). If #raw("size") is less than the length of #raw("string"), the result is truncated to #raw("size") characters. #raw("size") must not be negative and #raw("padstring") must be non-empty.
]

#function-def("fn-rtrim", "rtrim(string)", "varchar")[
Removes trailing whitespace from #raw("string").
]

#function-def("fn-soundex", "soundex(char)", "string")[
/ #raw("soundex") returns a character string containing the phonetic representation of #raw("char").: It is typically used to evaluate the similarity of two expressions phonetically, that is how the string sounds when spoken:  #code-block(none, "SELECT name FROM nation WHERE SOUNDEX(name)  = SOUNDEX('CHYNA');   name  | -------+----  CHINA | (1 row)")
]

#function-def("fn-split", "split(string, delimiter)", "array(varchar)")[
Splits #raw("string") on #raw("delimiter") and returns an array.
]

#function-def("fn-split-2", "split(string, delimiter, limit)", "array(varchar)", ref: false)[
Splits #raw("string") on #raw("delimiter") and returns an array of size at most #raw("limit"). The last element in the array always contain everything left in the #raw("string"). #raw("limit") must be a positive number.
]

#function-def("fn-split-part", "split_part(string, delimiter, index)", "varchar")[
Splits #raw("string") on #raw("delimiter") and returns the field #raw("index"). Field indexes start with #raw("1"). If the index is larger than the number of fields, then null is returned.
]

#function-def("fn-split-to-map", "split_to_map(string, entryDelimiter, keyValueDelimiter)", "map<varchar, varchar>")[
Splits #raw("string") by #raw("entryDelimiter") and #raw("keyValueDelimiter") and returns a map. #raw("entryDelimiter") splits #raw("string") into key-value pairs. #raw("keyValueDelimiter") splits each pair into key and value.
]

#function-def("fn-split-to-multimap", "split_to_multimap(string, entryDelimiter, keyValueDelimiter)", "map(varchar, array(varchar))")[
Splits #raw("string") by #raw("entryDelimiter") and #raw("keyValueDelimiter") and returns a map containing an array of values for each unique key. #raw("entryDelimiter") splits #raw("string") into key-value pairs. #raw("keyValueDelimiter") splits each pair into key and value. The values for each key will be in the same order as they appeared in #raw("string").
]

#function-def("fn-strpos", "strpos(string, substring)", "bigint")[
Returns the starting position of the first instance of #raw("substring") in #raw("string"). Positions start with #raw("1"). If not found, #raw("0") is returned.
]

#function-def("fn-strpos-2", "strpos(string, substring, instance)", "bigint", ref: false)[
Returns the position of the N-th #raw("instance") of #raw("substring") in #raw("string"). When #raw("instance") is a negative number the search will start from the end of #raw("string"). Positions start with #raw("1"). If not found, #raw("0") is returned.
]

#function-def("fn-starts-with", "starts_with(string, substring)", "boolean")[
Tests whether #raw("substring") is a prefix of #raw("string").
]

#function-def("fn-substr-3", "substr(string, start)", "varchar", ref: false)[
This is an alias for #link(label("fn-substring"), raw("substring")).
]

#function-def("fn-substring", "substring(string, start)", "varchar")[
Returns the rest of #raw("string") from the starting position #raw("start"). Positions start with #raw("1"). A negative starting position is interpreted as being relative to the end of the string.
]

#function-def("fn-substr-4", "substr(string, start, length)", "varchar", ref: false)[
This is an alias for #link(label("fn-substring"), raw("substring")).
]

#function-def("fn-substring-2", "substring(string, start, length)", "varchar", ref: false)[
Returns a substring from #raw("string") of length #raw("length") from the starting position #raw("start"). Positions start with #raw("1"). A negative starting position is interpreted as being relative to the end of the string.
]

#function-def("fn-translate", "translate(source, from, to)", "varchar")[
Returns the #raw("source") string translated by replacing characters found in the #raw("from") string with the corresponding characters in the #raw("to") string.  If the #raw("from") string contains duplicates, only the first is used.  If the #raw("source") character does not exist in the #raw("from") string, the #raw("source") character will be copied without translation.  If the index of the matching character in the #raw("from") string is beyond the length of the #raw("to") string, the #raw("source") character will be omitted from the resulting string.

Here are some examples illustrating the translate function:

#code-block(none, "SELECT translate('abcd', '', ''); -- 'abcd'
SELECT translate('abcd', 'a', 'z'); -- 'zbcd'
SELECT translate('abcda', 'a', 'z'); -- 'zbcdz'
SELECT translate('Palhoça', 'ç','c'); -- 'Palhoca'
SELECT translate('abcd', 'b', U&'\\+01F600'); -- a😀cd
SELECT translate('abcd', 'a', ''); -- 'bcd'
SELECT translate('abcd', 'a', 'zy'); -- 'zbcd'
SELECT translate('abcd', 'ac', 'z'); -- 'zbd'
SELECT translate('abcd', 'aac', 'zq'); -- 'zbd'")
]

#function-def("fn-trim", "trim(string)", "varchar")[
Removes leading and trailing whitespace from #raw("string").
]

#function-def("fn-trim-2", "trim( [ [ specification ] [ string ] FROM ] source )", "varchar", ref: false)[
Removes any leading and\/or trailing characters as specified up to and including #raw("string") from #raw("source"):

#code-block(none, "SELECT trim('!' FROM '!foo!'); -- 'foo'
SELECT trim(LEADING FROM '  abcd');  -- 'abcd'
SELECT trim(BOTH '$' FROM '$var$'); -- 'var'
SELECT trim(TRAILING 'ER' FROM upper('worker')); -- 'WORK'")
]

#function-def("fn-upper", "upper(string)", "varchar")[
Converts #raw("string") to uppercase.
]

#function-def("fn-word-stem", "word_stem(word)", "varchar")[
Returns the stem of #raw("word") in the English language.
]

#function-def("fn-word-stem-2", "word_stem(word, lang)", "varchar", ref: false)[
Returns the stem of #raw("word") in the #raw("lang") language.
]

== Unicode functions

#function-def("fn-normalize", "normalize(string)", "varchar")[
Transforms #raw("string") with NFC normalization form.
]

#function-def("fn-normalize-2", "normalize(string, form)", "varchar", ref: false)[
Transforms #raw("string") with the specified normalization form. #raw("form") must be one of the following keywords:

#list-table((
  ([Form], [Description],),
  ([#raw("NFD")], [Canonical Decomposition],),
  ([#raw("NFC")], [Canonical Decomposition, followed by Canonical Composition],),
  ([#raw("NFKD")], [Compatibility Decomposition],),
  ([#raw("NFKC")], [Compatibility Decomposition, followed by Canonical Composition],)
), header-rows: 1)

#note[
This SQL-standard function has special syntax and requires specifying #raw("form") as a keyword, not as a string.
]
]

#function-def("fn-to-utf8", "to_utf8(string)", "varbinary")[
Encodes #raw("string") into a UTF-8 varbinary representation.
]

#function-def("fn-from-utf8", "from_utf8(binary)", "varchar")[
Decodes a UTF-8 encoded string from #raw("binary"). Invalid UTF-8 sequences are replaced with the Unicode replacement character #raw("U+FFFD").
]

#function-def("fn-from-utf8-2", "from_utf8(binary, replace)", "varchar", ref: false)[
Decodes a UTF-8 encoded string from #raw("binary"). Invalid UTF-8 sequences are replaced with #raw("replace"). The replacement string #raw("replace") must either be a single character or empty \(in which case invalid characters are removed\).
]
