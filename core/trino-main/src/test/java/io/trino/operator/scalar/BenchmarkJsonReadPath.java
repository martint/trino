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
package io.trino.operator.scalar;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import io.airlift.slice.DynamicSliceOutput;
import io.airlift.slice.Slice;
import io.airlift.slice.SliceOutput;
import io.airlift.slice.Slices;
import io.trino.jmh.Benchmarks;
import io.trino.metadata.TestingFunctionResolution;
import io.trino.operator.DriverYieldSignal;
import io.trino.operator.project.PageProcessor;
import io.trino.spi.Page;
import io.trino.spi.block.BlockBuilder;
import io.trino.spi.connector.SourcePage;
import io.trino.spi.type.JsonValue;
import io.trino.sql.ir.Comparison;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Expression;
import io.trino.sql.ir.Reference;
import io.trino.sql.planner.Symbol;
import org.junit.jupiter.api.Test;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OperationsPerInvocation;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Param;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.runner.options.WarmupMode;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

import static io.trino.memory.context.AggregatedMemoryContext.newSimpleAggregatedMemoryContext;
import static io.trino.sql.analyzer.TypeSignatureProvider.fromTypes;
import static io.trino.sql.ir.IrExpressions.call;
import static io.trino.testing.TestingConnectorSession.SESSION;
import static io.trino.type.JsonType.JSON;
import static io.trino.type.JsonType.jsonValue;

/**
 * Benchmarks for "low-processing" reads of JSON columns: pass-through projection,
 * rendering as JSON text via {@code json_format}, and equality comparison against a
 * constant. These are the read-side costs paid by queries that don't invoke the
 * JSON path engine, and exercise the boundary between the typed-item storage
 * encoding and the operations that consume it.
 */
@SuppressWarnings("MethodMayBeStatic")
@State(Scope.Thread)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@Fork(2)
@Warmup(iterations = 3, time = 500, timeUnit = TimeUnit.MILLISECONDS)
@Measurement(iterations = 5, time = 500, timeUnit = TimeUnit.MILLISECONDS)
@BenchmarkMode(Mode.AverageTime)
public class BenchmarkJsonReadPath
{
    private static final int POSITION_COUNT = 10_000;

    @Benchmark
    @OperationsPerInvocation(POSITION_COUNT)
    public List<Optional<Page>> passThrough(BenchmarkData data)
    {
        return ImmutableList.copyOf(
                data.passThroughProcessor.process(
                        SESSION,
                        new DriverYieldSignal(),
                        newSimpleAggregatedMemoryContext().newLocalMemoryContext(PageProcessor.class.getSimpleName()),
                        SourcePage.create(data.page)));
    }

    @Benchmark
    @OperationsPerInvocation(POSITION_COUNT)
    public List<Optional<Page>> jsonFormat(BenchmarkData data)
    {
        return ImmutableList.copyOf(
                data.jsonFormatProcessor.process(
                        SESSION,
                        new DriverYieldSignal(),
                        newSimpleAggregatedMemoryContext().newLocalMemoryContext(PageProcessor.class.getSimpleName()),
                        SourcePage.create(data.page)));
    }

    @Benchmark
    @OperationsPerInvocation(POSITION_COUNT)
    public List<Optional<Page>> equalsConstant(BenchmarkData data)
    {
        return ImmutableList.copyOf(
                data.equalsProcessor.process(
                        SESSION,
                        new DriverYieldSignal(),
                        newSimpleAggregatedMemoryContext().newLocalMemoryContext(PageProcessor.class.getSimpleName()),
                        SourcePage.create(data.page)));
    }

    @SuppressWarnings("FieldMayBeFinal")
    @State(Scope.Thread)
    public static class BenchmarkData
    {
        @Param({"SCALAR", "FLAT_OBJECT", "NESTED_OBJECT"})
        private Shape shape = Shape.FLAT_OBJECT;

        private Page page;
        private PageProcessor passThroughProcessor;
        private PageProcessor jsonFormatProcessor;
        private PageProcessor equalsProcessor;

        @Setup
        public void setup()
        {
            BlockBuilder jsonBlockBuilder = JSON.createBlockBuilder(null, POSITION_COUNT);
            // Simulate a text-producing connector: rows arrive as raw JSON text.
            Slice sample = generateText(shape);
            for (int i = 0; i < POSITION_COUNT; i++) {
                JSON.writeSlice(jsonBlockBuilder, sample);
            }
            page = new Page(jsonBlockBuilder.build());

            TestingFunctionResolution functionResolution = new TestingFunctionResolution();

            // Pass-through projection: SELECT json_col
            List<Expression> passThroughProjection = ImmutableList.of(new Reference(JSON, "$col_0"));
            passThroughProcessor = functionResolution.getExpressionCompiler()
                    .compilePageProcessor(Optional.empty(), passThroughProjection, ImmutableMap.of(new Symbol(JSON, "$col_0"), 0))
                    .get();

            // SELECT json_format(json_col)
            List<Expression> jsonFormatProjection = ImmutableList.of(call(
                    functionResolution.resolveFunction("json_format", fromTypes(JSON)),
                    new Reference(JSON, "$col_0")));
            jsonFormatProcessor = functionResolution.getExpressionCompiler()
                    .compilePageProcessor(Optional.empty(), jsonFormatProjection, ImmutableMap.of(new Symbol(JSON, "$col_0"), 0))
                    .get();

            // SELECT json_col = JSON 'constant' — same text bytes, exercises the
            // byte-equality fast path.
            JsonValue constantValue = JsonValue.of(sample);
            List<Expression> equalsProjection = ImmutableList.of(new Comparison(
                    Comparison.Operator.EQUAL,
                    new Reference(JSON, "$col_0"),
                    new Constant(JSON, constantValue)));
            equalsProcessor = functionResolution.getExpressionCompiler()
                    .compilePageProcessor(Optional.empty(), equalsProjection, ImmutableMap.of(new Symbol(JSON, "$col_0"), 0))
                    .get();
        }

        static Slice generateText(Shape shape)
        {
            return switch (shape) {
                case SCALAR -> randomString(20);
                case FLAT_OBJECT -> flatObject(8);
                case NESTED_OBJECT -> nestedObject(4);
            };
        }

        private static Slice randomString(int length)
        {
            String characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
            StringBuilder builder = new StringBuilder(length + 2);
            builder.append('"');
            for (int i = 0; i < length; i++) {
                builder.append(characters.charAt(ThreadLocalRandom.current().nextInt(characters.length())));
            }
            builder.append('"');
            return Slices.utf8Slice(builder.toString());
        }

        private static Slice flatObject(int width)
        {
            try (SliceOutput output = new DynamicSliceOutput(width * 24)) {
                output.appendByte('{');
                for (int i = 0; i < width; i++) {
                    if (i > 0) {
                        output.appendByte(',');
                    }
                    output.appendBytes(("\"k" + i + "\":" + ThreadLocalRandom.current().nextInt(1_000_000)).getBytes(StandardCharsets.UTF_8));
                }
                output.appendByte('}');
                return output.slice();
            }
            catch (IOException e) {
                throw new RuntimeException(e);
            }
        }

        private static Slice nestedObject(int depth)
        {
            // Wraps a leaf record at `depth` levels of nesting.
            StringBuilder builder = new StringBuilder();
            for (int level = 0; level < depth; level++) {
                builder.append("{\"level").append(level).append("\":");
            }
            builder.append("\"").append(ThreadLocalRandom.current().nextInt(1_000_000)).append("\"");
            for (int level = 0; level < depth; level++) {
                builder.append('}');
            }
            return Slices.utf8Slice(builder.toString());
        }
    }

    public enum Shape
    {
        SCALAR,
        FLAT_OBJECT,
        NESTED_OBJECT,
    }

    @Test
    public void verify()
    {
        BenchmarkData data = new BenchmarkData();
        data.setup();
        BenchmarkJsonReadPath benchmark = new BenchmarkJsonReadPath();
        benchmark.passThrough(data);
        benchmark.jsonFormat(data);
        benchmark.equalsConstant(data);
    }

    /**
     * Simple in-process benchmark that doesn't require the JMH annotation processor
     * to be active. Run with {@code -Dtest=BenchmarkJsonReadPath#measure} and read the
     * stdout output for per-row timings (in ns). Less precise than the @Benchmark
     * methods above (no fork, no JIT-controlled warmup) but adequate for relative
     * comparisons across builds.
     */
    @Test
    public void measure()
            throws IOException
    {
        StringBuilder out = new StringBuilder();
        out.append("== BenchmarkJsonReadPath manual measurement ==\n");
        out.append("shape          | passThrough     | jsonFormat      | equalsConstant\n");
        out.append("---------------+-----------------+-----------------+-----------------\n");
        for (Shape shape : Shape.values()) {
            BenchmarkData data = new BenchmarkData();
            data.shape = shape;
            data.setup();

            double passThroughNs = measure(() -> passThrough(data));
            double jsonFormatNs = measure(() -> jsonFormat(data));
            double equalsConstantNs = measure(() -> equalsConstant(data));

            out.append(String.format(
                    "%-14s | %8.1f ns/row | %8.1f ns/row | %8.1f ns/row%n",
                    shape, passThroughNs, jsonFormatNs, equalsConstantNs));
        }
        Files.writeString(Path.of("/tmp/json-readpath-bench.txt"), out.toString());
    }

    /// Measures the cost of JsonType.jsonValue (parse + encode) on text inputs of each shape.
    @Test
    public void measureParse()
            throws IOException
    {
        StringBuilder out = new StringBuilder();
        out.append("== BenchmarkJsonReadPath jsonValue parse cost ==\n");
        out.append("shape          | jsonValue (text -> typed)\n");
        out.append("---------------+--------------------------\n");
        for (Shape shape : Shape.values()) {
            Slice text = BenchmarkData.generateText(shape);
            double parseNs = measureNs(() -> {
                for (int i = 0; i < POSITION_COUNT; i++) {
                    jsonValue(text);
                }
            });
            out.append(String.format("%-14s | %7.1f ns/row%n", shape, parseNs));
        }
        Files.writeString(Path.of("/tmp/json-parse-bench.txt"), out.toString());
    }

    /**
     * Measures connector-boundary ingestion cost: the per-row cost of
     * JsonType.writeSlice with raw JSON text input, simulating what a connector
     * pays when materializing a JSON column from a text-producing source.
     */
    @Test
    public void measureIngestion()
            throws IOException
    {
        StringBuilder out = new StringBuilder();
        out.append("== BenchmarkJsonReadPath ingestion (writeSlice with text input) ==\n");
        out.append("shape          | text input     | typed input\n");
        out.append("---------------+----------------+----------------\n");
        for (Shape shape : Shape.values()) {
            Slice text = BenchmarkData.generateText(shape);
            Slice typed = jsonValue(text);

            double textNs = measureNs(() -> writeBlock(text));
            double typedNs = measureNs(() -> writeBlock(typed));

            out.append(String.format(
                    "%-14s | %7.1f ns/row | %7.1f ns/row%n",
                    shape, textNs, typedNs));
        }
        Files.writeString(Path.of("/tmp/json-ingestion-bench.txt"), out.toString());
    }

    private static void writeBlock(Slice value)
    {
        BlockBuilder builder = JSON.createBlockBuilder(null, POSITION_COUNT);
        for (int i = 0; i < POSITION_COUNT; i++) {
            JSON.writeSlice(builder, value);
        }
        builder.build();
    }

    private static double measureNs(Runnable work)
    {
        for (int i = 0; i < 5; i++) {
            work.run();
        }
        int iterations = 20;
        long start = System.nanoTime();
        for (int i = 0; i < iterations; i++) {
            work.run();
        }
        long elapsed = System.nanoTime() - start;
        return (double) elapsed / iterations / POSITION_COUNT;
    }

    private static double measure(Runnable work)
    {
        // Warmup: 10 invocations (each processes POSITION_COUNT rows)
        for (int i = 0; i < 10; i++) {
            work.run();
        }
        // Measurement: 30 invocations
        int iterations = 30;
        long start = System.nanoTime();
        for (int i = 0; i < iterations; i++) {
            work.run();
        }
        long elapsed = System.nanoTime() - start;
        return (double) elapsed / iterations / POSITION_COUNT;
    }

    static void main()
            throws Exception
    {
        Benchmarks.benchmark(BenchmarkJsonReadPath.class, WarmupMode.BULK_INDI).run();
    }
}
