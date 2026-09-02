# Quality Model

<!-- swift-suite:REVIEW-SCORING -->

Use this model only when the user or repository explicitly requests numeric scoring. For ordinary
reviews, apply the same dimensions and gate questions qualitatively.

## Dimensions and weights

| ID | Weight | Evidence sought |
| --- | ---: | --- |
| `BOUNDARIES` | 10 | compiled SwiftPM/process isolation, imports, visibility, and guardrails |
| `OWNERSHIP` | 8 | single responsibility, source of truth, actor/process/lifetime owners |
| `API_SURFACE` | 7 | minimal access, direct dependencies, and clear call sites |
| `FUNCTIONAL_CORE` | 9 | pure decisions, immutable Sendable values, and narrow effect ports |
| `WORKFLOW_MODEL` | 9 | explicit legal transitions, proportionate outputs, and orchestration |
| `SWIFT_CORRECTNESS` | 12 | types, errors, isolation, Sendable, cancellation, and lifecycle correctness |
| `PRESENTATION_QUALITY` | 7 | thin SwiftUI, accessibility, localization, and adaptive behavior |
| `TEST_QUALITY` | 9 | deterministic behavior/invariant coverage at the owner |
| `PERFORMANCE_RESOURCES` | 5 | measured performance and correct memory/I/O/energy lifetime |
| `READABILITY` | 8 | cohesive, intention-revealing, locally understandable code |
| `PROPORTIONALITY` | 10 | every material mechanism has evidence and no simpler sufficient design remains |
| `INTEGRATION_RECOVERY` | 3 | live composition, entry paths, persistence, restoration, and recovery |
| `ENFORCEMENT_EVIDENCE` | 3 | executable negative guardrails and recorded validation |

Weights total 100. If a dimension is genuinely outside scope, mark it non-applicable with a reason
and renormalize applicable weights. Do not hide a weak dimension as non-applicable.

## Score anchors

- `0-2`: absent, contradicted, or critically broken.
- `3-4`: major gaps; design or behavior is unreliable.
- `5-6`: partial implementation with important unverified or disproportionate areas.
- `7-8`: solid but has material gaps, weak enforcement, or avoidable complexity.
- `8.5`: strong source-level implementation; only bounded improvement remains.
- `9-9.5`: excellent and executable, with comprehensive relevant evidence and lean mechanisms.
- `10`: exceptional for the scoped risk; never a default pass.

Score observed behavior and evidence, not effort or quantity. More targets, protocols, machines,
states, tests, guardrails, or reports do not improve a score by themselves.

## Evidence levels

| Level | Meaning | Maximum |
| --- | --- | ---: |
| `verified` | executable build/test/runtime/guardrail evidence directly supports the dimension | 10 |
| `source` | direct manifest/source inspection supports the claim; executable proof is absent | 8.5 |
| `inferred` | plausible reasoning but necessary source/runtime evidence is incomplete | 6 |
| `not_assessed` | permitted only for a reasoned non-applicable dimension | no score |

Every applicable dimension cites concise reviewer-observed evidence. Developer claims are replay
instructions, not review proof. A build verifies compilation, not every quality dimension.

## Hard gates

Take applicability from the request, accepted architecture, and observed risk:

- `changed-targets-build`;
- `focused-behavior-tests`;
- `architecture-guardrails`;
- `runtime-flow`;
- `accessibility-localization`;
- `performance-resources`;
- `security-privacy`.

Statuses are `pass`, `fail`, `not_run`, or `not_applicable`. A documented blocker does not convert
`not_run` into `pass`.

## Proportionality assessment

For every material target, machine, state/event family, protocol, wrapper, factory/environment key,
durable checkpoint, retry/recovery layer, correlation scheme, public seam, or implementation-shaped
validator, identify its protected scenario, owner, simpler alternative, and concrete cost.

A material mechanism without admission evidence is at least a `medium` finding. Repeated retry
states with identical legal inputs/UI, events that merely mirror internal call returns, duplicated
recovery policy, exact private topology guardrails, or abstraction for one hypothetical consumer
must reduce `PROPORTIONALITY` and block readiness until simplified or justified.

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
