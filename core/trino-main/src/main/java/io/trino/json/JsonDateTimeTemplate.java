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
import io.trino.json.ir.TypedValue;
import io.trino.spi.connector.ConnectorSession;
import io.trino.spi.type.TimeType;
import io.trino.spi.type.TimeWithTimeZoneType;
import io.trino.spi.type.TimestampType;
import io.trino.spi.type.TimestampWithTimeZoneType;
import io.trino.spi.type.Type;

import java.time.LocalDate;
import java.time.ZonedDateTime;
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
        this(template, type, precision, parseTemplate(template).tokens());
        if (!this.type.equals(type)) {
            throw new IllegalArgumentException(format("datetime() template type mismatch: expected %s, found %s", this.type.getDisplayName(), type.getDisplayName()));
        }
        if (this.precision != precision) {
            throw new IllegalArgumentException(format("datetime() template precision mismatch: expected %s, found %s", this.precision, precision));
        }
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

    public TypedValue parseValue(String value, ConnectorSession session)
    {
        requireNonNull(value, "value is null");
        requireNonNull(session, "session is null");

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

        ZonedDateTime current = ZonedDateTime.ofInstant(session.getStart(), session.getTimeZoneKey().getZoneId());
        return buildTypedValue(parsedValues, current);
    }

    private TypedValue buildTypedValue(ParsedValues parsedValues, ZonedDateTime current)
    {
        int year = parsedValues.resolveYear(current);
        if (parsedValues.dayOfYear.isPresent()) {
            LocalDate date = LocalDate.ofYearDay(year, parsedValues.dayOfYear.getAsInt());
            year = date.getYear();
            parsedValues.month = OptionalInt.of(date.getMonthValue());
            parsedValues.day = OptionalInt.of(date.getDayOfMonth());
        }

        int month = parsedValues.month.orElse(current.getMonthValue());
        int day = parsedValues.day.orElse(current.getDayOfMonth());
        int hour = parsedValues.resolveHour(current);
        int minute = parsedValues.resolveMinute(current);
        int second = parsedValues.resolveSecond(current);

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

        String offset = parsedValues.resolveOffset(current.getZone().getRules().getOffset(current.toInstant()).getTotalSeconds());
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
                values.fractionValue = readUnsignedNumber(cursor, token, 1, token.width());
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
        throw new IllegalArgumentException("invalid AM/PM marker");
    }

    private static OptionalInt readTimeZoneHour(Cursor cursor, FieldToken token)
    {
        if (cursor.atEnd()) {
            throw new IllegalArgumentException("expected time zone hour");
        }

        char signCharacter = cursor.current();
        if (signCharacter != '+' && signCharacter != '-' && signCharacter != ' ') {
            throw new IllegalArgumentException("time zone hour must start with '+', '-' or space");
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

        List<Token> tokens = new ArrayList<>();
        TemplateState state = new TemplateState();
        boolean previousWasDelimiter = false;
        int position = 0;
        while (position < template.length()) {
            FieldMatch fieldMatch = FieldMatch.match(template, position);
            if (fieldMatch != null) {
                state.add(fieldMatch.field(), fieldMatch.width());
                tokens.add(new FieldToken(fieldMatch.field(), fieldMatch.width(), false));
                previousWasDelimiter = false;
                position += fieldMatch.length();
                continue;
            }

            char character = template.charAt(position);
            if (!isDelimiter(character)) {
                throw new IllegalArgumentException(format("invalid datetime() template character: %s", character));
            }
            if (previousWasDelimiter) {
                throw new IllegalArgumentException("datetime() format template cannot contain consecutive delimiters");
            }
            tokens.add(new LiteralToken(String.valueOf(character)));
            previousWasDelimiter = true;
            position++;
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

    private static boolean isDelimiter(char character)
    {
        return switch (character) {
            case '-', '.', '/', ',', '\'', ';', ':', ' ' -> true;
            default -> false;
        };
    }

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

    private record FieldMatch(Field field, int width, int length)
    {
        private static final List<FieldMatch> PATTERNS = ImmutableList.of(
                new FieldMatch(Field.ROUNDED_YEAR, 4, 4),
                new FieldMatch(Field.HOUR24, 2, 4),
                new FieldMatch(Field.HOUR12, 2, 4),
                new FieldMatch(Field.YEAR, 4, 4),
                new FieldMatch(Field.AM_PM, 0, 4),
                new FieldMatch(Field.DAY_OF_YEAR, 3, 3),
                new FieldMatch(Field.SECOND_OF_DAY, 5, 5),
                new FieldMatch(Field.TIME_ZONE_HOUR, 3, 3),
                new FieldMatch(Field.TIME_ZONE_MINUTE, 2, 3),
                new FieldMatch(Field.ROUNDED_YEAR, 2, 2),
                new FieldMatch(Field.YEAR, 3, 3),
                new FieldMatch(Field.HOUR12, 2, 2),
                new FieldMatch(Field.YEAR, 2, 2),
                new FieldMatch(Field.MONTH, 2, 2),
                new FieldMatch(Field.DAY, 2, 2),
                new FieldMatch(Field.MINUTE, 2, 2),
                new FieldMatch(Field.SECOND, 2, 2),
                new FieldMatch(Field.YEAR, 1, 1));

        private static FieldMatch match(String template, int position)
        {
            for (FieldMatch pattern : PATTERNS) {
                if (matches(template, position, pattern)) {
                    return pattern;
                }
            }
            if (position + 3 <= template.length() &&
                    template.regionMatches(true, position, "FF", 0, 2) &&
                    isDigit(template.charAt(position + 2))) {
                int precision = template.charAt(position + 2) - '0';
                if (precision >= 1 && precision <= 9) {
                    return new FieldMatch(Field.FRACTION, precision, 3);
                }
            }
            return null;
        }

        private static boolean matches(String template, int position, FieldMatch pattern)
        {
            return switch (pattern.field()) {
                case AM_PM -> template.regionMatches(true, position, "A.M.", 0, 4) || template.regionMatches(true, position, "P.M.", 0, 4);
                case YEAR -> switch (pattern.width()) {
                    case 4 -> template.regionMatches(true, position, "YYYY", 0, 4);
                    case 3 -> template.regionMatches(true, position, "YYY", 0, 3);
                    case 2 -> template.regionMatches(true, position, "YY", 0, 2);
                    case 1 -> template.regionMatches(true, position, "Y", 0, 1);
                    default -> false;
                };
                case ROUNDED_YEAR -> switch (pattern.width()) {
                    case 4 -> template.regionMatches(true, position, "RRRR", 0, 4);
                    case 2 -> template.regionMatches(true, position, "RR", 0, 2);
                    default -> false;
                };
                case HOUR12 -> switch (pattern.length()) {
                    case 4 -> template.regionMatches(true, position, "HH12", 0, 4);
                    case 2 -> template.regionMatches(true, position, "HH", 0, 2);
                    default -> false;
                };
                case HOUR24 -> template.regionMatches(true, position, "HH24", 0, 4);
                case MONTH -> template.regionMatches(true, position, "MM", 0, 2);
                case DAY -> template.regionMatches(true, position, "DD", 0, 2);
                case DAY_OF_YEAR -> template.regionMatches(true, position, "DDD", 0, 3);
                case MINUTE -> template.regionMatches(true, position, "MI", 0, 2);
                case SECOND -> template.regionMatches(true, position, "SS", 0, 2);
                case SECOND_OF_DAY -> template.regionMatches(true, position, "SSSSS", 0, 5);
                case TIME_ZONE_HOUR -> template.regionMatches(true, position, "TZH", 0, 3);
                case TIME_ZONE_MINUTE -> template.regionMatches(true, position, "TZM", 0, 3);
                case FRACTION -> false;
            };
        }
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

        public int resolveYear(ZonedDateTime current)
        {
            if (year.isPresent()) {
                return prefixYear(current.getYear(), year.getAsInt(), yearDigits);
            }
            if (roundedYear.isPresent()) {
                return roundYear(current.getYear(), roundedYear.getAsInt(), roundedYearDigits);
            }
            return current.getYear();
        }

        public int resolveHour(ZonedDateTime current)
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
            return current.getHour();
        }

        public int resolveMinute(ZonedDateTime current)
        {
            if (secondOfDay.isPresent()) {
                return floorDiv(floorMod(secondOfDay.getAsInt(), 3600), 60);
            }
            return minute.orElse(current.getMinute());
        }

        public int resolveSecond(ZonedDateTime current)
        {
            if (secondOfDay.isPresent()) {
                return floorMod(secondOfDay.getAsInt(), 60);
            }
            return second.orElse(current.getSecond());
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

        public void expect(String literal)
        {
            if (!value.startsWith(literal, position)) {
                throw new IllegalArgumentException(format("expected literal '%s'", literal));
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
                throw new IllegalArgumentException("expected digits");
            }
            previousDigits = value.substring(start, position);
            return previousDigits;
        }

        public String readFixedDigits(int digits)
        {
            String result = readDigits(digits, digits);
            if (result.length() != digits) {
                throw new IllegalArgumentException("expected fixed-width digits");
            }
            return result;
        }

        public String previousDigits()
        {
            return previousDigits;
        }
    }
}
