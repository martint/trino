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
package io.trino.server;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.google.common.annotations.VisibleForTesting;
import com.google.common.collect.ImmutableList;
import io.airlift.units.Duration;
import io.trino.Session;
import io.trino.execution.StageId;
import io.trino.spi.QueryId;
import io.trino.sql.planner.PlanFragment;
import io.trino.sql.planner.SubPlan;
import io.trino.sql.planner.plan.DynamicFilterId;

import java.util.List;
import java.util.Objects;
import java.util.Optional;

import static com.google.common.base.MoreObjects.toStringHelper;
import static java.util.Objects.requireNonNull;

public class DynamicFilterService
{
    public void registerQuery(Session session, SubPlan fragmentedPlan) {}

    public void registerQueryRetry(QueryId queryId, int attemptId) {}

    public DynamicFiltersStats getDynamicFilteringStats(QueryId queryId)
    {
        return DynamicFiltersStats.EMPTY;
    }

    public void removeQuery(QueryId queryId) {}

    public boolean isCollectingTaskNeeded(QueryId queryId, PlanFragment plan)
    {
        return false;
    }

    public boolean isStageSchedulingNeededToCollectDynamicFilters(QueryId queryId, PlanFragment plan)
    {
        return false;
    }

    public void unblockStageDynamicFilters(QueryId queryId, int attemptId, PlanFragment plan) {}

    public void stageCannotScheduleMoreTasks(StageId stageId, int attemptId, int numberOfTasks) {}

    public static class DynamicFiltersStats
    {
        public static final DynamicFiltersStats EMPTY = new DynamicFiltersStats(ImmutableList.of(), 0, 0, 0, 0);

        private final List<DynamicFilterDomainStats> dynamicFilterDomainStats;
        private final int lazyDynamicFilters;
        private final int replicatedDynamicFilters;
        private final int totalDynamicFilters;
        private final int dynamicFiltersCompleted;

        @JsonCreator
        public DynamicFiltersStats(
                @JsonProperty("dynamicFilterDomainStats") List<DynamicFilterDomainStats> dynamicFilterDomainStats,
                @JsonProperty("lazyDynamicFilters") int lazyDynamicFilters,
                @JsonProperty("replicatedDynamicFilters") int replicatedDynamicFilters,
                @JsonProperty("totalDynamicFilters") int totalDynamicFilters,
                @JsonProperty("dynamicFiltersCompleted") int dynamicFiltersCompleted)
        {
            this.dynamicFilterDomainStats = requireNonNull(dynamicFilterDomainStats, "dynamicFilterDomainStats is null");
            this.lazyDynamicFilters = lazyDynamicFilters;
            this.replicatedDynamicFilters = replicatedDynamicFilters;
            this.totalDynamicFilters = totalDynamicFilters;
            this.dynamicFiltersCompleted = dynamicFiltersCompleted;
        }

        @JsonProperty
        public List<DynamicFilterDomainStats> getDynamicFilterDomainStats()
        {
            return dynamicFilterDomainStats;
        }

        @JsonProperty
        public int getLazyDynamicFilters()
        {
            return lazyDynamicFilters;
        }

        @JsonProperty
        public int getReplicatedDynamicFilters()
        {
            return replicatedDynamicFilters;
        }

        @JsonProperty
        public int getTotalDynamicFilters()
        {
            return totalDynamicFilters;
        }

        @JsonProperty
        public int getDynamicFiltersCompleted()
        {
            return dynamicFiltersCompleted;
        }

        @Override
        public boolean equals(Object o)
        {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }
            DynamicFiltersStats that = (DynamicFiltersStats) o;
            return lazyDynamicFilters == that.lazyDynamicFilters &&
                    replicatedDynamicFilters == that.replicatedDynamicFilters &&
                    totalDynamicFilters == that.totalDynamicFilters &&
                    dynamicFiltersCompleted == that.dynamicFiltersCompleted &&
                    Objects.equals(dynamicFilterDomainStats, that.dynamicFilterDomainStats);
        }

        @Override
        public int hashCode()
        {
            return Objects.hash(dynamicFilterDomainStats, lazyDynamicFilters, replicatedDynamicFilters, totalDynamicFilters, dynamicFiltersCompleted);
        }
    }

    public static class DynamicFilterDomainStats
    {
        private final DynamicFilterId dynamicFilterId;
        private final String simplifiedDomain;
        private final Optional<Duration> collectionDuration;

        @VisibleForTesting
        DynamicFilterDomainStats(DynamicFilterId dynamicFilterId, String simplifiedDomain)
        {
            this(dynamicFilterId, simplifiedDomain, Optional.empty());
        }

        @JsonCreator
        public DynamicFilterDomainStats(
                @JsonProperty("dynamicFilterId") DynamicFilterId dynamicFilterId,
                @JsonProperty("simplifiedDomain") String simplifiedDomain,
                @JsonProperty("collectionDuration") Optional<Duration> collectionDuration)
        {
            this.dynamicFilterId = requireNonNull(dynamicFilterId, "dynamicFilterId is null");
            this.simplifiedDomain = requireNonNull(simplifiedDomain, "simplifiedDomain is null");
            this.collectionDuration = requireNonNull(collectionDuration, "collectionDuration is null");
        }

        @JsonProperty
        public DynamicFilterId getDynamicFilterId()
        {
            return dynamicFilterId;
        }

        @JsonProperty
        public String getSimplifiedDomain()
        {
            return simplifiedDomain;
        }

        @JsonProperty
        public Optional<Duration> getCollectionDuration()
        {
            return collectionDuration;
        }

        @Override
        public boolean equals(Object o)
        {
            if (this == o) {
                return true;
            }
            if (o == null || getClass() != o.getClass()) {
                return false;
            }
            DynamicFilterDomainStats stats = (DynamicFilterDomainStats) o;
            return Objects.equals(dynamicFilterId, stats.dynamicFilterId) &&
                    Objects.equals(simplifiedDomain, stats.simplifiedDomain);
        }

        @Override
        public int hashCode()
        {
            return Objects.hash(dynamicFilterId, simplifiedDomain);
        }

        @Override
        public String toString()
        {
            return toStringHelper(this)
                    .add("dynamicFilterId", dynamicFilterId)
                    .add("simplifiedDomain", simplifiedDomain)
                    .add("collectionDuration", collectionDuration)
                    .toString();
        }
    }
}
