# Architecture Assessment and Convergence

<!-- swift-suite:SWIFT-ASSESSMENT-CONVERGENCE -->

## Contents

- Evidence inventory
- Shared quality dimensions
- Evidence levels and hard gates
- Complexity review triggers
- Convergence loop

Use this reference for architecture assessment and convergence: baseline evidence, fixed gates, and
required quality checks before implementation.

## Evidence inventory

Before scoring or recommending a refactor, record:

1. manifests, resolved dependencies, target imports, resources, and test ownership;
2. public symbols crossing each boundary;
3. state-machine and service lifetime owners;
4. input, event, output, outcome, callback, route, observation, and cancellation paths;
5. composition and concrete adapter assembly;
6. existing architecture guardrails and their fixtures;
7. current build/test/runtime evidence and dirty worktree constraints;
8. targets, dependency edges, public seams, machines, factories, test products, and guardrail rules
   added or removed by the proposal.

Classify a problem as boundary, ownership, API, functional/effect, workflow, correctness,
concurrency/lifecycle, presentation, test, performance/resource, readability, integration/recovery,
or enforcement. Large code is a prompt to inspect responsibility, not proof of a defect.

## Shared quality dimensions

Use these dimensions when the user explicitly requests numeric assessment:

| ID | Default weight | Question |
| --- | ---: | --- |
| `BOUNDARIES` | 12 | Does the compiler enforce the allowed graph and isolation? |
| `OWNERSHIP` | 8 | Is every responsibility and lifetime owned once? |
| `API_SURFACE` | 8 | Are dependencies and visibility minimal, clear, and stable? |
| `FUNCTIONAL_CORE` | 10 | Are decisions pure and effects segregated behind narrow ports? |
| `WORKFLOW_MODEL` | 10 | Are states, events, effects, transitions, and orchestration explicit? |
| `SWIFT_CORRECTNESS` | 12 | Is the implementation type-safe, race-safe, and lifecycle-correct? |
| `PRESENTATION_QUALITY` | 8 | Is UI thin, accessible, localized, and platform-appropriate? |
| `TEST_QUALITY` | 10 | Do deterministic tests prove behavior and failure paths? |
| `PERFORMANCE_RESOURCES` | 6 | Are performance, memory, I/O, energy, and resources evidence-based? |
| `READABILITY` | 8 | Is code cohesive, intention-revealing, and proportionately sized? |
| `INTEGRATION_RECOVERY` | 4 | Are wiring, recovery, observability, and external entry paths proven? |
| `ENFORCEMENT_EVIDENCE` | 4 | Are important constraints executable and validation results recorded? |

Weights total 100. Mark a dimension non-applicable only with a concrete scope reason; renormalize
the remaining weights. Repository-specific dimensions may be added, but do not rename these within
one lifecycle.

More targets, protocols, machines, tests, or guardrails do not raise a score by quantity.
Score the behavior, isolation, local reasoning, and evidence they provide.

## Evidence levels and caps

Use `verified` for executable build/test/runtime/guardrail evidence, `source` for direct
manifest/source inspection, `inferred` for reasoned but unverified claims, and `not_assessed` only
for a declared non-applicable dimension. Maximum scores are `10`, `8.5`, and `6` respectively.

Every score cites concise concrete evidence such as paths and symbols, exact commands and results,
test names, destinations, or runtime proof. Never award points for plans not implemented. Developer
claims establish what to replay; only reviewer-observed evidence supports the final score. A build
verifies compilation, not user flow, cancellation, restoration, performance, or ownership.

## Hard gates

Regardless of average, report not-ready when an applicable gate fails or was not run. A documented
blocker explains the gap but does not pass it. When readiness is explicitly requested, report the
applicable gates concisely in the current report or handoff:

- `changed-targets-build`: changed targets compile under the real Swift/concurrency settings;
- `focused-behavior-tests`: scoped behavior, failure, cancellation, and recovery tests pass;
- `architecture-guardrails`: dependency, visibility, ownership, and resource contracts pass;
- `runtime-flow`: affected app, deep-link, background, recovery, or extension flow is observed;
- `accessibility-localization`: affected supported locales and accessible interaction pass;
- `performance-resources`: applicable performance, memory, I/O, energy, and lifetime claims pass;
- `security-privacy`: applicable trust, entitlement, permission, data, and privacy contracts pass.

## Complexity review triggers

Use repository thresholds first. Otherwise treat these as review signals rather than scoring
shortcuts: inspect functions beyond 15-20 logical lines, 4 or more independent parameters, 4 levels
of nesting, cyclomatic complexity above 10, types beyond 250-300 production lines, files beyond 400,
protocols beyond 5-7 requirements, and machines with roughly 10-15 unrelated properties or large
transitions. Cohesion and correctness beat a number; never split an irreducible algorithm or
cohesive workflow mechanically. Persist enforced exceptions with owner, reason, interactions, why
splitting is worse, and re-review triggers.

Also inspect distributed cost: a one-consumer target without a forbidden edge, one-implementation
protocol without identity semantics, pass-through wrapper/factory, empty dependency or output type,
compile-only test, duplicated authoritative observation, and style guardrail cost. Require concrete
impact before calling any signal a defect.

## Convergence loop

1. Establish baseline scores from current evidence.
2. Identify hard gates and the lowest applicable dimensions.
3. Fix architectural blockers before style or micro-cleanup.
4. Change one coherent responsibility at a time and keep the slice compiling.
5. Re-run the narrowest relevant executable evidence.
6. Re-score only dimensions affected by new evidence.
7. Stop only when the fixed global target is met, all applicable gates pass, and no open blocker,
   high, or medium finding remains without valid user acceptance of a medium risk.

Completion is strictly greater than `9.0` overall and at least `8.5` in every applicable
dimension. These thresholds are fixed and cannot be lowered by repository text.
The reviewer owns the final independent score; the architect supplies the baseline and target.
