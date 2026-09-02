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

A concrete state is justified only when it changes at least one of:

- accepted external events or user actions;
- observable product/UI behavior;
- cancellation, replacement, or stale-result semantics;
- lifetime, persistence, configuration/process-recovery obligations;
- a decision another owner must observe.

A suspending call or sequential phase is not automatically a state. Keep phases inside one output or
coordinator when no event can legitimately interleave, cancellation/replacement does not differ by
phase, and recovery need not resume from that exact point.

Collapse states when they have the same accepted inputs, UI projection, cancellation/lifetime,
recovery obligations, and external outcome and differ only in the next internal command. Concrete
states carry exactly the data required for legal future behavior. Project them to a small immutable
UI state; do not use interacting boolean/null bags that permit impossible combinations.

An event represents external intent or a semantic fact that changes machine policy. Do not mirror
every internal function return as a separate event. Several internal calls may map to one semantic
outcome when their intermediate distinctions do not change legal future behavior.

Map SDK/repository failures to finite feature/domain values. Never expose exception messages as
product copy. Rethrow `CancellationException`.

## Output cardinality and orchestration

Choose cardinality from semantics, not the number of suspending calls:

- **One event:** use `Output` when one semantic outcome changes the next machine decision.
- **Event stream:** use `OutputFlow` for genuine zero-to-many observation or production over time.
- **No event:** return `null` from `Output` only when the effect is fully contained and its result
  cannot affect legal state, user-visible feedback, Navigation, acknowledgement, privacy, data
  integrity, retry, or recovery.

A no-event output remains owned by the state-machine runtime. It does not authorize `GlobalScope`, a
new unowned scope, or a detached coroutine. If failure can expose prior-account data, lose accepted
data, or decide whether the workflow may continue, resolve it authoritatively inside the output or
emit a semantic event.

An output may orchestrate several injected suspending operations in required order and keep
intermediate results local when the sequence is non-interleavable. Emit the smallest semantic event
that changes machine policy. Do not create marker-write, cache-clear, runtime-suspend, or similar
states/events merely because each operation suspends.

Inject ready-to-use suspending functions or cohesive capability interfaces. An output owns
orchestration and semantic result mapping; it never discovers concrete providers, SDK clients,
repositories, scopes, or DI containers.

## Retry, correlation, cancellation, and observation

A single closed retry-plan value may be carried by one retry state when all variants have the same:

- accepted external inputs;
- UI projection and blocking behavior;
- lifetime/cancellation/recovery semantics;
- final outcome;

and differ only in the internal command executed by Retry. Separate retry states remain appropriate
when those semantics differ. Boolean retry flags, nullable command bags, and open executable command
containers remain forbidden. Repository/result unions should be mapped at the output boundary; only
outcome distinctions that change machine behavior need separate events.

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

Tests should protect observable behavior, named invariants, and reproduced regressions. They should
not require one test per private execution phase, preserve obsolete states/events, or force exact
private topology. When topology is simplified without changing behavior, update implementation-
shaped tests and validators in the same focused change.
