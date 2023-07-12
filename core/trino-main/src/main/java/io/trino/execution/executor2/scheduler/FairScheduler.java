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

import com.google.common.base.Ticker;
import com.google.common.util.concurrent.ListenableFuture;
import com.google.common.util.concurrent.ListeningExecutorService;
import com.google.common.util.concurrent.MoreExecutors;
import com.google.common.util.concurrent.ThreadFactoryBuilder;
import com.google.errorprone.annotations.ThreadSafe;
import com.google.errorprone.annotations.concurrent.GuardedBy;
import io.airlift.log.Logger;
import io.trino.execution.executor2.scheduler.TaskControl.State;

import java.util.Set;
import java.util.StringJoiner;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static com.google.common.base.Preconditions.checkArgument;
import static java.util.Objects.requireNonNull;

/**
 * <h2>Implementation nodes</h2>
 *
 * <ul>
 *     <li>The TaskControl state machine is only modified by the task executor
 * thread (i.e., from within {@link FairScheduler#runTask(Schedulable, TaskControl)} )}). Other threads
 * can indirectly affect what the task executor thread does by marking the task as ready or cancelled
 * and unblocking the task executor thread, which will then act on that information.</li>
 * </ul>
 */
@ThreadSafe
public final class FairScheduler
        implements AutoCloseable
{
    private static final Logger LOG = Logger.get(FairScheduler.class);

    public static final long QUANTUM_NANOS = TimeUnit.MILLISECONDS.toNanos(1000);

    private final ExecutorService schedulerExecutor;
    private final ListeningExecutorService taskExecutor;
    private final BlockingSchedulingQueue<Group, TaskControl> queue = new BlockingSchedulingQueue<>();
    private final Reservation<TaskControl> concurrencyControl;
    private final Ticker ticker;

    private final Gate paused = new Gate(true);

    private final Thread dumper;

    @GuardedBy("this")
    private boolean closed;

    public FairScheduler(int maxConcurrentTasks, String threadNameFormat, Ticker ticker)
    {
        this.ticker = requireNonNull(ticker, "ticker is null");

        concurrencyControl = new Reservation<>(maxConcurrentTasks);

        schedulerExecutor = Executors.newCachedThreadPool(new ThreadFactoryBuilder()
                .setNameFormat("fair-scheduler-%d")
                .setDaemon(true)
                .build());

        taskExecutor = MoreExecutors.listeningDecorator(Executors.newCachedThreadPool(new ThreadFactoryBuilder()
                .setNameFormat(threadNameFormat)
                .setDaemon(true)
                .build()));

        dumper = new Thread(() -> {
            while (true) {
                LOG.info("Available permits: %s", concurrencyControl.availablePermits());
                LOG.info("Reservations: %s", concurrencyControl.reservations());
                LOG.info(queue.toString());
                try {
                    Thread.sleep(60_000);
                }
                catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
        });
    }

    public static FairScheduler newInstance(int maxConcurrentTasks)
    {
        return newInstance(maxConcurrentTasks, Ticker.systemTicker());
    }

    public static FairScheduler newInstance(int maxConcurrentTasks, Ticker ticker)
    {
        FairScheduler scheduler = new FairScheduler(maxConcurrentTasks, "fair-scheduler-runner-%d", ticker);
        scheduler.start();
        return scheduler;
    }

    public void start()
    {
        schedulerExecutor.submit(this::runScheduler);
        dumper.start();
    }

    public void pause()
    {
        paused.close();
    }

    public void resume()
    {
        paused.open();
    }

    @Override
    public synchronized void close()
    {
        if (closed) {
            return;
        }
        closed = true;

        LOG.info("Closing fair scheduler: %s", this);

        Set<TaskControl> tasks = queue.finishAll();

        for (TaskControl task : tasks) {
            task.cancel();
        }

        taskExecutor.shutdownNow();
        schedulerExecutor.shutdownNow();
    }

    public synchronized Group createGroup(String name)
    {
        checkArgument(!closed, "Already closed");

        LOG.info("Create group: %s", name);

        Group group = new Group(name);
        queue.startGroup(group);

        return group;
    }

    public synchronized void removeGroup(Group group)
    {
        checkArgument(!closed, "Already closed");

        LOG.info("Remove group: %s", group);

        Set<TaskControl> tasks = queue.finishGroup(group);

        for (TaskControl task : tasks) {
            task.cancel();
        }
    }

    public synchronized ListenableFuture<Void> submit(Group group, int id, Schedulable runner)
    {
        checkArgument(!closed, "Already closed");

        TaskControl task = new TaskControl(group, id, ticker);
        ListenableFuture<Void> done = taskExecutor.submit(() -> runTask(runner, task), null);
        queue.enqueue(group, task, 0);

        return done;
    }

    private void runTask(Schedulable runner, TaskControl task)
    {
        task.setThread(Thread.currentThread());

        // wait for the task to be scheduled
        if (!awaitReadyAndTransitionToRunning(task)) {
            return;
        }

        SchedulerContext context = new SchedulerContext(this, task);
        try {
            runner.run(context);
        }
        catch (Exception e) {
            LOG.error(e);
        }
        finally {
            // If the runner exited due to an exception in user code or
            // normally (not in response to an interruption during blocking or yield),
            // it must have had a semaphore permit reserved, so release it.
            if (task.getState() == State.RUNNING) {
                concurrencyControl.release(task);
            }
        }
    }

    /**
     * @return false if the transition was unsuccessful due to the task being cancelled
     */
    private boolean awaitReadyAndTransitionToRunning(TaskControl task)
    {
        if (!task.awaitReady()) {
            if (task.isReady()) {
                // If the task was marked as ready (slot acquired) but then cancelled before
                // awaitReady() was notified, we need to release the slot.
                concurrencyControl.release(task);
            }
            return false;
        }

        if (!task.transitionToRunning()) {
            concurrencyControl.release(task);
            return false;
        }

        return true;
    }

    boolean yield(TaskControl task)
    {
        long delta = task.elapsed();
        if (delta < QUANTUM_NANOS) {
            return true;
        }

        concurrencyControl.release(task);

        if (!task.transitionToWaiting()) {
            return false;
        }

        if (!queue.enqueue(task.group(), task, delta)) {
            return false;
        }

        return awaitReadyAndTransitionToRunning(task);
    }

    boolean block(TaskControl task, ListenableFuture<?> future)
    {
        long delta = task.elapsed();

        concurrencyControl.release(task);

        if (!task.transitionToBlocked()) {
            return false;
        }

        if (!queue.block(task.group(), task, delta)) {
            return false;
        }

        future.addListener(task::markUnblocked, MoreExecutors.directExecutor());
        task.awaitUnblock();

        if (!task.transitionToWaiting()) {
            return false;
        }

        if (!queue.enqueue(task.group(), task, 0)) {
            return false;
        }

        return awaitReadyAndTransitionToRunning(task);
    }

    private void runScheduler()
    {
        while (true) {
            try {
                paused.awaitOpen();
                concurrencyControl.reserve();
                TaskControl task = queue.dequeue(QUANTUM_NANOS);
                concurrencyControl.register(task);
                if (!task.markReady()) {
                    concurrencyControl.release(task);
                }
            }
            catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                return;
            }
        }
    }

    long getScheduledNanos(TaskControl task)
    {
        return task.getScheduledNanos();
    }

    long getWaitNanos(TaskControl task)
    {
        return task.getWaitNanos();
    }

    long getBlockedNanos(TaskControl task)
    {
        return task.getBlockedNanos();
    }

    @Override
    public String toString()
    {
        return new StringJoiner(", ", FairScheduler.class.getSimpleName() + "[", "]")
                .add("queue=" + queue)
                .add("concurrencyControl=" + concurrencyControl)
                .add("closed=" + closed)
                .toString();
    }
}
