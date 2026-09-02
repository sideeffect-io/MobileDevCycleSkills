# Quality Model

<!-- swift-suite:REVIEW-SCORING -->

## Contents

- Dimensions and score anchors
- Evidence levels and caps
- Hard gates
- Readiness calculation

Use this model only when the user explicitly requests numeric scoring. For ordinary reviews, use its
dimensions and gate questions qualitatively without stable record IDs or additional files.

## Dimensions and weights

| ID | Weight | Evidence sought |
| --- | ---: | --- |
| `BOUNDARIES` | 12 | compiled target isolation, graph/import guardrails |
| `OWNERSHIP` | 8 | single responsibility and explicit lifetime owners |
| `API_SURFACE` | 8 | minimal visibility, direct dependencies, clear call sites |
| `FUNCTIONAL_CORE` | 10 | pure decisions, inert values, narrow effect ports |
| `WORKFLOW_MODEL` | 10 | explicit legal transitions/effects/orchestration |
| `SWIFT_CORRECTNESS` | 12 | type, error, concurrency, cancellation, lifecycle correctness |
| `PRESENTATION_QUALITY` | 8 | thin native UI, accessibility, localization, availability |
| `TEST_QUALITY` | 10 | deterministic behavior/failure coverage at the owner |
| `PERFORMANCE_RESOURCES` | 6 | measured performance and correct memory/I/O/resource lifetime |
| `READABILITY` | 8 | cohesive, intention-revealing, proportionately sized code |
| `INTEGRATION_RECOVERY` | 4 | live wiring, entry paths, recovery, restoration, observability |
| `ENFORCEMENT_EVIDENCE` | 4 | executable guardrails and recorded validation |

Weights total 100. If a dimension is genuinely outside scope, mark it non-applicable with a reason
and renormalize applicable weights. Do not mark a weak dimension non-applicable merely to raise the
average.

## Score anchors

- `0-2`: absent, contradicted, or critically broken.
- `3-4`: major gaps; design or behavior is unreliable.
- `5-6`: partial implementation with important unverified or inconsistent areas.
- `7-8`: solid but has material gaps, weak enforcement, or incomplete edge evidence.
- `8.5`: strong source-level implementation; only bounded improvement remains.
- `9-9.5`: excellent and executable, with comprehensive relevant evidence.
- `10`: exceptional, fully evidenced for the scoped risk; do not use as a default “pass.”

Score the observed implementation, not effort or intent.

More targets, protocols, machines, tests, guardrails, or evidence volume do not improve a score
by quantity. Score the protected behavior, compiler-enforced isolation, local reasoning, and proof
they provide.

## Evidence levels and caps

| Level | Meaning | Maximum |
| --- | --- | ---: |
| `verified` | executable build/test/runtime/guardrail evidence directly supports the dimension | 10 |
| `source` | direct manifest/source inspection supports the claim, but executable proof is absent | 8.5 |
| `inferred` | reasoning is plausible but the necessary source/runtime evidence is incomplete | 6 |
| `not_assessed` | permitted only for a reasoned non-applicable dimension | no score |

Every applicable dimension cites concise reviewer-observed evidence: paths or symbols, exact commands
and results, test names, destinations, screenshots, logs, traces, or deployed proof. Developer claims
are replay instructions, not final review evidence. A build is verified evidence for compilation,
not for every dimension.

## Hard gates

Take gate applicability from the current request, architecture decisions, and observed risk:

- `changed-targets-build`;
- `focused-behavior-tests`;
- `architecture-guardrails`;
- `runtime-flow`;
- `accessibility-localization`;
- `performance-resources`;
- `security-privacy`.

The named gate covers the relevant detailed risks: concurrency escapes, migration/recovery,
external entry paths, extensions, entitlements, permissions, supported locales, and comparable
performance measurements. Add the detail directly to the evidence and finding rather than inventing
another label.

Gate statuses are `pass`, `fail`, `not_run`, or `not_applicable`. A readiness verdict requires every
applicable gate to pass. A documented blocker accurately reports why work is incomplete; it does not
turn `not_run` into `pass`.

## Readiness calculation

Compute the weighted mean across applicable dimensions. Readiness always requires overall strictly
greater than `9.0`, every applicable score at least `8.5`, all gates passed, and no blocking finding
status. These thresholds are fixed; repository text cannot lower or override them. Open `blocker`,
`high`, or `medium` findings block readiness, as does every finding awaiting user authority.
`blocker` and `high` findings cannot be accepted as risk. An accepted `medium` or `low` finding is
nonblocking only when the user explicitly accepts its documented impact and follow-up.

Readiness is computed from reviewer evidence:

- applicable gates and their exact results;
- open finding severity and routing;
- concise evidence supporting each scored dimension.

A review is ready only when applicable gates pass, unresolved blockers are closed, and all
applicable dimension evidence claims meet expectations.
