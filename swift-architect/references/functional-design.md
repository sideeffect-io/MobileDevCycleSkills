# Functional and Hexagonal Design

<!-- swift-suite:SWIFT-FUNCTIONAL-DESIGN -->

## Functional core, imperative shell

Model decisions as immutable values and pure, total functions. Keep I/O, task creation, mutation,
SDK calls, clocks, randomness, and global process state at explicit boundaries. The same input plus
the same injected context must produce the same decision.

Prefer algebraic data types: use `struct` or tuples for products and `enum` for sums/alternatives.
Compose absence with `Optional` and finite success/failure with `Result` when the reason matters.
Prefer validated values that make illegal states unrepresentable. Do not put raw `Error`, SDK
payloads, tasks, continuations, repositories, or runtime objects inside domain values, states, or
events.

Use higher-order functions when they make policy or transformation explicit: capabilities,
predicates, sort keys, mappings, validation rules, and strategy selection. Prefer platform-provided
operations—`map`, `compactMap`, `flatMap`, `filter`, `reduce`, `reduce(into:)`,
`Dictionary.merge`/`merging`, set algebra, and available `AsyncSequence` algorithms—when they read
as the transformation being performed. Use an asynchronous `merge` only when the selected toolchain
or an explicit package dependency provides it. Name an intermediate function when a chain obscures
intent. Never hide I/O or shared mutation inside a collection operator, and do not introduce a
custom FP/operator library when platform concepts are sufficient.

Do not pursue advanced FP vocabulary for its own sake. Prefer the simplest value/function design
that improves local reasoning, composition, determinism, or testability.

## Hexagonal ownership

Treat UI and workflow entry points as inbound adapters, and persistence/network/system services as
outbound adapters. The high-level consumer owns the port it needs:

- a feature-owned `Sendable` capability struct with `@Sendable` closures for a small effect seam;
- a narrow protocol when multiple implementations, associated behavior, or identity semantics are
  genuinely part of the contract;
- a concrete value/function when there is no substitution requirement.

The app composition root connects ports to adapters. Domain and feature code do not know which SDK,
database, or transport satisfies them. Convert implementation failures into finite domain/feature
failures before they enter state or user-facing projections.

Treat a state-machine output as feature-owned effect orchestration. Store only injected `@Sendable`
closures or cohesive `Sendable` capability structs in the output/dependency value. The output may
sequence those operations and map their domain-shaped success, failure, and cancellation into events;
it must not import, initialize, locate, or retain a concrete Frameworks client, Datasource, DAO,
repository implementation, SDK singleton, or app environment.

App composition builds the concrete path: construct generic low-level Frameworks wrappers, construct
data-domain Datasources from them, then close over Datasource operations when creating the
feature-owned output ports. This keeps policy pointing inward while concrete construction remains at
the process boundary. Composition owns construction and lifetime; the output retains use-case
sequencing, cancellation behavior, and result-to-event translation.

Avoid broad repository/service protocols that mirror a concrete class. Apply ISP: split by consumer
need, not CRUD categories. Apply DIP: dependencies point toward policy, while concrete construction
stays outside. A capability bag is acceptable only when its members form one cohesive use case; it
must not become a global service locator.

## SOLID in Swift

- **SRP:** Give each target/type/function one coherent responsibility and reason to change. Split by
  policy, projection, adapter, orchestration, lifecycle, or assembly—not by arbitrary line ranges.
- **OCP:** Add variants by composing values, functions, capabilities, or new conformers at a stable
  seam. Do not introduce abstraction until a real variation axis exists.
- **LSP:** If subtyping exists, every implementation must preserve the caller-visible contract,
  including errors, cancellation, ordering, and actor isolation. Prefer composition when this is
  difficult to state and test.
- **ISP:** Expose the smallest consumer-specific interface. Read-only consumers do not receive
  mutation, and a feature does not receive an entire SDK client for one operation.
- **DIP:** High-level policy owns domain-shaped abstractions; application composition supplies live
  implementations.

## Protocol-oriented and object-oriented design

Functional/value design is the default. Add a protocol when it expresses a stable semantic contract
with more than one useful implementation or enables necessary existential/generic composition. Do
not add a protocol solely to mock one closure; inject the closure or capability directly.

Use a class for identity, shared ownership, framework interoperation, or reference lifecycle. Make
it `final` unless external subclassing is a required API. Isolate shared mutable state with an actor
or a documented synchronization primitive. Never add `@unchecked Sendable` merely to silence the
compiler.

## Pure decision checklist

A candidate pure function should:

- depend only on parameters and immutable captured values;
- cover every valid input without traps or hidden preconditions;
- return a value describing the result or finite failure;
- avoid logging, metrics, storage, networking, UI mutation, task creation, and global reads;
- remain safe to call from any actor unless its input contract says otherwise;
- have direct deterministic tests, including boundaries and invalid input.

If locale, calendar, time zone, clock, UUID, permissions, feature flags, or randomness affects the
result, pass it explicitly or include it in a cohesive environment value.
