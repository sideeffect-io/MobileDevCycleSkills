# Finding Catalog

<!-- kotlin-suite:REVIEW-FINDING-CATALOG -->

Use this catalog for coverage, not checklist noise. Report only evidence-backed issues with concrete
impact.

## Boundaries and ownership

- package-only boundary while Gradle still permits forbidden access;
- reverse/cyclic module edge, umbrella dependency, or broad `api` exposure;
- UI/ViewModel depends on a data source, DAO, transport model, or concrete SDK;
- repository/source-of-truth ownership is duplicated or ambiguous;
- domain layer is a forwarding ceremony or contains mutable/application lifecycle state;
- public implementation type added only to compile or test;
- third-party/plugin/version change lacks canonical architecture approval;
- Hilt/application composition absorbs feature policy or a service locator leaks inward;
- child feature owns parent routes or receives repository/private prepared state;
- multiple state/reducer/machine owners or undocumented singleton/scope lifetime;
- resources, DI bindings, generated sources, or tests live in the wrong module/source set.

## Functional core and workflow

- Boolean/null fields model an exclusive alternative and allow impossible combinations;
- domain/state/event performs I/O or stores Job/scope/runtime/SDK/Throwable;
- nondeterministic clock/ID/locale/global read enters a pure decision;
- custom operator abstraction obscures standard collection/Flow operations;
- output/effect bypasses an event and directly mutates UI state;
- stale completion lacks correlation or cancellation becomes business failure;
- state-machine route hides policy in large inline guards/cancellation lambdas;
- state-machine target is hidden behind a helper/local/generic state, or an `On` body contains
  branching, iteration, result mapping, or another algorithm;
- machine event carries a result/update union or success discriminator instead of an atomic fact;
- retry legality is hidden in an enum, nullable command, flag, or equivalent state discriminator;
- a forbidden or guard-rejected event starts an output or uses an equal-state transition as a
  no-route substitute;
- machine construction starts I/O or an `init` block creates hidden work;
- mailbox rejection, retry, buffering, or observation lifetime is undefined;
- machine is split by line count rather than independent workflow/outcome ownership;
- feature emits a route instead of a semantic outcome.

## Kotlin, coroutines, and data

- `!!`, unchecked cast, swallowed exception, or raw exception message without proved invariant;
- Boolean mode parameter, argument train, or unrelated dependency bag;
- interface/mock abstraction with no real boundary or variation;
- unowned `CoroutineScope`, `GlobalScope`, unjustified `SupervisorJob`, or fire-and-forget launch;
- `CancellationException` swallowed by a broad catch;
- blocking or CPU-heavy work on main because the repository is not main-safe;
- mutable state read after suspension without revalidation/serialization;
- `callbackFlow` misses `awaitClose`, continuation can resume zero/multiple times;
- Flow sharing/replay/buffer/termination owner is undefined or cold Flow is collected repeatedly;
- independent test schedulers, sleeps, or real dispatchers make async tests nondeterministic;
- repository exposes DTO/entity/SDK failure or violates its declared source of truth.

## Compose and product quality

- business state duplicated between `remember` and ViewModel/machine;
- child composable receives ViewModel/repository/NavController/Hilt component;
- composable performs direct I/O/business policy or uses incorrectly keyed effects;
- unstable lazy keys, mutable collections, or false stability annotation breaks identity/recomposition;
- lossy one-shot Channel/SharedFlow used for durable navigation/message state;
- gesture replaces semantic control; accessibility role/state/focus/hit target missing;
- user-facing string/plural/accessibility text bypasses resources or locales diverge;
- phone-only assumptions break adaptive/foldable/multi-window behavior;
- API unavailable on min SDK or release/R8 behavior is unverified;
- performance claim lacks a comparable measurement.

## Tests and evidence

- happy path only; failure/cancellation/stale/retry/recovery omitted, or forbidden-route tests do
  not prove both no state transition/emission and no output capability call;
- local test asserts Android behavior it cannot execute, or instrumented test replaces cheap pure test;
- test relies on live backend, shared global/resource, timing sleeps, or implementation-shaped mocks;
- ViewModel `WhileSubscribed` state is never collected in the test;
- guardrail uses fragile regex where Gradle/Kotlin structure is required;
- validation omits module/variant/task/device/exit code or treats unrelated failure as success;
- runtime claim has only an assembly; performance/leak fix lacks before/after proof.

## Severity calibration

Use `blocker` for demonstrated unsafe merge conditions. Use `high` when behavior, data, security,
architecture enforcement, coroutine/lifecycle, recovery, or accessibility can plausibly break. Use
`medium` for bounded material maintainability/product/test/performance risk. Use `low` sparingly for
objective cleanup. Formatter preference alone is not a finding unless an enforced gate fails.
