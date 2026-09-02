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
6. Escalate missing product intent, scope, authority, dependency approvals, or unresolved risk to
   the user with concrete options.

Read `must`, `never`, and `required` as enforceable contracts. `prefer` is the default unless
evidence supports another valid choice; `consider` is a prompt and `only when` is a hard boundary.

## Resource routing

Load only rows needed by the task.

| Need | Read |
| --- | --- |
| Android layers, Gradle graph, visibility, DI, resources, tests | [Architecture layers](references/architecture-layers.md) |
| Functional core, SOLID, ports, adapters, interfaces | [Functional and hexagonal design](references/functional-design.md) |
| Feature/Navigation workflows and Kotlin State Machine | [State-machine feature design](references/state-machine-features.md) |
| Inter-agent lifecycle transition | [Kotlin handoff contract](references/handoff-contract.md) |
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

### 1. Establish constraints and scope

Record Kotlin, AGP, Gradle, JDK/JVM, Compose, AndroidX, SDK and variant compatibility, dependency
pins, process surfaces, owners, supported form factors/locales, and required validation. Read
relevant tests before architecture decisions.

### 2. Trace the live system

Follow real app and Android component entry points through composition, Navigation, Features,
Compose or View presentation, state holders, state machines, optional domain use cases,
Datasources/repositories, generic Frameworks, platform/vendor boundaries, persistence, and result
delivery. Include ownership, lifetime, cancellation, retry, buffering, correlation, stale-result
rejection, configuration change, process recreation, recovery, and repeat delivery where relevant.

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

Treat Feature package shape as an ownership contract, not cosmetic organization. Inventory every
product feature and subfeature before handoff and enforce the vertical `statemachine` / `views`
layout in [Architecture layers](references/architecture-layers.md): canonical four-file machine
owners, one discoverable `RootScreen` source per Compose owner, stateless-owner exclusions,
owner-root public contracts, mirrored tests, and no machine-to-view dependency. Require an
executable package/path guardrail whenever the repository has architecture validation.

### 4. Define behavior and effect seams

Start from immutable values, sealed states and failures, pure policy, semantic outcomes, and named
effects. State flows down and intent flows up. Features own their effect ports; composition injects
repositories or providers. Outputs define sequencing, cancellation, and result-to-event mapping.
UI and machines never construct SDK clients, DAOs, repositories, Hilt components, dispatchers,
service locators, or navigation controllers.

### 5. Choose mechanism intentionally

Use pure functions or local presentation state for trivial behavior. Use Kotlin State Machine when
a workflow needs persistent legality, meaningful async effects, retry/recovery, cancellation,
Navigation lifetime, or cross-feature coordination. Resolve and inspect the exact dependency
revision before designing DSL code; compile proposed API usage against it.

For each in-scope machine define owner, initial state, lifetime and coroutine scope, states, events,
outputs and capabilities, transitions, result events, cancellation/correlation/recovery, and
communication with other machines.

### 6. Make the contract executable

Define owner-local tests and structural guardrails with the design. Cover direct dependency/use
parity, forbidden edges, minimal visibility, exact source-set/test ownership, changed-module
builds, coroutine/lifecycle behavior, affected locales/accessibility, app/background/dynamic-
feature destinations, migration/recovery, release/R8, and security/privacy risk. Assembly is not
runtime or device proof.

### 7. Handoff without ambiguity

Architectural handoff must include:

- allowed and forbidden direction;
- owners, lifetimes, and source-of-truth edges;
- public seam or dependency changes and rationale;
- machine topology changes (states/events/outputs/capabilities);
- required sequencing and assumptions;
- validation expectations, unresolved decisions, and open risks.

Do not hand off unresolved ownership ambiguity, a reverse edge, or a hidden behavior change.

Run `scripts/validate_examples.sh` after changing the compiled example or a Kotlin State Machine
snippet. Set `RUN_ANDROID_TESTS=1` with a connected emulator or device to execute the Compose
semantics and callback tests; otherwise the validator compiles those tests without claiming a
device result.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. Read and follow the
[Kotlin handoff contract](references/handoff-contract.md), plus any stricter repository-local
contract, before emitting exactly one `KOTLIN-HANDOFF/1` block.

- Completed design routes `READY` to `KOTLIN_DEVELOPER`.
- Missing product intent, authority, approval, or external state routes `BLOCKED` to `ROOT`.
- Do not emit a Developer handoff for a standalone architecture report or advisory request unless
  the user or repository lifecycle explicitly requires implementation to follow.
