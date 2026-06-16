#import "/lib/trino-docs.typ": *

#anchor("doc-functions-color")
= Color functions

#function-def("fn-bar", "bar(x, width)", "varchar")[
Renders a single bar in an ANSI bar chart using a default #raw("low_color") of red and a #raw("high_color") of green.  For example, if #raw("x") of 25% and width of 40 are passed to this function. A 10-character red bar will be drawn followed by 30 spaces to create a bar of 40 characters.
]

#function-def("fn-bar-2", "bar(x, width, low_color, high_color)", "varchar", ref: false)[
Renders a single line in an ANSI bar chart of the specified #raw("width"). The parameter #raw("x") is a double value between 0 and 1. Values of #raw("x") that fall outside the range \[0, 1\] will be truncated to either a 0 or a 1 value. The #raw("low_color") and #raw("high_color") capture the color to use for either end of the horizontal bar chart.  For example, if #raw("x") is 0.5, #raw("width") is 80, #raw("low_color") is 0xFF0000, and #raw("high_color") is 0x00FF00 this function will return a 40 character bar that varies from red \(0xFF0000\) and yellow \(0xFFFF00\) and the remainder of the 80 character bar will be padded with spaces.

#figure-img("../images/functions_color_bar.png", alt: "")[

]
]

#function-def("fn-color", "color(string)", "color")[
Returns a color capturing a decoded RGB value from a 4-character string of the format "\#000".  The input string should be varchar containing a CSS-style short rgb string or one of #raw("black"), #raw("red"), #raw("green"), #raw("yellow"), #raw("blue"), #raw("magenta"), #raw("cyan"), #raw("white").
]

#function-def("fn-color-2", "color(x, low, high, low_color, high_color)", "color", ref: false)[
Returns a color interpolated between #raw("low_color") and #raw("high_color") using the double parameters #raw("x"), #raw("low"), and #raw("high") to calculate a fraction which is then passed to the #raw("color(fraction, low_color, high_color)") function shown below. If #raw("x") falls outside the range defined by #raw("low") and #raw("high") its value is truncated to fit within this range.
]

#function-def("fn-color-3", "color(x, low_color, high_color)", "color", ref: false)[
Returns a color interpolated between #raw("low_color") and #raw("high_color") according to the double argument #raw("x") between 0 and 1.  The parameter #raw("x") is a double value between 0 and 1. Values of #raw("x") that fall outside the range \[0, 1\] will be truncated to either a 0 or a 1 value.
]

#function-def("fn-render", "render(x, color)", "varchar")[
Renders value #raw("x") using the specific color using ANSI color codes. #raw("x") can be either a double, bigint, or varchar.
]

#function-def("fn-render-2", "render(b)", "varchar", ref: false)[
Accepts boolean value #raw("b") and renders a green true or a red false using ANSI color codes.
]

#function-def("fn-rgb", "rgb(red, green, blue)", "color")[
Returns a color value capturing the RGB value of three component color values supplied as int parameters ranging from 0 to 255: #raw("red"), #raw("green"), #raw("blue").
]
