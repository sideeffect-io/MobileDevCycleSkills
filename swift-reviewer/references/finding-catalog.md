# Finding Catalog

<!-- swift-suite:REVIEW-FINDING-CATALOG -->

## Contents

- [Boundaries and ownership](#boundaries-and-ownership)
- [Functional core and workflow](#functional-core-and-workflow)
- [Swift and concurrency](#swift-and-concurrency)
- [System surfaces](#system-surfaces)
- [SwiftUI and product quality](#swiftui-and-product-quality)
- [Tests and evidence](#tests-and-evidence)
- [Severity calibration](#severity-calibration)

Use this catalog to improve coverage, not to generate checklist noise. Report only issues supported
by scoped evidence and concrete impact.

## Boundaries and ownership

- folder-only boundary; target graph still permits forbidden import;
- reverse or cyclic edge, front-facing module importing Frameworks/Datasources (or a combined
  Infrastructure fallback), sibling adapters coupled;
- umbrella dependency/import hides exact ownership;
- vendor SDK linked above its owning adapter without need;
- a third party or pin-policy change lacks the architecture-owned canonical approval record, or its
  implementation restatement differs in identity, source, owner, requirement, selection, reference,
  or authorizer;
- public implementation type or setter added only to satisfy compilation/tests;
- feature owns routes, parent prepares child-private context, child receives repository/SDK object;
- Feature/Navigation output constructs a concrete provider, or composition absorbs output sequencing
  or result-to-event mapping;
- multiple state/runtime owners, unstable factory creation, undocumented singleton lifetime;
- one-consumer target with no distinct dependency set or forbidden edge;
- pass-through wrapper/factory or empty dependency/output type with no lifetime or effect seam;
- resources or unit tests live outside their owner.

## Functional core and workflow

- Boolean/optional fields model an algebraic alternative and permit impossible combinations;
- custom FP/operator abstraction obscures a transformation already expressed clearly by platform
  `map`, `compactMap`, `flatMap`, `filter`, `reduce`, `Dictionary.merge`/`merging`, set operations,
  or available `AsyncSequence` algorithms; asynchronous merge is assumed without toolchain or
  explicit-dependency support;
- state/event/domain value performs I/O or stores task/runtime/SDK/raw error;
- clock/UUID/locale/global read makes a decision nondeterministic;
- interacting flags represent impossible modes;
- output result bypasses an event or directly mutates UI/state;
- stale completion lacks correlation; cancellation is mapped to business failure;
- inline state-machine guard/cancellation predicate hides policy;
- DSL routes hidden behind helpers or a second transition representation;
- large machine split by file size rather than meaningful workflow/outcome;
- feature emits route instead of semantic outcome or child stores parent machine.

## Swift and concurrency

- force unwrap/`try!` without a proved invariant;
- boolean mode parameter, excessive argument train, broad dependency bag;
- protocol/mock abstraction with no real variation; non-final reference type without subclass contract;
- blanket `@MainActor`, unowned unstructured task, unjustified `Task.detached`;
- `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency` without safety proof;
- actor state used after `await` without revalidation;
- continuation can resume zero/multiple times; stream lacks termination/buffer policy;
- blocking wait in async code, lost cancellation, competing iterator on unicast sequence.

### Representative finding: cancellation mapped to business failure

When an adapter's catch-all maps every thrown error to an unavailable result, cancellation becomes a
user-visible failure and retry policy can run for work the caller deliberately stopped:

```swift
do {
  return .success(try await fetch())
} catch {
  return .failure(.unavailable)
}
```

Require the adapter to preserve every cancellation representation in its declared transport contract
before applying the finite business-error fallback:

```swift
do {
  return .success(try await fetch())
} catch is CancellationError {
  return .cancelled
} catch {
  let foundationError = error as NSError
  if foundationError.domain == NSURLErrorDomain,
    foundationError.code == NSURLErrorCancelled
  {
    return .cancelled
  }
  guard !Task.isCancelled else { return .cancelled }
  return .failure(.unavailable)
}
```

A strong finding identifies the concrete cancellation representation the adapter can receive,
including Foundation bridging where applicable, the incorrect user/workflow impact, the smallest
mapping correction, and a regression test that exercises that representation. Do not prescribe a URL
loading cancellation check when the selected transport cannot emit it.

## System surfaces

- an App Intent mirrors screens, navigation, or the persistence graph instead of one user-valued action;
- an `AppEntity` exposes implementation data, an `EntityQuery` adds taxonomy without disambiguation
  value, or fixed choices avoid a simpler `AppEnum`;
- business policy or concrete persistence/network access lives in the intent instead of an injected
  feature/domain capability;
- inline versus open-app behavior is ambiguous, or app opening bypasses the single owned runtime
  handoff;
- authorization, permission, correlation, idempotency, repeated/delayed invocation, stale entities,
  cancellation, finite failure, or recovery is unmodeled;
- shortcut titles, phrases, prompts, dialogs, or display representations are incomplete across
  supported locales;
- owning-target/process or host compilation is presented as proof without invocation from the actual system surface.

## SwiftUI and product quality

- child view stores workflow runtime or performs persistence/network/routing;
- wrong source-of-truth wrapper, duplicate mutable state, unstable list/view identity;
- I/O/business logic/heavy work in `body`; multiple booleans for exclusive presentation;
- gesture replaces semantic control; accessibility label/value/focus/hit target missing;
- adaptive behavior is unproved for an applicable Dynamic Type, color/contrast, motion, iPad
  multitasking/window, keyboard/pointer, or VoiceOver variant;
- user-facing string bypasses localization or package uses wrong bundle;
- locale set incomplete across UI, accessibility, notification, widget, intent, export, or metadata;
- API unavailable on supported deployment target; iPhone assumption breaks macOS interaction;
- performance claim lacks measurement or optimization broadens invalidation/lifetime.

## Tests and evidence

- happy path only; failure/cancellation/stale/retry/recovery omitted;
- unit test in app bundle rather than owner; broad shared test support bypasses boundaries;
- empty module-load test exists only to preserve target symmetry;
- test sleeps to sequence async work, shares mutable global/resource, or depends on live backend;
- `#expect` hides a required prerequisite, `.serialized` masks fixable shared state, a known failure is
  disabled instead of tracked with `withKnownIssue`, or availability/filtering hides a suite;
- implementation-shaped mocks make refactor impossible without behavior value;
- guardrail uses fragile whitespace/regex where AST/manifest structure is required;
- style-only guardrail costs more to maintain than the correctness or boundary risk it protects;
- validation claim omits command/destination/result or treats unrelated failure as success;
- runtime claim is supported only by build or the wrong process; a first-party trace is
  unsymbolicated or lacks UUID-matched build symbols; performance/leak proof lacks a comparable flow
  or the claimed retaining-path removal.

## Severity calibration

Use `blocker` for demonstrated unsafe merge conditions. Use `high` when the defect or missing proof
can plausibly break important behavior, safety, architecture enforcement, lifecycle, or product
access. Use `medium` for bounded but material maintainability/product/test/performance risk. Use
`low` sparingly for objective cleanup. Repository formatter preference alone is not a review finding
unless it fails an enforced gate.
