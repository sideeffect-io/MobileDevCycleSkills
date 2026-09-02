# Production Kotlin

<!-- kotlin-suite:KOTLIN-PRODUCTION -->

## API and naming

Follow the repository formatter/linter and Kotlin coding conventions. Optimize for clarity at the
call site. Types/properties are nouns, functions describe actions, and Boolean names read as
predicates. Use domain terminology consistently; avoid platform or transport vocabulary in domain
and feature state.

Design the call site before the declaration. Avoid Boolean mode parameters; use a sealed alternative
or distinct semantic operation. Put defaults after required parameters. Document public contracts,
non-obvious complexity, thread/main-safety, cancellation, ordering, and surprising failure behavior.

Use the narrowest visibility. Keep implementation details `private`, module collaboration
`internal`, and only real cross-module/library contracts public. Remember that public Kotlin/JVM APIs
are binary/metadata commitments; inline functions and default arguments can expand compatibility
surface.

## Value and functional design

Prefer immutable `data class` products, value classes for validated identifiers, and sealed types
for alternatives or mutually exclusive modes. Use nullable types only for absence. Use finite result
and failure types when callers need a reason; do not expose arbitrary exception text or sentinel
values as domain failure. Preserve `CancellationException` separately.

Keep transformations pure and total. Pass environment inputs explicitly. Prefer standard
`map`, `mapNotNull`, `flatMap`, `filter`, `fold`, `associate`, `groupBy`, sorting, set operations,
and supported Flow operators when clear. Extract named predicates/mappings when a closure holds
policy. Do not create clever operator DSLs or hide I/O/mutation in a pipeline.

## Interface and class decisions

Use a function value or `fun interface` for one small effect surface. Introduce an interface for a
stable multi-operation contract, real cross-module boundary, or meaningful alternative
implementations. Do not create an interface solely because a mocking library prefers one.

Use classes for identity, shared ownership, Android/framework integration, and lifecycle. Kotlin
classes are final by default; open only a designed extension point. Prefer composition over
inheritance. State and test substitutability, cancellation, ordering, and thread-safety guarantees
when a hierarchy exists.

## Nulls, errors, and resources

Avoid `!!`, unchecked casts, swallowed exceptions, and broad `catch (Throwable)`. Use `require` for
caller preconditions, `check` for internal state invariants, and exhaustive `when` for finite
alternatives. Catch expected exceptions at the boundary that can translate them; rethrow
`CancellationException` before `Exception` catches.

Close files/cursors/streams with `use`, unregister callbacks in `awaitClose`, and give every Job,
Flow sharing scope, listener, database transaction, and cache an explicit owner/lifetime. Do not put
secrets or personal data in logs, errors, test fixtures, screenshots, reports, or handoffs.

## Readability and cleanliness

- Keep one abstraction level per function and one coherent reason to change per owner.
- Prefer early returns and exhaustive `when` over deep nesting.
- Name intermediate values that expose business meaning.
- Remove dead code, stale comments, unused dependencies, wrappers, flags, and temporary adapters in
  the focused scope after parity is proven.
- Avoid global mutable state, service locators, hidden singletons, and broad dependency bags.
- Comment invariants, tradeoffs, ownership, and why—not syntax.
- Apply [engineering metrics](engineering-metrics.md) as review signals, never mechanical split rules.

## Android boundaries

Keep `Context`, `Resources`, Compose types, `NavController`, lifecycle owners, DTOs/entities, DAOs,
Retrofit/Room/Firebase types, and Android services out of pure/domain values and workflow state.
Convert at UI, data, or technology adapter boundaries. Repository/data-source suspend APIs are
main-safe; callers should not need to guess a dispatcher for ordinary operations.
