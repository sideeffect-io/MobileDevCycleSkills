# Quality Model

<!-- kotlin-suite:REVIEW-SCORING -->

## Contents

- Dimensions and score anchors
- Evidence levels and caps
- Hard gates
- Readiness calculation

Use this model only when the user explicitly requests numeric scoring. For ordinary reviews, use
its dimensions and gate questions qualitatively without stable record IDs or additional files.

## Dimensions and weights

| ID | Weight | Evidence sought |
| --- | ---: | --- |
| `BOUNDARIES` | 12 | compiled module/source-set isolation and dependency/visibility guardrails |
| `OWNERSHIP` | 8 | single responsibility, source of truth, and explicit lifetime owners |
| `API_SURFACE` | 8 | minimal visibility, direct dependencies, and clear call sites |
| `FUNCTIONAL_CORE` | 10 | pure decisions, immutable values, and narrow effect ports |
| `WORKFLOW_MODEL` | 10 | explicit legal transitions, effects, and orchestration |
| `KOTLIN_CORRECTNESS` | 12 | type, null/error, coroutine, cancellation, and lifecycle correctness |
| `PRESENTATION_QUALITY` | 8 | thin Compose UI, accessibility, localization, and adaptive behavior |
| `TEST_QUALITY` | 10 | deterministic behavior/failure coverage at the owner |
| `PERFORMANCE_RESOURCES` | 6 | measured performance and correct memory/I/O/battery lifetime |
| `READABILITY` | 8 | cohesive, intention-revealing, proportionately sized code |
| `INTEGRATION_RECOVERY` | 4 | live DI/wiring, entry paths, persistence, restoration, and recovery |
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
- `10`: exceptional, fully evidenced for the scoped risk; do not use as a default pass.

Score the observed implementation, not effort or intent.

More modules, interfaces, machines, tests, guardrails, or evidence volume do not improve a score by
quantity. Score the protected behavior, compiler-enforced isolation, local reasoning, and proof
they provide.

## Evidence levels and caps

| Level | Meaning | Maximum |
| --- | --- | ---: |
| `verified` | executable build/test/runtime/guardrail evidence directly supports the dimension | 10 |
| `source` | direct Gradle/manifest/source inspection supports the claim, but executable proof is absent | 8.5 |
| `inferred` | reasoning is plausible but necessary source/runtime evidence is incomplete | 6 |
| `not_assessed` | permitted only for a reasoned non-applicable dimension | no score |

Every applicable dimension cites concise reviewer-observed evidence: paths or symbols, exact
commands and results, test names, variants, devices, screenshots, logs, traces, or deployed proof.
Developer claims are replay instructions, not final review evidence. A build is verified evidence
for compilation, not for every dimension.

## Hard gates

Take gate applicability from the current request, architecture decisions, and observed risk:

- `changed-modules-build`;
- `focused-behavior-tests`;
- `architecture-guardrails`;
- `runtime-flow`;
- `accessibility-localization`;
- `performance-resources`;
- `security-privacy`.

The named gate covers the relevant detailed risks: coroutine/lifecycle escapes, migration/recovery,
external entry paths, exported components, permissions, supported locales, release/R8 behavior,
and comparable performance measurements. Add detail directly to evidence and findings rather than
inventing another label.

Gate statuses are `pass`, `fail`, `not_run`, or `not_applicable`. A readiness verdict requires every
applicable gate to pass. A documented blocker accurately reports why work is incomplete; it does
not turn `not_run` into `pass`.

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
