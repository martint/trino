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
package io.trino.sql.planner.optimizations.unnest;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableListMultimap;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.ListMultimap;
import com.google.common.collect.Sets;
import io.trino.metadata.Metadata;
import io.trino.sql.ir.Cast;
import io.trino.sql.ir.Comparison;
import io.trino.sql.ir.Constant;
import io.trino.sql.ir.Expression;
import io.trino.sql.ir.Logical;
import io.trino.sql.ir.Switch;
import io.trino.sql.ir.WhenClause;
import io.trino.sql.planner.NodeAndMappings;
import io.trino.sql.planner.OrderingScheme;
import io.trino.sql.planner.PlanCopier;
import io.trino.sql.planner.PlanNodeIdAllocator;
import io.trino.sql.planner.Symbol;
import io.trino.sql.planner.SymbolAllocator;
import io.trino.sql.planner.SymbolsExtractor;
import io.trino.sql.planner.iterative.GroupReference;
import io.trino.sql.planner.iterative.Lookup;
import io.trino.sql.planner.optimizations.SymbolMapper;
import io.trino.sql.planner.plan.AggregationNode;
import io.trino.sql.planner.plan.AssignUniqueId;
import io.trino.sql.planner.plan.Assignments;
import io.trino.sql.planner.plan.CorrelatedJoinNode;
import io.trino.sql.planner.plan.DataOrganizationSpecification;
import io.trino.sql.planner.plan.EnforceSingleRowNode;
import io.trino.sql.planner.plan.ExceptNode;
import io.trino.sql.planner.plan.FilterNode;
import io.trino.sql.planner.plan.GroupIdNode;
import io.trino.sql.planner.plan.IntersectNode;
import io.trino.sql.planner.plan.JoinNode;
import io.trino.sql.planner.plan.JoinType;
import io.trino.sql.planner.plan.LimitNode;
import io.trino.sql.planner.plan.PlanNode;
import io.trino.sql.planner.plan.PlanVisitor;
import io.trino.sql.planner.plan.ProjectNode;
import io.trino.sql.planner.plan.RowNumberNode;
import io.trino.sql.planner.plan.SetOperationNode;
import io.trino.sql.planner.plan.SimplePlanRewriter;
import io.trino.sql.planner.plan.TopNNode;
import io.trino.sql.planner.plan.UnionNode;
import io.trino.sql.planner.plan.UnnestNode;
import io.trino.sql.planner.plan.ValuesNode;
import io.trino.sql.planner.plan.WindowNode;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

import static com.google.common.collect.ImmutableList.toImmutableList;
import static com.google.common.collect.ImmutableSet.toImmutableSet;
import static io.trino.spi.StandardErrorCode.SUBQUERY_MULTIPLE_ROWS;
import static io.trino.spi.type.BigintType.BIGINT;
import static io.trino.spi.type.BooleanType.BOOLEAN;
import static io.trino.sql.ir.Booleans.TRUE;
import static io.trino.sql.ir.Comparison.Operator.IDENTICAL;
import static io.trino.sql.ir.Comparison.Operator.LESS_THAN_OR_EQUAL;
import static io.trino.sql.planner.LogicalPlanner.failFunction;
import static io.trino.sql.planner.optimizations.SymbolMapper.symbolMapper;
import static io.trino.sql.planner.plan.AggregationNode.singleAggregation;
import static io.trino.sql.planner.plan.AggregationNode.singleGroupingSet;
import static io.trino.sql.planner.plan.WindowNode.Frame.DEFAULT_FRAME;
import static java.util.Objects.requireNonNull;

/**
 * Unnesting of correlated subqueries via the dependent-join algebra of Neumann and Kemper (BTW 2015).
 *
 * <p>Treats a {@link CorrelatedJoinNode} as the algebraic dependent join `T₁ ⋈^D T₂` and pushes the
 * dependency down through `T₂` until the inner side no longer references the correlation symbols
 * (`F(T₂) ∩ A(T₁) = ∅`), at which point the dependent join degenerates to a regular cross-join.
 * Correlation-using predicates that were sitting under operators in T₂ rise as filters on top of
 * the regular join, recovering theta-join shapes the legacy `PlanNodeDecorrelator` cannot lift.
 *
 * <h2>Pushdown rules implemented (Phase 1)</h2>
 *
 * <ul>
 *     <li>σ: `T₁ ⋈^D σ_p(T) ≡ σ_p(T₁ ⋈^D T)`</li>
 *     <li>π: `T₁ ⋈^D π_e(T) ≡ π_{A(T₁) ∪ e}(T₁ ⋈^D T)`</li>
 *     <li>Γ: `T₁ ⋈^D Γ_{G;A}(T) ≡ Γ_{G ∪ A(T₁); A}(T₁ ⋈^D T)`. Sound when the aggregate is
 *         existence-checked (EXISTS/HAVING) — "no group" maps to FALSE. A <b>scalar</b> global
 *         aggregate (value position, e.g. {@code (SELECT count(*) …)}) instead needs the empty
 *         group restored to the aggregate-over-empty value, handled separately by
 *         {@link #unnestScalarGlobalAggregate} (magic-set + {@code non_null} mask).</li>
 *     <li>⋈ (inner join): single-side dependence pushes into the dependent side and preserves
 *         the join with the independent side. Both-side dependence reduces to
 *         `σ_q((T₁ ⋈^D L) ⋈^D R)` — push into the left, then push that result (now carrying
 *         T₁'s correlation columns) into the right, and apply the original join condition as a
 *         filter.</li>
 *     <li>⟕ / ⟖ (left/right outer join in the dependent side): when the dependency is on the
 *         <b>preserving</b> side, push T₁ into it — `T₁ ⋈^D (L ⟕_p R) ≡ (T₁ ⋈^D L) ⟕_p R` (R
 *         correlation-free), symmetrically for ⟖. When the <b>null-supplying</b> side carries the
 *         correlation (preserving side correlation-free), cross-join the preserving side into T₁
 *         and decorrelate via the LEFT magic-set — `T₁ ⋈^D (L ⟕_p R) ≡ (T₁ × L) ⟕^D_p R`. Both
 *         sides depending, or FULL outer, bails.</li>
 *     <li>Window functions: `T₁ ⋈^D W_{P;O}(T) ≡ W_{uid(T₁) ∪ P; O}(T₁ ⋈^D T)` — a unique id of
 *         the input is added to the PARTITION BY so each function evaluates once per outer row.</li>
 *     <li>lim ({@code LimitNode} / {@code TopNNode}):
 *         `T₁ ⋈^D Lim_n(T) ≡ σ_{rn ≤ n}(rowNumber OVER (PARTITION BY uid(T₁))(T₁ ⋈^D T))`.
 *         The input is tagged with {@code AssignUniqueId} so the per-outer-row row numbering
 *         partitions correctly even when {@code T₁} has duplicate rows. TopN carries its
 *         ordering into the window's ORDER BY. {@code LIMIT … WITH TIES} uses {@code rank()}
 *         (keeps the nth row plus all ties) ordered by the ties-resolving scheme instead of
 *         {@code row_number()}.</li>
 *     <li>GroupId (the basis of {@code GROUPING SETS}/{@code ROLLUP}/{@code CUBE}, planned as an
 *         aggregation over a {@link GroupIdNode}): add T₁'s columns to every grouping set so each
 *         set is computed once per outer row.</li>
 *     <li>⊕ ({@code UNION} / {@code INTERSECT} / {@code EXCEPT}):
 *         `T₁ ⋈^D (B_1 ⊕ … ⊕ B_n) ≡ (T₁ ⋈^D B_1) ⊕ … ⊕ (T₁ ⋈^D B_n)`. Each distributed branch
 *         carries T₁'s columns into the set-op key, partitioning the set semantics by outer row.
 *         Branches after the first get a fresh clone of T₁ (a plan is a tree, not a DAG) with their
 *         correlation references rebound onto the clone.</li>
 *     <li>{@code UNNEST}: `T₁ ⋈^D Unnest_{R; arrs}(S) ≡ Unnest_{R ∪ A(T₁); arrs}(T₁ ⋈^D S)`. In a
 *         correlated subquery the unnested arrays are free correlation references, so pushing T₁
 *         into the source brings them into scope; the unnest's join type (INNER/LEFT) and
 *         ordinality are preserved.</li>
 *     <li>LEFT correlated join (the outer {@link CorrelatedJoinNode} is {@code LEFT}): first try a
 *         plain LEFT join ({@link #tryPlainLeftJoin}) — when the correlation is confined to liftable
 *         filter predicates (→ the ON condition) and projections (→ above the join), no magic-set is
 *         needed and the result is a single join, matching what the legacy
 *         {@code TransformCorrelatedJoinToJoin} produces. Otherwise fall back to Neumann &amp;
 *         Kemper's magic-set ({@link #magicSetLeftJoin}) — `T₁ ⟕^D T₂ ≡ T₁ ⟕_{C ≡ C'}
 *         (D ⋈^D T₂[C→C'])` with `D = δ(π_{C'}(T₁'))`, NULL-safe join-back — which additionally
 *         handles correlation in aggregations/joins below the filters (legacy cannot).</li>
 * </ul>
 *
 * <h2>Not yet handled — falls back to legacy by returning {@link Optional#empty()}</h2>
 *
 * <ul>
 *     <li>An outer join in the dependent side with <b>both</b> sides depending on correlation, and
 *         FULL outer joins (both sides null-supplying) — the legacy decorrelator does not handle
 *         these either.</li>
 *     <li>A non-aggregate scalar sub-case ({@code EnforceSingleRowNode}) with a top projection or a
 *         non-trivial correlated-join filter (the scalar <i>aggregate</i> path handles both).</li>
 * </ul>
 *
 * <p>Correlated {@code IN} predicates do not arrive as a {@link CorrelatedJoinNode}; the companion
 * rule {@code RewriteCorrelatedInPredicateToCorrelatedJoin} (also gated on {@code UNIFIED}) lowers
 * {@code x IN (subquery)} into a {@link CorrelatedJoinNode} over a global count aggregation (with
 * the three-valued result computed in a projection above), which this unnester then decorrelates
 * via its scalar global-aggregate path.
 *
 * <p>Where the magic-set must clone the input ({@link #tryCopyInput}), an input subtree containing
 * a node {@link PlanCopier} can't copy makes unnesting bail to legacy rather than fail.
 */
public final class DependentJoinUnnester
{
    private final PlanNodeIdAllocator idAllocator;
    private final SymbolAllocator symbolAllocator;
    private final Lookup lookup;
    private final Metadata metadata;

    public DependentJoinUnnester(PlanNodeIdAllocator idAllocator, SymbolAllocator symbolAllocator, Lookup lookup, Metadata metadata)
    {
        this.idAllocator = requireNonNull(idAllocator, "idAllocator is null");
        this.symbolAllocator = requireNonNull(symbolAllocator, "symbolAllocator is null");
        this.lookup = requireNonNull(lookup, "lookup is null");
        this.metadata = requireNonNull(metadata, "metadata is null");
    }

    /**
     * Returns a decorrelated equivalent of `correlatedJoin`, or {@link Optional#empty()} when the
     * subquery contains a shape this framework cannot push the dependent join through.
     */
    public Optional<PlanNode> unnest(CorrelatedJoinNode correlatedJoin)
    {
        JoinType type = correlatedJoin.getType();
        if (type != JoinType.INNER && type != JoinType.LEFT) {
            return Optional.empty();
        }

        Set<Symbol> correlation = ImmutableSet.copyOf(correlatedJoin.getCorrelation());
        PlanNode input = correlatedJoin.getInput();
        PlanNode subquery = correlatedJoin.getSubquery();
        Expression joinFilter = correlatedJoin.getFilter();

        // The framework rebinds free correlation references in expressions to the cloned correlation.
        // It cannot handle a correlation symbol that a join inside the subquery carries as a
        // structural output (a column that directly selects the outer value), so defer those to legacy.
        if (correlationCarriedAsJoinOutput(subquery, correlation)) {
            return Optional.empty();
        }

        // A TopN ordered by correlation has no meaningful per-outer-row order (the sort key is
        // constant within each outer row), so the bounded result is non-deterministic; defer to legacy.
        if (topNOrdersByCorrelation(subquery, correlation)) {
            return Optional.empty();
        }

        // A non-aggregate scalar subquery `(SELECT u.b … WHERE correlated)` wraps its body in an
        // EnforceSingleRowNode (exactly one row: NULL-filled if empty, error if >1). When the
        // correlation is filter-only, defer to the legacy scalar rule: it is cardinality-aware
        // (a plain LEFT join when the body is provably ≤1 row via a unique key, the row-count check
        // only when needed), which the framework's per-group row_number can't match. The framework
        // keeps the projection-correlated case (the scalar value references correlation), which
        // legacy can't decorrelate.
        if (lookup.resolve(subquery) instanceof EnforceSingleRowNode) {
            if (joinFilter.equals(TRUE) && correlationOnlyInFilters(subquery, correlation)) {
                return Optional.empty();
            }
            // A scalar subquery that outputs a bare correlation symbol (e.g. `(SELECT o.col WHERE p(o.col))`)
            // AND filters on the correlation selects the outer value directly: rebinding aliases the inner
            // correlation to the outer symbol, so for outer rows the filter excludes it would return the
            // outer value instead of NULL. Defer to legacy. (A computed projection like `o.col * 2` gets a
            // fresh output symbol; a bare output with no correlated filter — e.g. `(SELECT t.* FROM …)` —
            // either always matches or errors with "multiple rows", so neither is matched here.)
            if (!Sets.intersection(ImmutableSet.copyOf(subquery.getOutputSymbols()), correlation).isEmpty()
                    && correlationInFilter(subquery, correlation)) {
                return Optional.empty();
            }
            Optional<PlanNode> scalar = unnestScalarSingleRow(correlatedJoin, input, correlatedJoin.getCorrelation(), joinFilter);
            return scalar.map(plan -> restrictOutputs(plan, correlatedJoin.getOutputSymbols()));
        }

        // A scalar global aggregate `(SELECT count(*) …)` (an INNER correlated join, aggregation
        // at the top) needs the non_null-mask treatment: a naive Γ pushdown groups by the
        // correlation and drops the empty group, losing the aggregate-over-empty value (count → 0).
        if (type == JoinType.INNER && isScalarGlobalAggregation(subquery)) {
            Optional<PlanNode> scalar = unnestScalarGlobalAggregate(correlatedJoin, input, correlatedJoin.getCorrelation(), joinFilter);
            // If the sub-shape isn't supported yet, fall through to legacy (returns empty).
            return scalar.map(plan -> restrictOutputs(plan, correlatedJoin.getOutputSymbols()));
        }

        Optional<PlanNode> result = type == JoinType.INNER
                ? unnestInner(input, subquery, correlation, joinFilter)
                : unnestLeft(correlatedJoin, input, subquery, correlatedJoin.getCorrelation(), joinFilter);

        return result.map(plan -> restrictOutputs(plan, correlatedJoin.getOutputSymbols()));
    }

    private Optional<PlanNode> unnestInner(PlanNode input, PlanNode subquery, Set<Symbol> correlation, Expression joinFilter)
    {
        return pushDown(input, subquery, correlation)
                .map(plan -> joinFilter.equals(TRUE) ? plan : new FilterNode(idAllocator.getNextId(), plan, joinFilter));
    }

    /**
     * LEFT correlated join `T₁ ⟕^D T₂` via Neumann and Kemper's magic-set decomposition:
     * <pre>
     *   T₁ ⟕^D T₂  ≡  T₁ ⟕_{C ≡ C'} (D ⋈^D T₂[C→C'])   where D = δ(π_{C'}(T₁'))
     * </pre>
     * `D` is the distinct correlation values of the input; the subquery is evaluated once per
     * distinct value, and the original input is LEFT-joined back on the correlation columns so
     * that input rows whose subquery is empty null-extend. Joining on the correlation columns
     * (the paper's construction) — rather than a synthetic unique id — keeps the unique id out
     * of any predicate, sidestepping {@code PredicatePushDown}.
     * <p>
     * Two Trino-specific mechanics the abstract algebra does not need: the input is cloned (it is
     * both {@code D}'s source and the join's left side, and a plan is a tree), and the subquery's
     * correlation references are rebound to the clone's symbols (symbols are single-definition).
     * NULL correlation values are handled by an {@code IS NOT DISTINCT FROM} ({@code IDENTICAL})
     * join condition.
     */
    private Optional<PlanNode> unnestLeft(CorrelatedJoinNode correlatedJoin, PlanNode input, PlanNode subquery, List<Symbol> correlation, Expression joinFilter)
    {
        // Filter-correlated EXISTS / NOT EXISTS (the shapes TransformExistsApplyToCorrelatedJoin
        // emits) is decorrelated by legacy to a single join + dedup aggregation — lighter than the
        // framework's magic-set (which would also turn the EXISTS Limit into a row_number window).
        // Defer to legacy for those. The guard requires the correlation to appear only in filter
        // predicates, i.e. exactly the shape legacy is known to handle, so this never gives up a
        // framework-only capability (correlation in a projection/aggregate argument stays here).
        if (joinFilter.equals(TRUE) && isLegacyHandledExistence(subquery, ImmutableSet.copyOf(correlation))) {
            return Optional.empty();
        }
        // A LATERAL LIMIT / TopN over a filter-only-correlated body (`LEFT JOIN LATERAL
        // (SELECT … WHERE p(C) [ORDER BY …] LIMIT n)`) is decorrelated by legacy to a single join +
        // a per-outer-row row_number window; the framework's magic-set would add a distinct set and
        // a second join. Defer to legacy. Gated on filter-only correlation, so the projection-
        // correlated variant (legacy can't do) stays with the framework.
        if (joinFilter.equals(TRUE) && isLimitOverFilterOnlyCorrelation(subquery, ImmutableSet.copyOf(correlation))) {
            return Optional.empty();
        }
        List<Symbol> subqueryOutputs = correlatedJoin.getSubquery().getOutputSymbols();
        // Prefer a plain LEFT join when the correlation is confined to liftable predicates/
        // projections (the common `LEFT JOIN LATERAL (SELECT … WHERE p(C)) ON true` shape): it
        // avoids the magic-set's input clone, distinct, and second join. Reserve the magic-set for
        // deeper correlation (in an aggregation/join below the filters) that genuinely needs
        // per-distinct-value evaluation, and for a non-trivial correlated-join filter.
        if (joinFilter.equals(TRUE)) {
            Optional<PlanNode> plain = tryPlainLeftJoin(input, subquery, ImmutableSet.copyOf(correlation));
            if (plain.isPresent()) {
                return plain;
            }
        }
        return magicSetLeftJoin(input, subquery, correlation, joinFilter, subqueryOutputs);
    }

    /**
     * True for the filter-correlated EXISTS/NOT EXISTS shapes that
     * {@code TransformExistsApplyToCorrelatedJoin} emits, which legacy decorrelates more cheaply
     * (single join + dedup) than the framework's magic-set:
     * <ul>
     *     <li>Shape 1 (equality correlation): {@code Project(marker := constant) over Limit over …}</li>
     *     <li>Shape 2 (otherwise): {@code Project(… COALESCE …) over global Aggregation over …}</li>
     * </ul>
     * Both are gated by {@link #correlationOnlyInFilters}: the correlation must appear only in
     * filter predicates (never a projection or aggregate argument), which is exactly the class
     * legacy handles — so deferring never gives up a framework-only capability.
     */
    private boolean isLegacyHandledExistence(PlanNode subquery, Set<Symbol> correlation)
    {
        PlanNode top = lookup.resolve(subquery);
        // The marker/COALESCE projection may or may not sit on top of the existence node.
        PlanNode below = top instanceof ProjectNode project ? lookup.resolve(project.getSource()) : top;
        boolean shape1 = top instanceof ProjectNode marker
                && below instanceof LimitNode
                && marker.getAssignments().assignments().values().stream().allMatch(Constant.class::isInstance);
        boolean shape2 = below instanceof AggregationNode aggregation
                && aggregation.hasEmptyGroupingSet()
                && aggregation.getGroupingSetCount() == 1;
        return (shape1 || shape2) && correlationOnlyInFilters(subquery, correlation);
    }

    /**
     * True when the subquery is a {@code LimitNode}/{@code TopNNode} (possibly under projections)
     * over a filter-only-correlated body — the LATERAL {@code LIMIT}/{@code TopN} shape legacy
     * decorrelates to a single join + per-outer-row {@code row_number}, cheaper than the framework's
     * magic-set. Filter-only gating keeps the projection-correlated variant with the framework.
     */
    private boolean isLimitOverFilterOnlyCorrelation(PlanNode subquery, Set<Symbol> correlation)
    {
        PlanNode node = lookup.resolve(subquery);
        while (node instanceof ProjectNode project) {
            node = lookup.resolve(project.getSource());
        }
        return (node instanceof LimitNode || node instanceof TopNNode)
                && correlationOnlyInFilters(subquery, correlation);
    }

    /**
     * True when the correlation symbols are referenced only inside {@code FilterNode} predicates
     * anywhere in the subtree — never in a projection, aggregate argument, join condition, etc.
     * This is precisely the correlation class the legacy {@code PlanNodeDecorrelator} can pull up.
     */
    private boolean correlationOnlyInFilters(PlanNode node, Set<Symbol> correlation)
    {
        PlanNode resolved = lookup.resolve(node);
        if (!(resolved instanceof FilterNode)
                && !Sets.intersection(SymbolsExtractor.extractUniqueNonRecursive(resolved), correlation).isEmpty()) {
            return false;
        }
        return resolved.getSources().stream().allMatch(source -> correlationOnlyInFilters(source, correlation));
    }

    /**
     * True when any {@code FilterNode} predicate in the subquery references a correlation symbol.
     */
    private boolean correlationInFilter(PlanNode node, Set<Symbol> correlation)
    {
        PlanNode resolved = lookup.resolve(node);
        if (resolved instanceof FilterNode filter
                && !Sets.intersection(SymbolsExtractor.extractUnique(filter.getPredicate()), correlation).isEmpty()) {
            return true;
        }
        return resolved.getSources().stream().anyMatch(source -> correlationInFilter(source, correlation));
    }

    /**
     * True when a correlation symbol is carried as an output of a {@code JoinNode} inside the
     * subquery — i.e. the planner reuses the outer symbol as a produced join column rather than only
     * referencing it inside an expression (e.g. {@code … CROSS JOIN (SELECT outer.col) …}, where the
     * derived relation's output column is the outer symbol itself). The correlation rebinder rewrites
     * free references in a join's criteria/filter but maps its structural output-symbol lists too; a
     * correlation symbol there becomes a declared output the rewritten child no longer provides,
     * violating the {@code JoinNode} invariant. Such shapes are left to the legacy decorrelator
     * (which also rejects them).
     */
    private boolean correlationCarriedAsJoinOutput(PlanNode node, Set<Symbol> correlation)
    {
        PlanNode resolved = lookup.resolve(node);
        if (resolved instanceof JoinNode join
                && (join.getLeftOutputSymbols().stream().anyMatch(correlation::contains)
                || join.getRightOutputSymbols().stream().anyMatch(correlation::contains))) {
            return true;
        }
        return resolved.getSources().stream().anyMatch(source -> correlationCarriedAsJoinOutput(source, correlation));
    }

    /**
     * True when a {@code TopNNode} in the subquery orders by a correlation symbol. Such a symbol is
     * constant within each outer row, so the bounded result has no meaningful per-outer-row order and
     * is non-deterministic; Trino treats this as unsupported rather than picking arbitrary rows, so
     * defer to legacy. (Ordering by the subquery's own symbols decorrelates fine and is not matched.)
     */
    private boolean topNOrdersByCorrelation(PlanNode node, Set<Symbol> correlation)
    {
        PlanNode resolved = lookup.resolve(node);
        if (resolved instanceof TopNNode topN
                && topN.getOrderingScheme().orderBy().stream().anyMatch(correlation::contains)) {
            return true;
        }
        return resolved.getSources().stream().anyMatch(source -> topNOrdersByCorrelation(source, correlation));
    }

    /**
     * Decorrelates a LEFT dependent join to a plain LEFT join when the subquery is
     * {@code π*(σ*(B))} with {@code B} correlation-free — i.e. the correlation appears only in
     * liftable filter predicates (which become the join's ON condition) and projections (lifted
     * above the join, where the input columns are in scope). NULL correlation and duplicate outer
     * rows are handled by the join itself (an unsatisfiable predicate null-extends; each outer row
     * is matched independently), so no {@code IS NOT DISTINCT FROM} join-back or distinct set is
     * needed. Returns empty when the correlation reaches below the filters (e.g. into an
     * aggregation), leaving the magic-set to handle it.
     */
    private Optional<PlanNode> tryPlainLeftJoin(PlanNode input, PlanNode subquery, Set<Symbol> correlation)
    {
        List<ProjectNode> projections = new ArrayList<>();
        List<Expression> predicates = new ArrayList<>();
        PlanNode node = lookup.resolve(subquery);
        while (true) {
            // Collect leading projections (above all filters) and the filter predicates beneath them.
            if (node instanceof ProjectNode project && predicates.isEmpty()) {
                projections.add(project);
                node = lookup.resolve(project.getSource());
            }
            else if (node instanceof FilterNode filter) {
                predicates.add(filter.getPredicate());
                node = lookup.resolve(filter.getSource());
            }
            else {
                break;
            }
        }
        PlanNode base = node;
        if (!Sets.intersection(SymbolsExtractor.extractUnique(base, lookup), correlation).isEmpty()) {
            return Optional.empty();
        }

        // A projection lifted above the LEFT join must yield NULL for null-extended (unmatched) outer
        // rows, matching the subquery producing no row. That holds only when every assignment derives
        // from a base (subquery) symbol the join null-extends; a constant or input-only expression
        // would wrongly keep a non-null value for unmatched rows. Defer those to the magic-set, which
        // keeps the projection below the null-extending join-back. (Innermost projection first, so a
        // projection's own outputs become base-derived for the projection above it.)
        Set<Symbol> baseDerived = Sets.newHashSet(base.getOutputSymbols());
        for (int i = projections.size() - 1; i >= 0; i--) {
            for (Expression expression : projections.get(i).getAssignments().expressions()) {
                if (Sets.intersection(SymbolsExtractor.extractUnique(expression), baseDerived).isEmpty()) {
                    return Optional.empty();
                }
            }
            baseDerived.addAll(projections.get(i).getOutputSymbols());
        }

        Expression condition = predicates.isEmpty()
                ? TRUE
                : predicates.size() == 1 ? predicates.get(0) : new Logical(Logical.Operator.AND, ImmutableList.copyOf(predicates));
        PlanNode joined = new JoinNode(
                idAllocator.getNextId(),
                JoinType.LEFT,
                input,
                base,
                ImmutableList.of(),
                input.getOutputSymbols(),
                base.getOutputSymbols(),
                false,
                condition.equals(TRUE) ? Optional.empty() : Optional.of(condition),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty());

        // Re-apply the lifted projections (innermost first), passing the input columns through.
        PlanNode result = joined;
        for (int i = projections.size() - 1; i >= 0; i--) {
            Assignments assignments = projections.get(i).getAssignments();
            Assignments.Builder augmented = Assignments.builder().putAll(assignments);
            for (Symbol symbol : input.getOutputSymbols()) {
                if (!assignments.outputs().contains(symbol)) {
                    augmented.putIdentity(symbol);
                }
            }
            result = new ProjectNode(idAllocator.getNextId(), result, augmented.build());
        }
        return Optional.of(result);
    }

    /**
     * Magic-set decomposition of a LEFT dependent join {@code left ⟕^D_{extra} dependent}:
     * <pre>
     *   left ⟕_{C ≡ C' AND extra} (D ⋈^D dependent[C→C']),   D = δ(π_{C'}(left'))
     * </pre>
     * Each {@code left} row sees its dependent rows (matched on the correlation columns via a
     * NULL-safe {@code IS NOT DISTINCT FROM} plus the {@code extra} condition), null-extending when
     * none match. Used for an outer {@link CorrelatedJoinNode} of type {@code LEFT} (with the
     * correlated-join filter as {@code extra}) and for a left/right outer join inside the subquery
     * whose null-supplying side carries the correlation (with the join's ON predicate as
     * {@code extra}; the correlation-free preserving side is cross-joined into {@code left} first).
     * Returns empty if the input can't be cloned or the dependent side can't be decorrelated.
     */
    private Optional<PlanNode> magicSetLeftJoin(PlanNode left, PlanNode dependent, List<Symbol> correlation, Expression extra, List<Symbol> dependentOutputs)
    {
        // Clone `left` for the distinct-correlation branch; fields = the correlation columns,
        // so getFields() returns their clones (C').
        Optional<NodeAndMappings> cloneOptional = tryCopyInput(left, correlation);
        if (cloneOptional.isEmpty()) {
            return Optional.empty();
        }
        NodeAndMappings clone = cloneOptional.get();
        List<Symbol> clonedCorrelation = clone.getFields();

        // D = δ(π_{C'}(left')) — distinct correlation values, output = C' only.
        PlanNode distinctCorrelation = singleAggregation(
                idAllocator.getNextId(),
                clone.getNode(),
                ImmutableMap.of(),
                singleGroupingSet(clonedCorrelation));

        // Rebind the dependent side's correlation references C → C', then evaluate it per value.
        PlanNode reboundDependent = rebindCorrelation(dependent, correlationMapping(correlation, clonedCorrelation));
        Optional<PlanNode> dependentPerD = pushDown(distinctCorrelation, reboundDependent, ImmutableSet.copyOf(clonedCorrelation));
        if (dependentPerD.isEmpty()) {
            return Optional.empty();
        }

        // LEFT-join `left` back on C ≡ C' (NULL-safe), plus the extra condition.
        Expression correlationMatch = correlationIdentical(correlation, clonedCorrelation);
        Expression condition = extra.equals(TRUE)
                ? correlationMatch
                : new Logical(Logical.Operator.AND, ImmutableList.of(correlationMatch, extra));

        return Optional.of(new JoinNode(
                idAllocator.getNextId(),
                JoinType.LEFT,
                left,
                dependentPerD.get(),
                ImmutableList.of(),
                left.getOutputSymbols(),
                dependentOutputs,
                false,
                Optional.of(condition),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty()));
    }

    /**
     * Scalar global aggregate `(SELECT count(*) … WHERE correlated)`. Decorrelates the
     * aggregation's source per distinct correlation value, LEFT-joins the (uniquely tagged) input
     * back on the correlation columns with a {@code non_null} marker, then re-aggregates grouped
     * by the input identity with each aggregate masked by {@code non_null} — so an outer row whose
     * subquery is empty becomes a single null-extended row that the mask folds into the correct
     * aggregate-over-empty value (count → 0, sum → NULL, …). Mirrors
     * {@code TransformCorrelatedGlobalAggregationWithoutProjection} but uses the framework pushdown
     * for the source, so correlation in the source's projections/filters is handled.
     * <p>
     * Leading projections over the aggregate (e.g. {@code (SELECT count(*) + 1 …)}, or the
     * existence projection an {@code EXISTS} adds) are stripped, the aggregate is decorrelated, and
     * the projections are re-applied on top — they reference the aggregate outputs (preserved) and
     * may reference correlation (the outer columns, which survive as the re-aggregation's grouping
     * keys). Mirrors {@code TransformCorrelatedGlobalAggregationWithProjection}.
     * <p>
     * An aggregate that already carries a mask (e.g. a {@code FILTER} clause) is combined with the
     * {@code non_null} marker. A non-trivial correlated-join filter (only possible for an explicit
     * {@code JOIN LATERAL … ON …}, since this path is INNER-only) is applied as a filter on top of
     * the per-outer-row result.
     */
    private Optional<PlanNode> unnestScalarGlobalAggregate(CorrelatedJoinNode correlatedJoin, PlanNode input, List<Symbol> correlation, Expression joinFilter)
    {
        // Strip leading projections over the aggregate; they are re-applied after decorrelation.
        List<ProjectNode> projections = new ArrayList<>();
        PlanNode resolved = lookup.resolve(correlatedJoin.getSubquery());
        while (resolved instanceof ProjectNode project) {
            projections.add(project);
            resolved = lookup.resolve(project.getSource());
        }
        if (!(resolved instanceof AggregationNode aggregation)
                || !aggregation.hasEmptyGroupingSet()
                || aggregation.getGroupingSetCount() != 1
                || aggregation.getStep() != AggregationNode.Step.SINGLE) {
            return Optional.empty();
        }
        PlanNode source = aggregation.getSource();

        // An aggregate whose base (below liftable filters/projections) is a VALUES relation that embeds
        // the correlation in its rows runs over the correlation value itself — e.g. {@code (VALUES k)} as
        // produced by a correlated quantified comparison like {@code x > ALL (VALUES k)}. Decorrelating
        // it yields a malformed distinct aggregation that a later optimizer rule rejects, so defer to
        // legacy (which also rejects the shape). (A correlated UNNEST base consumes the correlation as
        // its array input and is handled by visitUnnest, so it is not matched here.)
        PlanNode base = lookup.resolve(source);
        while (true) {
            if (base instanceof ProjectNode project) {
                base = lookup.resolve(project.getSource());
            }
            else if (base instanceof FilterNode filter) {
                base = lookup.resolve(filter.getSource());
            }
            else {
                break;
            }
        }
        if (base instanceof ValuesNode
                && !Sets.intersection(SymbolsExtractor.extractUnique(base, lookup), ImmutableSet.copyOf(correlation)).isEmpty()) {
            return Optional.empty();
        }

        // Tag the input so the re-aggregation can group per outer row even with duplicate rows.
        Symbol uid = symbolAllocator.newSymbol("unique", BIGINT);
        PlanNode inputWithUid = new AssignUniqueId(idAllocator.getNextId(), input, uid);
        Symbol nonNull = symbolAllocator.newSymbol("non_null", BOOLEAN);

        // Prefer the legacy-equivalent join-then-aggregate (a single LEFT join, no distinct/clone)
        // when the correlation is filter-only over a correlation-free base; fall back to the
        // magic-set (distinct-D + NULL-safe join-back) for deeper correlation. Both produce a node
        // carrying [inputWithUid columns, the source's output columns, non_null] for re-aggregation.
        Optional<PlanNode> joinedOptional = joinThenAggregateSource(inputWithUid, source, ImmutableSet.copyOf(correlation), nonNull);
        if (joinedOptional.isEmpty()) {
            joinedOptional = magicSetAggregateSource(input, inputWithUid, source, correlation, nonNull);
        }
        if (joinedOptional.isEmpty()) {
            return Optional.empty();
        }
        PlanNode joined = joinedOptional.get();

        // Re-aggregate per outer row, masking each aggregate by non_null to restore empty groups.
        // An aggregate that already carries a mask (e.g. a FILTER clause, which may reference
        // correlation) gets `mask AND non_null` instead, so the null-extended row of an empty group
        // is still excluded.
        Map<Symbol, Symbol> combinedMask = new HashMap<>();
        Assignments.Builder maskAssignments = Assignments.builder().putIdentities(joined.getOutputSymbols());
        aggregation.getAggregations().values().forEach(agg -> agg.getMask().ifPresent(mask ->
                combinedMask.computeIfAbsent(mask, existing -> {
                    Symbol combined = symbolAllocator.newSymbol("mask", BOOLEAN);
                    maskAssignments.put(combined, new Logical(Logical.Operator.AND, ImmutableList.of(existing.toSymbolReference(), nonNull.toSymbolReference())));
                    return combined;
                })));
        PlanNode maskedSource = combinedMask.isEmpty() ? joined : new ProjectNode(idAllocator.getNextId(), joined, maskAssignments.build());

        ImmutableMap.Builder<Symbol, AggregationNode.Aggregation> masked = ImmutableMap.builder();
        aggregation.getAggregations().forEach((symbol, agg) -> masked.put(symbol, new AggregationNode.Aggregation(
                agg.getResolvedFunction(),
                agg.getArguments(),
                agg.isDistinct(),
                agg.getFilter(),
                agg.getOrderingScheme(),
                Optional.of(agg.getMask().map(combinedMask::get).orElse(nonNull)))));
        PlanNode reaggregated = new AggregationNode(
                idAllocator.getNextId(),
                maskedSource,
                masked.buildOrThrow(),
                singleGroupingSet(inputWithUid.getOutputSymbols()),
                ImmutableList.of(),
                AggregationNode.Step.SINGLE,
                Optional.empty(),
                Optional.empty());

        // Re-apply the stripped projections (innermost first). Each references the aggregate
        // outputs (preserved) and may reference correlation, which survives as a grouping key; add
        // identities for the input columns so they pass through to the correlated-join output.
        PlanNode result = reaggregated;
        for (int i = projections.size() - 1; i >= 0; i--) {
            Assignments projectionAssignments = projections.get(i).getAssignments();
            Assignments.Builder augmented = Assignments.builder().putAll(projectionAssignments);
            for (Symbol symbol : input.getOutputSymbols()) {
                if (!projectionAssignments.outputs().contains(symbol)) {
                    augmented.putIdentity(symbol);
                }
            }
            result = new ProjectNode(idAllocator.getNextId(), result, augmented.build());
        }
        // INNER-only path: a non-trivial correlated-join filter selects which outer rows survive.
        if (!joinFilter.equals(TRUE)) {
            result = new FilterNode(idAllocator.getNextId(), result, joinFilter);
        }
        return Optional.of(result);
    }

    /**
     * Join-then-aggregate decorrelation of a scalar global aggregate's source — the cheap form
     * (one LEFT join) that legacy {@code TransformCorrelatedGlobalAggregation*} produces. Applies
     * when the source is {@code π*(σ*(B))} with {@code B} correlation-free: LEFT-join the
     * (uniquely tagged) input to a {@code non_null}-marked {@code B} on the lifted filter predicates,
     * then re-apply the source's projections (which compute the aggregate arguments). An input row
     * with no match null-extends, so {@code non_null} is NULL and the empty group folds to the
     * aggregate-over-empty value. Returns empty when the correlation is deeper than liftable
     * filters/projections, leaving the magic-set to handle it.
     */
    private Optional<PlanNode> joinThenAggregateSource(PlanNode inputWithUid, PlanNode source, Set<Symbol> correlation, Symbol nonNull)
    {
        List<ProjectNode> projections = new ArrayList<>();
        List<Expression> predicates = new ArrayList<>();
        PlanNode node = lookup.resolve(source);
        while (true) {
            if (node instanceof ProjectNode project && predicates.isEmpty()) {
                projections.add(project);
                node = lookup.resolve(project.getSource());
            }
            else if (node instanceof FilterNode filter) {
                predicates.add(filter.getPredicate());
                node = lookup.resolve(filter.getSource());
            }
            else {
                break;
            }
        }
        PlanNode base = node;
        if (!Sets.intersection(SymbolsExtractor.extractUnique(base, lookup), correlation).isEmpty()) {
            return Optional.empty();
        }

        PlanNode markedBase = new ProjectNode(
                idAllocator.getNextId(),
                base,
                Assignments.builder().putIdentities(base.getOutputSymbols()).put(nonNull, TRUE).build());
        Expression condition = predicates.isEmpty()
                ? TRUE
                : predicates.size() == 1 ? predicates.get(0) : new Logical(Logical.Operator.AND, ImmutableList.copyOf(predicates));
        PlanNode result = new JoinNode(
                idAllocator.getNextId(),
                JoinType.LEFT,
                inputWithUid,
                markedBase,
                ImmutableList.of(),
                inputWithUid.getOutputSymbols(),
                markedBase.getOutputSymbols(),
                false,
                condition.equals(TRUE) ? Optional.empty() : Optional.of(condition),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty());

        // Re-apply the source's projections above the join, passing the input columns and the
        // non_null marker through so the re-aggregation can mask on them.
        for (int i = projections.size() - 1; i >= 0; i--) {
            Assignments assignments = projections.get(i).getAssignments();
            Assignments.Builder augmented = Assignments.builder().putAll(assignments);
            for (Symbol symbol : inputWithUid.getOutputSymbols()) {
                if (!assignments.outputs().contains(symbol)) {
                    augmented.putIdentity(symbol);
                }
            }
            if (!assignments.outputs().contains(nonNull)) {
                augmented.putIdentity(nonNull);
            }
            result = new ProjectNode(idAllocator.getNextId(), result, augmented.build());
        }
        return Optional.of(result);
    }

    /**
     * Magic-set decorrelation of a scalar global aggregate's source (fallback when the correlation
     * is deeper than liftable filters): evaluate the source once per distinct correlation value
     * (clone the input, build {@code D = δ(π_{C'})}, push the rebound source through), mark the rows,
     * and LEFT-join the (uniquely tagged) input back on the correlation columns (NULL-safe).
     */
    private Optional<PlanNode> magicSetAggregateSource(PlanNode input, PlanNode inputWithUid, PlanNode source, List<Symbol> correlation, Symbol nonNull)
    {
        Optional<NodeAndMappings> cloneOptional = tryCopyInput(input, correlation);
        if (cloneOptional.isEmpty()) {
            return Optional.empty();
        }
        NodeAndMappings clone = cloneOptional.get();
        List<Symbol> clonedCorrelation = clone.getFields();
        PlanNode distinctCorrelation = singleAggregation(
                idAllocator.getNextId(),
                clone.getNode(),
                ImmutableMap.of(),
                singleGroupingSet(clonedCorrelation));
        PlanNode reboundSource = rebindCorrelation(source, correlationMapping(correlation, clonedCorrelation));
        Optional<PlanNode> perD = pushDown(distinctCorrelation, reboundSource, ImmutableSet.copyOf(clonedCorrelation));
        if (perD.isEmpty()) {
            return Optional.empty();
        }
        PlanNode marked = new ProjectNode(
                idAllocator.getNextId(),
                perD.get(),
                Assignments.builder().putIdentities(perD.get().getOutputSymbols()).put(nonNull, TRUE).build());
        return Optional.of(new JoinNode(
                idAllocator.getNextId(),
                JoinType.LEFT,
                inputWithUid,
                marked,
                ImmutableList.of(),
                inputWithUid.getOutputSymbols(),
                ImmutableList.<Symbol>builder().addAll(source.getOutputSymbols()).add(nonNull).build(),
                false,
                Optional.of(correlationIdentical(correlation, clonedCorrelation)),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty()));
    }

    /**
     * Non-aggregate scalar subquery `(SELECT u.b … WHERE correlated)` — `EnforceSingleRowNode`
     * over the body. Decorrelates the body per distinct correlation value, enforces ≤1 row per
     * group (failing otherwise, like the original), then LEFT-joins the input back on the
     * correlation columns so an empty group NULL-fills the scalar — matching
     * {@code EnforceSingleRowNode}'s exactly-one-row semantics.
     * <p>
     * First cut: the subquery is exactly an {@code EnforceSingleRowNode} (no top projection) and
     * the correlated-join filter is {@code TRUE}; otherwise returns empty (→ legacy).
     */
    private Optional<PlanNode> unnestScalarSingleRow(CorrelatedJoinNode correlatedJoin, PlanNode input, List<Symbol> correlation, Expression joinFilter)
    {
        if (!joinFilter.equals(TRUE) || !(lookup.resolve(correlatedJoin.getSubquery()) instanceof EnforceSingleRowNode enforce)) {
            return Optional.empty();
        }
        PlanNode source = enforce.getSource();

        Optional<NodeAndMappings> cloneOptional = tryCopyInput(input, correlation);
        if (cloneOptional.isEmpty()) {
            return Optional.empty();
        }
        NodeAndMappings clone = cloneOptional.get();
        List<Symbol> clonedCorrelation = clone.getFields();
        PlanNode distinctCorrelation = singleAggregation(
                idAllocator.getNextId(),
                clone.getNode(),
                ImmutableMap.of(),
                singleGroupingSet(clonedCorrelation));
        PlanNode reboundSource = rebindCorrelation(source, correlationMapping(correlation, clonedCorrelation));
        Optional<PlanNode> perD = pushDown(distinctCorrelation, reboundSource, ImmutableSet.copyOf(clonedCorrelation));
        if (perD.isEmpty()) {
            return Optional.empty();
        }

        // Enforce ≤1 source row per correlation group; fail (at runtime) on the 2nd row.
        Symbol rowNumber = symbolAllocator.newSymbol("row_number", BIGINT);
        PlanNode numbered = new RowNumberNode(idAllocator.getNextId(), perD.get(), clonedCorrelation, false, rowNumber, Optional.empty());
        PlanNode checked = new FilterNode(
                idAllocator.getNextId(),
                numbered,
                new Switch(
                        new Comparison(LESS_THAN_OR_EQUAL, rowNumber.toSymbolReference(), new Constant(BIGINT, 1L)),
                        ImmutableList.of(new WhenClause(TRUE, TRUE)),
                        new Cast(failFunction(metadata, SUBQUERY_MULTIPLE_ROWS, "Scalar sub-query has returned multiple rows"), BOOLEAN)));

        List<Symbol> subqueryOutputs = correlatedJoin.getSubquery().getOutputSymbols();
        PlanNode joined = new JoinNode(
                idAllocator.getNextId(),
                JoinType.LEFT,
                input,
                checked,
                ImmutableList.of(),
                input.getOutputSymbols(),
                subqueryOutputs,
                false,
                Optional.of(correlationIdentical(correlation, clonedCorrelation)),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty());

        return Optional.of(joined);
    }

    private static Expression correlationIdentical(List<Symbol> correlation, List<Symbol> clonedCorrelation)
    {
        ImmutableList.Builder<Expression> conjuncts = ImmutableList.builder();
        for (int i = 0; i < correlation.size(); i++) {
            conjuncts.add(new Comparison(IDENTICAL, correlation.get(i).toSymbolReference(), clonedCorrelation.get(i).toSymbolReference()));
        }
        List<Expression> all = conjuncts.build();
        return all.size() == 1 ? all.get(0) : new Logical(Logical.Operator.AND, all);
    }

    private static Map<Symbol, Symbol> correlationMapping(List<Symbol> from, List<Symbol> to)
    {
        ImmutableMap.Builder<Symbol, Symbol> mapping = ImmutableMap.builder();
        for (int i = 0; i < from.size(); i++) {
            mapping.put(from.get(i), to.get(i));
        }
        return mapping.buildOrThrow();
    }

    /**
     * Clones the input subtree (the magic-set needs the input twice: as the distinct-correlation
     * source and the join's left side). {@link PlanCopier} throws for node types it doesn't
     * implement (e.g. a {@code SemiJoinNode} or {@code MarkDistinctNode} in the outer plan); in
     * that case return empty so unnesting falls back to legacy rather than failing the query.
     */
    private Optional<NodeAndMappings> tryCopyInput(PlanNode input, List<Symbol> correlation)
    {
        try {
            return Optional.of(PlanCopier.copyPlan(input, correlation, symbolAllocator, idAllocator, lookup));
        }
        catch (UnsupportedOperationException _) {
            return Optional.empty();
        }
    }

    /**
     * Rewrites references to the correlation symbols (which are free in the subquery) to the
     * clone's symbols, leaving the subquery's own (defined) symbols untouched. Covers exactly the
     * node types {@link #pushDown} handles and can carry correlation in expressions — Filter,
     * Project, Aggregation, Join; everything else recurses unchanged via the default rewrite (and
     * if it does carry correlation, {@code pushDown} will bail on it anyway, so unnesting falls
     * back to legacy).
     */
    private PlanNode rebindCorrelation(PlanNode subquery, Map<Symbol, Symbol> mapping)
    {
        return SimplePlanRewriter.rewriteWith(new CorrelationRebinder(symbolMapper(mapping)), subquery, null);
    }

    private boolean isScalarGlobalAggregation(PlanNode subquery)
    {
        PlanNode node = lookup.resolve(subquery);
        while (node instanceof ProjectNode project) {
            node = lookup.resolve(project.getSource());
        }
        // A *scalar* global aggregate is a single global grouping set (the empty set). An
        // aggregation with several grouping sets one of which happens to be empty (GROUPING SETS)
        // is not scalar — it must not take the non_null-mask path.
        return node instanceof AggregationNode aggregation
                && aggregation.getGroupingSetCount() == 1
                && aggregation.hasEmptyGroupingSet();
    }

    // Some pushdowns (LIMIT/TopN) introduce helper columns (a unique id, a row number) that the
    // rule's output-equivalence check rejects. Restrict to the correlated join's declared
    // outputs, which downstream consumers expect.
    private PlanNode restrictOutputs(PlanNode plan, List<Symbol> outputs)
    {
        if (plan.getOutputSymbols().equals(outputs)) {
            return plan;
        }
        return new ProjectNode(idAllocator.getNextId(), plan, Assignments.identity(outputs));
    }

    /**
     * Recursive pushdown driver. Returns a non-correlated plan equivalent to `input ⋈^D subquery`
     * (cross product when no correlation is consumed), or empty when an unhandled shape is hit.
     */
    private Optional<PlanNode> pushDown(PlanNode input, PlanNode subquery, Set<Symbol> correlation)
    {
        PlanNode resolved = lookup.resolve(subquery);
        Set<Symbol> usedInSubquery = SymbolsExtractor.extractUnique(resolved, lookup);
        if (Sets.intersection(usedInSubquery, correlation).isEmpty()) {
            // Base equivalence: no actual dependence — degenerate to cross product. Any
            // correlation-using predicates will rise to become filters above this join.
            return Optional.of(crossJoin(input, subquery));
        }
        return resolved.accept(new PushDownVisitor(input, correlation), null);
    }

    private JoinNode crossJoin(PlanNode left, PlanNode right)
    {
        return new JoinNode(
                idAllocator.getNextId(),
                JoinType.INNER,
                left,
                right,
                ImmutableList.of(),
                left.getOutputSymbols(),
                right.getOutputSymbols(),
                false,
                Optional.empty(),
                Optional.empty(),
                Optional.empty(),
                ImmutableMap.of(),
                Optional.empty());
    }

    private final class PushDownVisitor
            extends PlanVisitor<Optional<PlanNode>, Void>
    {
        private final PlanNode input;
        private final Set<Symbol> correlation;

        private PushDownVisitor(PlanNode input, Set<Symbol> correlation)
        {
            this.input = input;
            this.correlation = correlation;
        }

        @Override
        protected Optional<PlanNode> visitPlan(PlanNode node, Void context)
        {
            // Unhandled shape — caller falls back to the legacy decorrelator.
            return Optional.empty();
        }

        @Override
        public Optional<PlanNode> visitFilter(FilterNode node, Void context)
        {
            // σ pushdown: `T₁ ⋈^D σ_p(T) ≡ σ_p(T₁ ⋈^D T)`. The predicate `p` may reference both
            // input and subquery symbols after the join — it becomes a filter above the recursive
            // result. Any sub-expression of `p` that references correlation is now a theta-join
            // predicate (the source of inequality-correlation support).
            return pushDown(input, node.getSource(), correlation)
                    .map(inner -> new FilterNode(idAllocator.getNextId(), inner, node.getPredicate()));
        }

        @Override
        public Optional<PlanNode> visitProject(ProjectNode node, Void context)
        {
            // π pushdown: `T₁ ⋈^D π_e(T) ≡ π_{A(T₁) ∪ e}(T₁ ⋈^D T)`. Add identity assignments for
            // the input symbols so they remain accessible above the projection.
            return pushDown(input, node.getSource(), correlation)
                    .map(inner -> {
                        Assignments augmented = Assignments.builder()
                                .putIdentities(input.getOutputSymbols())
                                .putAll(node.getAssignments())
                                .build();
                        return new ProjectNode(idAllocator.getNextId(), inner, augmented);
                    });
        }

        @Override
        public Optional<PlanNode> visitAggregation(AggregationNode node, Void context)
        {
            // Γ pushdown: add input symbols to the grouping keys so the aggregation runs once per
            // outer row. Multiple grouping sets (GROUPING SETS / ROLLUP / CUBE, an aggregation over
            // a GroupIdNode) are supported too: adding T₁'s columns to every set (here and in
            // visitGroupId) makes none of them global, so the augmented descriptor carries no
            // global grouping set — no per-empty-input default row is produced.
            // Pre-grouped symbols and a non-SINGLE step (PARTIAL/FINAL splits) are post-optimizer
            // constructs we don't expect here, but bail conservatively if seen.
            if (!node.getPreGroupedSymbols().isEmpty() || node.getStep() != AggregationNode.Step.SINGLE) {
                return Optional.empty();
            }
            return pushDown(input, node.getSource(), correlation)
                    .map(inner -> {
                        List<Symbol> augmentedKeys = ImmutableList.<Symbol>builder()
                                .addAll(input.getOutputSymbols())
                                .addAll(node.getGroupingKeys())
                                .build();
                        return new AggregationNode(
                                idAllocator.getNextId(),
                                inner,
                                node.getAggregations(),
                                AggregationNode.groupingSets(augmentedKeys, node.getGroupingSetCount(), ImmutableSet.of()),
                                ImmutableList.of(),
                                node.getStep(),
                                node.getGroupIdSymbol());
                    });
        }

        @Override
        public Optional<PlanNode> visitGroupId(GroupIdNode node, Void context)
        {
            // GroupId pushdown (the basis of GROUPING SETS / ROLLUP / CUBE, which plan as an
            // AggregationNode over a GroupIdNode): add T₁'s columns to every grouping set as
            // identity grouping columns, so each set is computed once per outer row and T₁'s columns
            // survive to the aggregation above (GroupId only outputs grouping-set/aggregation/groupId
            // columns, so columns not added here would be dropped). The empty grouping set `()` does
            // not manufacture phantom rows for outer rows whose source is empty, because GroupId only
            // replicates existing source rows — so EXISTS-over-grouping-sets stays sound.
            return pushDown(input, node.getSource(), correlation)
                    .map(inner -> {
                        List<Symbol> inputSymbols = input.getOutputSymbols();
                        List<List<Symbol>> augmentedSets = node.getGroupingSets().stream()
                                .map(set -> ImmutableList.<Symbol>builder().addAll(inputSymbols).addAll(set).build())
                                .collect(toImmutableList());
                        ImmutableMap.Builder<Symbol, Symbol> augmentedColumns = ImmutableMap.builder();
                        augmentedColumns.putAll(node.getGroupingColumns());
                        for (Symbol symbol : inputSymbols) {
                            augmentedColumns.put(symbol, symbol);
                        }
                        return new GroupIdNode(
                                idAllocator.getNextId(),
                                inner,
                                augmentedSets,
                                augmentedColumns.buildOrThrow(),
                                node.getAggregationArguments(),
                                node.getGroupIdSymbol());
                    });
        }

        @Override
        public Optional<PlanNode> visitLimit(LimitNode node, Void context)
        {
            // lim pushdown: `T₁ ⋈^D Lim_n(T) ≡ σ_{rn ≤ n}(rowNumber OVER (PARTITION BY uid(T₁))(T₁ ⋈^D T))`.
            // Tag T₁'s rows with a unique id so "first n per outer row" partitions correctly even
            // when T₁ contains duplicate rows. WITH TIES uses rank() (which keeps the nth row plus
            // all rows tying with it) ordered by the ties-resolving scheme, instead of row_number().
            Symbol uniqueSymbol = symbolAllocator.newSymbol("unique", BIGINT);
            PlanNode taggedInput = new AssignUniqueId(idAllocator.getNextId(), input, uniqueSymbol);
            return pushDown(taggedInput, node.getSource(), correlation)
                    .map(inner -> {
                        Symbol counter = symbolAllocator.newSymbol(node.isWithTies() ? "rank_num" : "row_number", BIGINT);
                        PlanNode numbered = node.isWithTies()
                                ? rankWindow(inner, uniqueSymbol, counter, node.getTiesResolvingScheme())
                                : new RowNumberNode(idAllocator.getNextId(), inner, ImmutableList.of(uniqueSymbol), false, counter, Optional.empty());
                        return new FilterNode(
                                idAllocator.getNextId(),
                                numbered,
                                new Comparison(LESS_THAN_OR_EQUAL, counter.toSymbolReference(), new Constant(BIGINT, node.getCount())));
                    });
        }

        private WindowNode rankWindow(PlanNode source, Symbol partition, Symbol rank, Optional<OrderingScheme> ordering)
        {
            WindowNode.Function rankFunction = new WindowNode.Function(
                    metadata.resolveBuiltinFunction("rank", ImmutableList.of()),
                    ImmutableList.of(),
                    Optional.empty(),
                    DEFAULT_FRAME,
                    false,
                    false);
            return new WindowNode(
                    idAllocator.getNextId(),
                    source,
                    new DataOrganizationSpecification(ImmutableList.of(partition), ordering),
                    ImmutableMap.of(rank, rankFunction),
                    ImmutableSet.of(),
                    0);
        }

        @Override
        public Optional<PlanNode> visitTopN(TopNNode node, Void context)
        {
            // TopN pushdown: like LIMIT but row numbering follows the TopN ordering, evaluated
            // per outer row via a window partitioned by the unique input id. (TopN ordered by a
            // correlation symbol is deferred to legacy earlier — see topNOrdersByCorrelation.)
            Symbol uniqueSymbol = symbolAllocator.newSymbol("unique", BIGINT);
            PlanNode taggedInput = new AssignUniqueId(idAllocator.getNextId(), input, uniqueSymbol);
            return pushDown(taggedInput, node.getSource(), correlation)
                    .map(inner -> {
                        Symbol rowNumber = symbolAllocator.newSymbol("row_number", BIGINT);
                        WindowNode.Function rowNumberFunction = new WindowNode.Function(
                                metadata.resolveBuiltinFunction("row_number", ImmutableList.of()),
                                ImmutableList.of(),
                                Optional.empty(),
                                DEFAULT_FRAME,
                                false,
                                false);
                        WindowNode window = new WindowNode(
                                idAllocator.getNextId(),
                                inner,
                                new DataOrganizationSpecification(ImmutableList.of(uniqueSymbol), Optional.of(node.getOrderingScheme())),
                                ImmutableMap.of(rowNumber, rowNumberFunction),
                                ImmutableSet.of(),
                                0);
                        return new FilterNode(
                                idAllocator.getNextId(),
                                window,
                                new Comparison(LESS_THAN_OR_EQUAL, rowNumber.toSymbolReference(), new Constant(BIGINT, node.getCount())));
                    });
        }

        @Override
        public Optional<PlanNode> visitWindow(WindowNode node, Void context)
        {
            // Window pushdown: `T₁ ⋈^D W_{P;O}(T) ≡ W_{uid(T₁) ∪ P; O}(T₁ ⋈^D T)`. Adding a unique
            // id of the input to the PARTITION BY makes each window function evaluate once per outer
            // row (the unique id, not the input columns, so duplicate outer rows don't merge), with
            // the original partitioning/ordering preserved within each outer row.
            Symbol uniqueSymbol = symbolAllocator.newSymbol("unique", BIGINT);
            PlanNode taggedInput = new AssignUniqueId(idAllocator.getNextId(), input, uniqueSymbol);
            return pushDown(taggedInput, node.getSource(), correlation)
                    .map(inner -> new WindowNode(
                            idAllocator.getNextId(),
                            inner,
                            new DataOrganizationSpecification(
                                    ImmutableList.<Symbol>builder().add(uniqueSymbol).addAll(node.getPartitionBy()).build(),
                                    node.getOrderingScheme()),
                            node.getWindowFunctions(),
                            ImmutableSet.of(),
                            0));
        }

        @Override
        public Optional<PlanNode> visitJoin(JoinNode node, Void context)
        {
            boolean leftDepends = referencesCorrelation(node.getLeft());
            boolean rightDepends = referencesCorrelation(node.getRight());

            return switch (node.getType()) {
                case INNER -> pushInnerJoin(node, leftDepends, rightDepends);
                // Outer joins. When the dependency is confined to the PRESERVING side (or rides only
                // on the predicate), the outer join distributes — push T₁ into the preserving side:
                //   T₁ ⋈^D (L ⟕_p R) ≡ (T₁ ⋈^D L) ⟕_p R   when R is correlation-free
                //   T₁ ⋈^D (L ⟖_p R) ≡ L ⟖_p (T₁ ⋈^D R)   when L is correlation-free
                // When the NULL-SUPPLYING side carries the correlation (and the preserving side is
                // correlation-free), cross-join the preserving side into T₁ and decorrelate via the
                // LEFT magic-set, since (e.g.) T₁ ⋈^D (L ⟕_p R) ≡ (T₁ × L) ⟕^D_p R. Both sides
                // depending, or FULL outer, still bail.
                case LEFT -> {
                    if (!rightDepends) {
                        yield pushDown(input, node.getLeft(), correlation)
                                .map(decorrelatedLeft -> rebuildJoin(node, decorrelatedLeft, node.getRight()));
                    }
                    yield leftDepends
                            ? Optional.empty()
                            : magicSetLeftJoin(crossJoin(input, node.getLeft()), node.getRight(), ImmutableList.copyOf(correlation), joinConditionOf(node), node.getRight().getOutputSymbols());
                }
                case RIGHT -> {
                    if (!leftDepends) {
                        yield pushDown(input, node.getRight(), correlation)
                                .map(decorrelatedRight -> rebuildJoin(node, node.getLeft(), decorrelatedRight));
                    }
                    yield rightDepends
                            ? Optional.empty()
                            : magicSetLeftJoin(crossJoin(input, node.getRight()), node.getLeft(), ImmutableList.copyOf(correlation), joinConditionOf(node), node.getLeft().getOutputSymbols());
                }
                // FULL: both sides are null-supplying — neither push is sound.
                case FULL -> Optional.empty();
            };
        }

        private Optional<PlanNode> pushInnerJoin(JoinNode node, boolean leftDepends, boolean rightDepends)
        {
            if (leftDepends && rightDepends) {
                // Both sides depend on correlation:
                //   T₁ ⋈^D (L ⋈_q R) ≡ σ_q((T₁ ⋈^D L) ⋈^D R)
                // Push T₁ into L, then treat the whole (T₁ ⋈^D L) — which now carries T₁'s
                // correlation columns — as the input for a dependent join with R. The original
                // join condition q (criteria + filter) becomes a filter on the combined result.
                // No AssignUniqueId is needed: T₁'s rows ride along in both pushdowns and the
                // final filter q selects the matching (L, R) pairs per T₁ row.
                Optional<PlanNode> leftResult = pushDown(input, node.getLeft(), correlation);
                if (leftResult.isEmpty()) {
                    return Optional.empty();
                }
                Optional<PlanNode> combined = pushDown(leftResult.get(), node.getRight(), correlation);
                return combined.map(plan -> {
                    Expression joinCondition = joinConditionOf(node);
                    return joinCondition.equals(TRUE) ? plan : new FilterNode(idAllocator.getNextId(), plan, joinCondition);
                });
            }
            if (leftDepends) {
                return pushDown(input, node.getLeft(), correlation)
                        .map(decorrelatedLeft -> rebuildJoin(node, decorrelatedLeft, node.getRight()));
            }
            // rightDepends — or neither, but then we shouldn't have entered the visitor.
            return pushDown(input, node.getRight(), correlation)
                    .map(decorrelatedRight -> rebuildJoin(node, node.getLeft(), decorrelatedRight));
        }

        private Expression joinConditionOf(JoinNode node)
        {
            ImmutableList.Builder<Expression> conjuncts = ImmutableList.builder();
            for (JoinNode.EquiJoinClause clause : node.getCriteria()) {
                conjuncts.add(new Comparison(Comparison.Operator.EQUAL, clause.getLeft().toSymbolReference(), clause.getRight().toSymbolReference()));
            }
            node.getFilter().ifPresent(conjuncts::add);
            List<Expression> all = conjuncts.build();
            if (all.isEmpty()) {
                return TRUE;
            }
            return all.size() == 1 ? all.get(0) : new Logical(Logical.Operator.AND, all);
        }

        @Override
        public Optional<PlanNode> visitUnnest(UnnestNode node, Void context)
        {
            // UNNEST pushdown: `T₁ ⋈^D Unnest_{R; arrs}(S) ≡ Unnest_{R ∪ A(T₁); arrs}(T₁ ⋈^D S)`.
            // In a correlated subquery the unnested arrays are free correlation references and the
            // unnest's own source is a trivial single-row, so pushing T₁ into the source brings the
            // array columns into scope; T₁'s columns are added to the replicate list to pass through.
            // The unnest's own join type (INNER/LEFT, controlling empty-array null-extension) and
            // ordinality are preserved.
            return pushDown(input, node.getSource(), correlation)
                    .map(inner -> new UnnestNode(
                            idAllocator.getNextId(),
                            inner,
                            ImmutableList.<Symbol>builder()
                                    .addAll(input.getOutputSymbols())
                                    .addAll(node.getReplicateSymbols())
                                    .build(),
                            node.getMappings(),
                            node.getOrdinalitySymbol(),
                            node.getJoinType()));
        }

        @Override
        public Optional<PlanNode> visitUnion(UnionNode node, Void context)
        {
            return distributeSetOp(node);
        }

        @Override
        public Optional<PlanNode> visitIntersect(IntersectNode node, Void context)
        {
            return distributeSetOp(node);
        }

        @Override
        public Optional<PlanNode> visitExcept(ExceptNode node, Void context)
        {
            return distributeSetOp(node);
        }

        /**
         * ⊕ pushdown: {@code T₁ ⋈^D (B_1 ⊕ … ⊕ B_n) ≡ (T₁ ⋈^D B_1) ⊕ … ⊕ (T₁ ⋈^D B_n)}, valid for
         * {@code UNION}/{@code INTERSECT}/{@code EXCEPT} alike. Each distributed branch carries
         * {@code T₁}'s columns, so they join the set-op key and partition the set semantics by outer
         * row — for a fixed {@code t}, the distributed set-op reduces to {@code B_1(t) ⊕ … ⊕ B_n(t)}.
         *
         * <p>A plan is a tree, not a DAG, so {@code T₁} can't be physically shared across branches:
         * every branch after the first gets a fresh clone of {@code T₁} (via {@link #tryCopyInput})
         * with its correlation references rebound onto the clone. If {@code PlanCopier} can't copy
         * the input, unnesting bails to legacy.
         */
        private Optional<PlanNode> distributeSetOp(SetOperationNode node)
        {
            List<Symbol> correlationList = ImmutableList.copyOf(correlation);
            List<Symbol> inputSymbols = input.getOutputSymbols();
            List<PlanNode> branches = node.getSources();

            ImmutableList.Builder<PlanNode> newSources = ImmutableList.builder();
            // perBranchInputSymbols.get(i) is parallel to inputSymbols: branch i's copy of T₁'s columns.
            List<List<Symbol>> perBranchInputSymbols = new ArrayList<>();

            for (int i = 0; i < branches.size(); i++) {
                PlanNode branch = branches.get(i);
                PlanNode branchInput;
                List<Symbol> branchInputSymbols;
                PlanNode branchSubquery;
                Set<Symbol> branchCorrelation;
                if (i == 0) {
                    // The first branch reuses the original input directly — no clone needed.
                    branchInput = input;
                    branchInputSymbols = inputSymbols;
                    branchSubquery = branch;
                    branchCorrelation = correlation;
                }
                else {
                    Optional<NodeAndMappings> cloneOptional = tryCopyInput(input, inputSymbols);
                    if (cloneOptional.isEmpty()) {
                        return Optional.empty();
                    }
                    NodeAndMappings clone = cloneOptional.get();
                    branchInput = clone.getNode();
                    branchInputSymbols = clone.getFields();
                    Map<Symbol, Symbol> rebind = correlationMapping(inputSymbols, branchInputSymbols);
                    branchSubquery = rebindCorrelation(branch, rebind);
                    branchCorrelation = correlationList.stream()
                            .map(rebind::get)
                            .collect(toImmutableSet());
                }
                Optional<PlanNode> pushed = pushDown(branchInput, branchSubquery, branchCorrelation);
                if (pushed.isEmpty()) {
                    return Optional.empty();
                }
                newSources.add(pushed.get());
                perBranchInputSymbols.add(branchInputSymbols);
            }

            // Canonical outputs for T₁'s columns are the original input symbols (branch 0's copy);
            // the original set-op outputs keep their per-source mapping (the subquery side is never
            // cloned, so its symbols survive the pushdown unchanged).
            ImmutableListMultimap.Builder<Symbol, Symbol> outputToInputs = ImmutableListMultimap.builder();
            for (int col = 0; col < inputSymbols.size(); col++) {
                for (List<Symbol> branchSymbols : perBranchInputSymbols) {
                    outputToInputs.put(inputSymbols.get(col), branchSymbols.get(col));
                }
            }
            for (Symbol output : node.getOutputSymbols()) {
                node.getSymbolMapping().get(output).forEach(source -> outputToInputs.put(output, source));
            }
            List<Symbol> outputs = ImmutableList.<Symbol>builder()
                    .addAll(inputSymbols)
                    .addAll(node.getOutputSymbols())
                    .build();

            return Optional.of(rebuildSetOp(node, newSources.build(), outputToInputs.build(), outputs));
        }

        private PlanNode rebuildSetOp(SetOperationNode original, List<PlanNode> sources, ListMultimap<Symbol, Symbol> outputToInputs, List<Symbol> outputs)
        {
            return switch (original) {
                case UnionNode _ -> new UnionNode(idAllocator.getNextId(), sources, outputToInputs, outputs);
                case IntersectNode intersect -> new IntersectNode(idAllocator.getNextId(), sources, outputToInputs, outputs, intersect.isDistinct());
                case ExceptNode except -> new ExceptNode(idAllocator.getNextId(), sources, outputToInputs, outputs, except.isDistinct());
                default -> throw new IllegalStateException("Unexpected set operation: " + original.getClass().getSimpleName());
            };
        }

        private boolean referencesCorrelation(PlanNode node)
        {
            return !Sets.intersection(SymbolsExtractor.extractUnique(node, lookup), correlation).isEmpty();
        }

        private JoinNode rebuildJoin(JoinNode original, PlanNode newLeft, PlanNode newRight)
        {
            return new JoinNode(
                    idAllocator.getNextId(),
                    original.getType(),
                    newLeft,
                    newRight,
                    original.getCriteria(),
                    chooseOutputs(newLeft, original.getLeftOutputSymbols()),
                    chooseOutputs(newRight, original.getRightOutputSymbols()),
                    original.isMaySkipOutputDuplicates(),
                    original.getFilter(),
                    Optional.empty(),
                    Optional.empty(),
                    ImmutableMap.of(),
                    Optional.empty());
        }

        private List<Symbol> chooseOutputs(PlanNode side, List<Symbol> originalOutputs)
        {
            // After decorrelating one side, that side carries T₁'s input columns (pushed in from the
            // cross-join base case). The rebuilt join must surface them alongside the still-available
            // original outputs, so a consumer above the join — ultimately restrictOutputs to the
            // correlated join's declared outputs — can see the correlation columns. The undecorrelated
            // side carries none of T₁'s columns, so the availability filter leaves it unchanged.
            Set<Symbol> available = ImmutableSet.copyOf(side.getOutputSymbols());
            ImmutableList.Builder<Symbol> chosen = ImmutableList.builder();
            for (Symbol symbol : input.getOutputSymbols()) {
                if (available.contains(symbol)) {
                    chosen.add(symbol);
                }
            }
            for (Symbol symbol : originalOutputs) {
                if (available.contains(symbol)) {
                    chosen.add(symbol);
                }
            }
            return chosen.build();
        }
    }

    /**
     * Rewrites free correlation-symbol references to the clone's symbols. Only the node types that
     * can carry correlation in their expressions are overridden; the rest recurse unchanged.
     */
    private final class CorrelationRebinder
            extends SimplePlanRewriter<Void>
    {
        private final SymbolMapper mapper;

        private CorrelationRebinder(SymbolMapper mapper)
        {
            this.mapper = requireNonNull(mapper, "mapper is null");
        }

        @Override
        public PlanNode visitGroupReference(GroupReference node, RewriteContext<Void> context)
        {
            return context.rewrite(lookup.resolve(node));
        }

        @Override
        public PlanNode visitFilter(FilterNode node, RewriteContext<Void> context)
        {
            PlanNode source = context.rewrite(node.getSource());
            return new FilterNode(node.getId(), source, mapper.map(node.getPredicate()));
        }

        @Override
        public PlanNode visitProject(ProjectNode node, RewriteContext<Void> context)
        {
            PlanNode source = context.rewrite(node.getSource());
            Assignments.Builder assignments = Assignments.builder();
            node.getAssignments().forEach((symbol, expression) -> assignments.put(symbol, mapper.map(expression)));
            return new ProjectNode(node.getId(), source, assignments.build());
        }

        @Override
        public PlanNode visitAggregation(AggregationNode node, RewriteContext<Void> context)
        {
            PlanNode source = context.rewrite(node.getSource());
            return mapper.map(node, source);
        }

        @Override
        public PlanNode visitUnnest(UnnestNode node, RewriteContext<Void> context)
        {
            PlanNode source = context.rewrite(node.getSource());
            return new UnnestNode(
                    node.getId(),
                    source,
                    mapper.map(node.getReplicateSymbols()),
                    node.getMappings().stream()
                            // Only the unnested array (mapping input) can be a free correlation
                            // reference; the produced element/ordinality symbols are defined here.
                            .map(mapping -> new UnnestNode.Mapping(mapper.map(mapping.getInput()), mapping.getOutputs()))
                            .collect(toImmutableList()),
                    node.getOrdinalitySymbol(),
                    node.getJoinType());
        }

        @Override
        public PlanNode visitJoin(JoinNode node, RewriteContext<Void> context)
        {
            PlanNode left = context.rewrite(node.getLeft());
            PlanNode right = context.rewrite(node.getRight());
            return new JoinNode(
                    node.getId(),
                    node.getType(),
                    left,
                    right,
                    node.getCriteria().stream()
                            .map(clause -> new JoinNode.EquiJoinClause(mapper.map(clause.getLeft()), mapper.map(clause.getRight())))
                            .collect(toImmutableList()),
                    mapper.map(node.getLeftOutputSymbols()),
                    mapper.map(node.getRightOutputSymbols()),
                    node.isMaySkipOutputDuplicates(),
                    node.getFilter().map(mapper::map),
                    node.getDistributionType(),
                    node.isSpillable(),
                    ImmutableMap.of(),
                    Optional.empty());
        }
    }
}
