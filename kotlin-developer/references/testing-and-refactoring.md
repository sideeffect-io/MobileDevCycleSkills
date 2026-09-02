# Testing and Refactoring

<!-- kotlin-suite:KOTLIN-TESTING -->

## Test at the owning boundary

| Owner | Prove |
| --- | --- |
| model/pure policy | invariants, boundaries, parsing, finite failures, projections |
| repository/data source | source of truth, mapping, conflicts, offline/retry, main safety |
| capability/adapter | success, finite failure, cancellation, termination, payload conversion |
| state machine/reducer | journeys, forbidden pairs with no state emission or effect, both guard sides, atomic output events, stale results, recovery |
| ViewModel | intent mapping, immutable state, sharing, owner cancellation, SavedState reconstruction |
| Compose Screen | rendering, semantics, callbacks, adaptive/localized states |
| navigation/application DI | outcome-to-route behavior, deep links, bindings, lifetimes |
| architecture | forbidden dependencies, visibility, source sets, resources, complexity exceptions |

Prefer local JVM tests for pure logic, repositories with fakes, state machines, and ViewModels.
Use Robolectric only when Android framework simulation is the behavior. Use instrumented/emulator
tests for real lifecycle, permissions, navigation, database/platform integration, accessibility, or
rendering that the host cannot prove.

Name tests as behavior. Keep setup local or use small value fixtures/builders. Prefer deterministic
fakes at real seams over deep mocks that reproduce implementation. Assert observable state, events,
outcomes, persisted values, or semantics—not private fields.

## Coroutine and Flow tests

Use `runTest`, one shared `TestCoroutineScheduler`, and a controlled `Dispatchers.Main`. Collect
`WhileSubscribed` state when its pipeline requires a subscriber. Await virtual time or explicit
`CompletableDeferred`/Channel gates. Timeouts are failure bounds, not sequencing tools.

Test cancellation as cancellation, replacement, stale completion, Flow error/termination, callback
unregistration, buffer/replay semantics, and owner shutdown. Do not use short sleeps.

For Kotlin State Machine, use the consumer-compatible `statemachine-debug` APIs for complete
journeys and forbidden transitions, and test Output capability mapping directly. A rejected event
must produce no state transition/emission and no capability call; do not treat an equal-state
transition as rejection. Call deterministic shutdown barriers when the runtime exposes them.

## Behavior-preserving refactoring

1. Capture current behavior and observable journeys.
2. Make one structural change with no intended product delta.
3. Keep the module compiling; move resources/tests/DI with their owner.
4. Run focused tests after each coherent slice.
5. Remove the obsolete owner only after parity is proved.
6. Search all variants/source sets for stale imports, fields, Flows, Jobs, providers, and tests.
7. Run architecture and app/runtime validation.

Do not mix broad rename, module migration, coroutine migration, and user-visible change unless
correctness makes them inseparable. Never disable a failing/flaky test without a tracked reason and
replacement evidence.
