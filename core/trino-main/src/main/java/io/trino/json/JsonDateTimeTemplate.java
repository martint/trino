/*
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package io.trino.json;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.common.collect.ImmutableList;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.Type;
import org.antlr.v4.runtime.ANTLRErrorListener;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.OptionalInt;

import static io.trino.spi.type.DateType.DATE;
import static io.trino.spi.type.TimeType.createTimeType;
import static io.trino.spi.type.TimeWithTimeZoneType.createTimeWithTimeZoneType;
import static io.trino.spi.type.TimestampType.createTimestampType;
import static io.trino.spi.type.TimestampWithTimeZoneType.createTimestampWithTimeZoneType;
import static io.trino.type.DateTimes.parseTime;
import static io.trino.type.DateTimes.parseTimeWithTimeZone;
import static io.trino.type.DateTimes.parseTimestamp;
import static io.trino.type.DateTimes.parseTimestampWithTimeZone;
import static io.trino.type.DateTimes.rescale;
import static io.trino.util.DateTimeUtils.parseDate;
import static java.lang.Character.isDigit;
import static java.lang.Math.floorDiv;
import static java.lang.Math.floorMod;
import static java.lang.String.format;
import static java.util.Objects.requireNonNull;

/**
 * SQL/JSON path datetime template parser per ISO/IEC 9075-2:2023 9.46.
 */
public final class JsonDateTimeTemplate
{
    private final String template;
    private final Type type;
    private final int precision;
    private final List<Token> tokens;

    public static JsonDateTimeTemplate parse(String template)
    {
        ParsedTemplate parsedTemplate = parseTemplate(template);
        return new JsonDateTimeTemplate(parsedTemplate.template(), parsedTemplate.type(), parsedTemplate.precision(), parsedTemplate.tokens());
    }

    @JsonCreator
    public JsonDateTimeTemplate(
            @JsonProperty("template") String template,
            @JsonProperty("type") Type type,
            @JsonProperty("precision") int precision)
    {
        this(template, type, precision, validateAndParse(template, type, precision));
    }

    private static List<Token> validateAndParse(String template, Type type, int precision)
    {
        ParsedTemplate parsed = parseTemplate(template);
        if (!parsed.type().equals(type)) {
            throw new IllegalArgumentException(format("datetime() template type mismatch: expected %s, found %s", parsed.type().getDisplayName(), type.getDisplayName()));
        }
        if (parsed.precision() != precision) {
            throw new IllegalArgumentException(format("datetime() template precision mismatch: expected %s, found %s", parsed.precision(), precision));
        }
        return parsed.tokens();
    }

    private JsonDateTimeTemplate(String template, Type type, int precision, List<Token> tokens)
    {
        this.template = requireNonNull(template, "template is null");
        this.type = requireNonNull(type, "type is null");
        this.precision = precision;
        this.tokens = ImmutableList.copyOf(tokens);
    }

    @JsonProperty
    public String getTemplate()
    {
        return template;
    }

    @JsonProperty
    public Type getType()
    {
        return type;
    }

    @JsonProperty
    public int getPrecision()
    {
        return precision;
    }

    public TypedValue parseValue(String value)
    {
        requireNonNull(value, "value is null");

        Cursor cursor = new Cursor(value);
        ParsedValues parsedValues = new ParsedValues();
        for (Token token : tokens) {
            switch (token) {
                case LiteralToken literalToken -> cursor.expect(literalToken.literal());
                case FieldToken fieldToken -> parseField(fieldToken, cursor, parsedValues);
            }
        }

        if (!cursor.atEnd()) {
            throw new IllegalArgumentException("unexpected trailing input");
        }

        return buildTypedValue(parsedValues);
    }

    private TypedValue buildTypedValue(ParsedValues parsedValues)
    {
        // Per SQL:2023 §9.46, default values for unspecified fields are fixed constants, not
        // session-dependent values. Using session.getStart() would make the same query yield
        // different results depending on when it's evaluated.
        int year = parsedValues.resolveYear();
        if (parsedValues.dayOfYear.isPresent()) {
            LocalDate date = LocalDate.ofYearDay(year, parsedValues.dayOfYear.getAsInt());
            year = date.getYear();
            parsedValues.month = OptionalInt.of(date.getMonthValue());
            parsedValues.day = OptionalInt.of(date.getDayOfMonth());
        }

        int month = parsedValues.month.orElse(1);
        int day = parsedValues.day.orElse(1);
        int hour = parsedValues.resolveHour();
        int minute = parsedValues.resolveMinute();
        int second = parsedValues.resolveSecond();

        String fraction = "";
        if (precision > 0) {
            long fractionValue = rescale(parsedValues.fractionValue, parsedValues.fractionDigits, precision);
            fraction = "." + zeroPad(fractionValue, precision);
        }

        if (type.equals(DATE)) {
            String canonicalValue = LocalDate.of(year, month, day).toString();
            return new TypedValue(DATE, (long) parseDate(canonicalValue));
        }

        if (type instanceof TimeType timeType) {
            String canonicalValue = format("%02d:%02d:%02d%s", hour, minute, second, fraction);
            return new TypedValue(timeType, parseTime(canonicalValue));
        }

        // Per SQL:2023, default time-zone offset is UTC when no TZH/TZM fields are present.
        String offset = parsedValues.resolveOffset(0);
        if (type instanceof TimeWithTimeZoneType timeWithTimeZoneType) {
            String canonicalValue = format("%02d:%02d:%02d%s%s", hour, minute, second, fraction, offset);
            return TypedValue.fromValueAsObject(timeWithTimeZoneType, parseTimeWithTimeZone(timeWithTimeZoneType.getPrecision(), canonicalValue));
        }

        String canonicalTimestamp = format("%s %02d:%02d:%02d%s", LocalDate.of(year, month, day), hour, minute, second, fraction);
        if (type instanceof TimestampType timestampType) {
            return TypedValue.fromValueAsObject(timestampType, parseTimestamp(timestampType.getPrecision(), canonicalTimestamp));
        }

        TimestampWithTimeZoneType timestampWithTimeZoneType = (TimestampWithTimeZoneType) type;
        return TypedValue.fromValueAsObject(timestampWithTimeZoneType, parseTimestampWithTimeZone(timestampWithTimeZoneType.getPrecision(), canonicalTimestamp + offset));
    }

    private static void parseField(FieldToken token, Cursor cursor, ParsedValues values)
    {
        switch (token.field()) {
            case YEAR -> {
                values.year = OptionalInt.of(readUnsignedNumber(cursor, token, 1, token.width()));
                values.yearDigits = cursor.previousDigits().length();
            }
            case ROUNDED_YEAR -> {
                values.roundedYear = OptionalInt.of(readUnsignedNumber(cursor, token, 1, token.width()));
                values.roundedYearDigits = cursor.previousDigits().length();
            }
            case MONTH -> values.month = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
            case DAY -> values.day = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
            case DAY_OF_YEAR -> values.dayOfYear = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 3));
            case HOUR12 -> values.hour12 = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
            case HOUR24 -> values.hour24 = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
            case MINUTE -> values.minute = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
            case SECOND -> values.second = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
            case SECOND_OF_DAY -> values.secondOfDay = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 5));
            case FRACTION -> {
                values.fractionValue = readUnsignedLongNumber(cursor, token, 1, token.width());
                values.fractionDigits = cursor.previousDigits().length();
            }
            case AM_PM -> values.pm = readAmPm(cursor);
            case TIME_ZONE_HOUR -> values.timeZoneHour = readTimeZoneHour(cursor, token);
            case TIME_ZONE_MINUTE -> values.timeZoneMinute = OptionalInt.of(readUnsignedNumber(cursor, token, 1, 2));
        }
    }

    private static int readUnsignedNumber(Cursor cursor, FieldToken token, int minimumDigits, int maximumDigits)
    {
        int actualMinimumDigits = token.delimited() ? minimumDigits : token.width();
        int actualMaximumDigits = token.delimited() ? maximumDigits : token.width();
        String number = cursor.readDigits(actualMinimumDigits, actualMaximumDigits);
        return Integer.parseInt(number);
    }

    // FRACTION values at FF10..FF12 precision don't fit in int; use a long variant.
    private static long readUnsignedLongNumber(Cursor cursor, FieldToken token, int minimumDigits, int maximumDigits)
    {
        int actualMinimumDigits = token.delimited() ? minimumDigits : token.width();
        int actualMaximumDigits = token.delimited() ? maximumDigits : token.width();
        String number = cursor.readDigits(actualMinimumDigits, actualMaximumDigits);
        return Long.parseLong(number);
    }

    private static boolean readAmPm(Cursor cursor)
    {
        if (cursor.regionMatchesIgnoreCase("A.M.")) {
            cursor.advance("A.M.".length());
            return false;
        }
        if (cursor.regionMatchesIgnoreCase("P.M.")) {
            cursor.advance("P.M.".length());
            return true;
        }
        throw new IllegalArgumentException(format("invalid AM/PM marker at position %d", cursor.position()));
    }

    private static OptionalInt readTimeZoneHour(Cursor cursor, FieldToken token)
    {
        if (cursor.atEnd()) {
            throw new IllegalArgumentException(format("expected time zone hour at position %d", cursor.position()));
        }

        char signCharacter = cursor.current();
        if (signCharacter != '+' && signCharacter != '-' && signCharacter != ' ') {
            throw new IllegalArgumentException(format("time zone hour must start with '+', '-' or space at position %d", cursor.position()));
        }
        cursor.advance(1);

        String hourDigits = token.delimited() ? cursor.readDigits(1, 2) : cursor.readFixedDigits(2);
        int hour = Integer.parseInt(hourDigits);
        int sign = signCharacter == '-' ? -1 : 1;
        return OptionalInt.of(sign * hour);
    }

    private static String zeroPad(long value, int width)
    {
        String text = Long.toString(value);
        if (text.length() >= width) {
            return text;
        }
        return "0".repeat(width - text.length()) + text;
    }

    private static ParsedTemplate parseTemplate(String template)
    {
        requireNonNull(template, "template is null");
        if (template.isEmpty()) {
            throw new IllegalArgumentException("datetime() format template is empty");
        }

        JsonDateTimeTemplateLexer lexer = new JsonDateTimeTemplateLexer(CharStreams.fromString(template));
        CommonTokenStream tokenStream = new CommonTokenStream(lexer);
        JsonDateTimeTemplateParser parser = new JsonDateTimeTemplateParser(tokenStream);

        lexer.removeErrorListeners();
        lexer.addErrorListener(ERROR_LISTENER);
        parser.removeErrorListeners();
        parser.addErrorListener(ERROR_LISTENER);

        JsonDateTimeTemplateParser.TemplateContext tree = parser.template();

        List<Token> tokens = new ArrayList<>();
        TemplateState state = new TemplateState();
        boolean previousWasLiteral = false;
        for (JsonDateTimeTemplateParser.TokenContext tokenContext : tree.token()) {
            if (tokenContext.field() != null) {
                FieldToken fieldToken = toFieldToken(tokenContext.field());
                state.add(fieldToken.field(), fieldToken.width());
                tokens.add(fieldToken);
                previousWasLiteral = false;
            }
            else {
                String literal = toLiteral(tokenContext.literal());
                if (literal.isEmpty()) {
                    throw new IllegalArgumentException("datetime() format template cannot contain empty quoted literal");
                }
                if (previousWasLiteral) {
                    throw new IllegalArgumentException("datetime() format template cannot contain consecutive delimiters");
                }
                tokens.add(new LiteralToken(literal));
                previousWasLiteral = true;
            }
        }

        if (state.isEmpty()) {
            throw new IllegalArgumentException("datetime() format template must contain at least one datetime field");
        }

        ImmutableList.Builder<Token> normalizedTokens = ImmutableList.builder();
        for (int index = 0; index < tokens.size(); index++) {
            Token token = tokens.get(index);
            if (token instanceof LiteralToken) {
                normalizedTokens.add(token);
                continue;
            }
            FieldToken fieldToken = (FieldToken) token;
            boolean delimited = (index == 0 || tokens.get(index - 1) instanceof LiteralToken) &&
                    (index == tokens.size() - 1 || tokens.get(index + 1) instanceof LiteralToken);
            normalizedTokens.add(new FieldToken(fieldToken.field(), fieldToken.width(), delimited));
        }

        return new ParsedTemplate(template, normalizedTokens.build(), state.type(), state.precision);
    }

    private static FieldToken toFieldToken(JsonDateTimeTemplateParser.FieldContext context)
    {
        int tokenType = context.getStart().getType();
        return switch (tokenType) {
            case JsonDateTimeTemplateLexer.YYYY -> new FieldToken(Field.YEAR, 4, false);
            case JsonDateTimeTemplateLexer.YYY -> new FieldToken(Field.YEAR, 3, false);
            case JsonDateTimeTemplateLexer.YY -> new FieldToken(Field.YEAR, 2, false);
            case JsonDateTimeTemplateLexer.Y -> new FieldToken(Field.YEAR, 1, false);
            case JsonDateTimeTemplateLexer.RRRR -> new FieldToken(Field.ROUNDED_YEAR, 4, false);
            case JsonDateTimeTemplateLexer.RR -> new FieldToken(Field.ROUNDED_YEAR, 2, false);
            case JsonDateTimeTemplateLexer.MM -> new FieldToken(Field.MONTH, 2, false);
            case JsonDateTimeTemplateLexer.DD -> new FieldToken(Field.DAY, 2, false);
            case JsonDateTimeTemplateLexer.DDD -> new FieldToken(Field.DAY_OF_YEAR, 3, false);
            case JsonDateTimeTemplateLexer.HH, JsonDateTimeTemplateLexer.HH12 -> new FieldToken(Field.HOUR12, 2, false);
            case JsonDateTimeTemplateLexer.HH24 -> new FieldToken(Field.HOUR24, 2, false);
            case JsonDateTimeTemplateLexer.MI -> new FieldToken(Field.MINUTE, 2, false);
            case JsonDateTimeTemplateLexer.SS -> new FieldToken(Field.SECOND, 2, false);
            case JsonDateTimeTemplateLexer.SSSSS -> new FieldToken(Field.SECOND_OF_DAY, 5, false);
            case JsonDateTimeTemplateLexer.FRACTION -> new FieldToken(Field.FRACTION, fractionWidth(context.getStart().getText()), false);
            case JsonDateTimeTemplateLexer.AM_PM -> new FieldToken(Field.AM_PM, 0, false);
            case JsonDateTimeTemplateLexer.TZH -> new FieldToken(Field.TIME_ZONE_HOUR, 3, false);
            case JsonDateTimeTemplateLexer.TZM -> new FieldToken(Field.TIME_ZONE_MINUTE, 2, false);
            default -> throw new IllegalStateException("unexpected datetime() template field token: " + context.getStart().getText());
        };
    }

    private static int fractionWidth(String text)
    {
        // FF1..FF9 are the standard widths; FF10..FF12 extend coverage to Trino's
        // maximum TIME / TIMESTAMP precision of 12.
        int width = Integer.parseInt(text.substring(2));
        if (width < 1 || width > 12) {
            throw new IllegalArgumentException("invalid datetime() format template fraction width: " + text);
        }
        return width;
    }

    private static String toLiteral(JsonDateTimeTemplateParser.LiteralContext context)
    {
        if (context.DELIMITER() != null) {
            return context.DELIMITER().getText();
        }
        // Strip surrounding quotes and unescape doubled embedded quotes.
        String quoted = context.QUOTED_LITERAL().getText();
        return quoted.substring(1, quoted.length() - 1).replace("\"\"", "\"");
    }

    private static final ANTLRErrorListener ERROR_LISTENER = new BaseErrorListener()
    {
        @Override
        public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String message, RecognitionException e)
        {
            throw new IllegalArgumentException(format("invalid datetime() format template at position %d: %s", charPositionInLine, message));
        }
    };

    @Override
    public boolean equals(Object object)
    {
        if (this == object) {
            return true;
        }
        if (!(object instanceof JsonDateTimeTemplate other)) {
            return false;
        }
        return precision == other.precision &&
                template.equals(other.template) &&
                type.equals(other.type);
    }

    @Override
    public int hashCode()
    {
        return Objects.hash(template, type, precision);
    }

    @Override
    public String toString()
    {
        return template;
    }

    private sealed interface Token
            permits FieldToken, LiteralToken {}

    private record LiteralToken(String literal)
            implements Token
    {
        private LiteralToken
        {
            requireNonNull(literal, "literal is null");
        }
    }

    private record FieldToken(Field field, int width, boolean delimited)
            implements Token
    {
        private FieldToken
        {
            requireNonNull(field, "field is null");
        }
    }

    private enum Field
    {
        YEAR,
        ROUNDED_YEAR,
        MONTH,
        DAY,
        DAY_OF_YEAR,
        HOUR12,
        HOUR24,
        MINUTE,
        SECOND,
        SECOND_OF_DAY,
        FRACTION,
        AM_PM,
        TIME_ZONE_HOUR,
        TIME_ZONE_MINUTE
    }

    private static final class TemplateState
    {
        private boolean year;
        private boolean roundedYear;
        private boolean month;
        private boolean day;
        private boolean dayOfYear;
        private boolean hour12;
        private boolean hour24;
        private boolean minute;
        private boolean second;
        private boolean secondOfDay;
        private boolean fraction;
        private boolean amPm;
        private boolean timeZoneHour;
        private boolean timeZoneMinute;
        private int precision;

        public void add(Field field, int width)
        {
            switch (field) {
                case YEAR -> checkUnique("year", year);
                case ROUNDED_YEAR -> checkUnique("rounded year", roundedYear);
                case MONTH -> checkUnique("month", month);
                case DAY -> checkUnique("day", day);
                case DAY_OF_YEAR -> checkUnique("day of year", dayOfYear);
                case HOUR12 -> checkUnique("12-hour field", hour12);
                case HOUR24 -> checkUnique("24-hour field", hour24);
                case MINUTE -> checkUnique("minute", minute);
                case SECOND -> checkUnique("second", second);
                case SECOND_OF_DAY -> checkUnique("second-of-day", secondOfDay);
                case FRACTION -> checkUnique("fraction", fraction);
                case AM_PM -> checkUnique("AM/PM", amPm);
                case TIME_ZONE_HOUR -> checkUnique("time zone hour", timeZoneHour);
                case TIME_ZONE_MINUTE -> checkUnique("time zone minute", timeZoneMinute);
            }

            switch (field) {
                case YEAR -> year = true;
                case ROUNDED_YEAR -> roundedYear = true;
                case MONTH -> month = true;
                case DAY -> day = true;
                case DAY_OF_YEAR -> dayOfYear = true;
                case HOUR12 -> hour12 = true;
                case HOUR24 -> hour24 = true;
                case MINUTE -> minute = true;
                case SECOND -> second = true;
                case SECOND_OF_DAY -> secondOfDay = true;
                case AM_PM -> amPm = true;
                case TIME_ZONE_HOUR -> timeZoneHour = true;
                case TIME_ZONE_MINUTE -> timeZoneMinute = true;
                case FRACTION -> {
                    fraction = true;
                    precision = Math.max(precision, width);
                }
            }
        }

        public boolean isEmpty()
        {
            return !(year || roundedYear || month || day || dayOfYear || hour12 || hour24 || minute || second || secondOfDay || fraction || amPm || timeZoneHour || timeZoneMinute);
        }

        public Type type()
        {
            validate();
            boolean hasDateFields = year || roundedYear || month || day || dayOfYear;
            boolean hasTimeFields = hour12 || hour24 || minute || second || secondOfDay || fraction || amPm;
            boolean hasTimeZoneFields = timeZoneHour || timeZoneMinute;

            if (hasDateFields) {
                if (hasTimeZoneFields) {
                    return createTimestampWithTimeZoneType(precision);
                }
                if (hasTimeFields) {
                    return createTimestampType(precision);
                }
                return DATE;
            }

            if (hasTimeZoneFields) {
                return createTimeWithTimeZoneType(precision);
            }
            return createTimeType(precision);
        }

        private void validate()
        {
            if (year && roundedYear) {
                throw new IllegalArgumentException("datetime() format template cannot contain both year and rounded year fields");
            }
            if (dayOfYear && (month || day)) {
                throw new IllegalArgumentException("datetime() format template with DDD cannot contain MM or DD");
            }
            if (hour24 && (hour12 || amPm)) {
                throw new IllegalArgumentException("datetime() format template with HH24 cannot contain HH, HH12, A.M. or P.M.");
            }
            if (hour12 && !amPm) {
                throw new IllegalArgumentException("datetime() format template with HH or HH12 requires A.M. or P.M.");
            }
            if (amPm && !hour12) {
                throw new IllegalArgumentException("datetime() format template with A.M. or P.M. requires HH or HH12");
            }
            if (secondOfDay && (hour12 || hour24 || minute || second || amPm)) {
                throw new IllegalArgumentException("datetime() format template with SSSSS cannot contain HH, HH12, HH24, MI, SS, A.M. or P.M.");
            }
            if (timeZoneMinute && !timeZoneHour) {
                throw new IllegalArgumentException("datetime() format template with TZM requires TZH");
            }
        }

        private static void checkUnique(String fieldName, boolean seen)
        {
            if (seen) {
                throw new IllegalArgumentException(format("datetime() format template contains duplicate %s field", fieldName));
            }
        }
    }

    private static final class ParsedValues
    {
        private OptionalInt year = OptionalInt.empty();
        private int yearDigits;
        private OptionalInt roundedYear = OptionalInt.empty();
        private int roundedYearDigits;
        private OptionalInt month = OptionalInt.empty();
        private OptionalInt day = OptionalInt.empty();
        private OptionalInt dayOfYear = OptionalInt.empty();
        private OptionalInt hour12 = OptionalInt.empty();
        private OptionalInt hour24 = OptionalInt.empty();
        private OptionalInt minute = OptionalInt.empty();
        private OptionalInt second = OptionalInt.empty();
        private OptionalInt secondOfDay = OptionalInt.empty();
        private boolean pm;
        private long fractionValue;
        private int fractionDigits;
        private OptionalInt timeZoneHour = OptionalInt.empty();
        private OptionalInt timeZoneMinute = OptionalInt.empty();

        // Fixed reference year (1970, per SQL:2023's use of epoch-based defaults) used to fill in the
        // century/millennium prefix when the template specifies only low-order year digits.
        private static final int REFERENCE_YEAR = 1970;

        public int resolveYear()
        {
            if (year.isPresent()) {
                return prefixYear(REFERENCE_YEAR, year.getAsInt(), yearDigits);
            }
            if (roundedYear.isPresent()) {
                return roundYear(REFERENCE_YEAR, roundedYear.getAsInt(), roundedYearDigits);
            }
            return REFERENCE_YEAR;
        }

        public int resolveHour()
        {
            if (secondOfDay.isPresent()) {
                return floorDiv(secondOfDay.getAsInt(), 3600);
            }
            if (hour24.isPresent()) {
                return hour24.getAsInt();
            }
            if (hour12.isPresent()) {
                int hour = hour12.getAsInt() % 12;
                if (pm) {
                    hour += 12;
                }
                return hour;
            }
            return 0;
        }

        public int resolveMinute()
        {
            if (secondOfDay.isPresent()) {
                return floorDiv(floorMod(secondOfDay.getAsInt(), 3600), 60);
            }
            return minute.orElse(0);
        }

        public int resolveSecond()
        {
            if (secondOfDay.isPresent()) {
                return floorMod(secondOfDay.getAsInt(), 60);
            }
            return second.orElse(0);
        }

        public String resolveOffset(int currentOffsetSeconds)
        {
            int totalOffsetSeconds = currentOffsetSeconds;
            if (timeZoneHour.isPresent()) {
                int offsetHour = timeZoneHour.getAsInt();
                int sign = offsetHour < 0 ? -1 : 1;
                int offsetMinute = timeZoneMinute.orElse(0);
                totalOffsetSeconds = sign * (Math.abs(offsetHour) * 3600 + offsetMinute * 60);
            }
            int absoluteOffsetSeconds = Math.abs(totalOffsetSeconds);
            int offsetHours = absoluteOffsetSeconds / 3600;
            int offsetMinutes = (absoluteOffsetSeconds % 3600) / 60;
            char sign = totalOffsetSeconds < 0 ? '-' : '+';
            return format(" %c%02d:%02d", sign, offsetHours, offsetMinutes);
        }

        private static int prefixYear(int currentYear, int value, int digits)
        {
            if (digits >= 4) {
                return value;
            }
            int prefix = floorDiv(currentYear, pow10(digits));
            return prefix * pow10(digits) + value;
        }

        private static int roundYear(int currentYear, int value, int digits)
        {
            if (digits > 2) {
                return value;
            }

            int currentCentury = floorDiv(currentYear, 100) * 100;
            int currentTwoDigits = floorMod(currentYear, 100);
            if (currentTwoDigits <= 49) {
                return value <= 49 ? currentCentury + value : currentCentury - 100 + value;
            }
            return value <= 49 ? currentCentury + 100 + value : currentCentury + value;
        }

        private static int pow10(int exponent)
        {
            int value = 1;
            for (int index = 0; index < exponent; index++) {
                value *= 10;
            }
            return value;
        }
    }

    private record ParsedTemplate(String template, List<Token> tokens, Type type, int precision) {}

    private static final class Cursor
    {
        private final String value;
        private int position;
        private String previousDigits = "";

        private Cursor(String value)
        {
            this.value = requireNonNull(value, "value is null");
        }

        public boolean atEnd()
        {
            return position == value.length();
        }

        public char current()
        {
            return value.charAt(position);
        }

        public int position()
        {
            return position;
        }

        public void expect(String literal)
        {
            if (!value.startsWith(literal, position)) {
                throw new IllegalArgumentException(format("expected literal '%s' at position %d", literal, position));
            }
            position += literal.length();
        }

        public boolean regionMatchesIgnoreCase(String text)
        {
            return value.regionMatches(true, position, text, 0, text.length());
        }

        public void advance(int length)
        {
            position += length;
        }

        public String readDigits(int minimumDigits, int maximumDigits)
        {
            int start = position;
            int count = 0;
            while (position < value.length() && isDigit(value.charAt(position)) && count < maximumDigits) {
                position++;
                count++;
            }
            if (count < minimumDigits) {
                throw new IllegalArgumentException(format("expected at least %d digits at position %d", minimumDigits, start));
            }
            previousDigits = value.substring(start, position);
            return previousDigits;
        }

        public String readFixedDigits(int digits)
        {
            int start = position;
            String result = readDigits(digits, digits);
            if (result.length() != digits) {
                throw new IllegalArgumentException(format("expected %d digits at position %d", digits, start));
            }
            return result;
        }

        public String previousDigits()
        {
            return previousDigits;
        }
    }
}
