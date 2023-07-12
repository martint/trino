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
import io.airlift.log.Logger;
import io.trino.execution.executor2.scheduler.TaskControl.State;

import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

import static java.util.Objects.requireNonNull;

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
                System.out.println("Available permits: " + concurrencyControl.availablePermits());
                System.out.println("Reservations: " + concurrencyControl.reservations());
                try {
                    Thread.sleep(10_000);
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
    public void close()
    {
        Set<TaskControl> tasks = queue.finishAll();

        for (TaskControl task : tasks) {
            task.cancel();
        }

        taskExecutor.shutdownNow();
        schedulerExecutor.shutdownNow();
    }

    public Group createGroup(String name)
    {
        Group group = new Group(name);
        queue.startGroup(group);

        return group;
    }

    public void removeGroup(Group group)
    {
        Set<TaskControl> tasks = queue.finishGroup(group);

        for (TaskControl task : tasks) {
            task.cancel();
        }
    }

    public ListenableFuture<Void> submit(Group group, int id, Schedulable runner)
    {
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

        if (!task.transitionToWaiting()) {
            concurrencyControl.release(task);
            return false;
        }

        queue.enqueue(task.group(), task, delta);
        concurrencyControl.release(task);

        return awaitReadyAndTransitionToRunning(task);
    }

    boolean block(TaskControl task, ListenableFuture<?> future)
    {
        long delta = task.elapsed();

        if (!task.transitionToBlocked()) {
            concurrencyControl.release(task);
            return false;
        }

        if (!queue.block(task.group(), task, delta)) {
            concurrencyControl.release(task);
            return false;
        }

        concurrencyControl.release(task);

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
}
