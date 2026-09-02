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

A state exists only when it changes legal inputs, observable projection, cancellation/replacement,
lifetime, persistence/recovery, or another owner's decision. A suspending call is not automatically
a state. Keep sequential non-interleavable phases inside one output or coordinator and collapse them
to the smallest semantic outcome.

Merge states with identical legal inputs, UI projection, cancellation/lifetime, recovery obligation,
and external outcome when they differ only in the next internal command. Events describe intent or
semantic facts that change machine policy; do not create one event per internal return value.

A single closed retry-plan value is valid inside one retry state when all variants have the same
legal inputs, UI/blocking behavior, lifetime/recovery, and final outcome and differ only in Retry's
internal command. Use distinct retry states when those semantics differ. Boolean flags, nullable
command bags, and open executable command containers remain forbidden.

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
targets in helpers, generate routes with loops, or put algorithms/result mapping inside `On` bodies.
Helpers may return values, plans, outputs, or semantic events but never route objects or target
states. An accepted output-only route omits `Transition` and preserves the current state.

Use capture-free named guards only for correlation, stale rejection, capability, or genuine value
policy. Map repository/platform result unions at the output boundary; only distinctions that change
machine behavior need separate event types.

## Perform the subtractive implementation pass

Before handoff:

- merge behaviorally equivalent states;
- move non-interleavable phases into local structured control flow;
- collapse mechanistic result events;
- remove duplicate retry, correlation, rollback, or cleanup policy already owned elsewhere;
- remove speculative outputs, wrappers, and topology-coupled tests;
- preserve every named correctness, privacy, data-integrity, accessibility, lifecycle, and platform
  invariant.

Escalate if a binding architecture decision prevents a behavior-preserving simplification.

## Verify state and effect behavior

Test accepted journeys, required forbidden pairs, both sides of material guards, semantic output
mapping, required cancellation/replacement, stale results, retry behavior, and no-event output
ownership. For rejection tests, assert no transition/emission and zero capability calls.

Do not demand exhaustive tests for deliberately unmodeled paths or one test per private phase.
Controller/ViewModel projections complement but do not replace raw machine tests when route legality
itself is the invariant.
