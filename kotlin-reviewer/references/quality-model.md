# Quality Model

<!-- kotlin-suite:REVIEW-SCORING -->

Use this model only when the user or repository explicitly requests numeric scoring. For ordinary
reviews, apply the same dimensions and gate questions qualitatively.

## Dimensions and weights

| ID | Weight | Evidence sought |
| --- | ---: | --- |
| `BOUNDARIES` | 10 | compiled module/source-set isolation and dependency/visibility guardrails |
| `OWNERSHIP` | 8 | single responsibility, source of truth, and explicit lifetime owners |
| `API_SURFACE` | 7 | minimal visibility, direct dependencies, and clear call sites |
| `FUNCTIONAL_CORE` | 9 | pure decisions, immutable values, and narrow effect ports |
| `WORKFLOW_MODEL` | 9 | explicit legal transitions, proportionate outputs, and orchestration |
| `KOTLIN_CORRECTNESS` | 12 | type, null/error, coroutine, cancellation, and lifecycle correctness |
| `PRESENTATION_QUALITY` | 7 | thin Compose UI, accessibility, localization, and adaptive behavior |
| `TEST_QUALITY` | 9 | deterministic behavior/invariant coverage at the owner |
| `PERFORMANCE_RESOURCES` | 5 | measured performance and correct memory/I/O/battery lifetime |
| `READABILITY` | 8 | cohesive, intention-revealing, locally understandable code |
| `PROPORTIONALITY` | 10 | no unearned mechanisms, over-splitting, hidden topology, or topology relocation |
| `INTEGRATION_RECOVERY` | 3 | live DI/wiring, entry paths, persistence, restoration, and recovery |
| `ENFORCEMENT_EVIDENCE` | 3 | executable negative guardrails and recorded validation |

Weights total 100. If a dimension is genuinely outside scope, mark it non-applicable with a reason
and renormalize applicable weights. Do not hide a weak dimension as non-applicable.

## Score anchors

- `0-2`: absent, contradicted, or critically broken.
- `3-4`: major gaps; design or behavior is unreliable.
- `5-6`: partial implementation with important unverified or disproportionate areas.
- `7-8`: solid but has material gaps, weak enforcement, avoidable complexity, or hidden topology.
- `8.5`: strong source-level implementation; only bounded improvement remains.
- `9-9.5`: excellent and executable, with comprehensive relevant evidence and explicit lean mechanisms.
- `10`: exceptional for the scoped risk; never a default pass.

Score observed behavior and evidence, not effort or quantity. More modules, interfaces, machines,
states, tests, guardrails, or reports do not improve a score by themselves. Fewer concrete states do
not improve a score when the same topology is moved into payloads and branches.

## Evidence levels

| Level | Meaning | Maximum |
| --- | --- | ---: |
| `verified` | executable build/test/runtime/guardrail evidence directly supports the dimension | 10 |
| `source` | direct source/Gradle/manifest inspection supports the claim; executable proof is absent | 8.5 |
| `inferred` | plausible reasoning but necessary source/runtime evidence is incomplete | 6 |
| `not_assessed` | permitted only for a reasoned non-applicable dimension | no score |

Every applicable dimension cites concise reviewer-observed evidence. Developer claims are replay
instructions, not review proof. A build verifies compilation, not every quality dimension.

## Hard gates

Take applicability from the request, accepted architecture, and observed risk:

- `changed-modules-build`;
- `focused-behavior-tests`;
- `architecture-guardrails`;
- `runtime-flow`;
- `accessibility-localization`;
- `performance-resources`;
- `security-privacy`.

Statuses are `pass`, `fail`, `not_run`, or `not_applicable`. A documented blocker does not convert
`not_run` into `pass`.

## Proportionality assessment

For every material module, machine, state/event family, interface, wrapper, factory, durable
checkpoint, retry/recovery layer, correlation scheme, public seam, or implementation-shaped
validator, identify its protected scenario, owner, simpler alternative, and concrete cost.

For state topology, do not equate equal UI projection with redundancy. Distinguish projection
equivalence, interaction equivalence, and full behavioral equivalence. A collapse is justified only
when both candidates represent the same business condition and, for every accepted event, have
equivalent meaning, guards, semantic outputs, next-state behavior, data invariants, cancellation,
lifetime, persistence, commit/rollback, and recovery semantics.

Assess both directions:

- over-splitting: fully behaviorally equivalent states add no useful meaning;
- over-collapsing: a merged state reconstructs former alternatives through a mode/phase/operation/
  retry discriminator, nullable payload matrix, runtime type test, guard cascade, or conditional
  output/transition dispatcher.

Moving explicit alternatives into a payload and `when` is topology relocation, not simplification.
Keep separate projection-equivalent states when their types express distinct business facts, data
guarantees, semantic outputs, commit boundaries, owners, recovery paths, or clearer DSL routes.

A material mechanism without admission evidence is at least a `medium` finding. Events that merely
mirror internal call returns, duplicated recovery policy, exact private topology guardrails,
abstraction for one hypothetical consumer, unearned state splitting, hidden state discriminators,
or topology relocation must reduce `PROPORTIONALITY` and block readiness until simplified or
justified.

## Readiness

Numeric scores are diagnostic. They support trend comparison and expose weak dimensions, but do not
independently approve or reject a change unless the user explicitly requested a numeric threshold
as a decision criterion.

A ready verdict requires:

- every applicable hard gate to pass;
- accepted behavior and named invariants to have proportionate evidence;
- no open `blocker`, `high`, or `medium` finding;
- no unresolved user-authority or external-state decision.

A high average never hides a required finding. An accepted `low` finding is nonblocking only when
its impact and follow-up are explicit.
