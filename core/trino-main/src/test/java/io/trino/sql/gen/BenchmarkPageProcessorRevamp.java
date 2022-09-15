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
package io.trino.sql.gen;

import com.google.common.collect.ImmutableList;
import io.airlift.slice.BasicSliceInput;
import io.airlift.slice.SliceInput;
import io.airlift.slice.Slices;
import io.trino.metadata.TestingFunctionResolution;
import io.trino.operator.DriverYieldSignal;
import io.trino.operator.project.PageProcessor;
import io.trino.spi.Page;
import io.trino.spi.PageBuilder;
import io.trino.sql.relational.CallExpression;
import io.trino.sql.relational.RowExpression;
import io.trino.sql.relational.SpecialForm;
import io.trino.sql.relational.SpecialForm.Form;
import io.trino.tpch.LineItem;
import io.trino.tpch.LineItemColumn;
import io.trino.tpch.LineItemGenerator;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.runner.RunnerException;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Iterator;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import static io.trino.jmh.Benchmarks.benchmark;
import static io.trino.memory.context.AggregatedMemoryContext.newSimpleAggregatedMemoryContext;
import static io.trino.spi.function.OperatorType.LESS_THAN;
import static io.trino.spi.function.OperatorType.LESS_THAN_OR_EQUAL;
import static io.trino.spi.function.OperatorType.MULTIPLY;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.spi.type.VarcharType.VARCHAR;
import static io.trino.sql.relational.Expressions.constant;
import static io.trino.sql.relational.Expressions.field;
import static java.nio.charset.StandardCharsets.UTF_8;

@State(Scope.Thread)
@OutputTimeUnit(TimeUnit.SECONDS)
@Fork(value = 1, jvmArgsAppend = {
        "--add-modules=jdk.incubator.vector",
        "-XX:+UnlockDiagnosticVMOptions",
//        "-XX:CompileCommand=print,*BenchmarkCore*.*",
//        "-XX:PrintAssemblyOptions=intel"
})
@Warmup(iterations = 20, time = 1000, timeUnit = TimeUnit.MILLISECONDS)
@Measurement(iterations = 20, time = 1000, timeUnit = TimeUnit.MILLISECONDS)
public class BenchmarkPageProcessorRevamp
{
    private static final int EXTENDED_PRICE = 0;
    private static final int DISCOUNT = 1;
    private static final int SHIP_DATE = 2;
    private static final int QUANTITY = 3;

    private Page inputPage;
    private PageProcessor compiledProcessor;

    int positions;

    long[] discount;
    boolean[] discountNull;
    byte[] discountNullByte;

    long[] quantity;
    boolean[] quantityNull;
    byte[] quantityNullByte;

    long[] extendedPrice;
    boolean[] extendedPriceNull;
    byte[] extendedPriceNullByte;

    int[] shipDatePositions;
    byte[] shipDate;
    boolean[] shipDateNull;
    byte[] shipDateNullByte;

    long[] result;
    boolean[] resultNull;
    byte[] resultNullByte;
    boolean[] resultMask;
    byte[] resultMaskByte;

    @Setup
    public void setup()
            throws IOException
    {
        inputPage = createInputPage();

        TestingFunctionResolution functionResolution = new TestingFunctionResolution();
        RowExpression filterExpression = createFilterExpression(functionResolution);
        RowExpression projectExpression = createProjectExpression(functionResolution);
        ExpressionCompiler expressionCompiler = functionResolution.getExpressionCompiler();
        compiledProcessor = expressionCompiler.compilePageProcessor(Optional.of(filterExpression), ImmutableList.of(projectExpression)).get();

        initializeArrays();
    }

    private void initializeArrays()
            throws IOException
    {
        positions = 10_000;
        discount = new long[positions];
        extendedPrice = new long[positions];
        quantity = new long[positions];
        shipDatePositions = new int[positions + 1];
        shipDate = new byte[positions * 10];

        byte[] buffer = Files.readAllBytes(Paths.get("data.bin"));
        SliceInput input = new BasicSliceInput(Slices.wrappedBuffer(buffer));

        positions = input.readInt();

        discount = new long[positions];
        discountNull = new boolean[positions];
        discountNullByte = new byte[positions];
        for (int i = 0; i < discount.length; i++) {
            discount[i] = input.readLong();
        }

        extendedPrice = new long[positions];
        extendedPriceNull = new boolean[positions];
        extendedPriceNullByte = new byte[positions];
        for (int i = 0; i < extendedPrice.length; i++) {
            extendedPrice[i] = input.readLong();
        }

        quantity = new long[positions];
        quantityNull = new boolean[positions];
        quantityNullByte = new byte[positions];
        for (int i = 0; i < quantity.length; i++) {
            quantity[i] = input.readLong();
        }

        shipDatePositions = new int[positions + 1];
        shipDateNull = new boolean[positions];
        shipDateNullByte = new byte[positions];
        for (int i = 0; i < shipDatePositions.length; i++) {
            shipDatePositions[i] = input.readInt();
        }

        shipDate = new byte[shipDatePositions[positions]];
        input.read(shipDate);

        result = new long[positions];

        resultNull = new boolean[positions];
        resultNullByte = new byte[positions];

        resultMask = new boolean[positions];
        resultMaskByte = new byte[positions];
    }

    //    @Benchmark
    public Object row_Block_NoNull_PageBuilder()
    {
        return BenchmarkCore.row_Block_NoNull_PageBuilder(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                inputPage.getPositionCount());
    }

    //    @Benchmark
    public Object row_Block_NoNull_NoTrampoline_PageBuilder()
    {
        return BenchmarkCore.row_Block_NoNull_NoTrampoline_PageBuilder(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                inputPage.getPositionCount());
    }

    //    @Benchmark
    public Object row_Array_NoNull_CompactArray()
    {
        return BenchmarkCore.row_Array_NoNull_CompactArray(
                discount,
                quantity,
                extendedPrice,
                positions);
    }

    @Benchmark
    public Object row_Array_NoNull_Array()
    {
        return BenchmarkCore.row_Array_NoNull_Array(
                discount,
                quantity,
                extendedPrice,
                positions);
    }

    //    @Benchmark
    public Object row_Block_NoNull_CompactArray()
    {
        return BenchmarkCore.row_Block_NoNull_CompactArray(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                inputPage.getPositionCount());
    }

    //    @Benchmark
    public Object columnar_Array_NoNull_CompactArray()
    {
        return BenchmarkCore.columnar_Array_NoNull_CompactArray(
                discount,
                quantity,
                extendedPrice,
                positions,
                resultMask);
    }

    //    @Benchmark
    public Object columnar_Array_Fused_NoNull_CompactArray()
    {
        return BenchmarkCore.columnar_Array_Fused_NoNull_CompactArray(
                discount,
                quantity,
                extendedPrice,
                positions,
                resultMask);
    }

    @Benchmark
    public Object columnar_Array_Fused_NoNull_Array()
    {
        return BenchmarkCore.columnar_Array_Fused_NoNull_Array(
                discount,
                quantity,
                extendedPrice,
                positions);
    }

    //    @Benchmark
    public Object columnar_Block_NoNull_CompactArray()
    {
        return BenchmarkCore.columnar_Block_NoNull_CompactArray(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                positions,
                resultMask);
    }

    //    @Benchmark
    public Object columnarHybrid_NoNull_CompactArray()
    {
        return BenchmarkCore.columnarHybrid_NoNull_CompactArray(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                positions,
                resultMask);
    }

    //    @Benchmark
    public Object columnarHybrid_NoNull_NoTrampoline_CompactArray()
    {
        return BenchmarkCore.columnarHybrid_Block_NoNull_NoTrampoline_CompactArray(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                positions,
                resultMask);
    }

    //    @Benchmark
    public Object columnarHybrid_NoNull_PageBuilder()
    {
        return BenchmarkCore.columnarHybrid_Block_NoNull_PageBuilder(
                inputPage.getBlock(DISCOUNT),
                inputPage.getBlock(QUANTITY),
                inputPage.getBlock(EXTENDED_PRICE),
                this.positions,
                resultMask);
    }

    //    @Benchmark
    public Object compiled()
    {
        return ImmutableList.copyOf(
                compiledProcessor.process(
                        null,
                        new DriverYieldSignal(),
                        newSimpleAggregatedMemoryContext().newLocalMemoryContext(PageProcessor.class.getSimpleName()),
                        inputPage));
    }

    private static Page createInputPage()
    {
        PageBuilder pageBuilder = new PageBuilder(ImmutableList.of(BIGINT, BIGINT, VARCHAR, BIGINT));
        LineItemGenerator lineItemGenerator = new LineItemGenerator(1, 1, 1);
        Iterator<LineItem> iterator = lineItemGenerator.iterator();

        for (int i = 0; i < 10_000; i++) {
            pageBuilder.declarePosition();

            LineItem lineItem = iterator.next();
            BIGINT.writeLong(pageBuilder.getBlockBuilder(EXTENDED_PRICE), lineItem.getExtendedPriceInCents());
            BIGINT.writeLong(pageBuilder.getBlockBuilder(DISCOUNT), lineItem.getDiscountPercent());
            VARCHAR.writeSlice(pageBuilder.getBlockBuilder(SHIP_DATE), Slices.wrappedBuffer(LineItemColumn.SHIP_DATE.getString(lineItem).getBytes(UTF_8)));
            BIGINT.writeLong(pageBuilder.getBlockBuilder(QUANTITY), lineItem.getQuantity());
        }
        return pageBuilder.build();
    }

    private static RowExpression createFilterExpression(TestingFunctionResolution functionResolution)
    {
        return new SpecialForm(
                Form.AND,
                BOOLEAN,
                new CallExpression(
                        functionResolution.resolveOperator(LESS_THAN_OR_EQUAL, ImmutableList.of(BIGINT, BIGINT)),
                        ImmutableList.of(constant(5L, BIGINT), field(DISCOUNT, BIGINT))),
                new CallExpression(
                        functionResolution.resolveOperator(LESS_THAN_OR_EQUAL, ImmutableList.of(BIGINT, BIGINT)),
                        ImmutableList.of(field(DISCOUNT, BIGINT), constant(7L, BIGINT))),
                new CallExpression(
                        functionResolution.resolveOperator(LESS_THAN, ImmutableList.of(BIGINT, BIGINT)),
                        ImmutableList.of(field(QUANTITY, BIGINT), constant(24L, BIGINT))));
    }

    private static RowExpression createProjectExpression(TestingFunctionResolution functionResolution)
    {
        return new CallExpression(
                functionResolution.resolveOperator(MULTIPLY, ImmutableList.of(BIGINT, BIGINT)),
                ImmutableList.of(field(EXTENDED_PRICE, BIGINT), field(DISCOUNT, BIGINT)));
    }

    public static void main(String[] args)
            throws RunnerException, IOException
    {
        BenchmarkPageProcessorRevamp bench = new BenchmarkPageProcessorRevamp();
        bench.setup();
        bench.columnar_Array_Fused_NoNull_CompactArray();
//        bench.row_NoNull_PageBuilder();
//        bench.row_Block_NoNull_CompactArray();
//        bench.columnar_Block_NoNull_CompactArray();
//        bench.columnar_Array_NoNull_CompactArray();
//        bench.columnarHybrid_NoNull_PageBuilder();
//        bench.columnarHybrid_NoNull_CompactArray();
//        bench.columnarHybrid_NoNull_NoTrampoline_CompactArray();

        benchmark(BenchmarkPageProcessorRevamp.class).run();
    }

}
