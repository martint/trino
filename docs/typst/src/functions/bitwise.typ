#import "/lib/trino-docs.typ": *

#anchor("doc-functions-bitwise")
= Bitwise functions

#function-def("fn-bit-count", "bit_count(x, bits)", "bigint")[
Count the number of bits set in #raw("x") \(treated as #raw("bits")-bit signed integer\) in 2's complement representation:

#code-block(none, "SELECT bit_count(9, 64); -- 2
SELECT bit_count(9, 8); -- 2
SELECT bit_count(-7, 64); -- 62
SELECT bit_count(-7, 8); -- 6")
]

#function-def("fn-bitwise-and", "bitwise_and(x, y)", "bigint")[
Returns the bitwise AND of #raw("x") and #raw("y") in 2's complement representation.

Bitwise AND of #raw("19") \(binary: #raw("10011")\) and #raw("25") \(binary: #raw("11001")\) results in #raw("17") \(binary: #raw("10001")\):

#code-block(none, "SELECT bitwise_and(19,25); -- 17")
]

#function-def("fn-bitwise-not", "bitwise_not(x)", "bigint")[
Returns the bitwise NOT of #raw("x") in 2's complement representation \(#raw("NOT x = -x - 1")\):

#code-block(none, "SELECT bitwise_not(-12); --  11
SELECT bitwise_not(19);  -- -20
SELECT bitwise_not(25);  -- -26")
]

#function-def("fn-bitwise-or", "bitwise_or(x, y)", "bigint")[
Returns the bitwise OR of #raw("x") and #raw("y") in 2's complement representation.

Bitwise OR of #raw("19") \(binary: #raw("10011")\) and #raw("25") \(binary: #raw("11001")\) results in #raw("27") \(binary: #raw("11011")\):

#code-block(none, "SELECT bitwise_or(19,25); -- 27")
]

#function-def("fn-bitwise-xor", "bitwise_xor(x, y)", "bigint")[
Returns the bitwise XOR of #raw("x") and #raw("y") in 2's complement representation.

Bitwise XOR of #raw("19") \(binary: #raw("10011")\) and #raw("25") \(binary: #raw("11001")\) results in #raw("10") \(binary: #raw("01010")\):

#code-block(none, "SELECT bitwise_xor(19,25); -- 10")
]

#function-def("fn-bitwise-left-shift", "bitwise_left_shift(value, shift)", "[same as value]")[
Returns the left shifted value of #raw("value").

Shifting #raw("1") \(binary: #raw("001")\) by two bits results in #raw("4") \(binary: #raw("00100")\):

#code-block(none, "SELECT bitwise_left_shift(1, 2); -- 4")

Shifting #raw("5") \(binary: #raw("0101")\) by two bits results in #raw("20") \(binary: #raw("010100")\):

#code-block(none, "SELECT bitwise_left_shift(5, 2); -- 20")

Shifting a #raw("value") by #raw("0") always results in the original #raw("value"):

#code-block(none, "SELECT bitwise_left_shift(20, 0); -- 20
SELECT bitwise_left_shift(42, 0); -- 42")

Shifting #raw("0") by a #raw("shift") always results in #raw("0"):

#code-block(none, "SELECT bitwise_left_shift(0, 1); -- 0
SELECT bitwise_left_shift(0, 2); -- 0")
]

#function-def("fn-bitwise-right-shift", "bitwise_right_shift(value, shift)", "[same as value]")[
Returns the logical right shifted value of #raw("value").

Shifting #raw("8") \(binary: #raw("1000")\) by three bits results in #raw("1") \(binary: #raw("001")\):

#code-block(none, "SELECT bitwise_right_shift(8, 3); -- 1")

Shifting #raw("9") \(binary: #raw("1001")\) by one bit results in #raw("4") \(binary: #raw("100")\):

#code-block(none, "SELECT bitwise_right_shift(9, 1); -- 4")

Shifting a #raw("value") by #raw("0") always results in the original #raw("value"):

#code-block(none, "SELECT bitwise_right_shift(20, 0); -- 20
SELECT bitwise_right_shift(42, 0); -- 42")

Shifting a #raw("value") by #raw("64") or more bits results in #raw("0"):

#code-block(none, "SELECT bitwise_right_shift( 12, 64); -- 0
SELECT bitwise_right_shift(-45, 64); -- 0")

Shifting #raw("0") by a #raw("shift") always results in #raw("0"):

#code-block(none, "SELECT bitwise_right_shift(0, 1); -- 0
SELECT bitwise_right_shift(0, 2); -- 0")
]

#function-def("fn-bitwise-right-shift-arithmetic", "bitwise_right_shift_arithmetic(value, shift)", "[same as value]")[
Returns the arithmetic right shifted value of #raw("value").

Returns the same values as #link(label("fn-bitwise-right-shift"), raw("bitwise_right_shift")) when shifting by less than #raw("64") bits. Shifting by #raw("64") or more bits results in #raw("0") for a positive and #raw("-1") for a negative #raw("value"):

#code-block(none, "SELECT bitwise_right_shift_arithmetic( 12, 64); --  0
SELECT bitwise_right_shift_arithmetic(-45, 64); -- -1")
]

See also #link(label("fn-bitwise-and-agg"), raw("bitwise_and_agg")) and #link(label("fn-bitwise-or-agg"), raw("bitwise_or_agg")).
