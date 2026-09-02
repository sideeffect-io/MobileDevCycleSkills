# Kotlin State Machine Feature Design

<!-- kotlin-suite:KOTLIN-WORKFLOW -->

## Repository and modules

Use the official [Kotlin State Machine repository](https://github.com/sideeffect-io/KotlinStateMachine).
The published modules are `statemachine`, `statemachine-compose`, `statemachine-debug`,
`statemachine-dump`, and `statemachine-dump-no-op` under
`io.sideeffect.kotlinstatemachine`. Use only the modules the owner needs and preserve the
consumer's repository-approved version or revision.

## Ground the API first

Resolve the consumer's exact version, read that revision's README, then inspect public source and
downstream tests before writing DSL code. Compiled public source/tests settle signatures and
semantics. Check Kotlin metadata, JVM target, coroutines, Compose runtime, and Android toolchain
compatibility. Never suppress metadata incompatibility with `-Xskip-metadata-version-check`.

At the currently inspected API:

- `Output` accepts a suspending side effect returning `EventSet?`;
- a non-null value becomes a one-element event Flow;
- `null` produces no event;
- `OutputFlow` accepts a suspending side effect returning `Flow<EventSet>` for zero-to-many events;
- the runtime owns the output Job and optional cancellation policy.

`StateMachineFlow` owns a serialized bounded event mailbox; collection observes committed states and
does not drive execution. `trySend`, `sendSuspending`, `sendAndWait`, and `finishAndWait` have
different contracts. Re-inspect the resolved revision before relying on these details.

## Mechanism admission

A significant business name does not by itself require a state machine. Use Kotlin State Machine
when accepted behavior genuinely needs one or more of:

- persistent state-dependent legality;
- replaceable or long-lived asynchronous outputs;
- cancellation or stale-result decisions;
- retry/recovery modes visible to the workflow;
- Navigation, Android component, or process lifetime;
- correlation or cross-owner coordination.

Prefer pure functions for validation/projection, local Compose state for transient presentation, one
structured suspending function for a non-interleavable operation, or a small coordinator when those
mechanisms completely express the contract. Do not create an empty machine or empty Outputs file
for structural uniformity.

Model the extended Mealy loop:

```text
(current State, Event) -> (optional next State, optional Output)
Output -> zero, one, or many semantic Events -> machine
```

States/events are inert immutable values. The machine is free of Retrofit, Room, Firebase, Android
clients, repositories, data sources, Hilt, dispatchers, and global containers.

Before implementation, define the business owner, initial state, scope/lifetime, activation,
accepted behavioral modes and intents, outputs/capabilities, transition rules, output cardinality,
required cancellation/correlation/recovery, semantic outcomes, and owner interactions. A
repository's canonical file layout organizes an admitted machine; it never proves that a machine or
every file is necessary.

## Naming and route readability

Follow repository naming first. Prefer `<Owner>Is<PresentCondition>` states and intent or semantic-
fact events such as `<Owner><Operation>WasRequested` and `<Owner><Operation>DidSucceed`. Keep
concrete states, events, guards, retry plans, and routes internal unless another module genuinely
consumes them.

Keep `When`/`On` routes sentence-readable. Each route visibly identifies the concrete current state,
concrete event, literal next state when transitioning, and named output. An accepted route may
transition, start an output while preserving state, or do both.

Keep route bodies declarative. Use literal concrete state constructors/objects or `state.copy(...)`
with a visible value change. Do not hide target states in helpers, local generic values, branching,
or loop-generated routes. Helpers may build arguments, plans, outputs, or semantic events but must
not accept or return DSL route types. An illegal or rejected input selects no route and starts no
output; an equal-state transition is not a substitute.

Use capture-free named guards only for correlation, stale rejection, capability, and genuine value
policy. Keep algorithms and result mapping outside `On` bodies.

## Behavioral state and event design

A concrete state is justified when its identity changes at least one of:

- the business condition or invariant currently known to hold;
- accepted external events or user actions;
- the semantic output selected for an accepted event;
- the next-state path or another externally relevant outcome;
- cancellation, replacement, correlation, or stale-result semantics;
- lifetime, persistence, commit, rollback, configuration, or process-recovery obligations;
- data availability that the type must prove;
- a decision another owner must observe.

A suspending call or sequential phase is not automatically a state. Keep phases inside one output or
coordinator when no event can legitimately interleave, cancellation/replacement does not differ by
phase, recovery need not resume from that exact point, and the phase does not establish a business
fact or invariant needed by later routes.

### Projection equivalence is not state equivalence

`State.superState` or another UI projection is intentionally many-to-one. Several concrete business
states may produce the same UI while preserving different facts, payload guarantees, output choices,
commit boundaries, rollback rules, or future transition paths. Equal UI projection is a prompt to
inspect the states; it is never sufficient evidence for merging them.

Distinguish three levels:

- **projection-equivalent:** the UI projection is equal;
- **interaction-equivalent:** the same event types are accepted;
- **behaviorally equivalent:** every accepted event has equivalent guards, semantic outputs,
  transitions, invariants, and future behavior.

Only full behavioral equivalence makes states collapse candidates. For every accepted event, both
states must accept or reject it with the same meaning, select the same semantic output, and move to
the same state or to states that are themselves behaviorally equivalent. They must also share the
same cancellation, replacement, correlation, lifetime, persistence, commit/rollback, recovery, and
data-invariant semantics.

Differences may be ordinary data parameters of the same semantic route or operation. For example,
`TripIsLoading(tripId)` naturally represents many identifiers because Retry always launches the
same `LoadTrip` effect family parameterized by `tripId`.

Even when full behavioral equivalence holds, merge only when one natural payload represents both
cases and the result lowers total conceptual complexity.

### Do not relocate topology into payloads and branches

Do not merge explicit state alternatives when the merged representation must reconstruct them
through a `kind`, `mode`, `phase`, `operation`, or `retryPlan` discriminator; a nullable-field matrix;
a runtime type test; or conditional output/transition dispatch. Moving a sealed alternative from
concrete states into one state's payload or a generic output dispatcher is topology relocation, not
simplification.

Keep states separate when their type identity:

- names a meaningful business phase or historical fact;
- proves different data availability or prevents invalid payload combinations;
- makes the same event select a different semantic output or next-state path;
- marks a different authoritative owner, commit, rollback, cancellation, persistence, or recovery
  boundary;
- keeps the transition table declarative and sentence-readable.

Branching remains valid for genuine data/domain decisions and result mapping. Branching introduced
only to recover a distinction removed from the concrete state model is evidence that the states
should probably remain separate.

A useful shorthand is:

> Payload represents data within one behavior. Concrete state alternatives represent different
> behavior.

For example, these states may deliberately share one Retry UI and the same Retry event while
remaining behaviorally distinct:

```text
When LogoutIsAwaitingAuthenticationRetry
  On LogoutRetryWasRequested
  -> Output RetryAuthentication

When LogoutIsAwaitingPrivateCleanupRetry
  On LogoutRetryWasRequested
  -> Output RetryPrivateCleanup
```

The first retry concerns the authentication transition; the second concerns a privacy-critical
cleanup boundary. Collapsing them into `LogoutIsAwaitingRetry(kind = ...)` and branching with
`when (kind)` would hide rather than remove that topology.

Concrete states carry exactly the data required for legal future behavior. Project them to a small
immutable UI state; do not use interacting boolean/null bags that permit impossible combinations.

An event represents external intent or a semantic fact that changes machine policy. Do not mirror
every internal function return as a separate event. Several internal calls may map to one semantic
outcome when their intermediate distinctions do not change legal future behavior.

Map SDK/repository failures to finite feature/domain values. Never expose exception messages as
product copy. Rethrow `CancellationException`.

## Output cardinality and orchestration

Output cardinality and internal execution topology are independent decisions.

Choose cardinality from machine semantics, not from the number of injected functions or suspending
calls:

- **One event:** use `Output` when one semantic outcome changes the next machine decision.
- **Event stream:** use `OutputFlow` for genuine zero-to-many observation or production over time.
- **No event:** return `null` from `Output` only when the effect is fully contained and its result
  cannot affect legal state, user-visible feedback, Navigation, acknowledgement, privacy, data
  integrity, retry, or recovery.

A no-event output remains owned by the state-machine runtime. It does not authorize `GlobalScope`, a
new unowned scope, or a detached coroutine. If failure can expose prior-account data, lose accepted
data, or decide whether the workflow may continue, resolve it authoritatively inside the output or
emit a semantic event.

One `Output` may invoke one or several injected suspending functions when they form one cohesive
business effect. Its internal execution may be:

- **sequential** when ordering, a data dependency, a transaction boundary, or a business invariant
  requires one operation to complete before another starts;
- **concurrent** when the operations are independent and parallel execution serves the accepted
  behavior, such as reducing latency for unrelated reads or cleanup operations;
- **mixed** when a small explicit dependency graph requires sequential stages containing one or
  more concurrent groups.

Use structured concurrency owned by the output Job, normally `coroutineScope` with child `async`
operations and `await`/`awaitAll`. Every child must complete or be cancelled before the `Output`
finishes. Do not use `GlobalScope`, create an unowned `CoroutineScope`, or launch detached work to
hide it from the output lifetime. Use `supervisorScope` only when the accepted failure policy
requires independent sibling completion and the aggregate result handles those failures explicitly.

Parallelize only semantically independent operations. Keep execution sequential when one result
feeds another operation, order is observable, the operations share mutable or transactional state,
or concurrency could violate a privacy, data-integrity, rate-limit, resource, or Android/platform
invariant. Choose and document aggregate failure behavior: fail fast when one failure invalidates
the cohesive effect, or collect independent results when the business contract requires a combined
outcome. Cancellation must propagate through the structured children.

For example, three independent cleanup capabilities may run concurrently and produce one aggregate
machine event:

```kotlin
Output {
    val results = coroutineScope {
        listOf(
            async { clearWidgetData() },
            async { clearTransientExports() },
            async { clearRouteHandoffs() },
        ).awaitAll()
    }

    CleanupDidFinish(summary = summarize(results))
}
```

The same internal execution could validly return `null` when every result is fully handled and no
machine decision depends on it, or use `OutputFlow` when multiple events over time are semantically
meaningful. Do not emit one event per invoked function merely because functions run separately or
concurrently. Keep intermediate results local and emit the smallest semantic event cardinality
required by the machine.

Inject ready-to-use suspending functions or cohesive capability interfaces. An output owns
orchestration, child-job lifetime, cancellation, failure aggregation, and semantic result mapping;
it never discovers concrete providers, SDK clients, repositories, scopes, or DI containers.

## Retry, correlation, cancellation, and observation

A shared retry state is appropriate when its payload parameterizes the same semantic retry
operation with ordinary data and the Retry route selects the same output family without branching
over operation kinds. For example, `TripIsAwaitingLoadRetry(tripId)` can retry `LoadTrip(tripId)`
for any identifier.

Keep distinct retry states when Retry selects different semantic effect families, business phases,
commit boundaries, authoritative owners, rollback rules, or recovery paths, even when those states
project to the same UI and accept the same Retry event.

A closed retry-plan value remains permissible when it is already a meaningful domain concept and
demonstrably improves local reasoning. Do not introduce one solely to reduce concrete-state count.
A `when` with one branch per former retry state is normally hidden topology rather than
simplification. Boolean retry flags, nullable command bags, and open executable command containers
remain forbidden. Repository/result unions should be mapped at the output boundary; only outcome
distinctions that change machine behavior need separate events.

Carry request/generation/observation IDs only when operations can overlap, previous work can be
replaced, stale completion may arrive, equal outcomes can repeat, or another owner requires an
acknowledgement protocol. A proved serialized or single-flight owner does not need per-phase
correlation merely for uniformity.

Define cancellation for every long-lived or replaceable output. The runtime owns the output Job; do
not replace it through an output context. Cancellation is cooperative, so retain correlation when a
non-cooperative dependency can produce a stale result after replacement.

Define Flow observation owner, sharing/buffer policy, termination, retry, and stale-delivery policy
only to the degree required by the accepted behavior. Screen visibility is not automatically
repository observation lifetime. Do not collect one cold/unicast producer multiple times
accidentally.

## ViewModel and Compose ownership

Use `viewModelScope` when the machine belongs to a destination and must survive configuration
changes. Expose immutable `StateFlow` and collect it in a Route with
`collectAsStateWithLifecycle()`. The Route passes state and semantic callbacks to a stateless
Screen; do not expose the mutable machine throughout the composable tree.

With Hilt, inject a cohesive machine factory into the `@HiltViewModel` and create the machine once
with `viewModelScope`. Use assisted injection for runtime destination identity. Hilt must not provide
the machine or its scope. Use `rememberStateMachine(factory)` only when composition intentionally
owns creation and shutdown; otherwise observe the longer-lived machine without taking ownership.

Choose mailbox rejection behavior explicitly. `trySend` returning `false` is not success; disable
duplicate actions, expose/log the bounded failure safely, or use `sendSuspending` from an owned
coroutine when waiting is required.

## Communication and decomposition

A child emits a semantic outcome/callback and its parent Navigation/Feature owner translates it.
The child does not store parent routes or machine types. Pass stable identifiers or irretrievable
transient domain payloads, not prepared state or repository objects.

Before connecting machines, record producer, consumer, payload, required correlation,
cancellation, and lifetime owner. Split only at a stable independently meaningful workflow boundary
with its own vocabulary, effects, tests, and outcome contract. Use peer mediation only when
independent machines truly require it. File size alone justifies neither splitting nor retention.

## Required tests

Cover accepted legal journeys, required forbidden state/event pairs, named guards, semantic output
success/failure, cancellation/replacement, stale results, retry behavior, observation termination,
mailbox policy, owner cancellation, factory identity/lifetime, and outcome delivery only where those
paths are part of the contract. Use one coroutine test scheduler, virtual time, and explicit barriers
rather than sleeps.

When evaluating a collapse, characterize both candidate states across the accepted event alphabet.
Prove semantic output selection, next-state behavior, guards, cancellation/lifetime, invariants, and
recovery—not only UI projection. Add a negative test when a merged payload could represent an
invalid combination or when conditional dispatch would reconstruct the former alternatives.

For an output that composes several operations, test the business dependency graph rather than
implementation timing alone: prove required ordering, prove safe overlap when concurrency is
material, verify aggregate success/failure mapping, and verify cancellation of owned child jobs.
Do not require one event per internal operation when the machine contract has one aggregate outcome.

Tests should protect observable behavior, named invariants, and reproduced regressions. They should
not require one test per private execution phase, preserve obsolete states/events, or force exact
private topology. Conversely, do not delete meaningful business states merely to reduce type or test
counts. When topology is simplified without changing behavior, update implementation-shaped tests
and validators in the same focused change.
