# Concurrency and Lifecycle

<!-- swift-suite:SWIFT-CONCURRENCY -->

## Intake before changing code

Inspect the Swift language mode, strict-concurrency level, default actor isolation, upcoming
features, deployment targets, and imported module annotations. For SwiftPM inspect `Package.swift`;
for Xcode inspect the target build settings. Diagnostics can change meaning across these settings.

Identify the current isolation boundary: nonisolated value code, `@MainActor`, another global actor,
an actor instance, or manual synchronization. Express what is true; do not apply `@MainActor` to an
entire subsystem merely to silence errors.

## Structured concurrency

- Prefer direct `async` calls, `async let`, and task groups whose parent owns completion and
  cancellation.
- Use unstructured `Task` only to bridge a synchronous lifecycle/UI callback into async work with a
  documented owner. Retain/cancel it when its lifetime is shorter than the process.
- Use `Task.detached` only when inheriting actor, priority, task locals, and cancellation would be
  incorrect and the detached lifetime is explicitly owned.
- Never block an async context with a semaphore or condition wait.
- Check cancellation in long CPU loops and propagate cancellation through streams and adapters.

An `await` is a reentrancy boundary. Revalidate actor state after suspension when another operation
could have changed the assumptions. Keep actor-isolated critical decisions synchronous where
possible.

When an operation spans authoritative identity/state observation, define whether same-identity
updates rebase the suspended operation and whether identity replacement cancels it. Apply the same
policy on success, failure, and cancellation; a cancellation path that restores stale pre-operation
state is still a race. Do not treat cooperative task cancellation as proof that a dependency cannot
deliver a late result.

A `Task {}` created from actor-isolated code normally inherits that actor. It is not a background-
execution primitive. Likewise, calling a synchronous `nonisolated` helper does not transfer work to a
different executor; the caller still performs that work. Move ownership to the correct actor or use
an explicitly justified concurrent operation rather than relying on either construct as offloading.

## Sendability and isolation

Prefer immutable Sendable values across concurrency domains. Use an actor for genuinely shared
mutable state and `@MainActor` for UI state or APIs that require it. A class with checked `Sendable`
must have a defensible immutable/synchronized design.

Treat `@MainActor` as a semantic ownership declaration, not as a generic safety annotation. A type-
wide or protocol-wide global-actor annotation isolates every instance member and propagates that
requirement into conformers, stored closures, callers, and tests. Apply it to the whole declaration
only when every operation belongs to UI/native-presentation ownership; otherwise isolate the narrow
requirements that actually need it.

Persistence, networking, JSON mapping, cache reconstruction, SDK listener management, and domain
workflow serialization do not become UI work merely because their results eventually update a view.
Put mutable non-UI state in a dedicated actor, or protect a small synchronous state cell with
`Mutex`/another documented synchronization primitive. Publish immutable `Sendable` projections to a
main-actor presentation owner at the final boundary.

For a bounded SDK seam, prefer a `Sendable` function-valued capability struct and a live factory.
The factory may close over a private actor that owns mutable or non-Sendable SDK runtime state. Tests
construct the same capability from deterministic closures; do not add a protocol or `@MainActor`
solely for mockability.

Separate mixed-isolation clients. For example, native Apple/Google presentation may remain
`@MainActor`, while token exchange, account mutation, persistence, and error mapping execute in an
actor-neutral client or a dedicated actor. Do not annotate the entire authentication abstraction
with `@MainActor` because two requirements present UIKit.

Treat `@unchecked Sendable`, `nonisolated(unsafe)`, and `@preconcurrency` as temporary or adapter-
specific escape hatches. Require a documented safety invariant, tests/evidence, narrow scope, and a
removal/migration plan. Never add one without understanding every mutable field and callback.

Do not assume async means background thread, or that an actor is a thread. Optimize isolation and
ownership, not thread folklore. An awaited network call releases its actor while suspended, but all
synchronous work before, between, and after suspension still runs on that actor.

## Streams and observations

Give each stream a producer, buffer policy, termination path, cancellation owner, and consumer
lifetime. Finish continuations exactly once and cancel producer tasks from `onTermination`. Avoid
unbounded buffers unless losslessness is a proven requirement.

Choose buffering from semantics, not convenience. Identity, authorization, transaction, logout,
security-boundary, and prerequisite transitions may require lossless ordered delivery even when the
final UI projection is newest-value state. Coalesce only events whose intermediate values are truly
irrelevant to every downstream invariant.

Do not create competing iterators over a unicast sequence. Share/multicast only at an explicit
lifetime owner. Screen visibility is not automatically data-observation lifetime; follow the
architecture contract and product semantics.

## Legacy callback bridging

Use checked continuations only for APIs that complete once. Prove every path resumes exactly once,
including error and cancellation. For repeating callbacks, use `AsyncStream` with explicit
termination instead. Preserve delegate/token lifetime until completion and unregister it on
termination.

Do not force a callback queue to `.main` merely to make a non-UI adapter compile. Bridge the callback
into the adapter’s actor or a thread-safe continuation. `MainActor.assumeIsolated` is a runtime
assertion, not a hop; use it only when an external API contract guarantees main-actor execution and
the callback is genuinely UI-owned.

## UI and process lifecycle

Keep UI mutations and native presentation on the main actor. Move expensive pure or I/O work out of
the main-actor hot path through a correctly isolated capability; do not wrap arbitrary code in a
detached task. Account for iOS scene/background transitions, macOS window/scene lifetimes, app
extensions, and process death. Persist authoritative state rather than relying on a task surviving
suspension or termination.

## Concurrency verification

Build with the consumer's actual strict settings. Test cancellation, replacement, reentrancy, stale
results, stream termination, and deallocation. For stale-result fencing, include a dependency that
ignores cancellation until a deterministic gate releases it; assert the late result causes neither
state transition nor effect. Add a regression that invokes non-UI capabilities
from a non-main actor so accidental global-actor propagation fails at compile time or in the focused
test boundary. Use deterministic gates/continuations instead of short sleeps. Run Thread Sanitizer
or actor race checks when appropriate, while recognizing that a clean run is supplementary to
compiler-enforced isolation.
