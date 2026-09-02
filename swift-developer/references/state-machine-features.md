# SwiftStateMachine Feature Design

<!-- swift-suite:SWIFT-WORKFLOW -->

## Contents

- [Repository and installation](#repository-and-installation)
- [Ground the API first](#ground-the-api-first)
- [Default for significant business areas](#default-for-significant-business-areas)
- [Naming and visibility](#naming-and-visibility)
- [State and event design](#state-and-event-design)
- [Effects, cancellation, and observation](#effects-cancellation-and-observation)
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

// In a production target:
.product(name: "StateMachineCore", package: "SwiftStateMachine")

// In the owning test target when needed:
.product(name: "StateMachineTest", package: "SwiftStateMachine")
```

In Xcode, choose **File > Add Package Dependencies**, enter the repository URL, then select the
repository-approved dependency rule. Do not invent a semantic version or silently follow an
unpinned branch. A local path dependency is appropriate while actively developing both checkouts:

```swift
.package(name: "SwiftStateMachine", path: "../SwiftStateMachine")
```

Prefer the smallest products: `StateMachineCore` for DSL/runtime/UI wrappers and
`StateMachineTest` in tests. Add broadcast or dump products only for demonstrated needs. Preserve
an existing aggregate `SwiftStateMachine` integration unless dependency cleanup is in scope.

## Ground the API first

SwiftStateMachine evolves independently of this skill. Resolve the consumer's exact revision, read
that revision's `README.md`, then inspect its `Package.swift`, public source, and external fixture or
tests before writing DSL code. The README establishes concepts and products; compiled public source
and tests settle signature or semantic disagreements. Compile examples against that revision.

Concrete state and event structs directly conform in their declarations to the exact public state
and event protocols exported by that resolved revision. Never guess protocol identifiers from an
older release, and never substitute extension-only conformance or a contextual DSL umbrella/token
for the concrete declaration. At the compiled reference fixture's pinned revision, public source
exports `State` and `Event`; the suite validator re-derives those names from the checkout before it
checks every `ProfileIs*` state and every concrete profile event declaration.

## Default for significant business areas

Make SwiftStateMachine the go-to choice for a Feature or Navigation module representing a
significant business area. Signals include persistent modes, different legal meanings for the same
event, explicit effects, cancellation, retry/recovery, correlation, navigation lifecycle, or
cross-feature coordination. Use pure functions for validation/projection and local SwiftUI state
for transient presentation without a business workflow. Do not create an empty machine for
structural uniformity.

Model the extended Mealy loop:

```text
(current State, Event) -> (next State, optional Output)
Output -> effect -> Event -> machine
```

States and events are inert `Equatable & Sendable` values. Effects are named `Sendable`
capabilities. Every asynchronous result returns through an event. The feature and state machine are
free of concrete implementations: they never import or construct SDK clients, Frameworks wrappers,
Datasources, DAOs, live repositories, or application services.

Before implementation, define each desired machine in the current architecture decision or lifecycle
handoff:
its business owner, initial state and lifetime, complete state and event vocabulary, outputs and
injected capabilities, transition rules, result events, cancellation/correlation/recovery, outcomes,
and communication with other machines. Include Navigation machines; do not reduce the definition
to a list of type names.

These are canonical responsibilities, not a global mandate for exactly four files. Keep state,
event, effect/output, transition/factory, projection, and public communication ownership legible;
use the repository's physical convention or group cohesive declarations when that improves local
reasoning and remains within its metrics.

## Naming and visibility

- Concrete states: `<Owner>Is<PresentCondition>`.
- Events: completed intent or fact, such as `WasRequested`, `WasReceived`, `WasSelected`,
  `WasDismissed`, `WasCancelled`, `DidChange`, `DidSucceed`, `DidFail`, or `DidFinish`.
- Outputs: use-case names such as `LoadProfileOutput` or `ObserveTripsOutput`.
- Upward communication: semantic `Outcome`; never a route or destination.
- Public inputs/outcomes/intents: one canonical contract surface when they cross targets; a
  repository may impose a physical file convention such as `<Owner>Contract.swift`.
- Concrete states/events, guards, and cancellation policies: internal or private.

Declare an owner-named alias and return it from the machine factory. Prefer the simplest typed DSL
supported by the resolved revision, such as `When(state: ProfileIsLoading.self)` and
`On(event: ProfileRetryWasRequested.self)`. Add contextual token wrappers only when they reduce
total code and improve local reasoning; never add one extension per state/event for uniformity.
Keep `When`, `On`, `Transition`, and `Output` routes visibly inside the factory. Do not hide routes
in helper functions, a `Rules` file, or a parallel transition representation.

Every `On(..., guard:)` uses a named static business predicate. Every
`Cancel(predicate:)` uses a named static cancellation decision. Never put a closure literal in
those arguments. Static functions make the route readable and independently testable.

## State and event design

Concrete states carry exactly the data required for their legal future transitions. Project a
small, equatable UI `SuperState`; do not expose the entire workflow implementation. Prefer exclusive
concrete states to interacting flags that permit impossible combinations.

User-facing failures are finite feature/domain values. Map transport/SDK errors in outputs or
adapters; do not store `String(describing: error)` as product copy. Treat cancellation as
cancellation, not business failure.

If work can be replaced, carry a request/generation/observation ID in both the active state and
completion event. A named guard rejects stale or duplicate results. Correlate repeatable equal
outcomes with a delivery ID and consume the delivery only after the root invokes its callback.

## Effects, cancellation, and observation

An output describes deferred work. Creating a machine and constructing transitions must remain
side-effect free. Send an explicit activation event when work begins.

The output owns orchestration, not concrete technology. Inject its effectful operations through
`@Sendable` closures or a cohesive `Sendable` capability struct. It may call those operations in the
required order and translate their domain-shaped results into events, but it must not initialize or
look up the concrete implementation. App composition constructs Frameworks and Datasources, then
closes over their operations when building the output/dependency value. Composition does not take
over the output's sequencing, cancellation, or result-to-event mapping.

Define cancellation semantics for every long-lived or replaceable output. Cancellation is
cooperative; cancelling an old output does not automatically declare the route that starts its
replacement. Test both. Use lifecycle restart only for resilient subscriptions/polling with an
explicit policy; ordinary loads use explicit retry events.

Authoritative observations normally live for the owning machine lifetime, not view visibility.
Temporary disappearance does not imply cancellation. Use newest-value buffering where appropriate,
and test termination, retry replacement, and stale delivery. Never create competing iterators over
one unicast `AsyncStateMachine`.

## Factory and SwiftUI ownership

`AsyncStateMachineFactory` is the lazy construction boundary. Store the factory itself in a
feature-owned environment value with a deterministic side-effect-free default. Pass it directly to
`StateMachineView`; do not add a registry, provider closure, type erasure, or forwarding factory
function.

Use `.instance` unless multiple consumers intentionally share one runtime. A `.singleton` applies
only within one retained factory instance; two singleton factories remain independent. Document
the retaining owner and lifetime.

Only the feature root owns `StateMachineView`/`UIStateMachine`. Child views receive immutable
projections and closures such as `retry`, `save`, or `selectionChanged`. The root receives `input:`
and `onOutcome:` where needed. Keep the machine factory independent of input and callback; activate
through a typed event from an awaiting-input state.

## Feature communication and decomposition

For ordinary hierarchy, a child emits semantic outcomes through a closure and the parent
navigation/feature machine translates them. The child never imports the parent's routes or machine.
The parent passes an identifier or irretrievable transient domain payload, not prepared child state,
drafts, repository objects, or private request IDs.

Before connecting machines, write an interaction matrix with producer, consumer, payload,
correlation, cancellation, and lifetime owner. Split a large machine only at a stable, independently
meaningful workflow boundary with its own vocabulary, effects, tests, and outcome contract. Let a
higher-level feature/navigation owner orchestrate those children.

Use `Composite` only when one parent state genuinely owns the coordinated lifetime of the supported
children. Use `Mediator` only when independent machines must exchange events without a hierarchical
owner. File size alone justifies neither.

When a feature needs to communicate with its parent layer (like the navigation layer or a parent feature),
It can listen for the state changes (using SwiftUI `.onChange`) and for the expected state call a locally stored
callback closure given by the parent layer.

## Required tests

Cover legal journeys, forbidden state/event pairs, guards, output success/failure/cancellation,
stale results, retries, observation termination, activation/replacement, repeated equal outcomes,
factory identity/lifecycle, and root callback delivery. Test pure projections separately. Use the
consumer revision's `StateMachineTest` APIs and external-public-API fixtures where visibility
matters.

The compiled example lives in `../assets/ArchitectureExample` relative to this reference's skill
root. It demonstrates public contracts, internal states/events, direct typed routes, named guards, finite
failures, concrete-free feature outputs, Frameworks-to-Datasources wiring in app composition, direct
factory assembly, and closure-based feature outcomes.
