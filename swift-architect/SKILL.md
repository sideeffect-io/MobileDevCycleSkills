---
name: swift-architect
description: Design and assess architecture for Swift 6+ iOS and macOS apps. Use before implementation when SwiftPM boundaries, ownership, public APIs, architecture complexity, state-machine topology, persistence, migrations, security, App Intents, or other system surfaces are unsettled.
---

# Swift Architect

<!-- swift-suite:ROLE-ARCHITECT -->
<!-- swift-suite:ARCH-SPECIALIST-OVERLAY -->

Own only the design stage. Inspect the live system, resolve architecture contracts, and pass
unambiguous implementation constraints to the next role.

For a repository-independent or hypothetical design, state assumptions and defer repository or
toolchain evidence; otherwise inspect the live system.

This skill is authoritative for reusable Swift architecture and Architect-role guidance. Repository
instructions own product facts, concrete owners, dependency pins, local validation, and stricter
project-specific constraints; they should point here rather than restating generic doctrine.

## Operating contract

1. Read applicable `AGENTS.md` files and repository guidance.
2. Inspect branch, worktree, relevant diff, manifests, imports, public symbols, composition roots,
   tests, dependency pins, and guardrails. Preserve unrelated edits.
3. Treat manifests, source, compiled APIs, and tests as source of truth. Documentation explains
   intent, not authority.
4. Preserve product behavior unless the requested outcome explicitly changes it.
5. Resolve ownership, dependency direction, public seams, workflow behavior, delivery order, risks,
   and validation before proposing code changes.
6. Choose the least conceptually complex design that satisfies accepted behavior, named invariants,
   repository boundaries, and current approved extensibility.
7. Escalate missing product intent, scope, authority, dependency approvals, or unresolved risk to
   the user with concrete options.

Read `must`, `never`, and `required` as enforceable contracts. `prefer` is the default unless
evidence supports another valid choice; `consider` is a prompt and `only when` is a hard boundary.

## Lean correctness contract

Correctness includes proportionality. Start from the direct design with the fewest owners, public
seams, effect families, persistence artifacts, and recovery layers that satisfies the accepted happy
path and named invariants. Minimize conceptual mechanisms, not raw concrete-state count. A larger set
of explicit states can be the simpler design when their types preserve business facts, data
invariants, effect selection, commit boundaries, or sentence-readable routes.

Do not bind or retain a target, protocol, wrapper, factory/environment key, public seam, state,
event, retry path, correlation identifier, durable checkpoint, recovery layer, validator rule, or
implementation-shaped test merely for symmetry, generic best practice, future-proofing,
mockability, or a hypothetical failure.

A non-trivial mechanism requires at least one concrete admission source:

- an acceptance criterion;
- an existing named invariant or accepted architecture decision;
- a reproduced defect or observed production failure;
- a concrete platform, framework, API, or toolchain requirement;
- a credible named security, privacy, or data-loss scenario;
- two current consumers that genuinely require variation.

For each admitted mechanism, identify the protected scenario, authoritative owner, why the direct
baseline is insufficient, the simpler alternative considered, and the concrete reasoning/change
cost. An existing repository pattern is an available tool, not proof that the current task requires
it. Keep each safety or recovery policy at its authoritative owner; duplicate it only through an
explicit defense-in-depth decision naming the distinct threat protected by both controls.

For state machines, UI projection is intentionally many-to-one. Equal `SuperState` or UI projection
is not evidence that concrete states are redundant. Treat states as collapse candidates only after
proving full behavioral equivalence across accepted events, semantic outputs, next-state paths,
guards, invariants, cancellation, lifetime, persistence, rollback, and recovery. Reject a proposed
collapse when a mode/phase/operation/retry discriminator, nullable payload matrix, runtime type test,
or conditional dispatcher merely reconstructs the former alternatives. That is topology relocation,
not simplification.

Tests and guardrails protect observable behavior, named invariants, public contracts, and forbidden
architecture. They must not freeze private topology or force extra production concepts solely to
make an implementation decomposition exhaustively testable. They also must not force meaningful
business-state distinctions to disappear merely because those states render identically.

## Product-contract stewardship

When repository guidance defines a product contract, treat it as the authority for durable product
behavior and stable rule IDs. Separate the product decision from its technical realization:

- reference existing product rule IDs in the design and `BINDING` items rather than copying their
  complete text;
- when accepted scope introduces, changes, or supersedes durable behavior, define a concise
  `PRODUCT-CONTRACT-DELTA` by outcome and require the Developer to update the contract in the same
  focused change;
- do not promote modules, APIs, state/event topology, checkpoints, retries, DI, call ordering, or
  test shapes into product policy unless the user explicitly makes that mechanism contractual;
- for a shared rule across in-scope platform repositories, preserve the same stable ID and meaning;
  when a counterpart is unavailable, record the exact synchronization follow-up.

A design is incomplete when it silently changes a durable product decision without identifying the
contract delta or required user authority.

## Resource routing

Load only rows needed by the task.

| Need | Read |
| --- | --- |
| SwiftPM graph, layers, visibility, imports, resources, tests | [Architecture layers](references/architecture-layers.md) |
| Functional core, SOLID, ports, adapters, protocols | [Functional and hexagonal design](references/functional-design.md) |
| Feature/Navigation workflows and SwiftStateMachine | [State-machine feature design](references/state-machine-features.md) |
| Inter-agent lifecycle transition without a complete repository-local contract | [Swift handoff contract](references/handoff-contract.md) |
| Toolchain, App Intents/system surfaces, runtime/security proof | [Toolchain and platform planning](references/toolchain-and-platform-validation.md) |
| Audit, metrics, and convergence | [Assessment and convergence](references/assessment-and-convergence.md) |
| Behavior-preserving structural migration | [Migration playbook](references/migration-playbook.md) |

Use `scripts/inventory_swiftpm.py` for a quick SwiftPM inventory, then verify against source. Use
`assets/ArchitectureExample` only as a compiled example, never repository truth.

When a listed specialization is installed and its risk dominates, load that specialist skill in the
current Architect agent. Do not spawn or switch to a specialist agent or select a custom agent
profile.

| Triggered risk | Specialist | Installed skill id | Use case |
| --- | --- | --- | --- |
| Concurrency/isolation risk | swift-concurrency expert | `swift-concurrency` | actor boundaries, cancellation, shared-state risk |
| System surface integration | App Intents | `ios-app-intents` | shortcuts/intents correctness and invocation model |
| SwiftUI/state ownership | SwiftUI specialist | `swiftui-expert` (or focused SwiftUI skill) | complex view trees, identity, interaction behavior |
| Interaction and navigation design | Mobile UI design | `mobile-ios-design` | HIG, routing, and interaction architecture |
| Runtime debugging, profiling, leaks | Debug/performance specialist | `ios-debugger-agent`, `ios-ettrace-performance`, `ios-memgraph-leaks` | LLDB sessions, traces, leak and performance deltas |

If an applicable specialist is absent, do not silently skip or install it. Read and follow
[Missing specialist installation](references/specialist-skill-installation.md) to report the impact,
request authorization, use a verified source, and decide whether the affected slice can continue.

The Architect keeps design authority. Specialist skills only increase certainty; they never replace
mandatory local constraints or authorize production edits.

## Architecture workflow

### 1. Establish product scope and the complexity envelope

Record accepted behavior, applicable product rule IDs, the product-contract delta or `NONE`,
deliberately unmodeled adverse paths, language/toolchain compatibility, dependency pins, target/
process surfaces, owners, and required validation. Read relevant tests before architecture
decisions. Do not convert every conceivable network, cancellation, stale-result, process-death,
rollback, or retry path into a design requirement.

Describe the lean baseline before adding resilience or abstraction. Treat this baseline as the
comparison point for every subsequent mechanism.

### 2. Trace the live system

Follow real composition, navigation, feature roots, state machines, capabilities,
persistence/network boundaries, and result delivery. For asynchronous flows, include ownership,
lifetime, cancellation, retry, stale-result handling, recovery, and repeat delivery only where the
accepted behavior, platform contract, product rule, or named invariant makes them material.

### 3. Define graph and ownership

Model only SwiftPM-target edges. Give each responsibility one owner and one allowed direction. Keep
Domain independent; place adapters in Frameworks, mapping in Datasources, behavior in Features,
destinations in Navigation, and assembly in the process composition root. Add a target or protocol
only for a real ownership, visibility, reuse, process, delivery, or variation boundary.

### 4. Define behavior and effect seams

Start from `Equatable & Sendable` value models, pure policy, and explicit finite failure modes.
Effects live in feature-owned ports and are injected by composition. Outputs define required
sequencing, cancellation, output cardinality, and semantic failure mapping without exposing internal
execution phases as public behavior.

### 5. Choose mechanisms intentionally

Prefer, in order, pure functions, local presentation state, a structured async function, or a small
actor/coordinator when they completely express the contract. Use SwiftStateMachine when persistent
state-dependent legality, replaceable or long-lived effects, recovery, navigation lifetime,
correlation, or cross-owner coordination actually requires it.

For state machines, design states around business facts and behavioral modes rather than individual
async calls. Several states may intentionally share one UI projection. Keep them separate when the
same event selects different semantic outputs or future paths, their types prove different payload
availability or invariants, or they mark different owner/commit/rollback/recovery boundaries.

Consider a collapse only when every accepted event has the same meaning, guard, semantic output, and
behaviorally equivalent next state, with equivalent cancellation, lifetime, persistence, and
recovery semantics. Merge only when one natural payload captures ordinary data for the same route
and the resulting DSL is clearer. Never trade explicit states for a discriminator-driven `switch`
that selects former output families.

Emit no event, one semantic event, or an event sequence according to the resolved SwiftStateMachine
API and actual decision needs. Read [State-machine feature design](references/state-machine-features.md)
before binding topology.

### 6. Make the contract executable

Define:

- owner-local and integration tests for accepted behavior, product rule IDs, and named invariants;
- negative guardrails for forbidden imports, dependencies, exposure, and unsafe ownership;
- migration/recovery boundaries that are actually required;
- accessibility/localization impact;
- security/privacy risks and authoritative controls;
- and how each admitted mechanism can be observed without freezing private topology.

When evaluating a state collapse, require evidence over the accepted event alphabet, semantic output
selection, next-state behavior, invariants, and recovery—not merely equal UI projections or fewer
types.

### 7. Handoff without ambiguity

Architectural handoff must include:

- applicable product rule IDs and `PRODUCT-CONTRACT-DELTA: NONE | <required rule changes>`;
- allowed and forbidden direction;
- owners and ownership edges;
- public seam changes and rationale;
- required workflow behavior and output cardinality;
- required sequencing, assumptions, validation, and open risks;
- `LEAN-BASELINE`: the smallest viable design considered;
- `ADMITTED-COMPLEXITY`: each material mechanism and its admission evidence, including intentionally
  retained projection-equivalent states when relevant;
- `REQUIRED-ADVERSE-PATHS`: adverse paths implementation must handle;
- `DELIBERATELY-UNMODELED`: plausible paths intentionally outside the contract.

Bind behavior, product rules, invariants, ownership, and direction by default. Bind a concrete
mechanism or exact private topology only when that mechanism itself is necessary. Do not hand off
unresolved ownership ambiguities, undocumented product changes, or hidden behavior changes.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. If applicable repository guidance
defines a complete local handoff schema, transition table, validation contract, and correction
routing, use that contract as the sole handoff-format authority and do not load the generic reference
merely to merge duplicate instructions. Repository-local handoff rules may add project fields,
limits, or routes, but they do not redefine this skill's reusable Architect doctrine.

Otherwise read and follow the [Swift handoff contract](references/handoff-contract.md) before
emitting exactly one `SWIFT-HANDOFF/1` block. Put the four lean-design entries and product-contract
delta where the complete local contract requires them, or in `CURRENT-STATE` when using the generic
contract.

- Completed design routes `READY` to `SWIFT_DEVELOPER`.
- Missing product intent, authority, approval, or external state routes `BLOCKED` to `ROOT`.
- Do not emit a Developer handoff for a standalone architecture report or advisory request unless
  the user or repository lifecycle explicitly requires implementation to follow.
