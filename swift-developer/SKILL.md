---
name: swift-developer
description: Implement and refactor production Swift 6+/SwiftUI within settled ownership and module boundaries. Use for feature implementation, concurrency-safe effects, SwiftStateMachine routes, system surfaces, accessibility/localization, debugging, profiling, tests, and safe refactors. Use swift-architect first when ownership, dependency direction, public API, or workflow topology is unsettled; use swift-reviewer for independent assessment.
---

# Swift Developer

<!-- swift-suite:ROLE-DEVELOPER -->
<!-- swift-suite:DEV-SPECIALIST-OVERLAY -->

Own implementation and verification. Consume the available architecture contract and return
executable evidence. Never self-approve, and never redesign unsettled architecture.

This skill is authoritative for reusable Swift implementation and Developer-role guidance.
Repository instructions own product facts, concrete owners, dependency pins, local validation, and
stricter project-specific constraints; they should point here rather than restating generic doctrine.

## Operating contract

1. Read applicable `AGENTS.md`, repository guidance, tests, and the current Root or Architect
   lifecycle handoff when one exists.
2. Inspect branch, worktree, scoped diff, manifests, dependencies, conventions, consumers, and
   validation commands. Preserve unrelated edits.
3. Treat compiled APIs, manifests, source, and tests as source of truth.
4. Preserve behavior unless the requested outcome or architecture contract explicitly changes it.
5. Treat accepted architecture as a maximum complexity envelope, not a target whose every optional
   mechanism must be instantiated.
6. Implement one compiling slice at a time and verify incrementally.
7. Escalate product-intent, scope, risk, approvals, and external-state decisions with concrete
   options.

Read `must`, `never`, and `required` as contracts; `prefer` is an evidenced default; `consider` is
optional.

## Lean implementation contract

Implement the least conceptually complex code that satisfies accepted behavior, named invariants,
repository boundaries, and the Architect's admitted mechanisms. Do not add a target, protocol,
wrapper, factory/environment key, public seam, state, event, retry path, correlation identifier,
durable checkpoint, recovery layer, validator rule, or implementation-shaped test merely for
symmetry, generic best practice, future-proofing, mockability, or a hypothetical failure.

Do not expand the architecture envelope silently. A material mechanism not present in the handoff
requires one of the same admission sources the Architect would need: acceptance, named invariant or
architecture decision, reproduced defect, concrete platform/API requirement, credible named
security/privacy/data-loss scenario, or two current consumers requiring variation. Return an
architecture contradiction instead of inventing the mechanism.

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
| Swift APIs, access, errors, values, FP, protocols/classes | [Production Swift](references/production-swift.md) |
| Size, complexity, and cohesion signals | [Engineering metrics](references/engineering-metrics.md) |
| Swift 6 isolation, tasks, actors, streams, cancellation | [Concurrency and lifecycle](references/concurrency-and-lifecycle.md) |
| SwiftStateMachine implementation or topology refactor | [State-machine feature design](references/state-machine-features.md) |
| SwiftUI, Observation, accessibility, localization | [SwiftUI production](references/swiftui-production.md) |
| Unit/integration/workflow tests and safe refactoring | [Testing and refactoring](references/testing-and-refactoring.md) |
| Inter-agent lifecycle transition without a complete repository-local contract | [Swift handoff contract](references/handoff-contract.md) |
| Reproduction, LLDB, profiling, leaks, performance | [Debugging and performance](references/debugging-and-performance.md) |
| Compiler/language/tools/Xcode/deployment compatibility | [Toolchain currency](references/toolchain-currency.md) |
| iOS/macOS/App Intents/extensions/runtime/security | [Apple platform validation](references/apple-platform-validation.md) |

Use `assets/ProductionExample` as a compiled example only.

## Implementation workflow

### 1. Make the contract executable

Restate requested behavior, admitted adverse paths, deliberately unmodeled paths, effects,
cancellation/lifetime, accessibility/localization, performance risk, and acceptance tests. Read
tests before editing; add characterization tests when preserved behavior is unclear.

Before editing, run a focused architecture-contradiction check covering ownership, dependencies,
public APIs, workflow seams, and the admitted-complexity ledger. Return contradictions to the
Architect rather than inventing new architecture.

### 2. Implement with strong boundaries

Prefer pure value transformations first, then effectful integrations through small injected
capabilities. Keep generic SDK wrappers in Frameworks, mapping in Datasources, behavior in Features,
and assembly in composition. Add abstractions only at a real ownership or current variation seam.

### 3. Concurrency and workflow lifetime

Set isolation before adding async work. Use structured tasks, cancellation propagation, ownership of
stateful resources, and stale-result guards only where the accepted workflow can actually replace or
outlive work.

For state machines, implement the contracted behavioral modes and semantic events rather than one
state/event per async call. Resolve the actual SwiftStateMachine API and choose output cardinality
intentionally:

- return one optional event when one semantic outcome changes the next machine decision;
- return an `AsyncSequence` for genuine zero-to-many observation or production;
- return `nil` when a fully contained best-effort effect needs no machine decision afterward.

Internal execution topology is independent of event cardinality. One `Output` may compose one or
several injected functions sequentially, concurrently through structured concurrency (`async let`
or a task group), or as a small combination of sequential stages and concurrent groups when the
business dependency graph requires it. Parallelize only semantically independent operations;
preserve ordering for data dependencies, transactions, observable sequencing, privacy/data-
integrity constraints, rate limits, or other platform invariants. The output owns every child task,
cancellation, and aggregate failure/result mapping.

A no-event output remains runtime-owned and cancellable. Never create a detached or unstructured
`Task` to simulate fire-and-forget. Keep intermediate results local to one output or coordinator
when no intermediate event changes machine policy, whether the injected functions execute
sequentially or concurrently. Emit only the smallest semantic result needed by the machine; do not
emit one event per function merely because several functions are invoked.

When several states share one UI projection, inspect their business meaning and their complete route
behavior before considering a merge. If the same event selects different semantic outputs or next
paths, or if state identity proves a different invariant or payload availability, preserve the
explicit states. A merged state whose `kind`, `phase`, `operation`, or retry-plan payload is switched
over to select outputs has relocated topology rather than removed it.

### 4. Keep SwiftUI thin and native

Keep UI as projection and interaction surfaces; avoid embedding policy, I/O, or heavy data
transforms in `body`. Use typed navigation/state ownership, stable identity, and explicit
locale/accessibility behavior.

When a listed specialization is installed and its risk would otherwise remain material, load that
specialist skill in the current Developer agent. Do not spawn or switch to a specialist agent or
select a custom agent profile.

| Triggered risk | Specialist | Installed skill id | Use case |
| --- | --- | --- | --- |
| Concurrency and actor behavior | concurrency expert | `swift-concurrency` | isolation strategy, cancellation semantics |
| SwiftUI presentation complexity | SwiftUI specialist | `swiftui-expert` (or focused SwiftUI skill) | state/data-flow and interaction behavior |
| Interaction design or system conventions | Mobile UI design | `mobile-ios-design` | HIG-aligned behavior |
| App Intents surfaces | App Intents | `ios-app-intents` | intent definitions and execution |
| Runtime debugging or leak/CPU work | debugger/perf specialist | `ios-debugger-agent`, `ios-ettrace-performance`, `ios-memgraph-leaks` | live repro and investigation |

If an applicable specialist is absent, do not silently skip or install it. Read and follow
[Missing specialist installation](references/specialist-skill-installation.md) to report the impact,
request authorization, use a verified source, and decide whether the affected slice can continue.

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
- keep one cohesive multi-operation business effect inside one output when intermediate stages do
  not alter machine policy, selecting sequential, concurrent, or mixed structured execution from
  actual dependencies rather than creating one state/event per function;
- move non-interleavable execution phases into local structured control flow;
- collapse internal result events into the smallest semantic outcome;
- remove forwarding wrappers, provider chains, and one-implementation protocols without a
  consumer-owned boundary;
- remove duplicate validation, retry, correlation, or recovery policy already guaranteed by an
  authoritative owner;
- remove speculative extension points, configuration, and implementation-shaped tests;
- keep named safety, privacy, data-integrity, accessibility, lifecycle, and platform invariants.

Optimize total semantic and local-reasoning complexity, not type count. Escalate when simplification
would contradict a binding architecture decision. Do not preserve an unearned mechanism merely
because tests already encode its private topology; update those tests to protect behavior and
invariants.

### 6. Verify at owner scope

Test policy and behavior end-to-end at owner scope: cancellation, recovery, navigation,
localization, accessibility, and error mapping when applicable. Prefer Swift Testing for Swift
unit/integration tests unless platform constraints require XCTest.

When evaluating a state merge, characterize both candidates across the accepted event alphabet and
verify semantic output selection, next-state paths, invariants, and recovery—not only their projected
UI. Include a negative proof when the merged payload could encode an invalid combination or when a
conditional dispatcher would recreate the former alternatives.

For multi-operation outputs, prove required ordering and safe overlap at the business boundary,
verify aggregate failure/result mapping, and verify cancellation of structured child tasks. Do not
couple tests to one event per internal function when the machine contract has one aggregate outcome.

### 7. Converge with concrete evidence

Format touched Swift files only. Run narrowest proving checks first, then expand by risk. Separate
required, blocked, skipped, and not-run checks explicitly. Reconstruct changed paths, rerun checks
after remediations, and rerun before final handoff.

## Verification handoff

Return:

- summary of implemented requirements by owner;
- changed files and public/dependency changes;
- commands run and validation outcomes;
- open blockers and residual risks;
- cold-audit result;
- `COMPLEXITY-DELTA`: material concepts introduced or removed and their evidence;
- `SUBTRACTIVE-PASS`: what was merged, kept explicit, localized, deleted, or deliberately avoided;
- `ENVELOPE-DEVIATIONS`: `NONE` or the exact required escalation.

If incomplete, distinguish an architecture contradiction from a user/authority/external-state
blocker and route it through the repository lifecycle instead of inventing a `needs_input` status.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. If applicable repository guidance
defines a complete local handoff schema, transition table, validation contract, and correction
routing, use that contract as the sole handoff-format authority and do not load the generic reference
merely to merge duplicate instructions. Repository-local handoff rules may add project fields,
limits, or routes, but they do not redefine this skill's reusable Developer doctrine.

Otherwise read and follow the [Swift handoff contract](references/handoff-contract.md) before
emitting exactly one `SWIFT-HANDOFF/1` block. Put the three implementation complexity entries where
the complete local contract requires them, or in `CURRENT-STATE` when using the generic contract.

- Completed implementation routes `READY` to `SWIFT_REVIEWER`.
- An architecture contradiction routes `CHANGES_REQUIRED` to `SWIFT_ARCHITECT`.
- Missing user authority or external state routes `BLOCKED` to `ROOT`.
- For direct work outside a lifecycle, return the normal implementation and verification report.
- For repository-classified `TRIVIAL` work, return the normal report without a handoff; the root
  then loads `swift-reviewer` for the required focused self-review.
