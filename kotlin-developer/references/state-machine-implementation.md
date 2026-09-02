# Kotlin State Machine Implementation

<!-- kotlin-suite:KOTLIN-STATE-MACHINE-IMPLEMENTATION -->

## Preserve the behavioral contract first

Before changing topology, enumerate accepted external intents, observable states/outcomes, named
invariants, and required adverse paths. Classify concrete state/event pairs as accepted, guarded, or
forbidden only where the distinction is part of the contract. A forbidden or rejected event means
no transition and no output; it does not mean an equal-state transition.

Do not preserve a private state/event inventory merely because existing tests encode it. Add
characterization tests for unclear behavior before simplification, then make tests assert the
behavior or invariant rather than the old decomposition.

## Implement behavioral topology

A state exists when its identity changes a business invariant, legal inputs, semantic output,
next-state path, data availability, cancellation/replacement, correlation, lifetime,
persistence/commit/rollback/recovery, or another owner's decision. A suspending call is not
automatically a state. Keep sequential non-interleavable phases inside one output or coordinator
when those phases establish no fact needed by later routes.

UI projection is intentionally many-to-one. Two states may project to the same UI and accept the
same event types while still representing different business phases or selecting different effects.
Equal UI is therefore a review signal, not a merge rule.

Treat states as merge candidates only after proving full behavioral equivalence across the accepted
event alphabet:

- they represent the same business condition and invariants;
- they accept and reject the same events with the same meaning;
- each accepted event selects the same semantic output and the same or behaviorally equivalent next
  state;
- guards, cancellation, replacement, stale-result, correlation, lifetime, persistence, rollback,
  and recovery semantics are equivalent;
- differences are ordinary data parameters of the same route and effect family.

Even then, merge only when one natural payload represents both cases and total conceptual
complexity decreases.

## Do not relocate topology into payloads

Do not collapse states when the merged state needs a `kind`, `mode`, `phase`, `operation`, or
`retryPlan` discriminator; a nullable-field matrix; runtime type checks; or conditional
output/transition dispatch to reconstruct the former alternatives. Moving a sealed alternative into
a payload and a `when` expression is topology relocation, not simplification.

Keep states separate when their type identity expresses a business phase or historical fact, proves
different data availability, prevents invalid payload combinations, selects a different semantic
output or next-state path for the same event, marks a different owner/commit/rollback/recovery
boundary, or keeps the DSL sentence-readable.

Branching remains valid for genuine data/domain policy and result mapping. Branching introduced only
to recover a removed state distinction is evidence that the alternatives should remain explicit.

A useful shorthand is:

> Payload represents data within one behavior. Concrete state alternatives represent different
> behavior.

For example, these states may share one Retry UI but should remain separate when Retry starts
different semantic effects:

```text
When LogoutIsAwaitingAuthenticationRetry
  On LogoutRetryWasRequested
  -> Output RetryAuthentication

When LogoutIsAwaitingPrivateCleanupRetry
  On LogoutRetryWasRequested
  -> Output RetryPrivateCleanup
```

By contrast, `TripIsAwaitingLoadRetry(tripId)` is one natural state when Retry always invokes the
same `LoadTrip(tripId)` operation for any identifier.

## Retry representation

A shared retry state is appropriate when its payload parameterizes the same semantic retry operation
and the Retry route selects one output family without branching over operation kinds.

Keep distinct retry states when Retry selects different effect families, business phases, commit
boundaries, authoritative owners, rollback rules, or recovery paths, even when the UI and accepted
Retry event are identical.

A closed retry plan is allowed when it is already a meaningful domain concept and demonstrably
improves local reasoning. Do not introduce one solely to reduce state count. A `when` with one branch
per former retry state is normally hidden topology. Boolean flags, nullable command bags, and open
executable command containers remain forbidden.

Carry correlation only for real overlap, replacement, stale completion, repeated equal delivery, or
cross-owner acknowledgement. Do not add per-phase IDs to a proved serialized/single-flight workflow
for uniformity.

## Choose the correct output cardinality

Resolve the consumer's exact KotlinStateMachine revision before implementation. At the currently
inspected API:

- `Output` executes `suspend () -> EventSet?`; return an event for one semantic result;
- returning `null` from `Output` emits no event;
- `OutputFlow` executes `suspend () -> Flow<EventSet>` for genuine zero-to-many events.

A no-event output remains runtime-owned. Never create an unowned scope or detached coroutine to
simulate fire-and-forget. Use no event only when the effect is fully contained and its result cannot
affect legal state, UI, Navigation, acknowledgement, privacy, data integrity, retry, or recovery.

One output may call several injected suspending capabilities in order and keep intermediate results
local. Emit only the semantic outcome that changes the machine's next decision. Failures that can
expose account data, lose accepted data, or gate continuation must be resolved authoritatively or
returned as a semantic event.

## Keep sentence-readable routes

Follow repository naming; when no stricter grammar exists, use `<Owner>Is<PresentCondition>` states
and events such as `<Owner><Operation>WasRequested` or `<Owner><Outcome>DidOccur`.

Each route exposes the sentence directly:

```text
When concrete current state, on concrete event, transition to literal concrete state
and/or start a named output.
```

Use a literal state constructor/object or `state.copy(...)` with a visible value change. Do not hide
targets in helpers, generate routes with loops, or put topology-reconstruction algorithms inside
`On` bodies. Helpers may return values, plans, outputs, or semantic events but never route objects or
target states. An accepted output-only route omits `Transition` and preserves the current state.

Use capture-free named guards only for correlation, stale rejection, capability, or genuine value
policy. Map repository/platform result unions at the output boundary; only distinctions that change
machine behavior need separate event types.

## Perform the subtractive implementation pass

Before handoff:

- inspect apparent duplicate states using the full event-to-output/transition equivalence test;
- merge only when behavior and invariants are equivalent and no discriminator, payload union,
  invalid combination, or conditional dispatch is introduced;
- preserve separate states when their explicit alternatives improve business meaning and DSL
  readability;
- move non-interleavable phases into local structured control flow;
- collapse mechanistic result events;
- remove duplicate retry, correlation, rollback, or cleanup policy already owned elsewhere;
- remove speculative outputs, wrappers, and topology-coupled tests;
- preserve every named correctness, privacy, data-integrity, accessibility, lifecycle, and platform
  invariant.

Reducing concrete-state count is not a success metric. Optimize total semantic and local-reasoning
complexity. Escalate if a binding architecture decision prevents a behavior-preserving
simplification.

## Verify state and effect behavior

Test accepted journeys, required forbidden pairs, both sides of material guards, semantic output
mapping, required cancellation/replacement, stale results, retry behavior, and no-event output
ownership. For rejection tests, assert no transition/emission and zero capability calls.

When assessing a merge, characterize both candidates across their accepted events and assert effect
selection, next-state behavior, invariants, and recovery—not only UI projection. Add a negative test
when a merged payload could encode an invalid combination or conditional dispatch would recreate the
former alternatives.

Do not demand exhaustive tests for deliberately unmodeled paths or one test per private phase.
Controller/ViewModel projections complement but do not replace raw machine tests when route legality
itself is the invariant.
