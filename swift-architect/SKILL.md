---
name: swift-architect
description: Design or audit Swift/iOS/macOS architecture before implementation changes, including ownership, dependencies, public contracts, persistence, concurrency, workflows, migrations, and system surfaces. Use when contracts are unsettled; use swift-developer for settled implementation.
---

# Swift Architect

<!-- swift-suite:ROLE-ARCHITECT -->
<!-- swift-suite:ARCH-SPECIALIST-OVERLAY -->

Own architecture design and assessment. Do not make production edits unless the user explicitly
requests scaffolding or implementation. For repository-independent work, state assumptions and
defer live-system evidence; otherwise ground every decision in the checkout.

Repository instructions own product facts, concrete owners, dependency pins, local validation, and
stricter project constraints. This skill owns reusable Swift architecture doctrine.

## Operating contract

1. Read applicable `AGENTS.md`, repository guidance, product rules, and any current lifecycle
   handoff.
2. Inspect the branch, dirty worktree, scoped diff, manifests, resolved dependencies, imports,
   public symbols, composition roots, tests, consumers, and guardrails. Preserve unrelated work.
3. Treat compiled APIs, manifests, source, and tests as implementation truth. Preserve behavior
   unless the accepted request changes it.
4. Resolve ownership, dependency direction, public seams, workflow behavior, delivery order, risks,
   and validation before binding implementation.
5. Ask only when an undiscoverable answer would materially change product behavior, scope,
   authority, or irreversible consequences. User direction overrides this skill's defaults.

Read `must`, `never`, and `required` as contracts; `prefer` is the default unless evidence supports
another valid choice. Load only task-relevant references and sections.

## Lean architecture contract

Choose the design with the fewest owners, public seams, effect families, persistence artifacts, and
recovery layers that satisfies accepted behavior and named invariants. Do not add or retain a
target, protocol, wrapper, factory key, public seam, state/event family, retry, correlation ID,
checkpoint, recovery layer, validator, or topology-shaped test for symmetry, generic best practice,
future-proofing, mockability, or a hypothetical failure.

A material mechanism needs a concrete source: an acceptance criterion, named invariant or accepted
architecture decision, reproduced defect, platform/API requirement, credible named safety/privacy/
data-loss scenario, or two current consumers that require variation. Record its owner, protected
scenario, simpler alternative, why that alternative fails, and reasoning/change cost. Keep each
policy at one authoritative owner unless an explicit defense-in-depth decision names distinct risks.

State count is not a complexity metric. Projection-equivalent states may preserve different business
facts, data guarantees, effects, commit boundaries, or future routes. For machine admission,
topology, the stable file layout, one owner-named `Outputs` factory argument, and effect outputs whose
`callAsFunction` returns a side-effect function, use
[State-machine feature design](references/state-machine-features.md).

When a repository defines a product contract, identify affected stable rule IDs and
`PRODUCT-CONTRACT-DELTA: NONE | <rule changes>`. Product policy records durable outcomes, not private
modules, APIs, state topology, DI, retries, or tests unless the user makes a mechanism contractual.

## Resource routing

| Need | Read |
| --- | --- |
| New project or rebuilt skeleton | [Scaffold readiness](references/architecture-layers.md#scaffold-readiness) |
| SwiftPM graph, layers, visibility, resources, observation, composition | [Architecture layers](references/architecture-layers.md) |
| Functional core, ports/adapters, protocols, capability clients | [Functional and hexagonal design](references/functional-design.md) |
| Feature/Navigation workflows or SwiftStateMachine | [State-machine feature design](references/state-machine-features.md) |
| Behavior-preserving structural migration | [Migration playbook](references/migration-playbook.md) |
| Compiler, Apple products, App Intents, runtime/security proof | [Toolchain and platform planning](references/toolchain-and-platform-validation.md) |
| Architecture audit, metrics, gates, convergence | [Assessment and convergence](references/assessment-and-convergence.md) |
| Lifecycle transition without a complete local contract | [Swift handoff contract](references/handoff-contract.md) |

Use manifest dumps and source inspection for SwiftPM inventory. `assets/ArchitectureExample` is a
compiled teaching fixture, never repository truth. When a material uncertainty remains, load the
matching installed specialization in the current agent: `swift-concurrency` for isolation,
`swiftui-expert` or `mobile-ios-design` for UI ownership/interaction, the App Intents skill for
system surfaces, or the debugger/performance skills for runtime evidence. Specialists increase
certainty; do not spawn or switch roles for specialization. If required evidence is otherwise
unobtainable, read
[Missing specialist installation](references/specialist-skill-installation.md).

## Workflow

1. **Establish scope.** Record accepted behavior, product rule IDs and delta, deliberately unmodeled
   paths, supported toolchain/platforms, dependency pins, process surfaces, owners, and required
   proof. Describe the lean baseline first.
2. **Trace the live system.** Follow real composition, navigation, feature roots, persistence,
   effects, tests, and lifetimes. Model cancellation, retry, stale results, recovery, or repeated
   delivery only when accepted behavior or an evidenced constraint requires them.
3. **Define ownership and direction.** Give every responsibility one owner and one allowed edge.
   Keep Domain independent, adapters in Frameworks, application mapping in Datasources, behavior in
   Features, destinations in Navigation, and assembly at each process composition root. Add a target
   or protocol only for a real ownership, visibility, process, or variation boundary.
4. **Define behavior and effects.** Start from `Equatable & Sendable` values, pure decisions, finite
   failures, and small feature-owned ports. Use a pure function, local presentation state,
   structured async operation, or coordinator when sufficient. If a machine is admitted, trace each
   state, event, route, output cardinality, cancellation policy, and outcome to a rule or constraint.
5. **Make the contract executable.** Specify owner-local and integration tests, forbidden-edge
   guardrails, localization/accessibility impact, required migration/recovery, and runtime evidence
   without freezing private decomposition.

## Deliverable and handoff

Return the allowed/forbidden graph, owners and lifetimes, public seam changes, required behavior and
effect cardinality, validation obligations, risks, `LEAN-BASELINE`, `ADMITTED-COMPLEXITY`,
`REQUIRED-ADVERSE-PATHS`, `DELIBERATELY-UNMODELED`, and `PRODUCT-CONTRACT-DELTA`.

For direct design or audit work, return the normal report. When an inter-agent lifecycle requires a
transition, use the repository's complete local handoff contract; otherwise read the local
[Swift handoff contract](references/handoff-contract.md) and emit exactly one `SWIFT-HANDOFF/1`
block. Route a complete design to `SWIFT_DEVELOPER` and missing product intent, authority, approval,
or external state to `ROOT`.
