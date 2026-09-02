# Kotlin State Machine Feature Design

<!-- kotlin-suite:KOTLIN-WORKFLOW -->

## Repository and modules

Use the official [Kotlin State Machine repository](https://github.com/sideeffect-io/KotlinStateMachine).
The published modules are `statemachine`, `statemachine-compose`, `statemachine-debug`,
`statemachine-dump`, and `statemachine-dump-no-op` under
`io.sideeffect.kotlinstatemachine`. Use only the modules the owner needs and preserve the
consumer's repository-approved version or revision.

## Ground the API first

Kotlin State Machine evolves independently of this skill. Resolve the consumer's exact version,
read that revision's README, then inspect public source and downstream tests before writing DSL
code. The README establishes concepts and modules; compiled public source/tests settle signatures
and semantics. Check Kotlin metadata, JVM target, coroutines, Compose runtime, and Android toolchain
compatibility as well as dependency coordinates. Never suppress metadata incompatibility with
`-Xskip-metadata-version-check`.

At the currently inspected API, `StateMachineFlow` owns a serialized bounded event mailbox;
collection observes committed states and does not drive execution. The owner supplies its
`CoroutineScope`. `trySend`, `sendSuspending`, and `sendAndWait` have different capacity/completion
contracts. `finishAndWait` is the deterministic shutdown barrier. Re-inspect before relying on any
of these details.

## Default for significant business areas

Use a state machine for a feature/navigation workflow with persistent modes, state-dependent legal
events, asynchronous outputs, retry/recovery, replacement/correlation, subscription lifetime, or
cross-feature coordination. Use pure functions and local Compose state for stateless validation or
transient UI element state. Do not create an empty machine for structural uniformity.

Model the extended Mealy loop:

```text
(current State, Event) -> (optional next State, optional Output)
Output -> suspend effect -> Event -> machine
```

States/events are inert immutable values. Each asynchronous result returns through an event. The
machine is free of Retrofit/Room/Firebase/Android clients, repositories, data sources, Hilt, and
global containers.

Before implementation, define the machine's business owner, initial state, scope/lifetime,
activation, complete state/event vocabulary, outputs and injected capabilities, transitions,
result events, cancellation/correlation/recovery, semantic outcomes, and interactions. These are
responsibilities represented by the canonical Feature-owner files described in
[Architecture layers](architecture-layers.md): `<Owner>States.kt`, `<Owner>Events.kt`,
`<Owner>Outputs.kt`, and `<Owner>StateMachine.kt`. Additional cohesive machine support may sit
beside them. If the workflow has no outputs, keep a package-only Outputs file; do not invent output
types or an otherwise unnecessary machine for structural symmetry.

## Naming, state, and event design

Follow repository naming first. Prefer concrete state names that describe a present condition,
events that describe intent or a completed fact, and output/capability names that describe a use
case. Keep concrete states/events/routes internal unless another module genuinely consumes them.

For Kotlin State Machine DSLs, make the transition table readable as sentences. Keep sealed state
and event sets, but flatten concrete alternatives. Prefer `<Owner>Is<PresentCondition>` states and
observed-fact events such as `<Owner><Operation>WasRequested` or
`<Owner><Operation>DidSucceed`. Each `When` / `On` route must visibly identify the concrete current
state and concrete event, plus the literal next state whenever it transitions and any named output.
An accepted route may transition, start an output while preserving state, or do both.

Concrete states carry exactly the data required for legal future transitions. Project them to one
small immutable UI state through `State.superState` or an explicit pure mapping. Do not use a bag of
independent booleans/nullables when a sealed alternative prevents impossible combinations.

Map implementation failures to finite feature/domain failures. Never expose exception messages as
product copy. If work can be replaced, carry a request/generation/observation ID in active state and
completion events; a named guard rejects stale results.

## Direct route grammar and atomic topology

Keep route bodies declarative. A transition target is a literal concrete state constructor/object,
or `state.copy(...)` with a visible value change. Never hide the target behind a state-returning
helper, local `nextState`, generic `state`, `if`/`when`, loop-generated routes, or an implicit DSL
receiver. Helpers may build constructor arguments, commands, plans, outputs, or atomic events; they
must not accept or return DSL route types.

An empty copy, a copy that only reassigns current values, or reconstruction of an equal state is an
observable transition, not a no-route operation. If an event is illegal, stale, or rejected by
policy, select no route and start no output. Preserve rejection before both state and effect when
refactoring; never move a capability check behind the effect merely to simplify a route.

Represent mutually exclusive outcomes as atomic event types emitted by the output boundary. Do not
put a repository/result union, success flag, retry enum, nullable retry command, or equivalent
discriminator inside a machine event or state and recover the alternative with guards. When retry
changes legal future events, model an explicit operation-specific retry state and a separate
non-retry failure state.

Use capture-free named top-level or private-object guards only for correlation, stale rejection,
capability, and genuine value policy. Use an event type directly for cancellation when sufficient;
value-dependent cancellation uses a capture-free named policy function reference. Keep `if`,
`when`, algorithms, and result mapping outside `On` bodies. Output helpers may branch on capability
results, but must return outcome-specific atomic events.

## Outputs, cancellation, and observation

Machine construction and transition selection stay side-effect free. Start work through an explicit
activation/intent event. Inject ready-to-use suspending functions or cohesive interfaces. An Output
may orchestrate them and map results to events; it does not discover concrete providers.

Rethrow `CancellationException`. Define cancellation for every long-lived or replaceable Output.
The runtime owns the Output Job; do not replace it through an Output context. Cancellation is
cooperative, so correlation remains necessary for non-cooperative dependencies.

Define Flow observation owner, sharing/buffer policy, termination, retry, and stale-delivery policy.
Screen visibility is not automatically repository observation lifetime. Never collect the same
cold/unicast producer multiple times accidentally to create duplicate work.

## ViewModel and Compose ownership

Use `viewModelScope` when the machine belongs to a screen/navigation destination and must survive
configuration changes. Expose immutable `StateFlow` and collect it in a Route with
`collectAsStateWithLifecycle()`. The Route passes state and semantic callbacks to a stateless Screen.
Do not expose the mutable machine throughout the composable tree.

With Hilt, inject a cohesive machine factory into the `@HiltViewModel` and create the machine once
with `viewModelScope`. Pass destination identity or another runtime navigation value through an
assisted ViewModel factory; let the Route obtain it with assisted `hiltViewModel` and a stable
identity key. The machine factory may receive injected effect capabilities, repositories, and ID
providers, but Hilt must not provide the machine or scope themselves. This keeps cancellation and
machine ownership compiler-visible and lets direct tests instantiate the ViewModel/factory without
building a Hilt component.

Use `ComposeStateMachineFactory` and `rememberStateMachine(factory)` only when the machine should be
created and finished with the composition. When a ViewModel or longer-lived owner owns the machine,
`rememberStateMachine(machine)` observes it without taking execution ownership. Use
`PreviewStateMachine` for synchronous previews/presentation tests where supported by the resolved
module.

Choose mailbox rejection behavior explicitly. `trySend` returning `false` is not success; disable
duplicate UI actions, log a privacy-safe metric, expose the result, or use `sendSuspending` from an
owned coroutine when waiting for capacity is required.

## Communication and decomposition

For normal hierarchy, a child emits a semantic outcome/callback and its parent navigation/feature
owner translates it. A child does not store the parent's state machine or routes. Pass identifiers
or irretrievable transient domain payloads rather than prepared child state or repository objects.

Before connecting machines, record producer, consumer, payload, correlation, cancellation, and
lifetime owner. Split only at a stable independently meaningful workflow boundary with its own
vocabulary, effects, tests, and outcome contract. Use mediator-style collaboration only when
independent machines truly require peer communication and the resolved runtime supports it.

## Required tests

Cover legal journeys, forbidden State/Event pairs, both sides of guards, output success/failure,
cancellation, stale results, retries, observation termination, activation/replacement, repeated
outcomes, mailbox rejection policy, owner cancellation, factory identity/lifetime, and callback
delivery. For every forbidden pair and rejected guard side, assert both that no state
transition/emission occurs and that no output capability runs; an equal-state transition does not
prove rejection. Use `statemachine-debug` helpers and `kotlinx-coroutines-test` when compatible with
the consumer. Await explicit barriers or virtual time; do not sequence with sleeps.
