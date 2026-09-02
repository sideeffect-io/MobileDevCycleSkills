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

## Sendability and isolation

Prefer immutable Sendable values across concurrency domains. Use an actor for genuinely shared
mutable state and `@MainActor` for UI state or APIs that require it. A class with checked `Sendable`
must have a defensible immutable/synchronized design.

Treat `@unchecked Sendable`, `nonisolated(unsafe)`, and `@preconcurrency` as temporary or adapter-
specific escape hatches. Require a documented safety invariant, tests/evidence, narrow scope, and a
removal/migration plan. Never add one without understanding every mutable field and callback.

Do not assume async means background thread, or that an actor is a thread. Optimize isolation and
ownership, not thread folklore.

## Streams and observations

Give each stream a producer, buffer policy, termination path, cancellation owner, and consumer
lifetime. Finish continuations exactly once and cancel producer tasks from `onTermination`. Avoid
unbounded buffers unless losslessness is a proven requirement.

Do not create competing iterators over a unicast sequence. Share/multicast only at an explicit
lifetime owner. Screen visibility is not automatically data-observation lifetime; follow the
architecture contract and product semantics.

## Legacy callback bridging

Use checked continuations only for APIs that complete once. Prove every path resumes exactly once,
including error and cancellation. For repeating callbacks, use `AsyncStream` with explicit
termination instead. Preserve delegate/token lifetime until completion and unregister it on
termination.

## UI and process lifecycle

Keep UI mutations on the main actor. Move expensive pure or I/O work out of the main-actor hot path
through a correctly isolated capability; do not wrap arbitrary code in a detached task. Account for
iOS scene/background transitions, macOS window/scene lifetimes, app extensions, and process death.
Persist authoritative state rather than relying on a task surviving suspension or termination.

## Concurrency verification

Build with the consumer's actual strict settings. Test cancellation, replacement, reentrancy, stale
results, stream termination, and deallocation. Use deterministic gates/continuations instead of
short sleeps. Run Thread Sanitizer or actor race checks when appropriate, while recognizing that a
clean run is supplementary to compiler-enforced isolation.
