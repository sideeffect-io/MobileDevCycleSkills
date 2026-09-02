# Architecture Migration Playbook

<!-- kotlin-suite:KOTLIN-MIGRATION-PLAYBOOK -->

## 1. Characterize behavior

List current user journeys, state combinations, lifecycle entry points, coroutine scopes,
asynchronous work, cancellation, retries, restoration, navigation, concrete dependencies, sources
of truth, and edge cases. Add characterization tests before moving ownership when needed.

## 2. Freeze the target contract

Write the allowed module/package graph, ownership table, public seams, repository/source-of-truth
policy, feature inputs/outcomes, workflow transition map, lifetime owners, and validation plan.
Identify compiler or DI failures expected while introducing the new boundary.

## 3. Migrate in dependency order

Use one compiling vertical slice:

1. Domain values, pure policies, and optional reusable use cases;
2. Gradle module/package boundaries and owner-local tests;
3. generic Frameworks wrappers where they provide a real technology boundary;
4. Datasources repository APIs, implementations, adapters, and source-of-truth policy;
5. Feature UI state, events, outputs/capabilities, machine/reducer, ViewModel, and Route/Screen;
6. Navigation outcomes and owner-local Hilt bindings or manual App composition;
7. integration tests and architecture guardrails;
8. removal of the obsolete owner/runtime.

Move resources, source sets, DI bindings, and tests with their owner. Compile/test after each
coherent boundary becomes valid.

## 4. Use temporary bridges narrowly

Bridge legacy code only at an immutable model, repository/capability, event, or outcome boundary.
One runtime owns authoritative state at a time. Do not synchronize two mutable state holders, expose
a concrete SDK to avoid an adapter, or retain temporary service locators/providers permanently.

## 5. Prove parity and remove the old path

Run characterization and focused tests, coroutine cancellation/stale-result tests, changed-module
builds, guardrails, app builds, and affected emulator/device flows. Then remove duplicate flags,
Flows, Jobs, callbacks, direct data-source access, obsolete DI bindings, dependencies, and tests.
Search for stale names/imports across all variants and source sets.

Keep architecture migration, toolchain upgrades, behavior changes, and broad cleanup in separate
reviewable slices unless inseparable for correctness.
