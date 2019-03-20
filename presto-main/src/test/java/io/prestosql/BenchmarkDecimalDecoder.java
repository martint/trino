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
package io.prestosql;

import io.airlift.slice.Slice;
import io.airlift.slice.Slices;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OperationsPerInvocation;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.RunnerException;
import org.openjdk.jmh.runner.options.Options;
import org.openjdk.jmh.runner.options.OptionsBuilder;
import org.openjdk.jmh.runner.options.VerboseMode;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;
import java.util.concurrent.TimeUnit;

import static io.prestosql.DecimalDecoder.encode;

@State(Scope.Thread)
@OutputTimeUnit(TimeUnit.NANOSECONDS)
@BenchmarkMode(Mode.AverageTime)
@Fork(3)
@Warmup(iterations = 10)
@Measurement(iterations = 10)
public class BenchmarkDecimalDecoder
{
    public static final int CHUNKS = 100;
    public static final int ITEMS_PER_CHUNK = 1024;

    private List<Slice> data;
    private long[] result = new long[CHUNKS * ITEMS_PER_CHUNK * 2];

    @Setup
    public void setup()
    {
        List<Slice> chunks = new ArrayList<>();

        for (int chunk = 0; chunk < CHUNKS; chunk++) {
            byte[] data = new byte[19 * ITEMS_PER_CHUNK];
            int offset = 0;

            int split = 0;
            for (int item = 0; item < ITEMS_PER_CHUNK; item++) {
                int bits = ThreadLocalRandom.current().nextInt(1, 128);
                offset = encode(data, offset, bits);

                if (item == ITEMS_PER_CHUNK / 2) {
                    split = offset - 1;
                }
            }

//            chunks.add(Slices.wrappedBuffer(data, 0, offset));
            // so that some values straddle the chunks
            chunks.add(Slices.wrappedBuffer(data, 0, split));
            chunks.add(Slices.wrappedBuffer(data, split, offset - split));
        }

        this.data = chunks;
    }

    @Benchmark
    @OperationsPerInvocation(CHUNKS * ITEMS_PER_CHUNK)
    public long[] benchmark()
    {
        DecimalDecoder decoder = new DecimalDecoder(data);
        return decoder.decode(result, CHUNKS * ITEMS_PER_CHUNK);
    }

    public static void main(String[] args)
            throws RunnerException
    {
        BenchmarkDecimalDecoder benchmark = new BenchmarkDecimalDecoder();
        benchmark.setup();
        try {
            benchmark.benchmark();
        }
        catch (Exception e) {

        }

        Options options = new OptionsBuilder()
                .verbosity(VerboseMode.NORMAL)
                .include(".*\\." + BenchmarkDecimalDecoder.class.getSimpleName() + "\\..*")
                .build();
        new Runner(options).run();
    }
}
