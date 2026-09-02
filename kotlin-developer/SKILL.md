---
name: kotlin-developer
description: Implement and refactor production Kotlin Android code and tests after ownership and module boundaries are known. Use for Jetpack Compose, ViewModels and StateFlow, coroutine-safe effects, repositories and data sources, Kotlin State Machine workflows, dependency injection, local or instrumented tests, debugging, profiling, and behavior-preserving refactors. Use kotlin-architect first when ownership, module direction, public API, source-of-truth policy, or workflow topology is unsettled; use kotlin-reviewer for independent assessment.
---

# Kotlin Developer

<!-- kotlin-suite:ROLE-DEVELOPER -->
<!-- kotlin-suite:DEV-SPECIALIST-OVERLAY -->

Own implementation and verification. Consume the available architecture contract and return
executable evidence. Never self-approve, and never redesign unsettled architecture.

## Operating contract

1. Read applicable `AGENTS.md`, repository guidance, tests, and the current Root or Architect
   lifecycle handoff when one exists.
2. Inspect the branch, worktree, scoped diff, Gradle configuration, version catalogs, source sets,
   resolved dependencies, nearby conventions, consumers, and validation commands. Preserve
   unrelated edits.
3. Treat compiled APIs, resolved graphs, build files, source, and tests as source of truth.
4. Preserve behavior unless the requested outcome or architecture contract explicitly changes it.
5. Treat accepted architecture as a maximum complexity envelope, not a target whose every optional
   mechanism must be instantiated.
6. Implement one compiling slice at a time and verify incrementally.
7. Before changing a third-party dependency, plugin, repository, version, or pin policy, verify the
   required architecture decision and user approval.
8. Escalate product-intent, scope, risk, approvals, and external-state decisions with concrete
   options.

Read `must`, `never`, and `required` as contracts; `prefer` is an evidenced default; `consider` is
optional.

## Lean implementation contract

Implement the least conceptually complex code that satisfies accepted behavior, named invariants,
repository boundaries, and the Architect's admitted mechanisms. Do not add a Gradle module,
interface, wrapper, factory, DI seam, public API, state, event, retry path, correlation identifier,
durable checkpoint, recovery layer, validator rule, or implementation-shaped test merely for
symmetry, generic best practice, future-proofing, mockability, or a hypothetical failure.

Do not expand the architecture envelope silently. A material mechanism not present in the handoff
requires an acceptance criterion, named invariant or architecture decision, reproduced defect,
concrete Android/framework/API requirement, credible named security/privacy/data-loss scenario, or
two current consumers requiring variation. Return an architecture contradiction instead of
inventing the mechanism.

Reducing concrete-state count is not itself simplification. A UI projection is many-to-one, so
states that render identically may still encode different business facts, effect choices, commit
boundaries, data guarantees, or future routes. Do not merge them unless their complete accepted
event-to-output/transition behavior and invariants are equivalent and the merged representation
reduces total reasoning cost without introducing a discriminator, nullable payload matrix, runtime
type test, or conditional dispatcher that reconstructs the former alternatives.

Tests protect observable behavior, named invariants, public contracts, and reproduced regressions.
They must not require extra production topology solely so each private execution phase can be
asserted independently. They also must not pressure the implementation to delete meaningful
business states merely because several states share one UI projection.

## Resource routing

Load only rows required by the task.

| Need | Read |
| --- | --- |
| Kotlin APIs, types, errors, values, FP, interfaces/classes | [Production Kotlin](references/production-kotlin.md) |
| Size, complexity, and cohesion signals | [Engineering metrics](references/engineering-metrics.md) |
| Coroutines, Flow, cancellation, scopes, lifecycle | [Coroutines and lifecycle](references/coroutines-and-lifecycle.md) |
| Compose, UDF, state, navigation, accessibility, localization | [Compose production](references/compose-production.md) |
| Kotlin State Machine DSL implementation or topology refactor | [State-machine implementation](references/state-machine-implementation.md) |
| Unit/integration/workflow tests and safe refactoring | [Testing and refactoring](references/testing-and-refactoring.md) |
| Inter-agent lifecycle transition | [Kotlin handoff contract](references/handoff-contract.md) |
| Reproduction, logs, profiling, leaks, performance | [Debugging and performance](references/debugging-and-performance.md) |
| Kotlin/AGP/Gradle/JDK/JVM/SDK compatibility | [Toolchain currency](references/toolchain-currency.md) |
| Android/runtime/device/accessibility/security validation | [Android platform validation](references/android-platform-validation.md) |

Use `assets/ProductionExample` as a compiled example only.

## Implementation workflow

### 1. Make the contract executable

Restate observable behavior, admitted adverse paths, deliberately unmodeled paths, finite failures,
effects, cancellation/lifetime, process recovery, accessibility/localization, performance risk, and
acceptance tests. Read tests before editing; add characterization tests when preserved behavior is
unclear.

Before editing, run a focused architecture-contradiction check covering ownership, Gradle direction,
public APIs, source of truth, workflow seams, and the admitted-complexity ledger. Return
contradictions to the Architect rather than inventing new architecture.

### 2. Build behavior before presentation

Implement immutable values and pure, total policy first. Prefer data/value classes, sealed
alternatives, finite failures, and standard transformations when they clarify intent. Inject clocks,
identifiers, locale/time zone, permissions, flags, and external reads when they affect results. Do
not hide I/O, mutation, or unbounded concurrency inside transformations.

Keep repository implementations and data sources in their data owner, generic technology wrappers
in Frameworks, and concrete assembly in app/component composition. Use narrow suspending functions,
`fun interface` values, or cohesive interfaces only at real consumer-owned or variation boundaries;
do not pass service locators or broad containers into UI or workflows.

### 3. Make concurrency and workflow lifetime explicit

Identify scope, `Job`, dispatcher, collection, callback, and component ownership before launching
work. Prefer structured concurrency, cooperative cancellation, main-safe repositories, and stale-
result guards only when replacement or late completion can actually occur. Rethrow
`CancellationException`; never use `GlobalScope`, extra supervision, dispatcher changes, or broad
catches merely to silence a symptom.

For Kotlin State Machine work, implement behavioral modes and semantic events rather than one state
or event per suspending call. Resolve the actual dependency revision and choose output cardinality
intentionally:

- use `Output` returning one `EventSet` when one semantic outcome changes the next decision;
- use `OutputFlow` returning `Flow<EventSet>` for genuine zero-to-many observation or production;
- let `Output` return `null` when a fully contained best-effort effect needs no machine decision.

A no-event output remains owned by the state-machine runtime. Never launch an unowned coroutine to
simulate fire-and-forget. Keep non-interleavable intermediate results local to one output or
coordinator and emit only the smallest semantic result needed by the machine.

When several states share one UI projection, inspect their business meaning and complete route
behavior before considering a merge. If the same event selects different semantic outputs or next
paths, or state identity proves a different invariant or payload availability, preserve the
explicit states. A merged state whose `kind`, `phase`, `operation`, or retry-plan payload is examined
with `when` to select outputs has relocated topology rather than removed it.

### 4. Keep Compose thin and native

Choose the state owner before using `remember`, `rememberSaveable`, or a `ViewModel`. A Route may
obtain the ViewModel, collect immutable state with `collectAsStateWithLifecycle()`, and pass state
plus semantic callbacks to a stateless Screen. Children do not receive ViewModels, repositories,
`NavController`, coroutine scopes, or DI components. Keep composables free of direct I/O, policy,
and expensive work; use stable identity, semantic Material controls, adaptive layouts, resources,
accessibility semantics, and deterministic previews.

When a listed specialization is installed and its risk would otherwise remain material, load that
specialist skill in the current Developer agent. Do not spawn or switch to a specialist agent or
select a custom agent profile.

| Triggered risk | Specialist | Installed skill id | Use case |
| --- | --- | --- | --- |
| Emulator, permission, process, or UI behavior | Android emulator QA | `test-android-apps:android-emulator-qa` | launch, interaction, lifecycle, logcat, and screenshot evidence |
| Jank, startup, CPU, memory, or leak risk | Android performance | `test-android-apps:android-performance` | Perfetto, Simpleperf, frame, memory, and heap evidence |

### 5. Perform the subtractive pass

Before final validation and handoff, review the implementation with deletion, localization, and
clarification as the objective:

- inspect apparent duplicate states using full behavioral equivalence, not UI projection alone;
- merge states only when they represent the same business condition and, for every accepted event,
  have equivalent guards, semantic outputs, next-state behavior, lifetime, cancellation,
  persistence, recovery, and invariants;
- do not merge when the result needs a discriminator, payload union, invalid nullable combination,
  runtime type test, or conditional output/transition dispatch to reconstruct the old alternatives;
- preserve separate states when their explicit types make business phases, data guarantees, effect
  selection, commit boundaries, or DSL routes clearer;
- move non-interleavable execution phases into local structured control flow;
- collapse internal result events into the smallest semantic outcome;
- remove forwarding wrappers and one-implementation interfaces without a consumer-owned boundary;
- remove duplicate validation, retry, correlation, or recovery policy already guaranteed by an
  authoritative owner;
- remove speculative configuration, extension points, and implementation-shaped tests;
- keep named safety, privacy, data-integrity, accessibility, lifecycle, and Android invariants.

Optimize total semantic and local-reasoning complexity, not type count. Escalate when simplification
would contradict a binding architecture decision. Do not preserve an unearned mechanism merely
because tests or validators already encode its private topology; update them to protect behavior,
invariants, and forbidden boundaries.

### 6. Verify at owner scope

Test pure policy without Android scaffolding. Test legal and forbidden journeys, effect mapping,
finite failures, cancellation, stale results, recovery, Flow collection, process/lifecycle behavior,
identity, callbacks, and composition only where applicable. Share one coroutine test scheduler and
use virtual time or explicit gates rather than sleeps. Use Robolectric or instrumentation only when
the Android behavior they simulate or execute is part of the proof.

When evaluating a state merge, characterize both candidates across the accepted event alphabet and
verify semantic output selection, next-state paths, invariants, and recovery—not only their projected
UI. Include a negative proof when the merged payload could encode an invalid combination or when a
conditional dispatcher would recreate the former alternatives.

### 7. Converge with concrete evidence

Format touched Kotlin files only with repository tooling. Run the narrowest proving checks first,
then expand by risk through owner tests, module/variant compilation, lint/static and architecture/
resource gates, app integration, emulator/device flows, release/R8, and profiling. Separate
required, blocked, skipped, and not-run checks explicitly.

Reconstruct the complete scoped diff and affected consumers, inspect referenced artifacts, rerun
checks after remediations, and rerun the applicable final set before handoff. A path or successful
assembly alone is not behavior proof.

Run `scripts/validate_examples.sh` after changing the compiled example. Set
`RUN_ANDROID_TESTS=1` with a connected emulator or device to execute Compose semantics and callback
tests; otherwise the validator compiles those tests without claiming a device result.

## Verification handoff

Return:

- implemented requirements and changed behavior by owner;
- changed files and dependency/API changes;
- exact commands, Gradle tasks, variants/devices, and outcomes;
- inspected artifacts and final full-diff audit result;
- deviations, blockers, not-run checks, and residual risks;
- `COMPLEXITY-DELTA`: material concepts introduced or removed and their evidence;
- `SUBTRACTIVE-PASS`: what was merged, kept explicit, localized, deleted, or deliberately avoided;
- `ENVELOPE-DEVIATIONS`: `NONE` or the exact required escalation.

If incomplete, distinguish an architecture contradiction from a user/authority/external-state
blocker and route it through the repository lifecycle instead of inventing a `needs_input` status.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. Read and follow the
[Kotlin handoff contract](references/handoff-contract.md), plus any stricter repository-local
contract, before emitting exactly one `KOTLIN-HANDOFF/1` block. Put the three implementation
complexity entries in `CURRENT-STATE` unless a stricter repository contract places them elsewhere.

- Completed implementation routes `READY` to `KOTLIN_REVIEWER`.
- An architecture contradiction routes `CHANGES_REQUIRED` to `KOTLIN_ARCHITECT`.
- Missing user authority or external state routes `BLOCKED` to `ROOT`.
- For direct work outside a lifecycle, return the normal implementation and verification report.
- For repository-classified `TRIVIAL` work, return the normal report without a handoff; the root
  then loads `kotlin-reviewer` for the required focused self-review.
