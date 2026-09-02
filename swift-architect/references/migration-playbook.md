# Architecture Migration Playbook

<!-- swift-suite:SWIFT-MIGRATION-PLAYBOOK -->

## 1. Characterize behavior

List current user journeys, state combinations, lifecycle entry points, asynchronous work,
cancellation, retries, restoration, navigation, concrete dependencies, and known edge cases. Add
characterization tests before moving ownership when behavior is not already protected.

## 2. Freeze the target contract

Write the allowed target graph, target ownership table, public seams, feature input/outcomes,
workflow transition map, lifetime owners, and validation plan. Identify which compiler errors are
expected while the new boundary is introduced.

## 3. Migrate in dependency order

Use a compiling vertical slice:

1. domain values and pure policies;
2. package/target boundaries and target-local tests;
3. feature input, projection, states, events, outputs, and machine;
4. root UI and child projection/callback APIs;
5. Frameworks wrapper and Datasources adapter conversion;
6. direct application composition and navigation outcome handling;
7. integration tests and architecture guardrails;
8. removal of the obsolete owner/runtime.

Move resources and tests with their owner. Add every source to the correct SwiftPM/Xcode target.
Build after each boundary becomes coherent.

## 4. Use temporary bridges narrowly

Bridge legacy code only at a domain value, capability, event, or outcome boundary. One runtime owns
state at a time. Do not synchronize two mutable sources of truth, expose a concrete SDK to avoid an
adapter, or preserve obsolete providers/registries as permanent compatibility layers.

## 5. Prove parity and remove the old path

Run characterization and new focused tests, cancellation/stale-result tests, target builds,
guardrails, top-level builds, and affected runtime flows. Then remove duplicate flags, tasks,
callbacks, direct SDK imports, old source membership, factory registries, forwarding factories, and
superseded tests. Search for stale names and forbidden imports.

Keep architecture migration, user-visible behavior changes, and broad cleanup in separate reviewable
slices unless they are inseparable for correctness.
