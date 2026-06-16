#import "/lib/trino-docs.typ": *

#anchor("doc-functions-math")
= Mathematical functions and operators

#anchor("ref-mathematical-operators")

== Mathematical operators

#list-table((
  ([Operator], [Description],),
  ([#raw("+")], [Addition],),
  ([#raw("-")], [Subtraction],),
  ([#raw("*")], [Multiplication],),
  ([#raw("/")], [Division \(integer division performs truncation\)],),
  ([#raw("%")], [Modulo \(remainder\)],)
), header-rows: 1)

== Mathematical functions

#function-def("fn-abs", "abs(x)", "[same as input]")[
Returns the absolute value of #raw("x").
]

#function-def("fn-cbrt", "cbrt(x)", "double")[
Returns the cube root of #raw("x").
]

#function-def("fn-ceil", "ceil(x)", "[same as input]")[
This is an alias for #link(label("fn-ceiling"), raw("ceiling")).
]

#function-def("fn-ceiling", "ceiling(x)", "[same as input]")[
Returns #raw("x") rounded up to the nearest integer.
]

#function-def("fn-degrees", "degrees(x)", "double")[
Converts angle #raw("x") in radians to degrees.
]

#function-def("fn-e", "e()", "double")[
Returns the constant Euler's number.
]

#function-def("fn-exp", "exp(x)", "double")[
Returns Euler's number raised to the power of #raw("x").
]

#function-def("fn-floor", "floor(x)", "[same as input]")[
Returns #raw("x") rounded down to the nearest integer.
]

#function-def("fn-ln", "ln(x)", "double")[
Returns the natural logarithm of #raw("x").
]

#function-def("fn-log", "log(b, x)", "double")[
Returns the base #raw("b") logarithm of #raw("x").
]

#function-def("fn-log2", "log2(x)", "double")[
Returns the base 2 logarithm of #raw("x").
]

#function-def("fn-log10", "log10(x)", "double")[
Returns the base 10 logarithm of #raw("x").
]

#function-def("fn-mod", "mod(n, m)", "[same as input]")[
Returns the modulo \(remainder\) of #raw("n") divided by #raw("m").
]

#function-def("fn-pi", "pi()", "double")[
Returns the constant Pi.
]

#function-def("fn-pow", "pow(x, p)", "double")[
This is an alias for #link(label("fn-power"), raw("power")).
]

#function-def("fn-power", "power(x, p)", "double")[
Returns #raw("x") raised to the power of #raw("p").
]

#function-def("fn-radians", "radians(x)", "double")[
Converts angle #raw("x") in degrees to radians.
]

#function-def("fn-round", "round(x)", "[same as input]")[
Returns #raw("x") rounded to the nearest integer.
]

#function-def("fn-round-2", "round(x, d)", "[same as input]", ref: false)[
Returns #raw("x") rounded to #raw("d") decimal places.
]

#function-def("fn-sign", "sign(x)", "[same as input]")[
Returns the signum function of #raw("x"), that is:

- 0 if the argument is 0,
- 1 if the argument is greater than 0,
- -1 if the argument is less than 0.

For floating point arguments, the function additionally returns:

- -0 if the argument is -0,
- NaN if the argument is NaN,
]

#function-def("fn-sqrt", "sqrt(x)", "double")[
Returns the square root of #raw("x").
]

#function-def("fn-truncate", "truncate(x)", "[same as input]")[
Returns #raw("x") rounded to integer by dropping digits after decimal point.
]

#function-def("fn-truncate-2", "truncate(x, d)", "[same as input]", ref: false)[
Returns #raw("x") truncated to #raw("d") decimal places. #raw("d") can be negative, in which case #raw("d") digits to the left of the decimal point are zeroed out.
]

#function-def("fn-width-bucket", "width_bucket(x, bound1, bound2, n)", "bigint")[
Returns the bin number of #raw("x") in an equi-width histogram with the specified #raw("bound1") and #raw("bound2") bounds and #raw("n") number of buckets.
]

#function-def("fn-width-bucket-2", "width_bucket(x, bins)", "bigint", ref: false)[
Returns the bin number of #raw("x") according to the bins specified by the array #raw("bins"). The #raw("bins") parameter must be an array of doubles and is assumed to be in sorted ascending order.
]

== Random functions

#function-def("fn-rand", "rand()", "double")[
This is an alias for #link(label("fn-random"), raw("random()")).
]

#function-def("fn-random", "random()", "double")[
Returns a pseudo-random value in the range 0.0 \<= x \< 1.0.
]

#function-def("fn-random-2", "random(n)", "[same as input]", ref: false)[
Returns a pseudo-random number between 0 and n \(exclusive\).
]

#function-def("fn-random-3", "random(m, n)", "[same as input]", ref: false)[
Returns a pseudo-random number between m and n \(exclusive\).
]

== Trigonometric functions

All trigonometric function arguments are expressed in radians. See unit conversion functions #link(label("fn-degrees"), raw("degrees")) and #link(label("fn-radians"), raw("radians")).

#function-def("fn-acos", "acos(x)", "double")[
Returns the arc cosine of #raw("x").
]

#function-def("fn-asin", "asin(x)", "double")[
Returns the arc sine of #raw("x").
]

#function-def("fn-atan", "atan(x)", "double")[
Returns the arc tangent of #raw("x").
]

#function-def("fn-atan2", "atan2(y, x)", "double")[
Returns the arc tangent of #raw("y / x").
]

#function-def("fn-cos", "cos(x)", "double")[
Returns the cosine of #raw("x").
]

#function-def("fn-cosh", "cosh(x)", "double")[
Returns the hyperbolic cosine of #raw("x").
]

#function-def("fn-sin", "sin(x)", "double")[
Returns the sine of #raw("x").
]

#function-def("fn-sinh", "sinh(x)", "double")[
Returns the hyperbolic sine of #raw("x").
]

#function-def("fn-tan", "tan(x)", "double")[
Returns the tangent of #raw("x").
]

#function-def("fn-tanh", "tanh(x)", "double")[
Returns the hyperbolic tangent of #raw("x").
]

== Geometric functions

#function-def("fn-cosine-distance", "cosine_distance(array(double), array(double))", "double")[
Calculates the cosine distance between two dense vectors:

#code-block("sql", "SELECT cosine_distance(ARRAY[1.0, 2.0], ARRAY[3.0, 4.0]);
-- 0.01613008990009257")
]

#function-def("fn-cosine-distance-2", "cosine_distance(x, y)", "double", ref: false)[
Calculates the cosine distance between two sparse vectors:

#code-block("sql", "SELECT cosine_distance(MAP(ARRAY['a'], ARRAY[1.0]), MAP(ARRAY['a'], ARRAY[2.0]));
-- 0.0")
]

#function-def("fn-cosine-similarity", "cosine_similarity(array(double), array(double))", "double")[
Calculates the cosine similarity of two dense vectors:

#code-block("sql", "SELECT cosine_similarity(ARRAY[1.0, 2.0], ARRAY[3.0, 4.0]);
-- 0.9838699100999074")
]

#function-def("fn-cosine-similarity-2", "cosine_similarity(x, y)", "double", ref: false)[
Calculates the cosine similarity of two sparse vectors:

#code-block("sql", "SELECT cosine_similarity(MAP(ARRAY['a'], ARRAY[1.0]), MAP(ARRAY['a'], ARRAY[2.0]));
-- 1.0")
]

== Floating point functions

#function-def("fn-infinity", "infinity()", "double")[
Returns the constant representing positive infinity.
]

#function-def("fn-is-finite", "is_finite(x)", "boolean")[
Determine if #raw("x") is finite.
]

#function-def("fn-is-infinite", "is_infinite(x)", "boolean")[
Determine if #raw("x") is infinite.
]

#function-def("fn-is-nan", "is_nan(x)", "boolean")[
Determine if #raw("x") is not-a-number.
]

#function-def("fn-nan", "nan()", "double")[
Returns the constant representing not-a-number.
]

== Base conversion functions

#function-def("fn-from-base", "from_base(string, radix)", "bigint")[
Returns the value of #raw("string") interpreted as a base-#raw("radix") number.
]

#function-def("fn-to-base", "to_base(x, radix)", "varchar")[
Returns the base-#raw("radix") representation of #raw("x").
]

== Statistical functions

#function-def("fn-t-pdf", "t_pdf(x, df)", "double")[
Computes the Student's t-distribution probability density function for given x and degrees of freedom \(df\). The x must be a real value and degrees of freedom must be an integer and positive value.
]

#function-def("fn-wilson-interval-lower", "wilson_interval_lower(successes, trials, z)", "double")[
Returns the lower bound of the Wilson score interval of a Bernoulli trial process at a confidence specified by the z-score #raw("z").
]

#function-def("fn-wilson-interval-upper", "wilson_interval_upper(successes, trials, z)", "double")[
Returns the upper bound of the Wilson score interval of a Bernoulli trial process at a confidence specified by the z-score #raw("z").
]

== Cumulative distribution functions

#function-def("fn-beta-cdf", "beta_cdf(a, b, v)", "double")[
Compute the Beta cdf with given a, b parameters:  P\(N \< v; a, b\). The a, b parameters must be positive real numbers and value v must be a real value. The value v must lie on the interval \[0, 1\].
]

#function-def("fn-inverse-beta-cdf", "inverse_beta_cdf(a, b, p)", "double")[
Compute the inverse of the Beta cdf with given a, b parameters for the cumulative probability \(p\): P\(N \< n\). The a, b parameters must be positive real values. The probability p must lie on the interval \[0, 1\].
]

#function-def("fn-inverse-normal-cdf", "inverse_normal_cdf(mean, sd, p)", "double")[
Compute the inverse of the Normal cdf with given mean and standard deviation \(sd\) for the cumulative probability \(p\): P\(N \< n\). The mean must be a real value and the standard deviation must be a real and positive value. The probability p must lie on the interval \(0, 1\).
]

#function-def("fn-normal-cdf", "normal_cdf(mean, sd, v)", "double")[
Compute the Normal cdf with given mean and standard deviation \(sd\):  P\(N \< v; mean, sd\). The mean and value v must be real values and the standard deviation must be a real and positive value.
]

#function-def("fn-t-cdf", "t_cdf(x, df)", "double")[
Compute the Student's t-distribution cumulative density function for given x and degrees of freedom \(df\). The x must be a real value and degrees of freedom must be an integer and positive value.
]
