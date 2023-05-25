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
package io.trino.execution.executor2.scheduler;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkState;

final class PriorityQueue<T>
{
    private final TreeSet<T> queue;
    private final Map<T, Entry<T>> index = new HashMap<>();

    public PriorityQueue()
    {
        queue = new TreeSet<>((a, b) -> {
            int result = Long.compare(index.get(a).priority(), index.get(b).priority());
            if (result == 0) {
                result = Integer.compare(System.identityHashCode(a), System.identityHashCode(b));
            }
            return result;
        });
    }

    public void add(T value, long priority)
    {
        checkArgument(!index.containsKey(value), "Value already in queue: %s", value);
        index.put(value, new Entry<>(priority, value));
        queue.add(value);
    }

    public void addOrReplace(T value, long priority)
    {
        if (index.containsKey(value)) {
            queue.remove(value);
            index.put(value, new Entry<>(priority, value));
            queue.add(value);
        }
        else {
            add(value, priority);
        }
    }

    public T poll()
    {
        T result = queue.pollFirst();
        index.remove(result);

        return result;
    }

    public void remove(T value)
    {
        checkArgument(index.containsKey(value), "Value not in queue: %s", value);

        queue.remove(value);
        index.remove(value);
    }

    public void removeIfPresent(T value)
    {
        if (index.containsKey(value)) {
            remove(value);
        }
    }

    public boolean contains(T value)
    {
        return index.containsKey(value);
    }

    public boolean isEmpty()
    {
        return index.isEmpty();
    }

    public Set<T> values()
    {
        return index.keySet();
    }

    public long nextPriority()
    {
        checkState(!queue.isEmpty(), "Queue is empty");
        return index.get(queue.first()).priority();
    }

    public T peek()
    {
        if (queue.isEmpty()) {
            return null;
        }
        return queue.first();
    }

    @Override
    public String toString()
    {
        return queue.toString();
    }

    private record Entry<T>(long priority, T value)
    {
    }
}
