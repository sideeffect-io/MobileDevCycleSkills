# Testing and Refactoring

<!-- swift-suite:SWIFT-TESTING -->

## Test at the owning boundary

| Owner | Prove |
| --- | --- |
| Domain/pure policy | invariants, boundaries, parsing, finite failures, deterministic projections |
| Capability/adapter | success, mapped failure, cancellation, payload conversion, termination |
| State machine | complete journeys, forbidden pairs, guards, effects, stale results, recovery |
| SwiftUI/root | input activation, callback delivery, identity, environment default, accessibility |
| Navigation | semantic outcome to route/state, deep-link correlation, unsupported terminal result |
| Composition | live adapter-to-capability wiring and intended factory/service lifetime |
| Architecture | forbidden imports/edges, visibility, resources, test ownership, complexity exceptions |

Prefer Swift Testing for unit and integration tests: `@Test`, `#expect`, `#require`, traits, and
parameterized arguments. Tests run in parallel by default, so isolate files, databases, clocks,
globals, and other mutable resources. Fix isolation before applying serialization. Keep XCTest for
`XCUIApplication`, XCTest-only metrics, and Objective-C cases.

Name tests as behavior. Keep setup local or use small value fixtures/builders. Avoid shared mutable
base classes and mocks that reproduce the implementation. Use fakes/stubs at the narrow capability
boundary and assert observable state, events, outcomes, or persisted values.

## Swift Testing mechanics

Use `#expect` for independent assertions and `try #require` when later steps depend on a prerequisite
value. Import `Testing` only in test targets. Put `@available` on individual test functions for
OS-gated behavior rather than hiding an entire suite, and use traits/tags plus test-plan filtering
instead of test-name conventions or ad hoc comments.

Keep the default parallel execution model. Give tests unique files, stores, accounts, clocks, and
other mutable resources; use `.serialized` only as a documented temporary bridge while isolation is
being repaired. Use `withKnownIssue` for a tracked temporary failure that should still execute and
report signal. Disable a test only when execution itself is unsafe or impossible, with an owner,
reason, and removal condition.

Migrate XCTest incrementally: assertions first, then suite structure, then parameterization and
traits. A `confirmation` proves callbacks observed within its operation; use an awaitable gate,
stream, or continuation when the completion can outlive that scope.

## Asynchronous tests

Await the contract, not time. Use explicit continuations, streams, clocks, or test gates. Short
sleeps are not sequencing. Bound a wait with a timeout only so a defect fails promptly. Test
cancellation and deallocation intentionally.

For SwiftStateMachine, use the consumer's `StateMachineTest` product to prove complete state
journeys and forbidden transitions. Test output capabilities directly, including cancellation
mapping and stream completion. Correlate and reject stale results in tests.

## Behavior-preserving refactoring

1. Capture current behavior with tests and a small observable journey list.
2. Make one structural change with no intended product delta.
3. Keep the target compiling; move tests/resources with their owner.
4. Run focused tests after each coherent step.
5. Remove the obsolete path only after parity is proved.
6. Remove stale imports, names, source membership, providers, factories, tests, and guardrails.
7. Run architecture and top-level validation.

Do not mix a broad rename, architecture migration, concurrency migration, and user-visible change
unless correctness makes them inseparable. Record intentional deviations concisely in the current
report or lifecycle handoff for the next verification pass.

## Test quality checks

- one clear behavior per test, with diagnostic expected/actual values;
- edge and invalid cases, not only happy paths;
- deterministic clocks/IDs/locale and no live backend for unit tests;
- parallel-safe resources and unique temporary locations;
- parameterization where cases differ only by data;
- prerequisites use `#require`, and known failures keep signal through `withKnownIssue`;
- availability and test-plan filtering use test functions, traits, and tags rather than suite/name hacks;
- integration tests only where a boundary crossing is the behavior under test;
- no target-local unit test stranded in the app test bundle;
- no empty module-load test created solely to mirror a compile-only target;
- failing tests are fixed or reported, not disabled without a tracked reason.
