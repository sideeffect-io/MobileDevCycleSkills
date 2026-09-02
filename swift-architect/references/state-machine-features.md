# SwiftStateMachine Feature Design

<!-- swift-suite:SWIFT-WORKFLOW -->

## Contents

- [Repository and installation](#repository-and-installation)
- [Ground the API first](#ground-the-api-first)
- [Mechanism admission](#mechanism-admission)
- [Naming and visibility](#naming-and-visibility)
- [Behavioral state and event design](#behavioral-state-and-event-design)
- [Output cardinality and orchestration](#output-cardinality-and-orchestration)
- [Retry, correlation, cancellation, and observation](#retry-correlation-cancellation-and-observation)
- [Factory and SwiftUI ownership](#factory-and-swiftui-ownership)
- [Feature communication and decomposition](#feature-communication-and-decomposition)
- [Required tests](#required-tests)

## Repository and installation

Use the official [SwiftStateMachine repository](https://github.com/sideeffect-io/SwiftStateMachine).
For SwiftPM, prefer an exact repository-approved revision unless the consumer already has an
intentional version or branch policy:

```swift
dependencies: [
  .package(
    url: "https://github.com/sideeffect-io/SwiftStateMachine",
    revision: "<repository-approved-commit>"
  )
]

.product(name: "StateMachineCore", package: "SwiftStateMachine")
.product(name: "StateMachineTest", package: "SwiftStateMachine")
```

In Xcode, select the repository-approved dependency rule. Do not invent a semantic version or
silently follow an unpinned branch. A local path dependency is appropriate while actively
developing both checkouts. Prefer the smallest products and add broadcast/dump products only for a
demonstrated need. Preserve an existing aggregate product integration unless dependency cleanup is
in scope.

## Ground the API first

SwiftStateMachine evolves independently of this skill. Resolve the consumer's exact revision, read
that revision's `README.md`, then inspect `Package.swift`, public source, and tests before writing
DSL code. The README establishes concepts and products; compiled public source and tests settle
signature or semantic disagreements. Compile examples against that revision.

At the currently inspected public API, `Output` supports:

- a `Sendable` `AsyncSequence` whose elements are machine events;
- an async or async-throwing closure returning one optional event;
- no event when that optional result is `nil`, which is wrapped as an immediately finishing
  sequence.

The runtime may change; re-inspect the resolved revision rather than relying on this snapshot.
Concrete state and event values conform directly to the public protocols exported by that revision.

## Mechanism admission

A significant business name does not by itself require a state machine. Use SwiftStateMachine when
accepted behavior genuinely needs one or more of:

- persistent state-dependent legality;
- replaceable or long-lived asynchronous outputs;
- cancellation or stale-result decisions;
- retry/recovery modes visible to the workflow;
- navigation or process lifetime;
- correlation or cross-owner coordination.

Prefer pure functions for validation and projection, local SwiftUI state for transient presentation,
a structured async function for one non-interleavable operation, or a small actor/coordinator when
those mechanisms completely express the contract. Do not create an empty machine or machine-shaped
files for structural uniformity.

Model the extended Mealy loop as:

```text
(current State, Event) -> (optional next State, optional Output)
Output -> zero, one, or many semantic Events -> machine
```

States and events are inert `Equatable & Sendable` values. Effects are named `Sendable`
capabilities. The feature and machine never construct SDK clients, Framework wrappers,
Datasources, DAOs, live repositories, or application services.

Before implementation, define the machine's owner, initial state/lifetime, accepted behavioral
modes and intents, outputs/capabilities, transition rules, output cardinality, required
cancellation/correlation/recovery, semantic outcomes, and communication with other owners. Do not
pre-enumerate every conceivable failure or internal function return as topology.

## Naming and visibility

- Concrete states: `<Owner>Is<PresentCondition>`.
- Events: completed intent or semantic fact, such as `WasRequested`, `WasReceived`, `DidSucceed`,
  `DidFail`, or `DidFinish`.
- Outputs: use-case names such as `LoadProfileOutput` or `ObserveTripsOutput`.
- Upward communication: semantic `Outcome`; never a route or destination.
- Public inputs/outcomes/intents: one canonical contract surface when they cross targets.
- Concrete states/events, guards, retry plans, and cancellation policies: internal or private.

Declare an owner-named alias and return it from the machine factory. Prefer the simplest typed DSL
supported by the resolved revision. Add contextual token wrappers only when they reduce total code
and improve local reasoning; never add one extension per state/event for uniformity. Keep `When`,
`On`, `Transition`, and `Output` routes visibly inside the factory rather than hiding topology in
helpers or a parallel representation.

Every guarded route and value-dependent cancellation policy uses a named static predicate. Static
functions keep policy readable and independently testable.

## Behavioral state and event design

A concrete state is justified only when it changes at least one of:

- accepted external events or user actions;
- observable product/UI behavior;
- cancellation, replacement, or stale-result semantics;
- lifetime, persistence, or process-recovery obligations;
- a decision another owner must observe.

An asynchronous call or sequential execution phase is not automatically a state. Keep phases inside
one output or coordinator when no event can legitimately interleave, cancellation/replacement does
not differ by phase, and recovery need not resume from that exact point.

Collapse states when they have the same accepted inputs, observable projection,
cancellation/lifetime behavior, recovery obligations, and external outcome and differ only in the
next internal command. Concrete states carry only data required for their legal future behavior.
Project a small equatable UI superstate rather than exposing workflow implementation.

An event represents an external intent or semantic fact that changes a machine decision. Do not
create one event for every internal return value. Several internal calls may map to one semantic
outcome when intermediate distinctions do not change legal future behavior.

Use finite feature/domain failures rather than transport strings. Map SDK/transport errors at the
output or adapter boundary. Treat cancellation as cancellation, not a business failure.

## Output cardinality and orchestration

Choose output cardinality from semantics, not from the number of suspending calls:

- **One optional event:** use the optional-event initializer when one semantic outcome changes the
  machine's next decision.
- **Event sequence:** use an `AsyncSequence` for genuine zero-to-many observation or production over
  time, such as an authoritative subscription.
- **No event:** return `nil`, or let a sequence finish without elements, only when the effect is fully
  contained and its result cannot affect legal state, user-visible feedback, navigation,
  acknowledgement, privacy, data integrity, retry, or recovery.

A no-event output remains owned and cancellable by the state-machine runtime. It is not permission
to launch a detached or unstructured `Task`. If failure can expose prior-account data, lose accepted
data, or decide whether the workflow may continue, resolve it authoritatively inside the output or
emit a semantic event.

An output may call several injected operations in required order and keep their intermediate
results local when the sequence is non-interleavable. Emit the smallest semantic event that changes
the machine's policy. Do not expose marker-write, cache-clear, runtime-suspend, or similar internal
steps as separate states/events merely because each operation is async.

Inject effectful operations through `@Sendable` closures or a cohesive `Sendable` capability value.
The output owns orchestration and result mapping but never discovers the concrete implementation.
App composition constructs concrete Frameworks/Datasources and closes over their operations.

## Retry, correlation, cancellation, and observation

A single closed retry-plan value may be carried by one retry state when all variants have the same:

- accepted external inputs;
- user-visible projection and blocking behavior;
- lifetime/cancellation/recovery semantics;
- final outcome;

and differ only in the internal command executed by Retry. Use separate retry states when those
semantics genuinely differ. Boolean retry flags, nullable command bags, and open executable command
containers remain forbidden.

Carry a request/generation/observation ID only when operations can overlap, earlier work can be
replaced, stale completion may arrive, equal outcomes can repeat, or another owner requires an
acknowledgement protocol. A proved actor-serialized or single-flight workflow does not need
per-phase correlation merely for consistency.

Define cancellation for every long-lived or replaceable output. Cancellation is cooperative;
cancelling old work does not itself define the route that starts replacement. Test both. Use
lifecycle restart only for resilient subscriptions/polling with an explicit policy; ordinary loads
use explicit retry behavior when retry is accepted product behavior.

Authoritative observations normally live for the owning machine lifetime, not view visibility.
Use suitable buffering and test termination, replacement, and stale delivery where those risks are
real. Never create competing iterators over one unicast machine.

## Factory and SwiftUI ownership

`AsyncStateMachineFactory` is the lazy construction boundary. Store the factory itself in a
feature-owned environment value with a deterministic side-effect-free default. Pass it directly to
`StateMachineView`; do not add a registry, provider chain, type erasure, or forwarding factory
function without a current consumer-owned need.

Use `.instance` unless multiple consumers intentionally share one runtime. A `.singleton` applies
only within one retained factory instance; document the retaining owner and lifetime.

Only the feature root owns `StateMachineView`/`UIStateMachine`. Child views receive immutable
projections and semantic closures. The root receives typed input and outcomes where needed. Keep
the machine factory independent of callbacks; activate through a typed event from an awaiting-input
state when activation itself is behavioral.

## Feature communication and decomposition

A child emits semantic outcomes through a closure and its parent navigation/feature owner translates
them. The child never imports parent routes or machine types. Pass stable identifiers or
irretrievable transient domain payloads, not prepared child state, repositories, or private request
machinery.

Before connecting machines, record producer, consumer, payload, required correlation,
cancellation, and lifetime owner. Split only at a stable independently meaningful workflow boundary
with its own vocabulary, effects, tests, and outcome contract. Use `Composite` only when one parent
state genuinely owns child lifetimes; use `Mediator` only when independent peers must exchange
events. File size alone justifies neither.

## Required tests

Cover accepted legal journeys, required forbidden state/event pairs, named guards, semantic output
success/failure, cancellation/replacement, stale results, retry behavior, observation termination,
factory identity/lifetime, and outcome delivery only where those paths are part of the contract.
Test pure projections separately.

Tests should assert observable behavior, named invariants, and reproduced regressions. They should
not require one test per private execution phase, preserve obsolete states/events, or force exact
private topology. When topology is simplified without changing behavior, update implementation-
shaped tests and guardrails in the same focused change.

Use the consumer revision's `StateMachineTest` APIs and external-public-API fixtures where
visibility matters. The compiled example under `assets/ArchitectureExample` demonstrates one valid
shape, not mandatory topology.
