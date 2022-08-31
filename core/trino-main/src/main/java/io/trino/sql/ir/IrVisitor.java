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
package io.trino.sql.ir;

import javax.annotation.Nullable;

public abstract class IrVisitor<R, C>
{
    public R process(Expression node)
    {
        return process(node, null);
    }

    public R process(Expression node, @Nullable C context)
    {
        return node.accept(this, context);
    }

    protected R visitExpression(Expression node, C context)
    {
        return null;
    }

    protected R visitCurrentTime(CurrentTime node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitExtract(Extract node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitArithmeticBinary(ArithmeticBinaryExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitBetweenPredicate(BetweenPredicate node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitCoalesceExpression(CoalesceExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitComparisonExpression(ComparisonExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitLiteral(Literal node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitDoubleLiteral(DoubleLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitDecimalLiteral(DecimalLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitGenericLiteral(GenericLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitTimeLiteral(TimeLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitTimestampLiteral(TimestampLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitWhenClause(WhenClause node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitIntervalLiteral(IntervalLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitInPredicate(InPredicate node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitFunctionCall(FunctionCall node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitLambdaExpression(LambdaExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitSimpleCaseExpression(SimpleCaseExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitStringLiteral(StringLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitCharLiteral(CharLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitBinaryLiteral(BinaryLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitBooleanLiteral(BooleanLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitInListExpression(InListExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitIdentifier(Identifier node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitDereferenceExpression(DereferenceExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitTrim(Trim node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitNullIfExpression(NullIfExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitIfExpression(IfExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitNullLiteral(NullLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitArithmeticUnary(ArithmeticUnaryExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitNotExpression(NotExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitSearchedCaseExpression(SearchedCaseExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitLikePredicate(LikePredicate node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitIsNotNullPredicate(IsNotNullPredicate node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitIsNullPredicate(IsNullPredicate node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitArrayConstructor(ArrayConstructor node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitSubscriptExpression(SubscriptExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitLongLiteral(LongLiteral node, C context)
    {
        return visitLiteral(node, context);
    }

    protected R visitLogicalExpression(LogicalExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitRow(Row node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitTryExpression(TryExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitCast(Cast node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitFieldReference(FieldReference node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitFrameBound(FrameBound node, C context)
    {
        return visitNode(node, context);
    }

    protected R visitAtTimeZone(AtTimeZone node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitSymbolReference(SymbolReference node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitQuantifiedComparisonExpression(QuantifiedComparisonExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitLambdaArgumentDeclaration(LambdaArgumentDeclaration node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitBindExpression(BindExpression node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitCurrentCatalog(CurrentCatalog node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitCurrentSchema(CurrentSchema node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitCurrentUser(CurrentUser node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitCurrentPath(CurrentPath node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitFormat(Format node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitDataType(DataType node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitRowDataType(RowDataType node, C context)
    {
        return visitDataType(node, context);
    }

    protected R visitGenericDataType(GenericDataType node, C context)
    {
        return visitDataType(node, context);
    }

    protected R visitRowField(RowDataType.Field node, C context)
    {
        return visitNode(node, context);
    }

    protected R visitDataTypeParameter(DataTypeParameter node, C context)
    {
        return visitNode(node, context);
    }

    protected R visitNumericTypeParameter(NumericParameter node, C context)
    {
        return visitDataTypeParameter(node, context);
    }

    protected R visitTypeParameter(TypeParameter node, C context)
    {
        return visitDataTypeParameter(node, context);
    }

    protected R visitIntervalDataType(IntervalDayTimeDataType node, C context)
    {
        return visitDataType(node, context);
    }

    protected R visitDateTimeType(DateTimeDataType node, C context)
    {
        return visitDataType(node, context);
    }

    protected R visitMeasureDefinition(MeasureDefinition node, C context)
    {
        return visitNode(node, context);
    }

    protected R visitLabelDereference(LabelDereference node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitJsonExists(JsonExists node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitJsonValue(JsonValue node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitJsonQuery(JsonQuery node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitJsonPathInvocation(JsonPathInvocation node, C context)
    {
        return visitNode(node, context);
    }

    protected R visitJsonObject(JsonObject node, C context)
    {
        return visitExpression(node, context);
    }

    protected R visitJsonArray(JsonArray node, C context)
    {
        return visitExpression(node, context);
    }
}
