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

A concrete state is justified when its identity changes at least one of:

- the business condition or invariant currently known to hold;
- accepted external events or user actions;
- the semantic output selected for an accepted event;
- the next-state path or another externally relevant outcome;
- cancellation, replacement, correlation, or stale-result semantics;
- lifetime, persistence, commit, rollback, or process-recovery obligations;
- data availability that the type must prove;
- a decision another owner must observe.

An asynchronous call or sequential execution phase is not automatically a state. Keep phases inside
one output or coordinator when no event can legitimately interleave, cancellation/replacement does
not differ by phase, recovery need not resume from that exact point, and the phase does not establish
a business fact or invariant needed by later routes.

### Projection equivalence is not state equivalence

`SuperState` or UI state is intentionally a many-to-one presentation projection. Several concrete
business states may project to the same UI while preserving different facts, payload guarantees,
effect choices, commit boundaries, rollback rules, or future transition paths. Equal projection is
a prompt to inspect the states; it is never sufficient evidence for merging them.

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
`TripIsLoading(tripID:)` naturally represents many trip identifiers because Retry always launches
the same `LoadTrip` effect family parameterized by `tripID`.

Even when full behavioral equivalence holds, merge only when one natural payload represents both
cases and the result lowers total conceptual complexity.

### Do not relocate topology into payloads and branches

Do not merge explicit state alternatives when the merged representation must reconstruct them
through a `kind`, `mode`, `phase`, `operation`, or `retryPlan` discriminator; a nullable-field matrix;
a runtime type test; or conditional output/transition dispatch. Moving a sum type from concrete
states into one state's payload or a generic output dispatcher is topology relocation, not
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
cleanup boundary. Collapsing them into `LogoutIsAwaitingRetry(kind: ...)` and switching on `kind`
would hide rather than remove that topology.

An event represents an external intent or semantic fact that changes a machine decision. Do not
create one event for every internal return value. Several internal calls may map to one semantic
outcome when intermediate distinctions do not change legal future behavior.

Use finite feature/domain failures rather than transport strings. Map SDK/transport errors at the
output or adapter boundary. Treat cancellation as cancellation, not a business failure.

## Output cardinality and orchestration

Output cardinality and internal execution topology are independent decisions.

Choose output cardinality from machine semantics, not from the number of injected functions or
asynchronous calls:

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

One `Output` may invoke one or several injected functions when they form one cohesive business
effect. Its internal execution may be:

- **sequential** when ordering, a data dependency, a transaction boundary, or a business invariant
  requires one operation to finish before another starts;
- **concurrent** when the operations are independent and parallel execution serves the accepted
  behavior, such as reducing latency for unrelated reads or cleanup operations;
- **mixed** when a small explicit dependency graph requires sequential stages containing one or
  more concurrent groups.

Use structured concurrency owned by the `Output`, such as `async let`, `withTaskGroup`, or
`withThrowingTaskGroup`. Every child task must complete or be cancelled before the output finishes.
Do not use `Task.detached` or another unstructured task to hide work from the output lifetime.

Parallelize only semantically independent operations. Keep execution sequential when one result
feeds another operation, order is observable, the operations share mutable or transactional state,
or concurrency could violate a privacy, data-integrity, rate-limit, resource, or platform invariant.
Choose and document aggregate failure behavior: fail fast when one failure invalidates the cohesive
effect, or collect independent results when the business contract requires a combined outcome.
Cancellation must propagate through the structured child tasks.

For example, three independent cleanup capabilities may run concurrently and produce one aggregate
machine event:

```swift
let cleanupOutput = Output<AppState, AppEvent> {
  async let widgetResult = clearWidgetData()
  async let exportResult = clearTransientExports()
  async let handoffResult = clearRouteHandoffs()

  let results = await (widgetResult, exportResult, handoffResult)
  return CleanupDidFinish(summary: summarize(results))
}
```

The same internal execution could validly return `nil` when every result is fully handled and no
machine decision depends on it, or produce an `AsyncSequence` when multiple events over time are
semantically meaningful. Do not emit one event per invoked function merely because functions run
separately or concurrently. Keep intermediate results local and emit the smallest semantic event
cardinality required by the machine.

Inject effectful operations through `@Sendable` closures or a cohesive `Sendable` capability value.
The output owns orchestration, child-task lifetime, cancellation, failure aggregation, and result
mapping but never discovers the concrete implementation. App composition constructs concrete
Frameworks/Datasources and closes over their operations.

## Retry, correlation, cancellation, and observation

A shared retry state is appropriate when its payload parameterizes the same semantic retry
operation with ordinary data and the Retry route selects the same output family without branching
over operation kinds. For example, `TripIsAwaitingLoadRetry(tripID:)` can retry `LoadTrip(tripID:)`
for any identifier.

Keep distinct retry states when Retry selects different semantic effect families, business phases,
commit boundaries, authoritative owners, rollback rules, or recovery paths, even when those states
project to the same UI and accept the same Retry event.

A closed retry-plan value remains permissible when it is already a meaningful domain concept and
demonstrably improves local reasoning. Do not introduce one solely to reduce concrete-state count.
A `switch` over one case per former retry state is normally hidden topology rather than
simplification. Boolean retry flags, nullable command bags, and open executable command containers
remain forbidden.

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

When evaluating a collapse, characterize both candidate states across the accepted event alphabet.
Prove semantic output selection, next-state behavior, guards, cancellation/lifetime, invariants, and
recovery—not only UI projection. Add a negative test when a merged payload could represent an
invalid combination or when conditional dispatch would reconstruct the former alternatives.

For an output that composes several operations, test the business dependency graph rather than
implementation timing alone: prove required ordering, prove safe overlap when concurrency is
material, verify aggregate success/failure mapping, and verify cancellation of owned child work.
Do not require one event per internal operation when the machine contract has one aggregate outcome.

Tests should assert observable behavior, named invariants, and reproduced regressions. They should
not require one test per private execution phase, preserve obsolete states/events, or force exact
private topology. Conversely, do not delete meaningful business states merely to reduce type or test
counts. When topology is simplified without changing behavior, update implementation-shaped tests
and guardrails in the same focused change.

Use the consumer revision's `StateMachineTest` APIs and external-public-API fixtures where
visibility matters. The compiled example under `assets/ArchitectureExample` demonstrates one valid
shape, not mandatory topology.
