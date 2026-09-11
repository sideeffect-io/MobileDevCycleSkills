---
name: swift-developer
description: Implement, refactor, debug, and test Swift 6+/SwiftUI within settled ownership and workflow boundaries. Use swift-architect for unresolved architecture and swift-reviewer for review.
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

Read `must`, `never`, and `required` as contracts; `prefer` is an evidenced default; `consider` is
optional.

Use the request and existing authorization to resolve routine implementation and validation choices.
Ask only when an undiscoverable answer would materially change product behavior, scope, authority,
or irreversible consequences. Continue independent authorized work while that decision is pending.
In a lifecycle, route the blocked slice to Root; do not turn a preference or a recoverable tool error
into a permission gate. User direction takes precedence over this skill's defaults.

Load only task-relevant references and sections; a routing table is an index, not a checklist.
Reuse current evidence and report concise decisions, findings, and proof without repeating the
request, skill doctrine, source, or full logs. High reasoning effort does not justify broader scope.

## Lean implementation contract

Implement the least conceptually complex code that satisfies accepted behavior, named invariants,
repository boundaries, and the Architect's admitted mechanisms. Do not add a target, protocol,
wrapper, factory/environment key, public seam, state, event, retry path, correlation identifier,
durable checkpoint, recovery layer, validator rule, or implementation-shaped test merely for
symmetry, generic best practice, future-proofing, mockability, or a hypothetical failure.

Do not expand the architecture envelope silently. A material mechanism not present in the handoff
requires one of the same admission sources the Architect would need: acceptance, named invariant or
architecture decision, reproduced defect, concrete platform/API requirement, credible named
security/privacy/data-loss scenario, or two current consumers requiring variation. Admit routine
owner-local details with that evidence; route changes to binding ownership or workflow topology to
the Architect.

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

For every behavior-owning SwiftStateMachine feature or navigation owner, preserve this four-file
machine layout: `StateMachine/States.swift` holds all concrete states and the `SuperState` projection;
`StateMachine/Events.swift` holds all concrete events and the super-event marker;
`StateMachine/Outputs.swift` holds output definitions, effect bodies, and output cancellation
policies; and `StateMachine/StateMachine.swift` holds the machine alias/factory, all
`When`/`On`/`Transition` routes, and named guards. Input, Outcome, and capability contracts may
stay in a neighboring contract file. Do not add empty machine files to stateless features. Prefer
an immutable struct projection when SwiftUI can consume common loading, failure, control, or form
properties directly. Keep a semantic enum when it represents genuinely exclusive content or
destinations with required payloads; do not mechanically wrap an enum and retain the same switch
tree.

## Product-contract maintenance

When accepted work adds, changes, or supersedes a durable product decision, update the repository's
product contract in the same focused change. Preserve stable rule IDs and shared meanings across
in-scope repositories; record an explicit synchronization follow-up for an unavailable or out-of-scope
counterpart. Report `PRODUCT-CONTRACT-DELTA: NONE` or the affected IDs.

Document observable outcomes and durable policy, not modules, APIs, state/event topology, DI, retry
mechanics, or tests unless the user makes the mechanism contractual. Technical sidecars own technical
deltas and point to rule IDs. Route an unaccepted product choice to Root before implementing it.

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

Identify accepted behavior, affected product rule IDs, the product-contract delta or `NONE`,
admitted adverse paths, deliberately unmodeled paths, effects, cancellation/lifetime,
accessibility/localization, performance risk, and acceptance tests. Read tests before editing; add
characterization tests when preserved behavior is unclear.

Before editing, run a focused architecture-contradiction check covering ownership, dependencies,
public APIs, workflow seams, the admitted-complexity ledger, and any product-contract delta. Return
contradictions to the Architect rather than inventing new architecture or product policy.

### 2. Implement with strong boundaries

Prefer pure value transformations first, then effectful integrations through small injected
capabilities. Keep generic SDK wrappers in Frameworks, mapping in Datasources, behavior in Features,
and assembly in composition. Add abstractions only at a real ownership or current variation seam.

### 3. Concurrency and workflow lifetime

Set isolation before adding async work. Use structured tasks, cancellation propagation, ownership of
stateful resources, and stale-result guards only where the accepted workflow can actually replace or
outlive work.

For machine work, read [State-machine implementation](references/state-machine-features.md) before editing.
Map the changed routes to business rules or evidenced technical constraints. Choose zero, one, or
many semantic output events from decisions the machine needs, independently of internal call count.
Keep one cohesive business effect inside one output when intermediate results change no machine
policy. That output owns structured child work, sequencing, cancellation, and aggregate failures;
it never launches unowned work. Preserve behaviorally distinct states despite equal UI projections.

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
| App Intents surfaces | App Intents | `build-ios-apps:ios-app-intents` | intent definitions and execution |
| Runtime debugging or leak/CPU work | debugger/perf specialist | `build-ios-apps:ios-debugger-agent`, `build-ios-apps:ios-ettrace-performance`, `build-ios-apps:ios-memgraph-leaks` | live repro and investigation |

If a listed skill is unavailable, use equivalent installed tools, source, or official documentation
when they can satisfy the contract. Read [Missing specialist installation](references/specialist-skill-installation.md)
only if required evidence is otherwise unobtainable or the user requests installation.

### 5. Perform the subtractive pass

Before handoff, remove unearned wrappers, speculative extension points, duplicated authoritative
policy, and tests that freeze private decomposition. For machine work, use the focused reference
to check state/event growth, cohesive outputs, full behavioral equivalence, and hidden dispatch.
Keep named invariants and meaningful state distinctions; measure total reasoning cost, not counts.
Do not keep an unnecessary mechanism merely because a test encodes it. Update topology-shaped tests
and guardrails with a behavior-preserving simplification, and escalate only a binding contradiction.

### 6. Verify at owner scope

Test product rules, policy, and behavior end-to-end at owner scope: cancellation, recovery,
navigation, localization, accessibility, and error mapping when applicable. Prefer Swift Testing for
Swift unit/integration tests unless platform constraints require XCTest.

For machine changes, apply the focused reference's behavioral and output-boundary tests.

### 7. Converge with concrete evidence

Format touched Swift files with repository tooling. Run the narrowest checks that prove the
changed behavior plus mandatory repository gates. Once they pass, broaden or repeat only for new
changes, failures, invalidated evidence, or a concrete unresolved risk. Do not rerun an unchanged
passing suite just because a handoff is due, or add tests for low-impact edits that mirror the code.

Inspect the final scoped diff and affected consumers, confirm product-contract maintenance, and
distinguish passed, failed, blocked, and not-run checks with exact evidence. Compilation proves
compilation; it does not replace required runtime evidence.

## Verification handoff

Return:

- summary of implemented requirements by owner and applicable product rule IDs;
- `PRODUCT-CONTRACT-DELTA`: `NONE` or rule IDs added, changed, or superseded;
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
emitting exactly one `SWIFT-HANDOFF/1` block. Put the implementation complexity entries and
`PRODUCT-CONTRACT-DELTA` where the complete local contract requires them, or in `CURRENT-STATE` when
using the generic contract.

- Completed implementation routes `READY` to `SWIFT_REVIEWER`.
- An architecture contradiction routes `CHANGES_REQUIRED` to `SWIFT_ARCHITECT`.
- Missing user authority or external state routes `BLOCKED` to `ROOT`.
- For direct work outside a lifecycle, return the normal implementation and verification report.
- For repository-classified `TRIVIAL` work, return the normal report without a handoff; the root
  then loads `swift-reviewer` for the required focused self-review.
