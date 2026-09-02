---
name: swift-developer
description: Implement and refactor production Swift 6+/SwiftUI within settled ownership and module boundaries. Use for feature implementation, concurrency-safe effects, SwiftStateMachine routes, system surfaces, accessibility/localization, debugging, profiling, tests, and safe refactors. Use swift-architect first when ownership, dependency direction, public API, or workflow topology is unsettled; use swift-reviewer for independent assessment.
---

# Swift Developer

<!-- swift-suite:ROLE-DEVELOPER -->
<!-- swift-suite:DEV-SPECIALIST-OVERLAY -->

Own implementation and verification. Consume the available architecture contract and return
executable evidence. Never self-approve, and never redesign unsettled architecture.

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

Tests protect observable behavior, named invariants, public contracts, and reproduced regressions.
They must not require extra production topology solely so each private execution phase can be
asserted independently.

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
| Inter-agent lifecycle transition | [Swift handoff contract](references/handoff-contract.md) |
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

A no-event output remains runtime-owned and cancellable. Never create a detached or unstructured
`Task` to simulate fire-and-forget. Keep non-interleavable intermediate results local to one output
or coordinator and emit only the smallest semantic result needed by the machine.

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

Before final validation and handoff, review the implementation with deletion and collapse as the
objective:

- merge states with equivalent legal inputs, UI projection, lifetime, cancellation, recovery, and
  external outcome;
- move non-interleavable execution phases into local structured control flow;
- collapse internal result events into the smallest semantic outcome;
- remove forwarding wrappers, provider chains, and one-implementation protocols without a
  consumer-owned boundary;
- remove duplicate validation, retry, correlation, or recovery policy already guaranteed by an
  authoritative owner;
- remove speculative extension points, configuration, and implementation-shaped tests;
- keep named safety, privacy, data-integrity, accessibility, lifecycle, and platform invariants.

Escalate when simplification would contradict a binding architecture decision. Do not preserve an
unearned mechanism merely because tests already encode its private topology; update those tests to
protect behavior and invariants.

### 6. Verify at owner scope

Test policy and behavior end-to-end at owner scope: cancellation, recovery, navigation,
localization, accessibility, and error mapping when applicable. Prefer Swift Testing for Swift
unit/integration tests unless platform constraints require XCTest.

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
- `SUBTRACTIVE-PASS`: what was merged, localized, deleted, or deliberately avoided;
- `ENVELOPE-DEVIATIONS`: `NONE` or the exact required escalation.

If incomplete, distinguish an architecture contradiction from a user/authority/external-state
blocker and route it through the repository lifecycle instead of inventing a `needs_input` status.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. Read and follow the
[Swift handoff contract](references/handoff-contract.md), plus any stricter repository-local
contract, before emitting exactly one `SWIFT-HANDOFF/1` block. Put the three implementation
complexity entries in `CURRENT-STATE` unless a stricter repository contract places them elsewhere.

- Completed implementation routes `READY` to `SWIFT_REVIEWER`.
- An architecture contradiction routes `CHANGES_REQUIRED` to `SWIFT_ARCHITECT`.
- Missing user authority or external state routes `BLOCKED` to `ROOT`.
- For direct work outside a lifecycle, return the normal implementation and verification report.
- For repository-classified `TRIVIAL` work, return the normal report without a handoff; the root
  then loads `swift-reviewer` for the required focused self-review.
