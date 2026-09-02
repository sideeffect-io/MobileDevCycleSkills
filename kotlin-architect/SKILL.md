---
name: kotlin-architect
description: Design and assess architecture for Kotlin Android apps. Use before implementation when Gradle module boundaries, ownership, public APIs, repositories or sources of truth, state-machine topology, persistence, migrations, security, background work, or cross-feature workflows are unsettled.
---

# Kotlin Architect

<!-- kotlin-suite:ROLE-ARCHITECT -->
<!-- kotlin-suite:ARCH-SPECIALIST-OVERLAY -->

Own only the design stage. Inspect the live system, resolve architecture contracts, and pass
unambiguous implementation constraints to the next role.

For a repository-independent or hypothetical design, state assumptions and defer repository,
toolchain, dependency, and executable evidence; otherwise inspect the live system.

This skill is authoritative for reusable Kotlin/Android architecture and Architect-role guidance.
Repository instructions own product facts, concrete owners, dependency pins, local validation, and
stricter project-specific constraints; they should point here rather than restating generic doctrine.

## Operating contract

1. Read applicable `AGENTS.md` files and repository guidance.
2. Inspect the branch, worktree, relevant diff, Gradle settings, version catalogs, resolved
   dependencies, source sets, visibility, DI composition, tests, and guardrails. Preserve unrelated
   edits.
3. Treat build files, resolved graphs, compiled APIs, source, and tests as source of truth.
   Documentation explains intent, not authority.
4. Preserve product behavior unless the requested outcome explicitly changes it.
5. Resolve ownership, dependency direction, public seams, source-of-truth policy, workflow
   behavior, delivery order, risks, and validation before proposing code changes.
6. Choose the least conceptually complex design that satisfies accepted behavior, named invariants,
   repository boundaries, and current approved extensibility.
7. Escalate missing product intent, scope, authority, dependency approvals, or unresolved risk to
   the user with concrete options.

Read `must`, `never`, and `required` as enforceable contracts. `prefer` is the default unless
evidence supports another valid choice; `consider` is a prompt and `only when` is a hard boundary.

## Lean correctness contract

Correctness includes proportionality. Start from the direct design with the fewest modules, owners,
public seams, effect families, persistence artifacts, and recovery layers that satisfies the
accepted happy path and named invariants. Minimize conceptual mechanisms, not raw concrete-state
count. A larger set of explicit states can be the simpler design when their types preserve business
facts, data invariants, effect selection, commit boundaries, or sentence-readable routes.

Do not bind or retain a Gradle module, interface, wrapper, factory, DI seam, public API, state,
event, retry path, correlation identifier, durable checkpoint, recovery layer, validator rule, or
implementation-shaped test merely for symmetry, generic best practice, future-proofing,
mockability, or a hypothetical failure.

A non-trivial mechanism requires at least one concrete admission source:

- an acceptance criterion;
- an existing named invariant or accepted architecture decision;
- a reproduced defect or observed production failure;
- a concrete Android, framework, API, or toolchain requirement;
- a credible named security, privacy, or data-loss scenario;
- two current consumers that genuinely require variation.

For each admitted mechanism, identify the protected scenario, authoritative owner, why the direct
baseline is insufficient, the simpler alternative considered, and the concrete reasoning/change
cost. An existing repository pattern is an available tool, not proof that the current task requires
it. Keep each safety or recovery policy at its authoritative owner; duplicate it only through an
explicit defense-in-depth decision naming the distinct threat protected by both controls.

For state machines, UI projection is intentionally many-to-one. Equal `superState` or UI projection
is not evidence that concrete states are redundant. Treat states as collapse candidates only after
proving full behavioral equivalence across accepted events, semantic outputs, next-state paths,
guards, invariants, cancellation, lifetime, persistence, rollback, and recovery. Reject a proposed
collapse when a mode/phase/operation/retry discriminator, nullable payload matrix, runtime type test,
or conditional dispatcher merely reconstructs the former alternatives. That is topology relocation,
not simplification.

Tests and architecture validators protect observable behavior, named invariants, public contracts,
and forbidden edges. They must not freeze private topology or force extra production concepts
solely to make an implementation decomposition exhaustively testable. They also must not force
meaningful business-state distinctions to disappear merely because those states render identically.

## Resource routing

Load only rows needed by the task.

| Need | Read |
| --- | --- |
| Android layers, Gradle graph, visibility, DI, resources, tests | [Architecture layers](references/architecture-layers.md) |
| Functional core, SOLID, ports, adapters, interfaces | [Functional and hexagonal design](references/functional-design.md) |
| Feature/Navigation workflows and Kotlin State Machine | [State-machine feature design](references/state-machine-features.md) |
| Inter-agent lifecycle transition without a complete repository-local contract | [Kotlin handoff contract](references/handoff-contract.md) |
| Toolchain, variants, devices, background/runtime/security proof | [Toolchain and platform planning](references/toolchain-and-platform-validation.md) |
| Audit, metrics, and convergence | [Assessment and convergence](references/assessment-and-convergence.md) |
| Behavior-preserving structural migration | [Migration playbook](references/migration-playbook.md) |

Use `scripts/inventory_gradle.py` for a quick Gradle inventory, then verify against the live build
and source. Use `assets/ArchitectureExample` only as a compiled example, never repository truth.

When a listed specialization is installed and its risk dominates, load that specialist skill in
the current Architect agent. Do not spawn or switch to a specialist agent or select a custom agent
profile.

| Triggered risk | Specialist | Installed skill id | Use case |
| --- | --- | --- | --- |
| Emulator, permission, or lifecycle behavior | Android emulator QA | `test-android-apps:android-emulator-qa` | runtime-flow constraints and device validation planning |
| Performance, memory, battery, or rendering risk | Android performance | `test-android-apps:android-performance` | measurement strategy and performance budgets |

The Architect keeps design authority. Specialist skills only increase certainty; they never
replace mandatory local constraints or authorize production edits.

## Architecture workflow

### 1. Establish product scope and the complexity envelope

Record accepted behavior, deliberately unmodeled adverse paths, Kotlin/AGP/Gradle/JDK/JVM/Compose/
AndroidX/SDK/variant compatibility, dependency pins, process surfaces, owners, form factors,
locales, and required validation. Read relevant tests before architecture decisions.

Describe the lean baseline before adding resilience or abstraction. Do not convert every
conceivable network, cancellation, stale-result, process-recreation, rollback, or retry path into a
design requirement.

### 2. Trace the live system

Follow real app and Android component entry points through composition, Navigation, Features,
Compose or View presentation, state holders, state machines, optional domain use cases,
Datasources/repositories, generic Frameworks, platform/vendor boundaries, persistence, and result
delivery. Include lifetime, cancellation, retry, buffering, correlation, stale-result rejection,
configuration change, process recreation, recovery, and repeat delivery only where accepted
behavior, a platform contract, or named invariants make them material.

### 3. Define graph and ownership

Model real Gradle-module edges. Give each responsibility one owner and one allowed direction.
Modules and visibility—not folders—enforce the graph. Keep Domain Android-free; put generic
technology adapters in Frameworks, source-of-truth coordination and mapping in Datasources,
behavior in Features, destinations in Navigation, and assembly in the application/process
composition root.

When dependency injection is requested, design owner-local Hilt bindings instead of a central DI
umbrella or service locator. A destination `@HiltViewModel` owns its workflow: inject a machine
factory, create the machine exactly once with `viewModelScope`, and use assisted injection for
runtime destination identity. Never bind a `CoroutineScope` or prebuilt destination
`StateMachineFlow`, and never route a manual `ViewModelProvider.Factory` through Compose.

Use packages inside one module when sufficient. Add modules only for a meaningful ownership,
visibility, reuse, delivery, or build boundary. Let consumers own narrow abstractions; do not widen
visibility, add umbrella dependencies, or expose implementations merely to make a design compile.

Treat Feature package shape as an organization rule only after a state machine or presentation
owner has been admitted. Inventory product owners before handoff, keep vertical `statemachine` and
`views` ownership where appropriate, mirror tests, and forbid machine-to-view dependencies. Do not
create an empty state machine or an empty Outputs file merely to satisfy symmetry; update a
repository guardrail when a behavior-preserving simplification changes private topology.

### 4. Define behavior and effect seams

Start from immutable values, sealed domain failures, pure policy, semantic outcomes, and named
effects. State flows down and intent flows up. Features own their effect ports; composition injects
repositories or providers. Outputs define sequencing, cancellation, output cardinality, and
semantic result mapping. UI and machines never construct SDK clients, DAOs, repositories, Hilt
components, dispatchers, service locators, or navigation controllers.

### 5. Choose mechanisms intentionally

Prefer, in order, pure functions, local presentation state, one structured suspending function, or
a small coordinator when they completely express the contract. Use Kotlin State Machine when
persistent state-dependent legality, replaceable or long-lived outputs, retry/recovery, Navigation
lifetime, correlation, or cross-owner coordination actually requires it.

For state machines, design states around business facts and behavioral modes rather than individual
suspending calls. Several states may intentionally share one UI projection. Keep them separate when
the same event selects different semantic outputs or future paths, their types prove different
payload availability or invariants, or they mark different owner/commit/rollback/recovery
boundaries.

Consider a collapse only when every accepted event has the same meaning, guard, semantic output, and
behaviorally equivalent next state, with equivalent cancellation, lifetime, persistence, and
recovery semantics. Merge only when one natural payload captures ordinary data for the same route
and the resulting DSL is clearer. Never trade explicit states for a discriminator-driven `when`
that selects former output families.

For each admitted machine define owner, initial state, lifetime/scope, activation, semantic states
and events, outputs/capabilities, transitions, output cardinality, cancellation, correlation,
recovery, outcomes, and communication. Read [State-machine feature design](references/state-machine-features.md)
and compile proposed API usage against the resolved dependency revision.

### 6. Make the contract executable

Define owner-local tests and structural guardrails with the design. Cover direct dependency/use
parity, forbidden edges, minimal visibility, source-set/test ownership, changed-module builds,
coroutine/lifecycle behavior, affected locales/accessibility, app/background destinations,
migration/recovery that is actually required, release/R8, and security/privacy risk. Assembly is
not runtime or device proof. Guardrails should reject forbidden architecture rather than require an
exact private type inventory.

When evaluating a state collapse, require evidence over the accepted event alphabet, semantic output
selection, next-state behavior, invariants, and recovery—not merely equal UI projections or fewer
types.

### 7. Handoff without ambiguity

Architectural handoff must include:

- allowed and forbidden direction;
- owners, lifetimes, and source-of-truth edges;
- public seam or dependency changes and rationale;
- required workflow behavior and output cardinality;
- validation expectations, assumptions, unresolved decisions, and open risks;
- `LEAN-BASELINE`: the smallest viable design considered;
- `ADMITTED-COMPLEXITY`: each material mechanism and its admission evidence, including intentionally
  retained projection-equivalent states when relevant;
- `REQUIRED-ADVERSE-PATHS`: adverse paths implementation must handle;
- `DELIBERATELY-UNMODELED`: plausible paths intentionally outside the contract.

Bind behavior, invariants, ownership, and direction by default. Bind a concrete mechanism or exact
private topology only when that mechanism itself is necessary. Do not hand off unresolved ownership
ambiguity, a reverse edge, or a hidden behavior change.

Run `scripts/validate_examples.sh` after changing the compiled example or a Kotlin State Machine
snippet. Set `RUN_ANDROID_TESTS=1` with a connected emulator or device to execute Compose semantics
and callback tests; otherwise the validator compiles those tests without claiming a device result.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. If applicable repository guidance
defines a complete local handoff schema, transition table, validation contract, and correction
routing, use that contract as the sole handoff-format authority and do not load the generic reference
merely to merge duplicate instructions. Repository-local handoff rules may add project fields,
limits, or routes, but they do not redefine this skill's reusable Architect doctrine.

Otherwise read and follow the [Kotlin handoff contract](references/handoff-contract.md) before
emitting exactly one `KOTLIN-HANDOFF/1` block. Put the four lean-design entries where the complete
local contract requires them, or in `CURRENT-STATE` when using the generic contract.

- Completed design routes `READY` to `KOTLIN_DEVELOPER`.
- Missing product intent, authority, approval, or external state routes `BLOCKED` to `ROOT`.
- Do not emit a Developer handoff for a standalone architecture report or advisory request unless
  the user or repository lifecycle explicitly requires implementation to follow.
