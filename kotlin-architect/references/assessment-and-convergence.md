# Architecture Assessment and Convergence

<!-- kotlin-suite:KOTLIN-ASSESSMENT-CONVERGENCE -->

## Contents

- Evidence inventory
- Shared quality dimensions
- Evidence levels and hard gates
- Complexity review triggers
- Convergence loop

Use this reference for architecture assessment and convergence: scope, evidence, necessity, and applicable gates.
Use numeric scoring only when requested by the user or repository; a design-only task need not
produce implementation or runtime proof. Record those downstream validation obligations instead.

## Evidence inventory

Before scoring or recommending a refactor, record:

1. Gradle settings/build files, version catalogs, locks, resolved dependencies, source sets,
   resources, and test ownership;
2. public symbols crossing each boundary;
3. state-machine, repository, ViewModel, service, and process lifetime owners;
4. input, event, output, outcome, callback, route, observation, and cancellation paths;
5. app/component composition and concrete adapter assembly;
6. existing architecture guardrails and their positive/negative fixtures;
7. current build/test/runtime evidence and dirty worktree constraints;
8. modules, dependency edges, public seams, machines, entry points, test tasks, and guardrail rules
   added or removed by the proposal.

Classify a problem as boundary, ownership, API, functional/effect, workflow, correctness,
coroutine/lifecycle, presentation, test, performance/resource, readability, integration/recovery,
or enforcement. Large code is a prompt to inspect responsibility, not proof of a defect.

## Shared quality dimensions

Use these dimensions when the user explicitly requests numeric assessment:

| ID | Default weight | Question |
| --- | ---: | --- |
| `BOUNDARIES` | 10 | Do Gradle, source sets, and visibility enforce the allowed graph? |
| `OWNERSHIP` | 8 | Is every responsibility, source of truth, and lifetime owned once? |
| `API_SURFACE` | 7 | Are dependencies and visibility minimal, clear, and stable? |
| `FUNCTIONAL_CORE` | 9 | Are decisions pure and effects segregated behind narrow ports? |
| `WORKFLOW_MODEL` | 9 | Do states, events, transitions, and outputs express required business rules and technical constraints? |
| `KOTLIN_CORRECTNESS` | 12 | Is the implementation type-safe, coroutine-safe, and lifecycle-correct? |
| `PRESENTATION_QUALITY` | 7 | Is UI thin, accessible, localized, adaptive, and Android-native? |
| `TEST_QUALITY` | 9 | Do deterministic tests prove behavior and failure paths? |
| `PERFORMANCE_RESOURCES` | 5 | Are performance, memory, I/O, battery, and resources evidence-based? |
| `READABILITY` | 8 | Is code cohesive, intention-revealing, and proportionately sized? |
| `PROPORTIONALITY` | 10 | Does each material mechanism serve a named rule or evidenced constraint with lower-cost alternatives considered? |
| `INTEGRATION_RECOVERY` | 3 | Are DI, entry paths, restoration, migration, and recovery proven? |
| `ENFORCEMENT_EVIDENCE` | 3 | Are important constraints executable and validation results recorded? |

Weights total 100. Mark a dimension non-applicable only with a concrete scope reason; renormalize
the remaining weights. Repository-specific dimensions may be added, but do not rename these within
one lifecycle.

More modules, interfaces, machines, tests, or guardrails do not raise a score by quantity. Score
the behavior, isolation, local reasoning, and evidence they provide.

## Evidence levels and caps

Use `verified` for executable build/test/runtime/guardrail evidence, `source` for direct
Gradle/manifest/source inspection, `inferred` for reasoned but unverified claims, and
`not_assessed` only for a declared non-applicable dimension. Maximum scores are `10`, `8.5`, and
`6` respectively.

Every score cites concise concrete evidence such as paths and symbols, exact commands and results,
test names, variants, devices, or runtime proof. Never award points for plans not implemented.
Developer claims establish what to replay; only reviewer-observed evidence supports the final
score. A module build verifies compilation, not user flow, cancellation, restoration, performance,
or ownership.

## Hard gates

Regardless of average, report not-ready when an applicable gate fails or was not run. A documented
blocker explains the gap but does not pass it. When readiness is explicitly requested, report the
applicable gates concisely in the current report or handoff:

- `changed-modules-build`: changed modules compile for the relevant variants and real toolchain;
- `focused-behavior-tests`: scoped behavior, failure, cancellation, and recovery tests pass;
- `architecture-guardrails`: dependency, visibility, ownership, and resource contracts pass;
- `runtime-flow`: affected app, deep-link, background, recovery, or component flow is observed;
- `accessibility-localization`: affected locales and accessible/adaptive interaction pass;
- `performance-resources`: applicable performance, memory, I/O, battery, and lifetime claims pass;
- `security-privacy`: applicable trust, exported-component, permission, data, and privacy contracts pass.

## Complexity review triggers

Use repository thresholds first. Otherwise treat these as review signals rather than scoring
shortcuts: inspect functions beyond 15-20 logical lines, 4 or more independent parameters, 4 levels
of nesting, cyclomatic complexity above 10, types beyond 250-300 production lines, files beyond 400,
interfaces beyond 5-7 members, and machines with roughly 10-15 unrelated properties or large
transitions. Cohesion and correctness beat a number; never split an irreducible algorithm or
cohesive workflow mechanically. Persist enforced exceptions with owner, reason, interactions, why
splitting is worse, and re-review triggers.

Also inspect distributed cost: a one-consumer module without a forbidden edge, one-implementation
interface without substitution value, pass-through wrapper/factory, empty capability/output type,
compile-only test, duplicated authoritative Flow observation, and style guardrail cost. Require
concrete impact before calling any signal a defect.

## Convergence loop

Establish the scoped findings and applicable gates. Recommend the smallest correction that preserves
accepted behavior; an assessment is not permission to implement it. Reassess only changed findings
and invalidated evidence. Score only when requested, and never add mechanisms or checks to chase a
number. Complete the requested design or assessment when its decisions and evidence obligations are
clear; implementation approval remains the independent Reviewer's responsibility.

Numeric scores are diagnostic unless the user explicitly makes a threshold binding. Applicable gates
and concrete blocker/high/medium findings cannot be averaged away. Repository-local readiness and
handoff rules apply; no fixed global score target overrides them.
