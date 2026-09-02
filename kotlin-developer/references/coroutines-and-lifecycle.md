# Coroutines and Lifecycle

<!-- kotlin-suite:KOTLIN-COROUTINES -->

## Intake before changing code

Inspect Kotlin/coroutines versions, compiler settings, JVM target, Android API levels, existing
scopes/dispatchers, Flow sharing, and lifecycle owners. Identify which layer owns the work and
whether it must survive a composable, destination/ViewModel, process, or reboot.

## Structured concurrency

- Prefer direct suspend calls, `coroutineScope`, and child `async`/`launch` whose parent owns
  completion and cancellation.
- Use `viewModelScope` for screen business work; use `lifecycleScope` only for lifecycle-owned UI
  collection/effects; use `rememberCoroutineScope` for composition-owned UI behavior.
- Inject an application/repository-owned external scope only for work intentionally outliving a
  ViewModel, and document completion/error policy. Use WorkManager for deferrable persistent work
  with OS scheduling guarantees.
- Never use `GlobalScope`. Do not create an unowned `CoroutineScope(SupervisorJob())`.
- Use `supervisorScope` only when sibling failure independence is part of the contract.
- Check cancellation in CPU loops and rethrow `CancellationException` from broad catches.

Suspension is a concurrency boundary. Revalidate mutable assumptions after a suspend call. Keep
critical decisions under one owner/lock or express them atomically in the source of truth.

## Dispatcher and main-safety policy

Suspend does not mean background thread. Repository and data-source APIs must be safe to call from
main. Move blocking file/database/legacy calls or expensive CPU work with
`withContext(injectedDispatcher)` inside the owning layer. Do not inject `Dispatchers.IO` into every
ViewModel or state-machine Output when dependencies are already main-safe.

Inject dispatchers when tests or policy need control. Avoid hard-coded unbounded parallelism; define
limits for retries, buffers, and concurrent work.

## Flow and StateFlow

Give every Flow a producer, cold/hot semantics, sharing owner, replay/buffer policy, error/termination
path, and collector lifetime. Expose immutable `Flow`/`StateFlow`, not mutable implementations.
Use `stateIn`/`shareIn` only with an intentional scope and `SharingStarted` policy. Avoid repeated
cold collection that duplicates network/listener work.

Use `callbackFlow` for repeating callbacks and unregister in `awaitClose`; use
`suspendCancellableCoroutine` for one-shot callbacks and prove exactly-once resume plus cancellation
cleanup. Never use an unbounded Channel/SharedFlow without a losslessness requirement.

Compose collects Android Flow state with `collectAsStateWithLifecycle()`. Collector visibility and
producer lifetime are distinct: stopping collection does not necessarily cancel a ViewModel-owned
machine or repository observation.

## Android lifecycle and process death

ViewModels survive configuration changes but not process death. Restore small navigation/UI inputs
from `SavedStateHandle`; reload authoritative data from persistent repositories. Do not serialize
Jobs, coroutine scopes, Flow collectors, or state-machine runtimes.

Account for destination removal, app background/foreground, multi-window, service/worker lifetime,
and process recreation. Persist durable intent/data before relying on in-memory continuation.

## Verification

Test cancellation, replacement, stale results, concurrent intent, Flow completion/error, sharing
start/stop, callback cleanup, owner cancellation, and process reconstruction. Use one
`TestCoroutineScheduler`, virtual time, `runCurrent`/`advanceUntilIdle`, and explicit gates instead
of sleeps. A clean run under stress is supplementary to clear ownership and deterministic tests.
