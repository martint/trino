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
package io.trino.sql;

import com.google.common.base.CharMatcher;
import com.google.common.base.Joiner;
import com.google.common.collect.ImmutableList;
import io.trino.sql.ir.ArithmeticBinaryExpression;
import io.trino.sql.ir.ArithmeticUnaryExpression;
import io.trino.sql.ir.ArrayConstructor;
import io.trino.sql.ir.AtTimeZone;
import io.trino.sql.ir.BetweenPredicate;
import io.trino.sql.ir.BinaryLiteral;
import io.trino.sql.ir.BindExpression;
import io.trino.sql.ir.BooleanLiteral;
import io.trino.sql.ir.Cast;
import io.trino.sql.ir.CharLiteral;
import io.trino.sql.ir.CoalesceExpression;
import io.trino.sql.ir.ComparisonExpression;
import io.trino.sql.ir.CurrentCatalog;
import io.trino.sql.ir.CurrentPath;
import io.trino.sql.ir.CurrentSchema;
import io.trino.sql.ir.CurrentTime;
import io.trino.sql.ir.CurrentUser;
import io.trino.sql.ir.DateTimeDataType;
import io.trino.sql.ir.DecimalLiteral;
import io.trino.sql.ir.DereferenceExpression;
import io.trino.sql.ir.DoubleLiteral;
import io.trino.sql.ir.Expression;
import io.trino.sql.ir.Extract;
import io.trino.sql.ir.FieldReference;
import io.trino.sql.ir.Format;
import io.trino.sql.ir.FunctionCall;
import io.trino.sql.ir.GenericDataType;
import io.trino.sql.ir.GenericLiteral;
import io.trino.sql.ir.Identifier;
import io.trino.sql.ir.IfExpression;
import io.trino.sql.ir.InListExpression;
import io.trino.sql.ir.InPredicate;
import io.trino.sql.ir.IntervalDayTimeDataType;
import io.trino.sql.ir.IntervalLiteral;
import io.trino.sql.ir.IrVisitor;
import io.trino.sql.ir.IsNotNullPredicate;
import io.trino.sql.ir.IsNullPredicate;
import io.trino.sql.ir.JsonArray;
import io.trino.sql.ir.JsonExists;
import io.trino.sql.ir.JsonObject;
import io.trino.sql.ir.JsonPathInvocation;
import io.trino.sql.ir.JsonPathParameter;
import io.trino.sql.ir.JsonQuery;
import io.trino.sql.ir.JsonValue;
import io.trino.sql.ir.LabelDereference;
import io.trino.sql.ir.LambdaArgumentDeclaration;
import io.trino.sql.ir.LambdaExpression;
import io.trino.sql.ir.LikePredicate;
import io.trino.sql.ir.LogicalExpression;
import io.trino.sql.ir.LongLiteral;
import io.trino.sql.ir.NotExpression;
import io.trino.sql.ir.NullIfExpression;
import io.trino.sql.ir.NullLiteral;
import io.trino.sql.ir.NumericParameter;
import io.trino.sql.ir.QualifiedName;
import io.trino.sql.ir.QuantifiedComparisonExpression;
import io.trino.sql.ir.Row;
import io.trino.sql.ir.RowDataType;
import io.trino.sql.ir.SearchedCaseExpression;
import io.trino.sql.ir.SimpleCaseExpression;
import io.trino.sql.ir.StringLiteral;
import io.trino.sql.ir.SubscriptExpression;
import io.trino.sql.ir.SymbolReference;
import io.trino.sql.ir.TimeLiteral;
import io.trino.sql.ir.TimestampLiteral;
import io.trino.sql.ir.Trim;
import io.trino.sql.ir.TryExpression;
import io.trino.sql.ir.TypeParameter;
import io.trino.sql.ir.WhenClause;

import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.List;
import java.util.Locale;
import java.util.Optional;
import java.util.PrimitiveIterator;

import static com.google.common.base.Preconditions.checkArgument;
import static java.lang.String.format;
import static java.util.stream.Collectors.joining;
import static java.util.stream.Collectors.toList;

public final class IrExpressionFormatter
{
    private static final ThreadLocal<DecimalFormat> doubleFormatter = ThreadLocal.withInitial(
            () -> new DecimalFormat("0.###################E0###", new DecimalFormatSymbols(Locale.US)));

    private IrExpressionFormatter() {}

    public static String formatExpression(Expression expression)
    {
        return new Formatter().process(expression, null);
    }

    private static String formatIdentifier(String s)
    {
        return '"' + s.replace("\"", "\"\"") + '"';
    }

    public static class Formatter
            extends IrVisitor<String, Void>
    {
        @Override
        protected String visitRow(Row node, Void context)
        {
            return "ROW (" + Joiner.on(", ").join(node.getItems().stream()
                    .map(child -> process(child, context))
                    .collect(toList())) + ")";
        }

        @Override
        protected String visitExpression(Expression node, Void context)
        {
            throw new UnsupportedOperationException(format("not yet implemented: %s.visit%s", getClass().getName(), node.getClass().getSimpleName()));
        }

        @Override
        protected String visitAtTimeZone(AtTimeZone node, Void context)
        {
            return new StringBuilder()
                    .append(process(node.getValue(), context))
                    .append(" AT TIME ZONE ")
                    .append(process(node.getTimeZone(), context)).toString();
        }

        @Override
        protected String visitCurrentCatalog(CurrentCatalog node, Void context)
        {
            return "CURRENT_CATALOG";
        }

        @Override
        protected String visitCurrentSchema(CurrentSchema node, Void context)
        {
            return "CURRENT_SCHEMA";
        }

        @Override
        protected String visitCurrentUser(CurrentUser node, Void context)
        {
            return "CURRENT_USER";
        }

        @Override
        protected String visitCurrentPath(CurrentPath node, Void context)
        {
            return "CURRENT_PATH";
        }

        @Override
        protected String visitTrim(Trim node, Void context)
        {
            if (!node.getTrimCharacter().isPresent()) {
                return format("trim(%s FROM %s)", node.getSpecification(), process(node.getTrimSource(), context));
            }

            return format("trim(%s %s FROM %s)", node.getSpecification(), process(node.getTrimCharacter().get(), context), process(node.getTrimSource(), context));
        }

        @Override
        protected String visitFormat(Format node, Void context)
        {
            return "format(" + joinExpressions(node.getArguments()) + ")";
        }

        @Override
        protected String visitCurrentTime(CurrentTime node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append(node.getFunction().getName());

            if (node.getPrecision() != null) {
                builder.append('(')
                        .append(node.getPrecision())
                        .append(')');
            }

            return builder.toString();
        }

        @Override
        protected String visitExtract(Extract node, Void context)
        {
            return "EXTRACT(" + node.getField() + " FROM " + process(node.getExpression(), context) + ")";
        }

        @Override
        protected String visitBooleanLiteral(BooleanLiteral node, Void context)
        {
            return String.valueOf(node.getValue());
        }

        @Override
        protected String visitStringLiteral(StringLiteral node, Void context)
        {
            return formatStringLiteral(node.getValue());
        }

        @Override
        protected String visitCharLiteral(CharLiteral node, Void context)
        {
            return "CHAR " + formatStringLiteral(node.getValue());
        }

        @Override
        protected String visitBinaryLiteral(BinaryLiteral node, Void context)
        {
            return "X'" + node.toHexString() + "'";
        }

        @Override
        protected String visitArrayConstructor(ArrayConstructor node, Void context)
        {
            ImmutableList.Builder<String> valueStrings = ImmutableList.builder();
            for (Expression value : node.getValues()) {
                valueStrings.add(value.toString());
            }
            return "ARRAY[" + Joiner.on(",").join(valueStrings.build()) + "]";
        }

        @Override
        protected String visitSubscriptExpression(SubscriptExpression node, Void context)
        {
            return node.getBase() + "[" + node.getIndex() + "]";
        }

        @Override
        protected String visitLongLiteral(LongLiteral node, Void context)
        {
            return Long.toString(node.getValue());
        }

        @Override
        protected String visitDoubleLiteral(DoubleLiteral node, Void context)
        {
            return doubleFormatter.get().format(node.getValue());
        }

        @Override
        protected String visitDecimalLiteral(DecimalLiteral node, Void context)
        {
            // TODO return node value without "DECIMAL '..'" when FeaturesConfig#parseDecimalLiteralsAsDouble switch is removed
            return "DECIMAL '" + node.getValue() + "'";
        }

        @Override
        protected String visitGenericLiteral(GenericLiteral node, Void context)
        {
            return node.getType() + " " + formatStringLiteral(node.getValue());
        }

        @Override
        protected String visitTimeLiteral(TimeLiteral node, Void context)
        {
            return "TIME '" + node.getValue() + "'";
        }

        @Override
        protected String visitTimestampLiteral(TimestampLiteral node, Void context)
        {
            return "TIMESTAMP '" + node.getValue() + "'";
        }

        @Override
        protected String visitNullLiteral(NullLiteral node, Void context)
        {
            return "null";
        }

        @Override
        protected String visitIntervalLiteral(IntervalLiteral node, Void context)
        {
            String sign = (node.getSign() == io.trino.sql.tree.IntervalLiteral.Sign.NEGATIVE) ? "- " : "";
            StringBuilder builder = new StringBuilder()
                    .append("INTERVAL ")
                    .append(sign)
                    .append(" '").append(node.getValue()).append("' ")
                    .append(node.getStartField());

            if (node.getEndField().isPresent()) {
                builder.append(" TO ").append(node.getEndField().get());
            }
            return builder.toString();
        }

        @Override
        protected String visitIdentifier(Identifier node, Void context)
        {
            if (!node.isDelimited()) {
                return node.getValue();
            }
            else {
                return '"' + node.getValue().replace("\"", "\"\"") + '"';
            }
        }

        @Override
        protected String visitLambdaArgumentDeclaration(LambdaArgumentDeclaration node, Void context)
        {
            return formatExpression(node.getName());
        }

        @Override
        protected String visitSymbolReference(SymbolReference node, Void context)
        {
            return formatIdentifier(node.getName());
        }

        @Override
        protected String visitDereferenceExpression(DereferenceExpression node, Void context)
        {
            String baseString = process(node.getBase(), context);
            return baseString + "." + node.getField().map(this::process).orElse("*");
        }

        @Override
        public String visitFieldReference(FieldReference node, Void context)
        {
            // add colon so this won't parse
            return ":input(" + node.getFieldIndex() + ")";
        }

        @Override
        protected String visitFunctionCall(FunctionCall node, Void context)
        {
            if (QualifiedName.of("LISTAGG").equals(node.getName())) {
                return visitListagg(node);
            }

            StringBuilder builder = new StringBuilder();

            String arguments = joinExpressions(node.getArguments());
            if (node.getArguments().isEmpty() && "count".equalsIgnoreCase(node.getName().getSuffix())) {
                arguments = "*";
            }
            if (node.isDistinct()) {
                arguments = "DISTINCT " + arguments;
            }

            builder.append(formatName(node.getName()))
                    .append('(').append(arguments);

            builder.append(')');

            node.getNullTreatment().ifPresent(nullTreatment -> {
                switch (nullTreatment) {
                    case IGNORE:
                        builder.append(" IGNORE NULLS");
                        break;
                    case RESPECT:
                        builder.append(" RESPECT NULLS");
                        break;
                }
            });

            if (node.getFilter().isPresent()) {
                builder.append(" FILTER ").append(visitFilter(node.getFilter().get(), context));
            }

            return builder.toString();
        }

        @Override
        protected String visitLambdaExpression(LambdaExpression node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append('(');
            Joiner.on(", ").appendTo(builder, node.getArguments());
            builder.append(") -> ");
            builder.append(process(node.getBody(), context));
            return builder.toString();
        }

        @Override
        protected String visitBindExpression(BindExpression node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("\"$INTERNAL$BIND\"(");
            for (Expression value : node.getValues()) {
                builder.append(process(value, context))
                        .append(", ");
            }
            builder.append(process(node.getFunction(), context))
                    .append(")");
            return builder.toString();
        }

        @Override
        protected String visitLogicalExpression(LogicalExpression node, Void context)
        {
            return "(" +
                    node.getTerms().stream()
                            .map(term -> process(term, context))
                            .collect(joining(" " + node.getOperator().toString() + " ")) +
                    ")";
        }

        @Override
        protected String visitNotExpression(NotExpression node, Void context)
        {
            return "(NOT " + process(node.getValue(), context) + ")";
        }

        @Override
        protected String visitComparisonExpression(ComparisonExpression node, Void context)
        {
            return formatBinaryExpression(node.getOperator().getValue(), node.getLeft(), node.getRight());
        }

        @Override
        protected String visitIsNullPredicate(IsNullPredicate node, Void context)
        {
            return "(" + process(node.getValue(), context) + " IS NULL)";
        }

        @Override
        protected String visitIsNotNullPredicate(IsNotNullPredicate node, Void context)
        {
            return "(" + process(node.getValue(), context) + " IS NOT NULL)";
        }

        @Override
        protected String visitNullIfExpression(NullIfExpression node, Void context)
        {
            return "NULLIF(" + process(node.getFirst(), context) + ", " + process(node.getSecond(), context) + ')';
        }

        @Override
        protected String visitIfExpression(IfExpression node, Void context)
        {
            StringBuilder builder = new StringBuilder();
            builder.append("IF(")
                    .append(process(node.getCondition(), context))
                    .append(", ")
                    .append(process(node.getTrueValue(), context));
            if (node.getFalseValue().isPresent()) {
                builder.append(", ")
                        .append(process(node.getFalseValue().get(), context));
            }
            builder.append(")");
            return builder.toString();
        }

        @Override
        protected String visitTryExpression(TryExpression node, Void context)
        {
            return "TRY(" + process(node.getInnerExpression(), context) + ")";
        }

        @Override
        protected String visitCoalesceExpression(CoalesceExpression node, Void context)
        {
            return "COALESCE(" + joinExpressions(node.getOperands()) + ")";
        }

        @Override
        protected String visitArithmeticUnary(ArithmeticUnaryExpression node, Void context)
        {
            String value = process(node.getValue(), context);

            switch (node.getSign()) {
                case MINUS:
                    // Unary is ambiguous with respect to negative numbers. "-1" parses as a number, but "-(1)" parses as "unaryMinus(number)"
                    // The parentheses are needed to ensure the parsing roundtrips properly.
                    return "-(" + value + ")";
                case PLUS:
                    return "+" + value;
            }
            throw new UnsupportedOperationException("Unsupported sign: " + node.getSign());
        }

        @Override
        protected String visitArithmeticBinary(ArithmeticBinaryExpression node, Void context)
        {
            return formatBinaryExpression(node.getOperator().getValue(), node.getLeft(), node.getRight());
        }

        @Override
        protected String visitLikePredicate(LikePredicate node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append('(')
                    .append(process(node.getValue(), context))
                    .append(" LIKE ")
                    .append(process(node.getPattern(), context));

            node.getEscape().ifPresent(escape -> builder.append(" ESCAPE ")
                    .append(process(escape, context)));

            builder.append(')');

            return builder.toString();
        }

        @Override
        public String visitCast(Cast node, Void context)
        {
            return (node.isSafe() ? "TRY_CAST" : "CAST") +
                    "(" + process(node.getExpression(), context) + " AS " + process(node.getType(), context) + ")";
        }

        @Override
        protected String visitSearchedCaseExpression(SearchedCaseExpression node, Void context)
        {
            ImmutableList.Builder<String> parts = ImmutableList.builder();
            parts.add("CASE");
            for (WhenClause whenClause : node.getWhenClauses()) {
                parts.add(process(whenClause, context));
            }

            node.getDefaultValue()
                    .ifPresent(value -> parts.add("ELSE").add(process(value, context)));

            parts.add("END");

            return "(" + Joiner.on(' ').join(parts.build()) + ")";
        }

        @Override
        protected String visitSimpleCaseExpression(SimpleCaseExpression node, Void context)
        {
            ImmutableList.Builder<String> parts = ImmutableList.builder();

            parts.add("CASE")
                    .add(process(node.getOperand(), context));

            for (WhenClause whenClause : node.getWhenClauses()) {
                parts.add(process(whenClause, context));
            }

            node.getDefaultValue()
                    .ifPresent(value -> parts.add("ELSE").add(process(value, context)));

            parts.add("END");

            return "(" + Joiner.on(' ').join(parts.build()) + ")";
        }

        @Override
        protected String visitWhenClause(WhenClause node, Void context)
        {
            return "WHEN " + process(node.getOperand(), context) + " THEN " + process(node.getResult(), context);
        }

        @Override
        protected String visitBetweenPredicate(BetweenPredicate node, Void context)
        {
            return "(" + process(node.getValue(), context) + " BETWEEN " +
                    process(node.getMin(), context) + " AND " + process(node.getMax(), context) + ")";
        }

        @Override
        protected String visitInPredicate(InPredicate node, Void context)
        {
            return "(" + process(node.getValue(), context) + " IN " + process(node.getValueList(), context) + ")";
        }

        @Override
        protected String visitInListExpression(InListExpression node, Void context)
        {
            return "(" + joinExpressions(node.getValues()) + ")";
        }

        private String visitFilter(Expression node, Void context)
        {
            return "(WHERE " + process(node, context) + ')';
        }

        @Override
        protected String visitQuantifiedComparisonExpression(QuantifiedComparisonExpression node, Void context)
        {
            return new StringBuilder()
                    .append("(")
                    .append(process(node.getValue(), context))
                    .append(' ')
                    .append(node.getOperator().getValue())
                    .append(' ')
                    .append(node.getQuantifier().toString())
                    .append(' ')
                    .append(process(node.getSubquery(), context))
                    .append(")")
                    .toString();
        }

        @Override
        protected String visitRowDataType(RowDataType node, Void context)
        {
            return node.getFields().stream()
                    .map(this::process)
                    .collect(joining(", ", "ROW(", ")"));
        }

        @Override
        protected String visitRowField(RowDataType.Field node, Void context)
        {
            StringBuilder result = new StringBuilder();

            if (node.getName().isPresent()) {
                result.append(process(node.getName().get(), context));
                result.append(" ");
            }

            result.append(process(node.getType(), context));

            return result.toString();
        }

        @Override
        protected String visitGenericDataType(GenericDataType node, Void context)
        {
            StringBuilder result = new StringBuilder();
            result.append(node.getName());

            if (!node.getArguments().isEmpty()) {
                result.append(node.getArguments().stream()
                        .map(this::process)
                        .collect(joining(", ", "(", ")")));
            }

            return result.toString();
        }

        @Override
        protected String visitTypeParameter(TypeParameter node, Void context)
        {
            return process(node.getType(), context);
        }

        @Override
        protected String visitNumericTypeParameter(NumericParameter node, Void context)
        {
            return node.getValue();
        }

        @Override
        protected String visitIntervalDataType(IntervalDayTimeDataType node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("INTERVAL ");
            builder.append(node.getFrom());
            if (node.getFrom() != node.getTo()) {
                builder.append(" TO ")
                        .append(node.getTo());
            }

            return builder.toString();
        }

        @Override
        protected String visitDateTimeType(DateTimeDataType node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append(node.getType().toString().toLowerCase(Locale.ENGLISH)); // TODO: normalize to upper case according to standard SQL semantics
            if (node.getPrecision().isPresent()) {
                builder.append("(")
                        .append(node.getPrecision().get())
                        .append(")");
            }

            if (node.isWithTimeZone()) {
                builder.append(" with time zone"); // TODO: normalize to upper case according to standard SQL semantics
            }

            return builder.toString();
        }

        @Override
        protected String visitLabelDereference(LabelDereference node, Void context)
        {
            // format LabelDereference L.x as "LABEL_DEREFERENCE("L", "x")"
            // LabelDereference, like SymbolReference, is an IR-type expression. It is never a result of the parser.
            // After being formatted this way for serialization, it will be parsed as functionCall
            // and swapped back for LabelDereference.
            return "LABEL_DEREFERENCE(" + formatIdentifier(node.getLabel()) + ", " + node.getReference().map(this::process).orElse("*") + ")";
        }

        @Override
        protected String visitJsonExists(JsonExists node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("JSON_EXISTS(")
                    .append(formatJsonPathInvocation(node.getJsonPathInvocation()))
                    .append(" ")
                    .append(node.getErrorBehavior())
                    .append(" ON ERROR")
                    .append(")");

            return builder.toString();
        }

        @Override
        protected String visitJsonValue(JsonValue node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("JSON_VALUE(")
                    .append(formatJsonPathInvocation(node.getJsonPathInvocation()));

            if (node.getReturnedType().isPresent()) {
                builder.append(" RETURNING ")
                        .append(process(node.getReturnedType().get()));
            }

            builder.append(" ")
                    .append(node.getEmptyBehavior())
                    .append(node.getEmptyDefault().map(expression -> " " + process(expression)).orElse(""))
                    .append(" ON EMPTY ")
                    .append(node.getErrorBehavior())
                    .append(node.getErrorDefault().map(expression -> " " + process(expression)).orElse(""))
                    .append(" ON ERROR")
                    .append(")");

            return builder.toString();
        }

        @Override
        protected String visitJsonQuery(JsonQuery node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("JSON_QUERY(")
                    .append(formatJsonPathInvocation(node.getJsonPathInvocation()));

            if (node.getReturnedType().isPresent()) {
                builder.append(" RETURNING ")
                        .append(process(node.getReturnedType().get()))
                        .append(node.getOutputFormat().map(string -> " FORMAT " + string).orElse(""));
            }

            switch (node.getWrapperBehavior()) {
                case WITHOUT:
                    builder.append(" WITHOUT ARRAY WRAPPER");
                    break;
                case CONDITIONAL:
                    builder.append(" WITH CONDITIONAL ARRAY WRAPPER");
                    break;
                case UNCONDITIONAL:
                    builder.append((" WITH UNCONDITIONAL ARRAY WRAPPER"));
                    break;
                default:
                    throw new IllegalStateException("unexpected array wrapper behavior: " + node.getWrapperBehavior());
            }

            if (node.getQuotesBehavior().isPresent()) {
                switch (node.getQuotesBehavior().get()) {
                    case KEEP:
                        builder.append(" KEEP QUOTES ON SCALAR STRING");
                        break;
                    case OMIT:
                        builder.append(" OMIT QUOTES ON SCALAR STRING");
                        break;
                    default:
                        throw new IllegalStateException("unexpected quotes behavior: " + node.getQuotesBehavior());
                }
            }

            builder.append(" ")
                    .append(node.getEmptyBehavior())
                    .append(" ON EMPTY ")
                    .append(node.getErrorBehavior())
                    .append(" ON ERROR")
                    .append(")");

            return builder.toString();
        }

        @Override
        protected String visitJsonObject(JsonObject node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("JSON_OBJECT(");

            if (!node.getMembers().isEmpty()) {
                builder.append(node.getMembers().stream()
                        .map(member -> "KEY " + formatExpression(member.getKey()) + " VALUE " + formatJsonExpression(member.getValue(), member.getFormat()))
                        .collect(joining(", ")));
                builder.append(node.isNullOnNull() ? " NULL ON NULL" : " ABSENT ON NULL");
                builder.append(node.isUniqueKeys() ? " WITH UNIQUE KEYS" : " WITHOUT UNIQUE KEYS");
            }

            if (node.getReturnedType().isPresent()) {
                builder.append(" RETURNING ")
                        .append(process(node.getReturnedType().get()))
                        .append(node.getOutputFormat().map(string -> " FORMAT " + string).orElse(""));
            }

            builder.append(")");

            return builder.toString();
        }

        @Override
        protected String visitJsonArray(JsonArray node, Void context)
        {
            StringBuilder builder = new StringBuilder();

            builder.append("JSON_ARRAY(");

            if (!node.getElements().isEmpty()) {
                builder.append(node.getElements().stream()
                        .map(element -> formatJsonExpression(element.getValue(), element.getFormat()))
                        .collect(joining(", ")));
                builder.append(node.isNullOnNull() ? " NULL ON NULL" : " ABSENT ON NULL");
            }

            if (node.getReturnedType().isPresent()) {
                builder.append(" RETURNING ")
                        .append(process(node.getReturnedType().get()))
                        .append(node.getOutputFormat().map(string -> " FORMAT " + string).orElse(""));
            }

            builder.append(")");

            return builder.toString();
        }

        private String formatBinaryExpression(String operator, Expression left, Expression right)
        {
            return '(' + process(left, null) + ' ' + operator + ' ' + process(right, null) + ')';
        }

        private String joinExpressions(List<Expression> expressions)
        {
            return Joiner.on(", ").join(expressions.stream()
                    .map((e) -> process(e, null))
                    .iterator());
        }

        /**
         * Returns the formatted `LISTAGG` function call corresponding to the specified node.
         * <p>
         * During the parsing of the syntax tree, the `LISTAGG` expression is synthetically converted
         * to a function call. This method formats the specified {@link FunctionCall} node to correspond
         * to the standardised syntax of the `LISTAGG` expression.
         *
         * @param node the `LISTAGG` function call
         */
        private String visitListagg(FunctionCall node)
        {
            StringBuilder builder = new StringBuilder();

            List<Expression> arguments = node.getArguments();
            Expression expression = arguments.get(0);
            Expression separator = arguments.get(1);
            BooleanLiteral overflowError = (BooleanLiteral) arguments.get(2);
            Expression overflowFiller = arguments.get(3);
            BooleanLiteral showOverflowEntryCount = (BooleanLiteral) arguments.get(4);

            String innerArguments = joinExpressions(ImmutableList.of(expression, separator));
            if (node.isDistinct()) {
                innerArguments = "DISTINCT " + innerArguments;
            }

            builder.append("LISTAGG")
                    .append('(').append(innerArguments);

            builder.append(" ON OVERFLOW ");
            if (overflowError.getValue()) {
                builder.append(" ERROR");
            }
            else {
                builder.append(" TRUNCATE")
                        .append(' ')
                        .append(process(overflowFiller, null));
                if (showOverflowEntryCount.getValue()) {
                    builder.append(" WITH COUNT");
                }
                else {
                    builder.append(" WITHOUT COUNT");
                }
            }

            builder.append(')');

            return builder.toString();
        }
    }

    static String formatStringLiteral(String s)
    {
        s = s.replace("'", "''");
        if (CharMatcher.inRange((char) 0x20, (char) 0x7E).matchesAllOf(s)) {
            return "'" + s + "'";
        }

        StringBuilder builder = new StringBuilder();
        builder.append("U&'");
        PrimitiveIterator.OfInt iterator = s.codePoints().iterator();
        while (iterator.hasNext()) {
            int codePoint = iterator.nextInt();
            checkArgument(codePoint >= 0, "Invalid UTF-8 encoding in characters: %s", s);
            if (isAsciiPrintable(codePoint)) {
                char ch = (char) codePoint;
                if (ch == '\\') {
                    builder.append(ch);
                }
                builder.append(ch);
            }
            else if (codePoint <= 0xFFFF) {
                builder.append('\\');
                builder.append(format("%04X", codePoint));
            }
            else {
                builder.append("\\+");
                builder.append(format("%06X", codePoint));
            }
        }
        builder.append("'");
        return builder.toString();
    }

    private static boolean isAsciiPrintable(int codePoint)
    {
        return codePoint >= 0x20 && codePoint < 0x7F;
    }

    private static String formatGroupingSet(List<Expression> groupingSet)
    {
        return format("(%s)", Joiner.on(", ").join(groupingSet.stream()
                .map(IrExpressionFormatter::formatExpression)
                .iterator()));
    }

    public static String formatJsonPathInvocation(JsonPathInvocation pathInvocation)
    {
        StringBuilder builder = new StringBuilder();

        builder.append(formatJsonExpression(pathInvocation.getInputExpression(), Optional.of(pathInvocation.getInputFormat())))
                .append(", ")
                .append(formatExpression(pathInvocation.getJsonPath()));

        if (!pathInvocation.getPathParameters().isEmpty()) {
            builder.append(" PASSING ");
            builder.append(formatJsonPathParameters(pathInvocation.getPathParameters()));
        }

        return builder.toString();
    }

    private static String formatJsonExpression(Expression expression, Optional<io.trino.sql.tree.JsonPathParameter.JsonFormat> format)
    {
        return formatExpression(expression) + format.map(jsonFormat -> " FORMAT " + jsonFormat).orElse("");
    }

    private static String formatJsonPathParameters(List<JsonPathParameter> parameters)
    {
        return parameters.stream()
                .map(parameter -> formatJsonExpression(parameter.getParameter(), parameter.getFormat()) + " AS " + formatExpression(parameter.getName()))
                .collect(joining(", "));
    }
}
