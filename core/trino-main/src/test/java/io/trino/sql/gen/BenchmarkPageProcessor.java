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
import io.airlift.slice.Slice;
import io.airlift.slice.SliceInput;
import io.airlift.slice.Slices;
import io.trino.metadata.TestingFunctionResolution;
import io.trino.operator.DriverYieldSignal;
import io.trino.operator.project.PageProcessor;
import io.trino.spi.Page;
import io.trino.spi.PageBuilder;
import io.trino.spi.block.Block;
import io.trino.sql.relational.CallExpression;
import io.trino.sql.relational.RowExpression;
import io.trino.sql.relational.SpecialForm;
import io.trino.sql.relational.SpecialForm.Form;
import io.trino.tpch.LineItem;
import io.trino.tpch.LineItemColumn;
import io.trino.tpch.LineItemGenerator;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.CompilerControl;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.runner.RunnerException;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

import static com.google.common.base.Preconditions.checkState;
import static io.airlift.slice.Slices.utf8Slice;
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
@Fork(1)
@Warmup(iterations = 30)
@Measurement(iterations = 20)
public class BenchmarkPageProcessor
{
    private static final int EXTENDED_PRICE = 0;
    private static final int DISCOUNT = 1;
    private static final int SHIP_DATE = 2;
    private static final int QUANTITY = 3;

    private static final Slice MIN_SHIP_DATE = utf8Slice("1994-01-01");
    private static final Slice MAX_SHIP_DATE = utf8Slice("1995-01-01");
    private static final byte[] MIN_SHIP_DATE_BYTES = "1994-01-01".getBytes();
    private static final byte[] MAX_SHIP_DATE_BYTES = "1995-01-01".getBytes();

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

//        initializeArrays();
        initialize2();
    }

    private void initialize2()
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

    private void initializeArrays()
    {
        LineItemGenerator lineItemGenerator = new LineItemGenerator(1, 1, 1);
        Iterator<LineItem> iterator = lineItemGenerator.iterator();

        positions = 10_000;

        discount = new long[positions];
        discountNull = new boolean[positions];
        discountNullByte = new byte[positions];

        quantity = new long[positions];
        quantityNull = new boolean[positions];
        quantityNullByte = new byte[positions];

        extendedPrice = new long[positions];
        extendedPriceNull = new boolean[positions];
        extendedPriceNullByte = new byte[positions];

        result = new long[positions];
        resultNull = new boolean[positions];
        resultNullByte = new byte[positions];
        resultMask = new boolean[positions];
        resultMaskByte = new byte[positions];

        shipDateNull = new boolean[positions];
        shipDateNullByte = new byte[positions];

        shipDatePositions = new int[positions + 1];
        shipDate = new byte[positions * 10];

        int currentShipDatePosition = 0;
        for (int i = 0; i < positions; i++) {
            LineItem lineItem = iterator.next();

            discount[i] = lineItem.getDiscountPercent();
            extendedPrice[i] = lineItem.getExtendedPriceInCents();

            quantity[i] = lineItem.getQuantity();

            byte[] date = LineItemColumn.SHIP_DATE.getString(lineItem).getBytes(StandardCharsets.UTF_8);
            shipDatePositions[i] = currentShipDatePosition;
            System.arraycopy(date, 0, shipDate, currentShipDatePosition, date.length);
            currentShipDatePosition += date.length;
        }

        shipDatePositions[positions] = currentShipDatePosition;
    }

    //    @Benchmark
    public Page handCoded()
    {
        PageBuilder pageBuilder = new PageBuilder(ImmutableList.of(BIGINT));
        int count = Tpch1FilterAndProject.process(inputPage, 0, inputPage.getPositionCount(), pageBuilder);
        checkState(count == inputPage.getPositionCount());
        return pageBuilder.build();
    }

    //    @Benchmark
    public Page handCoded2()
    {
        PageBuilder pageBuilder = new PageBuilder(ImmutableList.of(BIGINT));

        int position = processHandCoded2(pageBuilder);

        int count = position;
        checkState(count == inputPage.getPositionCount());
        return pageBuilder.build();
    }

    //    @Benchmark
    public Object[] handCodedWithCompactOutputArray()
    {
        Block discountBlock = inputPage.getBlock(DISCOUNT);
        int position = 0;
        int output = 0;
        for (; position < inputPage.getPositionCount(); position++) {
            // where shipdate >= '1994-01-01'
            //    and shipdate < '1995-01-01'
            //    and discount >= 0.05
            //    and discount <= 0.07
            //    and quantity < 24;
            Block shipDateBlock = inputPage.getBlock(SHIP_DATE);
            Block quantityBlock = inputPage.getBlock(QUANTITY);
            if (shipDateBlock.isNull(position) || discountBlock.isNull(position) || quantityBlock.isNull(position)) {
                continue;
            }

            boolean matches = BIGINT.getLong(discountBlock, position) >= 5
                    && BIGINT.getLong(discountBlock, position) <= 7
                    && BIGINT.getLong(quantityBlock, position) < 24
                    && VARCHAR.getSlice(shipDateBlock, position).compareTo(MIN_SHIP_DATE) >= 0
                    && VARCHAR.getSlice(shipDateBlock, position).compareTo(MAX_SHIP_DATE) < 0;

            if (matches) {
                Block extendedPriceBlock = inputPage.getBlock(EXTENDED_PRICE);

                if (discountBlock.isNull(position) || extendedPriceBlock.isNull(position)) {
                    resultNull[output] = true;
                }
                else {
                    resultNull[output] = false;
                    result[output] = BIGINT.getLong(discountBlock, position) * BIGINT.getLong(extendedPriceBlock, position);
                }

                output++;
            }
        }

        return new Object[] {result, resultNull, output};
    }

    private int processHandCoded2(PageBuilder pageBuilder)
    {
        Block discountBlock = inputPage.getBlock(DISCOUNT);
        int position = 0;
        for (; position < inputPage.getPositionCount(); position++) {
            // where shipdate >= '1994-01-01'
            //    and shipdate < '1995-01-01'
            //    and discount >= 0.05
            //    and discount <= 0.07
            //    and quantity < 24;
            boolean res = false;
            Block shipDateBlock = inputPage.getBlock(SHIP_DATE);
            Block quantityBlock = inputPage.getBlock(QUANTITY);
            if (!shipDateBlock.isNull(position) && !discountBlock.isNull(position) && !quantityBlock.isNull(position)) {
                res = BIGINT.getLong(discountBlock, position) >= 5
                        && BIGINT.getLong(discountBlock, position) <= 7
                        && BIGINT.getLong(quantityBlock, position) < 24
                        && VARCHAR.getSlice(shipDateBlock, position).compareTo(MIN_SHIP_DATE) >= 0
                        && VARCHAR.getSlice(shipDateBlock, position).compareTo(MAX_SHIP_DATE) < 0;
            }

            if (res) {
                Block extendedPriceBlock = inputPage.getBlock(EXTENDED_PRICE);
                pageBuilder.declarePosition();
                if (discountBlock.isNull(position) || extendedPriceBlock.isNull(position)) {
                    pageBuilder.getBlockBuilder(0).appendNull();
                }
                else {
                    BIGINT.writeLong(pageBuilder.getBlockBuilder(0), BIGINT.getLong(extendedPriceBlock, position) * BIGINT.getLong(discountBlock, position));
                }
            }
        }
        return position;
    }

    //    @Benchmark
    public List<Optional<Page>> compiled()
    {
        return ImmutableList.copyOf(
                compiledProcessor.process(
                        null,
                        new DriverYieldSignal(),
                        newSimpleAggregatedMemoryContext().newLocalMemoryContext(PageProcessor.class.getSimpleName()),
                        inputPage));
    }

    //    @Benchmark
    public Object[] rowOrientedArraysCompact()
    {
        int output = 0;
        for (int i = 0; i < result.length; i++) {
            if (shipDateNull[i] || discountNull[i] || quantityNull[i]) {
                continue;
            }

            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            boolean matches = discount[i] >= 5
                    && discount[i] <= 7
                    && quantity[i] < 24
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0;

            if (matches) {
                if (discountNull[i] || extendedPriceNull[i]) {
                    resultNull[output] = true;
                }
                else {
                    resultNull[output] = false;
                    result[output] = discount[i] * extendedPrice[i];
                }

                output++;
            }
        }

        return new Object[] {result, resultNull, output};
    }

    //    @Benchmark
    public Object[] rowOrientedArraysFlat()
    {
        for (int i = 0; i < result.length; i++) {
            if (shipDateNull[i] || discountNull[i] || quantityNull[i]) {
                continue;
            }

            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            boolean matches = discount[i] >= 5
                    && discount[i] <= 7
                    && quantity[i] < 24
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0;

            resultMask[i] = matches;
            if (matches) {
                if (discountNull[i] || extendedPriceNull[i]) {
                    resultNull[i] = true;
                }
                else {
                    resultNull[i] = false;
                    result[i] = discount[i] * extendedPrice[i];
                }
            }
        }

        return new Object[] {result, resultNull};
    }

    //    @Benchmark
    public Object[] separateFilterProject()
    {
        boolean[] mask = resultMask;

        for (int i = 0; i < mask.length; i++) {
            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            mask[i] = !shipDateNull[i]
                    && !discountNull[i]
                    && !quantityNull[i]
                    && discount[i] >= 5
                    && discount[i] <= 7
                    && quantity[i] < 24
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0;
        }

        for (int i = 0; i < mask.length; i++) {
            if (mask[i]) {
                resultNull[i] = discountNull[i] || quantityNull[i];
                result[i] = discount[i] * extendedPrice[i];
            }
        }

        return new Object[] {result, resultNull, mask};
    }

    //    @Benchmark
    public Object[] rowOrientedArraysMask()
    {
        for (int i = 0; i < positions; i++) {
            if (shipDateNull[i] || discountNull[i] || quantityNull[i]) {
                resultMask[i] = false;
                continue;
            }

            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            if (discount[i] >= 5
                    && discount[i] <= 7
                    && quantity[i] < 24
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0) {

                resultMask[i] = true;
                if (discountNull[i] || quantityNull[i]) {
                    resultNull[i] = true;
                }
                else {
                    resultNull[i] = false;
                    result[i] = discount[i] * extendedPrice[i];
                }
            }
            else {
                resultMask[i] = false;
            }
        }

        return new Object[] {result, resultNull, resultMask};
    }

    @Benchmark
    public Object[] rowOrientedArraysFlatSimple()
    {
        doRowOrientedArraysFlatByteSimple(shipDate, shipDatePositions, shipDateNullByte, discount, discountNullByte, quantity, quantityNullByte, extendedPrice, extendedPriceNullByte, result, resultMaskByte, resultNullByte);

        return new Object[] {result, resultNullByte, resultMaskByte};
    }

//    @Benchmark
    public Object[] rowOrientedArraysFlatSimpleInlined()
    {
        long[] result = this.result;
        int length = result.length;
        byte[] resultMaskByte = this.resultMaskByte;
        byte[] extendedPriceNullByte = this.extendedPriceNullByte;
        byte[] resultNullByte = this.resultNullByte;
        long[] extendedPrice = this.extendedPrice;
        byte[] shipDateNullByte = this.shipDateNullByte;
        byte[] discountNullByte = this.discountNullByte;
        byte[] quantityNullByte = this.quantityNullByte;
        int[] shipDatePositions = this.shipDatePositions;
        byte[] shipDate = this.shipDate;
        long[] discount = this.discount;
        long[] quantity = this.quantity;

        for (int i = 0; i < length; i++) {
            boolean match =
                    shipDateNullByte[i] == 0
                            & discountNullByte[i] == 0
                            & quantityNullByte[i] == 0
                            & discount[i] >= 5
                            & quantity[i] < 24
                            & discount[i] <= 7;

            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            match = match
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0;

            resultMaskByte[i] = (byte) (match ? 1 : 0);
            if (match) {
                boolean emit = discountNullByte[i] == 0 & extendedPriceNullByte[i] == 0;

                resultNullByte[i] = (byte) (emit ? 1 : 0);
                if (emit) {
                    result[i] = discount[i] * extendedPrice[i];
                }
            }
        }

        return new Object[] {result, resultNullByte, resultMaskByte};
    }

    //    @CompilerControl(CompilerControl.Mode.DONT_INLINE)
    public static void doRowOrientedArraysFlatByteSimple(
            byte[] shipDate,
            int[] shipDatePositions,
            byte[] shipDateNullByte,
            long[] discount,
            byte[] discountNullByte,
            long[] quantity,
            byte[] quantityNullByte,
            long[] extendedPrice,
            byte[] extendedPriceNullByte,
            long[] result,
            byte[] resultMaskByte,
            byte[] resultNullByte)
    {
//        int matches = 0;
        for (int i = 0; i < result.length; i++) {
            boolean match =
                    shipDateNullByte[i] == 0
                            & discountNullByte[i] == 0
                            & quantityNullByte[i] == 0
                            & discount[i] >= 5
                            & quantity[i] < 24
                            & discount[i] <= 7;

            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            match = match
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                    && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0;

            resultMaskByte[i] = (byte) (match ? 1 : 0);
            if (match) {
//                matches++;
                boolean emit = discountNullByte[i] == 0 & extendedPriceNullByte[i] == 0;

                resultNullByte[i] = (byte) (emit ? 1 : 0);
                if (emit) {
                    result[i] = discount[i] * extendedPrice[i];
                }
            }
        }
    }

    //    @Benchmark
    public Object[] rowOrientedArraysBranchFree()
    {
        for (int i = 0; i < positions; i++) {
            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            resultMask[i] = !(shipDateNull[i] || discountNull[i] || quantityNull[i]) &&
                    (discount[i] >= 5
                            && discount[i] <= 7
                            && quantity[i] < 24
                            && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                            && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0);

            resultNull[i] = discountNull[i] || quantityNull[i];
            result[i] = discount[i] * extendedPrice[i];
        }

        return new Object[] {result, resultNull, resultMask};
    }

    //    @Benchmark
    public Object[] columnarArrays()
    {
        for (int i = 0; i < positions; i++) {
            int shipDateStart = shipDatePositions[i];
            int shipDateEnd = shipDatePositions[i + 1];

            resultMask[i] = !(shipDateNull[i] || discountNull[i] || quantityNull[i]) &&
                    (discount[i] >= 5
                            && discount[i] <= 7
                            && quantity[i] < 24
                            && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0
                            && Arrays.compare(shipDate, shipDateStart, shipDateEnd, MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0);
        }

        for (int i = 0; i < positions; i++) {
            if (resultMask[i]) {
                resultNull[i] = discountNull[i] || extendedPriceNull[i];
                result[i] = discount[i] * extendedPrice[i];
            }
        }

        return new Object[] {result, resultNull, resultMask};
    }

    //    @Benchmark
    public Object[] filter1()
    {
        boolean[] inputMask = resultMask;
        Arrays.fill(inputMask, true);

        boolean[] outputMask = resultMask; //new boolean[inputMask.length];

        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            if (inputMask[i]) {
                selectedPositions++;
                outputMask[i] = !discountNull[i];
            }
        }

        return new Object[] {outputMask, selectedPositions};
    }

    //    @Benchmark
    public Object[] filter1a()
    {
        boolean[] inputMask = resultMask;
        Arrays.fill(inputMask, true);

        boolean[] outputMask = resultMask; //new boolean[inputMask.length];

        return filter1aImpl(inputMask, outputMask);
    }

    private Object[] filter1aImpl(boolean[] inputMask, boolean[] outputMask)
    {
        int selectedPositions = 0;
        for (int i = 0; i < outputMask.length; i++) {
            if (inputMask[i]) {
                selectedPositions++;
                outputMask[i] = !discountNull[i];
            }
        }

        return new Object[] {outputMask, selectedPositions};
    }

    //    @Benchmark
    public Object[] filter2()
    {
        boolean[] inputMask = resultMask;
        Arrays.fill(inputMask, true);

        boolean[] outputMask = resultMask; //new boolean[inputMask.length];

        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            boolean selected = inputMask[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected & !discountNull[i];
        }

        return new Object[] {outputMask, selectedPositions};
    }

    //    @Benchmark
    public Object[] filter2a()
    {
        boolean[] inputMask = resultMask;
        Arrays.fill(inputMask, true);

        boolean[] outputMask = resultMask; //new boolean[inputMask.length];

        int selectedPositions = 0;
        for (int i = 0; i < outputMask.length; i++) {
            boolean selected = inputMask[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected & !discountNull[i];
        }

        return new Object[] {outputMask, selectedPositions};
    }

    @Benchmark
    public Object[] columnarByte()
    {
        Arrays.fill(resultMaskByte, (byte) 1);
        Arrays.fill(resultNullByte, (byte) 0);

        int selectedPositions = positions;

        if (selectedPositions != 0) {
            selectedPositions = discountNotNull(resultMaskByte, resultMaskByte, discountNullByte);
        }

        if (selectedPositions != 0) {
            selectedPositions = shipDateNotNull(resultMaskByte, resultMaskByte, shipDateNullByte);
        }

        if (selectedPositions != 0) {
            selectedPositions = quantityNotNull(resultMaskByte, resultMaskByte, quantityNullByte);
        }

        if (selectedPositions != 0) {
            selectedPositions = discountGreater(resultMaskByte, resultMaskByte, discount);
        }

        if (selectedPositions != 0) {
            selectedPositions = discountLess(resultMaskByte, resultMaskByte, discount);
        }

        if (selectedPositions != 0) {
            selectedPositions = quantityLess(resultMaskByte, resultMaskByte, quantity);
        }

        if (selectedPositions != 0) {
            selectedPositions = shipDateGreater(resultMaskByte, resultMaskByte, shipDate, shipDatePositions);
        }

        if (selectedPositions != 0) {
            selectedPositions = shipDateLess(resultMaskByte, resultMaskByte, shipDate, shipDatePositions);
        }

        if (selectedPositions != 0) {
            computeDiscountedPriceAndNulls(resultMaskByte, result, resultNullByte);
        }

//        if (selectedPositions != 0) {
////            discountNull(resultMaskByte, resultNullByte);
////            extendedPriceNull(resultMaskByte, resultNullByte);
//            computeDiscountedPrice(resultMaskByte, resultNullByte, result);
//        }

        return new Object[] {result, resultNullByte, resultMaskByte};
    }

    //    @Benchmark
    public Object[] columnarByteInline()
    {
        Arrays.fill(resultMaskByte, (byte) 1);
        Arrays.fill(resultNullByte, (byte) 0);

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = resultMaskByte[i] & (discountNullByte[i] == 0 ? 1 : 0);
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = resultMaskByte[i] & (shipDateNullByte[i] == 0 ? 1 : 0);
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = resultMaskByte[i] & (quantityNullByte[i] == 0 ? 1 : 0);
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = resultMaskByte[i] & (discount[i] >= 5 ? 1 : 0);
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = resultMaskByte[i] & (discount[i] <= 7 ? 1 : 0);
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = resultMaskByte[i] & (quantity[i] < 24 ? 1 : 0);
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = (resultMaskByte[i] == 1 && Arrays.compare(shipDate, shipDatePositions[i], shipDatePositions[i + 1], MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0) ? 1 : 0;
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            int selected = (resultMaskByte[i] == 1 && Arrays.compare(shipDate, shipDatePositions[i], shipDatePositions[i + 1], MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0) ? 1 : 0;
            resultMaskByte[i] = (byte) selected;
        }

        for (int i = 0; i < resultMaskByte.length; i++) {
            if (resultMaskByte[i] == 1) {
                byte resultIsNull = (byte) (discountNullByte[i] | extendedPriceNullByte[i]);

                resultNullByte[i] = resultIsNull;
                if (resultIsNull == 0) {
                    result[i] = discount[i] * extendedPrice[i];
                }
            }
        }

//        if (selectedPositions != 0) {
////            discountNull(resultMaskByte, resultNullByte);
////            extendedPriceNull(resultMaskByte, resultNullByte);
//            computeDiscountedPrice(resultMaskByte, resultNullByte, result);
//        }

        return new Object[] {result, resultNullByte, resultMaskByte};
    }

    @CompilerControl(CompilerControl.Mode.INLINE)
    private void computeDiscountedPriceAndNulls(byte[] inputMask, long[] result, byte[] resultNull)
    {
        for (int i = 0; i < inputMask.length; i++) {
            if (inputMask[i] == 1) {
                byte resultIsNull = (byte) (discountNullByte[i] | extendedPriceNullByte[i]);

                resultNull[i] = resultIsNull;
                if (resultIsNull == 0) {
                    result[i] = discount[i] * extendedPrice[i];
                }
            }
        }
    }

    //    @Benchmark
    public Object[] columnar()
    {
        Arrays.fill(resultMask, true);
        Arrays.fill(resultNull, false);

        int selectedPositions = discountNotNull(resultMask, resultMask, discountNull);

        if (selectedPositions != 0) {
            selectedPositions = shipDateNotNull(resultMask, resultMask, shipDateNull);
        }

        if (selectedPositions != 0) {
            selectedPositions = quantityNotNull(resultMask, resultMask, quantityNull);
        }

        if (selectedPositions != 0) {
            selectedPositions = discountGreater(resultMask, resultMask, discount);
        }

        if (selectedPositions != 0) {
            selectedPositions = discountLess(resultMask, resultMask, discount);
        }

        if (selectedPositions != 0) {
            selectedPositions = quantityLess(resultMask, resultMask, quantity);
        }

        if (selectedPositions != 0) {
            selectedPositions = shipDateGreater(resultMask, resultMask, shipDate, shipDatePositions);
        }

        if (selectedPositions != 0) {
            selectedPositions = shipDateLess(resultMask, resultMask, shipDate, shipDatePositions);
        }

        if (selectedPositions != 0) {
            for (int i = 0; i < resultMask.length; i++) {
                if (resultMask[i]) {
                    boolean resultIsNull = discountNull[i] || extendedPriceNull[i];

                    resultNull[i] = resultIsNull;
                    if (!resultIsNull) {
                        result[i] = discount[i] * extendedPrice[i];
                    }
                }
            }
        }

//
//        if (selectedPositions != 0) {
//            int discountNulls = discountNull(resultMask, resultNull);
//
//            int extendedPriceNulls = 0;
//            if (selectedPositions != discountNulls) {
//                extendedPriceNulls = extendedPriceNull(resultMask, resultNull);
//            }
//
//            if (extendedPriceNulls < selectedPositions || discountNulls < selectedPositions) {
//                computeDiscountedPrice(resultMask, resultNull, result);
//            }
//        }

        return new Object[] {result, resultNull, resultMask};
    }

    private int shipDateLess(boolean[] inputMask, boolean[] outputMask, byte[] shipDate, int[] shipDatePositions)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            boolean selected = inputMask[i] && Arrays.compare(shipDate, shipDatePositions[i], shipDatePositions[i + 1], MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0;
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int shipDateLess(byte[] inputMask, byte[] outputMask, byte[] shipDate, int[] shipDatePositions)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = (inputMask[i] == 1 && Arrays.compare(shipDate, shipDatePositions[i], shipDatePositions[i + 1], MAX_SHIP_DATE_BYTES, 0, MAX_SHIP_DATE_BYTES.length) < 0) ? 1 : 0;
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }

        return selectedPositions;
    }

    private int shipDateGreater(boolean[] inputMask, boolean[] outputMask, byte[] shipDate, int[] shipDatePositions)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            boolean selected = inputMask[i] && Arrays.compare(shipDate, shipDatePositions[i], shipDatePositions[i + 1], MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0;
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int shipDateGreater(byte[] inputMask, byte[] outputMask, byte[] shipDate, int[] shipDatePositions)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = (inputMask[i] == 1 && Arrays.compare(shipDate, shipDatePositions[i], shipDatePositions[i + 1], MIN_SHIP_DATE_BYTES, 0, MIN_SHIP_DATE_BYTES.length) >= 0) ? 1 : 0;
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }

        return selectedPositions;
    }

    private int shipDateNotNull(boolean[] inputMask, boolean[] outputMask, boolean[] shipDateNull)
    {
        int selectedPositions = 0;
        for (int i = 0; i < shipDateNull.length; i++) {
            boolean selected = inputMask[i] & !shipDateNull[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int shipDateNotNull(byte[] inputMask, byte[] outputMask, byte[] shipDateNullByte)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (shipDateNullByte[i] == 0 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }
        return selectedPositions;
    }

    private int quantityNotNull(boolean[] inputMask, boolean[] outputMask, boolean[] quantityNull)
    {
        int selectedPositions = 0;
        for (int i = 0; i < quantityNull.length; i++) {
            boolean selected = inputMask[i] & !quantityNull[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int quantityNotNull(byte[] inputMask, byte[] outputMask, byte[] quantityNullByte)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (quantityNullByte[i] == 0 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }

        return selectedPositions;
    }

    private int discountLess(boolean[] inputMask, boolean[] outputMask, long[] discount)
    {
        int selectedPositions = 0;
        for (int i = 0; i < discount.length; i++) {
            boolean selected = inputMask[i] & discount[i] <= 7;
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int discountLess(byte[] inputMask, byte[] outputMask, long[] discount)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (discount[i] <= 7 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }

        return selectedPositions;
    }

    private int discountGreater(boolean[] inputMask, boolean[] outputMask, long[] discount)
    {
        int selectedPositions = 0;
        for (int i = 0; i < discount.length; i++) {
            boolean selected = inputMask[i] & discount[i] >= 5;
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int discountGreater(byte[] inputMask, byte[] outputMask, long[] discount)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (discount[i] >= 5 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }

        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int quantityLess(byte[] inputMask, byte[] outputMask, long[] quantity)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (quantity[i] < 24 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }

        return selectedPositions;
    }

    private int quantityLess(boolean[] inputMask, boolean[] outputMask, long[] quantity)
    {
        int selectedPositions = 0;
        for (int i = 0; i < quantity.length; i++) {
            boolean selected = inputMask[i] && quantity[i] < 24;
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }

        return selectedPositions;
    }

    private int discountNotNull(boolean[] inputMask, boolean[] outputMask, boolean[] discountNull)
    {
        int selectedPositions = 0;
        for (int i = 0; i < discountNull.length; i++) {
            boolean selected = inputMask[i] & !discountNull[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }
        return selectedPositions;
    }

    private int discountNull(boolean[] inputMask, boolean[] outputMask)
    {
        int selectedPositions = 0;
        for (int i = 0; i < discountNull.length; i++) {
            boolean selected = inputMask[i] & discountNull[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }
        return selectedPositions;
    }

    private int extendedPriceNonNull(boolean[] inputMask, boolean[] outputMask)
    {
        int selectedPositions = 0;
        for (int i = 0; i < discountNull.length; i++) {
            boolean selected = inputMask[i] & !extendedPriceNull[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }
        return selectedPositions;
    }

    private int extendedPriceNull(boolean[] inputMask, boolean[] outputMask)
    {
        int selectedPositions = 0;
        for (int i = 0; i < discountNull.length; i++) {
            boolean selected = inputMask[i] & extendedPriceNull[i];
            selectedPositions += selected ? 1 : 0;
            outputMask[i] = selected;
        }
        return selectedPositions;
    }

    //    @CompilerControl(CompilerControl.Mode.INLINE)
    private int discountNotNull(byte[] inputMask, byte[] outputMask, byte[] discountNullByte)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (discountNullByte[i] == 0 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }
        return selectedPositions;
    }

    private int discountNull(byte[] inputMask, byte[] outputMask, byte[] discountNullByte)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (discountNullByte[i] == 1 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }
        return selectedPositions;
    }

    private int extendedPriceNull(byte[] inputMask, byte[] outputMask, byte[] extendedPriceNullByte)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (extendedPriceNullByte[i] == 1 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }
        return selectedPositions;
    }

    private int extendedPriceNonNull(byte[] inputMask, byte[] outputMask, byte[] extendedPriceNullByte)
    {
        int selectedPositions = 0;
        for (int i = 0; i < inputMask.length; i++) {
            int selected = inputMask[i] & (extendedPriceNullByte[i] == 0 ? 1 : 0);
            selectedPositions += selected;
            outputMask[i] = (byte) selected;
        }
        return selectedPositions;
    }

    @CompilerControl(CompilerControl.Mode.INLINE)
    private void computeDiscountedPrice(boolean[] inputMask, boolean[] nulls, long[] result)
    {
        for (int i = 0; i < inputMask.length; i++) {
            if (inputMask[i] && !nulls[i]) {
                result[i] = discount[i] * extendedPrice[i];
            }
        }
    }

    @CompilerControl(CompilerControl.Mode.INLINE)
    private void computeDiscountedPrice(byte[] inputMask, byte[] nulls, long[] result)
    {
        for (int i = 0; i < result.length; i++) {
            if (inputMask[i] == 1) {
//            if (inputMask[i] == 1 && nulls[i] == 0) {
                result[i] = discount[i] * extendedPrice[i];
            }
        }
    }

    @CompilerControl(CompilerControl.Mode.INLINE)
    private void computeDiscountedPrice(byte[] inputMask, long[] result)
    {
        for (int i = 0; i < inputMask.length; i++) {
            if (inputMask[i] == 1) {
                result[i] = discount[i] * extendedPrice[i];
            }
        }
    }

    public static void main(String[] args)
            throws RunnerException, IOException
    {
        BenchmarkPageProcessor x = new BenchmarkPageProcessor();
        x.setup();
//        x.handCoded2();
//        x.columnar();
//        x.columnarByte();
//        Tpch1FilterAndProject.process(x.inputPage, 0, x.inputPage.getPositionCount(), new PageBuilder(ImmutableList.of(DOUBLE)));
//        x.rowOrientedArraysMask();
        x.rowOrientedArraysFlatSimple();

        benchmark(BenchmarkPageProcessor.class).run();
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

    private static final class Tpch1FilterAndProject
    {
        public static int process(Page page, int start, int end, PageBuilder pageBuilder)
        {
            Block discountBlock = page.getBlock(DISCOUNT);
            int position = start;
            for (; position < end; position++) {
                // where shipdate >= '1994-01-01'
                //    and shipdate < '1995-01-01'
                //    and discount >= 0.05
                //    and discount <= 0.07
                //    and quantity < 24;
                if (filter(position, discountBlock, page.getBlock(SHIP_DATE), page.getBlock(QUANTITY))) {
                    project(position, pageBuilder, page.getBlock(EXTENDED_PRICE), discountBlock);
                }
            }

            return position;
        }

        private static void project(int position, PageBuilder pageBuilder, Block extendedPriceBlock, Block discountBlock)
        {
            pageBuilder.declarePosition();
            if (discountBlock.isNull(position) || extendedPriceBlock.isNull(position)) {
                pageBuilder.getBlockBuilder(0).appendNull();
            }
            else {
                BIGINT.writeLong(pageBuilder.getBlockBuilder(0), BIGINT.getLong(extendedPriceBlock, position) * BIGINT.getLong(discountBlock, position));
            }
        }

        private static boolean filter(int position, Block discountBlock, Block shipDateBlock, Block quantityBlock)
        {
            return !shipDateBlock.isNull(position) && VARCHAR.getSlice(shipDateBlock, position).compareTo(MIN_SHIP_DATE) >= 0 &&
                    !shipDateBlock.isNull(position) && VARCHAR.getSlice(shipDateBlock, position).compareTo(MAX_SHIP_DATE) < 0 &&
                    !discountBlock.isNull(position) && BIGINT.getLong(discountBlock, position) >= 0.05 &&
                    !discountBlock.isNull(position) && BIGINT.getLong(discountBlock, position) <= 0.07 &&
                    !quantityBlock.isNull(position) && BIGINT.getLong(quantityBlock, position) < 24;
        }
    }

    // where shipdate >= '1994-01-01'
    //    and shipdate < '1995-01-01'
    //    and discount >= 0.05
    //    and discount <= 0.07
    //    and quantity < 24;
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
                        ImmutableList.of(field(QUANTITY, BIGINT), constant(24L, BIGINT))),
                new CallExpression(
                        functionResolution.resolveOperator(LESS_THAN_OR_EQUAL, ImmutableList.of(VARCHAR, VARCHAR)),
                        ImmutableList.of(constant(MIN_SHIP_DATE, VARCHAR), field(SHIP_DATE, VARCHAR))),
                new CallExpression(
                        functionResolution.resolveOperator(LESS_THAN, ImmutableList.of(VARCHAR, VARCHAR)),
                        ImmutableList.of(field(SHIP_DATE, VARCHAR), constant(MAX_SHIP_DATE, VARCHAR))));
    }

    private static RowExpression createProjectExpression(TestingFunctionResolution functionResolution)
    {
        return new CallExpression(
                functionResolution.resolveOperator(MULTIPLY, ImmutableList.of(BIGINT, BIGINT)),
                ImmutableList.of(field(EXTENDED_PRICE, BIGINT), field(DISCOUNT, BIGINT)));
    }
}
