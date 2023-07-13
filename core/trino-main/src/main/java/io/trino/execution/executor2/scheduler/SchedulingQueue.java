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

import com.google.common.collect.ImmutableSet;
import io.trino.annotation.NotThreadSafe;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import static com.google.common.base.Preconditions.checkArgument;
import static com.google.common.base.Preconditions.checkState;
import static com.google.common.base.Verify.verify;
import static io.trino.execution.executor2.scheduler.SchedulingQueue.State.BLOCKED;
import static io.trino.execution.executor2.scheduler.SchedulingQueue.State.RUNNABLE;
import static io.trino.execution.executor2.scheduler.SchedulingQueue.State.RUNNING;

/**
 * <p>A queue of tasks that are scheduled for execution. Modeled after
 * <a href="https://en.wikipedia.org/wiki/Completely_Fair_Scheduler">Completely Fair Scheduler</a>.
 * Tasks are grouped into scheduling groups. Within a group, tasks are ordered based
 * on their relative weight. Groups are ordered relative to each other based on the
 * accumulated weight of their tasks.</p>
 *
 * <p>A task can be in one of three states:
 * <ul>
 *     <li><b>runnable</b>: the task is ready to run and waiting to be dequeued
 *     <li><b>running</b>: the task has been dequeued and is running
 *     <li><b>blocked</b>: the task is blocked on some external event and is not running
 * </ul>
 * </p>
 * <p>
 * A group can be in one of three states:
 * <ul>
 *     <li><b>runnable</b>: the group has at least one runnable task
 *     <li><b>running</b>: all the tasks in the group are currently running
 *     <li><b>blocked</b>: all the tasks in the group are currently blocked
 * </ul>
 * </p>
 * <p>
 * The goal is to balance the consideration among groups to ensure the accumulated
 * weight in the long run is equal among groups. Within a group, the goal is to
 * balance the consideration among tasks to ensure the accumulated weight in the
 * long run is equal among tasks within the group.
 *
 * <p>Groups start in the blocked state and transition to the runnable state when a task is
 * added via the {@link #enqueue(Object, Object, long)} method.</p>
 *
 * <p>Tasks are dequeued via the {@link #dequeue(long)}. When all tasks in a group have
 * been dequeued, the group transitions to the running state and is removed from the
 * queue.</p>
 *
 * <p>When a task time slice completes, it needs to be re-enqueued via the
 * {@link #enqueue(Object, Object, long)}, which includes the desired
 * increment in relative weight to apply to the task for further prioritization.
 * The weight increment is also applied to the group.
 * </p>
 *
 * <p>If a task blocks, the caller must call the {@link #block(Object, Object, long)}
 * method to indicate that the task is no longer running. A weight increment can be
 * included for the portion of time the task was not blocked.</p>
 * <br/>
 * <h2>Group state transitions</h2>
 * <pre>
 *                                                                 blockTask()
 *    finishTask()               enqueueTask()                     enqueueTask()
 *        ┌───┐   ┌──────────────────────────────────────────┐       ┌────┐
 *        │   │   │                                          │       │    │
 *        │   ▼   │                                          ▼       ▼    │
 *      ┌─┴───────┴─┐   all blocked        finishTask()   ┌────────────┐  │
 *      │           │◄──────────────O◄────────────────────┤            ├──┘
 * ────►│  BLOCKED  │               │                     │  RUNNABLE  │
 *      │           │               │   ┌────────────────►│            │◄───┐
 *      └───────────┘       not all │   │  enqueueTask()  └──────┬─────┘    │
 *            ▲             blocked │   │                        │          │
 *            │                     │   │           dequeueTask()│          │
 *            │ all blocked         ▼   │                        │          │
 *            │                   ┌─────┴─────┐                  ▼          │
 *            │                   │           │◄─────────────────O──────────┘
 *            O◄──────────────────┤  RUNNING  │      queue empty     queue
 *            │      blockTask()  │           ├───┐                 not empty
 *            │                   └───────────┘   │
 *            │                     ▲      ▲      │ finishTask()
 *            └─────────────────────┘      └──────┘
 *                not all blocked
 * </pre>
 *
 * <h2>Implementation notes</h2>
 * <ul>
 *     <li>TODO: Initial weight upon registration</li>
 *     <li>TODO: Weight adjustment during blocking / unblocking</li>
 *     <li>TODO: Uncommitted weight on dequeue</li>
 * </ul>
 * </p>
 */
@NotThreadSafe
final class SchedulingQueue<G, T>
{
    private final PriorityQueue<G> runnableQueue = new PriorityQueue<>();
    private final Map<G, Group<T>> groups = new HashMap<>();
    private final PriorityQueue<G> baselineWeights = new PriorityQueue<>();
    private final Map<G, Blocked> blocked = new HashMap<>();

    public void startGroup(G group)
    {
        checkArgument(!groups.containsKey(group), "Group already started: %s", group);

        Group<T> info = new Group<>(baselineWeight());
        groups.put(group, info);

        doTransition(group, info);
    }

    public Set<T> finishGroup(G group)
    {
        checkArgument(groups.containsKey(group), "Unknown group: %s", group);

        runnableQueue.removeIfPresent(group);
        baselineWeights.removeIfPresent(group);
        blocked.remove(group);
        return groups.remove(group).tasks();
    }

    public boolean containsGroup(G group)
    {
        return groups.containsKey(group);
    }

    public Set<T> finishAll()
    {
        Set<G> groups = ImmutableSet.copyOf(this.groups.keySet());
        return groups.stream()
                .map(this::finishGroup)
                .flatMap(Collection::stream)
                .collect(Collectors.toSet());
    }

    public void finish(G group, T task)
    {
        checkArgument(groups.containsKey(group), "Unknown group: %s", group);
        verifyState(group);

        Group<T> info = groups.get(group);
        info.finish(task);

        doTransition(group, info);
    }

    public void enqueue(G group, T task, long deltaWeight)
    {
        checkArgument(groups.containsKey(group), "Unknown group: %s", group);
        verifyState(group);

        Group<T> info = groups.get(group);

        State previousState = info.state();
        info.enqueue(task, deltaWeight);

        if (previousState == BLOCKED) {
            // When transitioning from blocked, set the baseline weight to the minimum current weight
            // to avoid the newly unblocked group from monopolizing the queue while it catches up
            Blocked blockedGroup = blocked.remove(group);
            info.adjustWeight(blockedGroup.savedDelta());
        }

        checkState(info.state() == RUNNABLE);
        doTransition(group, info);
    }

    public void block(G group, T task, long deltaWeight)
    {
        Group<T> info = groups.get(group);
        checkArgument(info != null, "Unknown group: %s", group);
        checkArgument(info.state() == RUNNABLE || info.state() == RUNNING, "Group is already blocked: %s", group);
        verifyState(group);

        info.block(task, deltaWeight);
        doTransition(group, info);
    }

    public T dequeue(long expectedWeight)
    {
        G group = runnableQueue.poll();

        if (group == null) {
            return null;
        }

        Group<T> info = groups.get(group);
        verify(info.state() == RUNNABLE, "Group is not runnable: %s", group);

        T task = info.dequeue(expectedWeight);
        verify(task != null);

        doTransition(group, info);

        return task;
    }

    public T peek()
    {
        G group = runnableQueue.peek();

        if (group == null) {
            return null;
        }

        Group<T> info = groups.get(group);
        verify(info.state() == RUNNABLE, "Group is not runnable: %s", group);

        T task = info.peek();
        checkState(task != null);

        return task;
    }

    private void doTransition(G group, Group<T> info)
    {
        switch (info.state()) {
            case RUNNABLE -> transitionToRunnable(group, info);
            case RUNNING -> transitionToRunning(group, info);
            case BLOCKED -> transitionToBlocked(group, info);
        }

        verifyState(group);
    }

    private void transitionToRunning(G group, Group<T> info)
    {
        checkArgument(info.state() == RUNNING);

        baselineWeights.addOrReplace(group, info.weight());
    }

    private void transitionToBlocked(G group, Group<T> info)
    {
        checkArgument(info.state() == BLOCKED);

        blocked.put(group, new Blocked(info.weight() - baselineWeight()));
        baselineWeights.removeIfPresent(group);
        runnableQueue.removeIfPresent(group);
    }

    private void transitionToRunnable(G group, Group<T> info)
    {
        checkArgument(info.state() == RUNNABLE);

        runnableQueue.addOrReplace(group, info.weight());
        baselineWeights.addOrReplace(group, info.weight());
    }

    public State state(G group)
    {
        Group<T> info = groups.get(group);
        checkArgument(info != null, "Unknown group: %s", group);

        return info.state();
    }

    private long baselineWeight()
    {
        if (baselineWeights.isEmpty()) {
            return 0;
        }

        return baselineWeights.nextPriority();
    }

    private void verifyState(G groupKey)
    {
        Group<T> group = groups.get(groupKey);
        checkArgument(group != null, "Unknown group: %s", groupKey);

        switch (group.state()) {
            case BLOCKED -> {
                checkState(!runnableQueue.contains(groupKey), "Group in BLOCKED state should not be in queue: %s", groupKey);
                checkState(!baselineWeights.contains(groupKey));
            }
            case RUNNABLE -> {
                checkState(runnableQueue.contains(groupKey), "Group in RUNNABLE state should be in queue: %s", groupKey);
                checkState(baselineWeights.contains(groupKey));
            }
            case RUNNING -> {
                checkState(!runnableQueue.contains(groupKey), "Group in RUNNING state should not be in queue: %s", groupKey);
                checkState(baselineWeights.contains(groupKey));
            }
        }
    }

    @Override
    public String toString()
    {
        StringBuilder builder = new StringBuilder();

        builder.append("Baseline weight: %s\n".formatted(baselineWeight()));
        builder.append("\n");

        for (Map.Entry<G, Group<T>> entry : groups.entrySet()) {
            G group = entry.getKey();
            Group<T> info = entry.getValue();

            switch (entry.getValue().state()) {
                case BLOCKED -> builder.append("   - %s [BLOCKED, saved delta = %s]\n".formatted(
                        group,
                        blocked.get(entry.getKey()).savedDelta()));
                case RUNNING, RUNNABLE -> builder.append("  %s %s [%s, weight = %s, baseline = %s]\n".formatted(
                        group == runnableQueue.peek() ? "=>" : " -",
                        group,
                        info.state(),
                        info.weight(),
                        info.baselineWeight()));
            }

            for (Map.Entry<T, Task> taskEntry : info.tasks.entrySet()) {
                T task = taskEntry.getKey();
                Task taskInfo = taskEntry.getValue();

                if (info.blocked.containsKey(task)) {
                    builder.append("         %s [BLOCKED, saved delta = %s]\n".formatted(task, info.blocked.get(task).savedDelta()));
                }
                else if (info.runnableQueue.contains(task)) {
                    builder.append("      %s %s [RUNNABLE, weight = %s]\n".formatted(
                            task == info.peek() ? "=>" : "  ",
                            task,
                            taskInfo.weight()));
                }
                else {
                    builder.append("         %s [RUNNING, weight = %s, uncommitted = %s]\n".formatted(
                            task,
                            taskInfo.weight(),
                            taskInfo.uncommittedWeight()));
                }
            }
        }

        return builder.toString();
    }

    private static class Group<T>
    {
        private State state;
        private long weight;
        private final Map<T, Task> tasks = new HashMap<>();
        private final PriorityQueue<T> runnableQueue = new PriorityQueue<>();
        private final Map<T, Blocked> blocked = new HashMap<>();
        private final PriorityQueue<T> baselineWeights = new PriorityQueue<>();

        public Group(long weight)
        {
            this.state = BLOCKED;
            this.weight = weight;
        }

        public void enqueue(T task, long deltaWeight)
        {
            Task info = tasks.get(task);

            if (info == null) {
                // New tasks get assigned the baseline weight so that they don't monopolize the queue
                // while they catch up
                info = new Task(baselineWeight());
                tasks.put(task, info);
            }
            else if (blocked.containsKey(task)) {
                Blocked blockedTask = blocked.remove(task);
                info.adjustWeight(blockedTask.savedDelta());
            }

            weight -= info.uncommittedWeight();
            weight += deltaWeight;

            info.commitWeight(deltaWeight);
            runnableQueue.add(task, info.weight());
            baselineWeights.addOrReplace(task, info.weight());

            updateState();
        }

        public T dequeue(long expectedWeight)
        {
            checkArgument(state == RUNNABLE);

            T task = runnableQueue.poll();

            Task info = tasks.get(task);
            info.setUncommittedWeight(expectedWeight);
            weight += expectedWeight;

            baselineWeights.addOrReplace(task, info.weight());

            updateState();

            return task;
        }

        public void finish(T task)
        {
            checkArgument(tasks.containsKey(task), "Unknown task: %s", task);
            tasks.remove(task);
            runnableQueue.removeIfPresent(task);
            baselineWeights.removeIfPresent(task);

            updateState();
        }

        public void block(T task, long deltaWeight)
        {
            checkArgument(tasks.containsKey(task), "Unknown task: %s", task);
            checkArgument(!runnableQueue.contains(task), "Task is already in queue: %s", task);

            weight += deltaWeight;

            Task info = tasks.get(task);
            info.commitWeight(deltaWeight);

            blocked.put(task, new Blocked(weight - baselineWeight()));
            baselineWeights.remove(task);

            updateState();
        }

        private long baselineWeight()
        {
            if (baselineWeights.isEmpty()) {
                return 0;
            }

            return baselineWeights.nextPriority();
        }

        public void adjustWeight(long delta)
        {
            weight += delta;
        }

        private void updateState()
        {
            if (blocked.size() == tasks.size()) {
                state = BLOCKED;
            }
            else if (runnableQueue.isEmpty()) {
                state = RUNNING;
            }
            else {
                state = RUNNABLE;
            }
        }

        public long weight()
        {
            return weight;
        }

        public Set<T> tasks()
        {
            return tasks.keySet();
        }

        public State state()
        {
            return state;
        }

        public T peek()
        {
            return runnableQueue.peek();
        }
    }

    private static class Task
    {
        private long weight;
        private long uncommittedWeight;

        public Task(long initialWeight)
        {
            weight = initialWeight;
        }

        public void commitWeight(long delta)
        {
            weight += delta;
            uncommittedWeight = 0;
        }

        public void adjustWeight(long delta)
        {
            weight += delta;
        }

        public long weight()
        {
            return weight + uncommittedWeight;
        }

        public void setUncommittedWeight(long weight)
        {
            this.uncommittedWeight = weight;
        }

        public long uncommittedWeight()
        {
            return uncommittedWeight;
        }
    }

    public enum State
    {
        BLOCKED, // all tasks are blocked
        RUNNING, // all tasks are dequeued and running
        RUNNABLE // some tasks are enqueued and ready to run
    }

    private record Blocked(long savedDelta)
    {
    }
}
