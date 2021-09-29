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

import io.airlift.slice.DynamicSliceOutput;
import io.trino.tpch.LineItem;
import io.trino.tpch.LineItemColumn;
import io.trino.tpch.LineItemGenerator;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Iterator;

public class DumpData
{
    public static void main(String[] args)
            throws IOException
    {
        LineItemGenerator lineItemGenerator = new LineItemGenerator(1, 1, 1);
        Iterator<LineItem> iterator = lineItemGenerator.iterator();

        int positions = 10_000;
        long[] discount = new long[positions];
        long[] extendedPrice = new long[positions];
        long[] quantity = new long[positions];
        int[] shipDatePositions = new int[positions + 1];
        byte[] shipDate = new byte[positions * 10];

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

        DynamicSliceOutput output = new DynamicSliceOutput(300000);
        output.writeInt(positions);
        for (int i = 0; i < positions; i++) {
            output.writeLong(discount[i]);
        }
        for (int i = 0; i < positions; i++) {
            output.writeLong(extendedPrice[i]);
        }
        for (int i = 0; i < positions; i++) {
            output.writeLong(quantity[i]);
        }
        for (int i = 0; i < positions + 1; i++) {
            output.writeInt(shipDatePositions[i]);
        }
        output.write(shipDate, 0, shipDatePositions[positions]);

        Files.write(Paths.get("data.bin"), output.slice().getBytes());
    }
}
