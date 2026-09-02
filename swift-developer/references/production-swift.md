# Production Swift

<!-- swift-suite:SWIFT-PRODUCTION -->

## API and naming

Follow the repository formatter and Swift API Design Guidelines. Optimize for clarity at the point
of use. Types and properties are nouns; functions describe actions; boolean names read as
assertions. Use domain terminology consistently and avoid abbreviations unless established by the
platform or domain.

Design the call site before the declaration. Use argument labels to express grammar and meaning.
Put defaulted parameters after required ones. Avoid boolean mode flags; use an enum or separate
semantic operation. Document public APIs, invariants, complexity that is not O(1), cancellation,
actor isolation, and surprising failure behavior.

Choose the narrowest access level. Keep implementation helpers `private`, module collaboration
`internal`, deliberate same-package seams `package`, and only real cross-module contracts `public`.
Use `fileprivate` rarely and `open` only for designed external subclassing.

## Value and functional design

Prefer algebraic data types: immutable structs or tuples for products and enums for
sums/alternatives and mutually exclusive modes. Compose absence with `Optional` and finite
success/failure with `Result`. Make invalid states unrepresentable with validated value types and
failable/throwing factories rather than comments or setter order.

Keep transformations pure and total. Pass environmental inputs explicitly. Prefer platform-provided
`map`, `compactMap`, `flatMap`, `filter`, `sorted(by:)`, `reduce`, `reduce(into:)`,
`Dictionary.merge`/`merging`, set algebra, and available `AsyncSequence` algorithms when the
transformation reads clearly. Use asynchronous `merge` only when the toolchain or an explicit
dependency provides it. Extract named predicates/transformations when a closure contains policy or
a pipeline becomes hard to scan. Avoid clever point-free composition or a custom FP/operator
library when a direct platform function is clearer.

Use `Optional` only for absence. Use a finite error type or `Result` when callers need a reason.
Do not expose transport errors, arbitrary strings, or sentinel values as domain failure. Preserve
`CancellationError`/cancellation separately from business failure.

## State-machine implementation with SwiftStateMachine

Use SwiftStateMachine for significant business features, navigation workflows, and flows with
legal state constraints, async effects, retry/recovery, or cancellation requirements.
When a workflow is simple presentation/state reflection, use plain SwiftUI state instead.

Treat each workflow as a compact state transition contract:

- Define concrete, `Equatable & Sendable` value states and events.
- Keep machine definitions deterministic and side-effect free.
- Place all async work in outputs/capabilities passed through composition.
- Represent outcomes explicitly and feed them back into the machine as events.

A minimal implementation sequence is:

1. Define one owner-authored state graph with initial state, terminal states, legal transitions, and
   outputs/events in that feature owner.
2. Build the machine in the owner with an `AsyncStateMachineFactory` (or equivalent DSL for the
   pinned revision), owned as process-local immutable environment.
3. Inject concrete work as closure-based capabilities (API clients, repositories, location, storage),
   never create concrete infra objects inside machine declarations.
4. Mount `StateMachineView`/`UIStateMachine` at the feature root and pass only projection + callback
   contracts to children.

Map every async result to a single explicit event and require cancellation, stale-result, and retry
behaviors in tests. Use named guards/cancellation predicates for any branch where ordering or idempotency
matters.

For exact type names, repository-owned DSL shape, and tests, read the pinned SwiftStateMachine revision in
the live checkout first, then apply this doc as the workflow template.
For detailed machine topology and contract examples, follow the design reference in
[SwiftStateMachine Feature Design](state-machine-features.md).

## Functional programming as default paradigm

Functional programming is the default style for Swift implementation in this skill scope. Prefer pure,
explicit transformations and explicit effect boundaries over object-oriented mutation.

- Represent domain behavior as pure functions from inputs to outputs where possible.
- Make impossible states unrepresentable through types and finite enums.
- Keep state immutable by default; expose explicit mutating transitions at feature boundaries.
- Isolate side effects in small injected capabilities owned by composition, not in feature core types.
- Prefer `map`/`filter`/`reduce` pipelines to hand-rolled loops for deterministic logic.
- Use output/effect orchestration to model async behavior; avoid ad-hoc callback sprawl.

Imperative constructs are acceptable for UI event wiring and platform interop, but they must remain shallow
and local. Default to functional structure first, then add imperative layers only where API or lifecycle
requirements require them.

## Protocol and reference decisions

Use a capability struct with `@Sendable` closures for a small injected effect surface. Introduce a
protocol when multiple implementations form a stable semantic family, generic constraints add
value, or reference identity/lifecycle is part of the contract. Do not create one-method protocols
solely for mocks.

Use a class for identity, shared ownership, framework inheritance/interoperation, or lifecycle. Make
it `final` by default. Prefer composition over inheritance. If a hierarchy is required, state and
test substitutability, error, cancellation, and isolation guarantees.

## Readability and cleanliness

- Keep one abstraction level per function and one coherent reason to change per owner.
- Prefer early `guard` exits over deep nesting.
- Name intermediate values when they expose business meaning.
- Remove dead code, stale comments, redundant wrappers, unused dependencies, and needless type
  erasure in the same focused scope.
- Avoid force unwraps and `try!` outside proven startup/test invariants. State the invariant when used.
- Avoid global mutable state, service locators, hidden singletons, and broad dependency containers.
- Group extensions by conformance or semantic capability, not arbitrary numbering.
- Keep comments for why, contracts, invariants, and tradeoffs. Let names and types explain what.

Apply the canonical [engineering metrics](engineering-metrics.md). A cohesive request/options value
is better than an argument train; a grab-bag parameter object is not. Split at stable
responsibilities, not arbitrary length.

## Foundation and platform APIs

Prefer typed Foundation APIs, `FormatStyle`, `URL`, `Calendar`, `Locale`, `Clock`, and safe path/file
APIs over string construction. Inject locale/calendar/time zone for deterministic policy. Keep
UIKit/AppKit/Core Data/CloudKit/network/vendor objects out of Domain and feature state. Convert them
at Frameworks/Datasources boundaries and respect API availability for every supported
platform/deployment target. A combined Infrastructure target is an explicit legacy/cohesive
fallback, not the preferred layer name.

The compiled examples in `../assets/ProductionExample` are authoritative for this skill's code
style. If a prose example and compiled fixture diverge, fix both before using either.
