# Functional and Hexagonal Design

<!-- kotlin-suite:KOTLIN-FUNCTIONAL-DESIGN -->

## Functional core, imperative shell

Model decisions as immutable values and pure, total functions. Keep I/O, coroutine creation,
mutation, Android/vendor calls, clocks, randomness, and globals at explicit boundaries. The same
input plus injected context should produce the same decision.

Prefer algebraic data types:

- `data class` or value class for products and validated values;
- `sealed interface`/`sealed class` for finite alternatives;
- nullable types only for genuine absence;
- a finite result/failure type when callers need a reason.

Do not place `Throwable`, DTO/entity objects, SDK clients, Jobs, coroutine scopes, repositories, or
runtime controllers inside domain values, workflow states, or events.

Use higher-order functions where they clarify policy: capabilities, predicates, mappings,
validation, sorting, and strategies. Prefer Kotlin standard operations—`map`, `mapNotNull`,
`flatMap`, `filter`, `fold`, `associate`, `groupBy`, set algebra—and supported Flow operators when
they read as the transformation. Name intermediate functions when a chain hides intent. Never hide
I/O or shared mutation inside a collection operator, and do not add an FP/operator library merely
for vocabulary.

## Hexagonal ownership

Treat UI/workflow entry points as inbound adapters and persistence/network/system services as
outbound adapters. The high-level consumer owns the port it needs:

- a suspending function or `fun interface` for one small effect;
- a cohesive interface for a stable multi-operation contract;
- a concrete value/function when substitution is unnecessary.

Application/Hilt composition connects Feature ports to Datasources backed by generic Frameworks. A
Feature can sequence injected operations and translate domain-shaped success/failure/cancellation
into events, but it never initializes or locates the concrete repository, data source, Framework, or
SDK. Convert implementation failures before they enter state or user-facing projections.

Avoid interfaces that mirror every method on one implementation. Apply ISP by consumer need and DIP
by keeping policy pointed inward. A dependency container passed through the graph is a service
locator even if its properties are typed.

## SOLID in Kotlin/Android

- **SRP:** one coherent responsibility and reason to change per module/type/function.
- **OCP:** add variants through values, functions, sealed alternatives, or real interface seams.
- **LSP:** implementations preserve error, cancellation, ordering, threading, and lifecycle
  contracts. Prefer composition when substitutability is hard to state.
- **ISP:** expose the smallest consumer-specific surface; read-only consumers do not receive writes.
- **DIP:** UI/domain policy depends on application-shaped contracts; application composition
  supplies concrete adapters.

## Interface and class decisions

Functional/value design is the default. Add an interface when multiple implementations form a real
semantic family, a module boundary needs a public contract, or reference identity/lifecycle is part
of the contract. Do not add a one-method interface solely to mock it when a function value is clear.

Use a class for identity, shared ownership, Android/framework interoperation, or controlled mutable
lifecycle. Keep it final by default (Kotlin's normal class behavior). Encapsulate shared mutation
with one owner, `Mutex`, atomics, or another documented primitive; do not assume coroutine usage
alone makes state race-safe.

## Pure decision checklist

A pure function should:

- depend only on parameters and immutable captures;
- cover every valid input without hidden preconditions;
- return a value describing success or finite failure;
- avoid logging, metrics, storage, network, UI mutation, coroutine launch, and globals;
- remain safe from any dispatcher unless its input contract says otherwise;
- have direct deterministic tests for boundaries and invalid input.

Pass locale, time zone, clock, ID generator, permissions, feature flags, or randomness explicitly
whenever it affects the result.
