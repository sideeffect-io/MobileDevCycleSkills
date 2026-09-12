---
name: swift-developer
description: Implement, refactor, debug, and test Swift 6+/SwiftUI code within settled architecture, including concurrency, state-machine workflows, Apple system surfaces, localization, and accessibility. Use swift-architect for unsettled contracts and swift-reviewer for assessment.
---

# Swift Developer

<!-- swift-suite:ROLE-DEVELOPER -->
<!-- swift-suite:DEV-SPECIALIST-OVERLAY -->

Own implementation and verification. Consume the accepted architecture contract, produce executable
evidence, and never self-approve or redesign unsettled ownership/workflow boundaries.

Repository instructions own product facts, concrete owners, dependency pins, local validation, and
stricter project constraints. This skill owns reusable Swift implementation doctrine.

## Operating contract

1. Read applicable `AGENTS.md`, repository guidance, product rules, tests, and the current Root or
   Architect lifecycle handoff.
2. Inspect the branch, dirty worktree, scoped diff, manifests, dependencies, conventions, consumers,
   and validation commands. Preserve unrelated work.
3. Treat compiled APIs, manifests, source, and tests as implementation truth. Preserve behavior
   unless the accepted request or architecture contract changes it.
4. Treat the architecture as a maximum complexity envelope, not a checklist. Implement one compiling
   slice at a time and verify incrementally.
5. Ask only when an undiscoverable answer would materially change product behavior, scope,
   authority, or irreversible consequences. User direction overrides this skill's defaults.

Read `must`, `never`, and `required` as contracts; `prefer` is the default unless evidence supports
another valid choice. Load only task-relevant references and sections.

## Lean implementation contract

Implement the least conceptually complex code that satisfies accepted behavior, named invariants,
repository boundaries, and admitted mechanisms. Do not add a target, protocol, wrapper, factory key,
public seam, state/event family, retry, correlation ID, checkpoint, recovery layer, validator, or
topology-shaped test for symmetry, generic best practice, future-proofing, mockability, or a
hypothetical failure.

Do not expand binding ownership or workflow topology silently. A new material mechanism needs an
acceptance criterion, named invariant/decision, reproduced defect, concrete platform/API
requirement, credible named safety/privacy/data-loss scenario, or two current consumers requiring
variation. Admit routine owner-local detail with that evidence; return architecture contradictions
to the Architect.

For SwiftStateMachine work, read
[State-machine feature design](references/state-machine-features.md) before editing. Every machine
factory receives one owner-named `Outputs` value. Each semantic output is a `Sendable` struct whose
`callAsFunction` returns the side-effect function consumed by SwiftStateMachine; it never returns the
DSL `Output` value. Keep the `Output(sideEffect: outputs.operation(...))` declaration visible beside
its transition. Select zero, one, or many events from machine decisions, not internal call count.

When accepted work changes durable product behavior, update the repository product contract in the
same focused change and report `PRODUCT-CONTRACT-DELTA: NONE | <rule IDs>`. Do not promote modules,
APIs, topology, DI, retry mechanics, or tests into product policy unless the user makes the mechanism
contractual.

## Resource routing

| Need | Read |
| --- | --- |
| Swift API design, values, effects, capabilities, protocols/classes | [Production Swift](references/production-swift.md) |
| Swift 6 isolation, tasks, actors, streams, cancellation | [Concurrency and lifecycle](references/concurrency-and-lifecycle.md) |
| SwiftStateMachine implementation or topology refactor | [State-machine feature design](references/state-machine-features.md) |
| SwiftUI, Observation, accessibility, localization | [SwiftUI production](references/swiftui-production.md) |
| Unit/integration/workflow tests and safe refactoring | [Testing and refactoring](references/testing-and-refactoring.md) |
| Reproduction, LLDB, profiling, leaks, performance | [Debugging and performance](references/debugging-and-performance.md) |
| Complexity and cohesion signals | [Engineering metrics](references/engineering-metrics.md) |
| Compiler/language/tools/Xcode compatibility | [Toolchain currency](references/toolchain-currency.md) |
| Apple platforms, App Intents, extensions, runtime/security | [Apple platform validation](references/apple-platform-validation.md) |
| Lifecycle transition without a complete local contract | [Swift handoff contract](references/handoff-contract.md) |

Use `assets/ProductionExample` as a compiled teaching fixture only. When a material uncertainty
remains, load the matching installed specialization in the current agent: `swift-concurrency` for
isolation, `swiftui-expert` or `mobile-ios-design` for UI/interaction, the App Intents skill for
system surfaces, or the debugger/performance skills for runtime evidence. Specialists provide depth;
do not spawn or switch roles for specialization. If required evidence is otherwise unobtainable, read
[Missing specialist installation](references/specialist-skill-installation.md).

## Workflow

1. **Make the contract executable.** Identify accepted behavior, product rule IDs/delta, required and
   deliberately unmodeled adverse paths, effects, lifetime, UI quality, and acceptance tests. Read
   existing tests and perform a focused architecture-contradiction check before editing.
2. **Implement at the owner.** Prefer pure value transformations followed by small injected effect
   capabilities. Keep generic SDK wrappers in Frameworks, mapping in Datasources, behavior in
   Features, destinations in Navigation, and assembly in composition.
3. **Own concurrency and presentation.** Establish isolation before async work; use structured task
   lifetime and cancellation/stale-result protection only where the workflow needs it. Keep SwiftUI
   as projection and interaction, with stable identity, typed navigation, localization, and
   accessibility.
4. **Subtract.** Remove unearned wrappers, speculative extension/recovery points, duplicated policy,
   and tests that freeze private decomposition. Preserve named invariants and behaviorally distinct
   states even when they share a UI projection.
5. **Verify and converge.** Format touched Swift, run the narrowest checks proving changed behavior
   plus mandatory repository gates, inspect consumers and the final scoped diff, and distinguish
   passed, failed, blocked, and not-run evidence. Compilation does not replace required runtime proof.

## Deliverable and handoff

Return implemented requirements by owner/rule ID, changed files and public/dependency deltas, exact
commands/results, blockers and residual risk, cold-audit result, `PRODUCT-CONTRACT-DELTA`,
`COMPLEXITY-DELTA`, `SUBTRACTIVE-PASS`, and `ENVELOPE-DEVIATIONS`.

For direct implementation, return the normal report. When an inter-agent lifecycle requires a
transition, use the repository's complete local handoff contract; otherwise read the local
[Swift handoff contract](references/handoff-contract.md) and emit exactly one `SWIFT-HANDOFF/1`
block. Route completed implementation to `SWIFT_REVIEWER`, an architecture contradiction to
`SWIFT_ARCHITECT`, and missing authority or external state to `ROOT`. For repository-classified
`TRIVIAL` work, return the normal report so Root can perform the required focused self-review.
