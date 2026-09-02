# Kotlin State Machine Implementation

<!-- kotlin-suite:KOTLIN-STATE-MACHINE-IMPLEMENTATION -->

## Preserve the behavior matrix first

Before changing topology or DSL grammar, enumerate each concrete state/event pair as accepted,
guarded, or forbidden. Record its next state, output, cancellation, correlation, and controller-
visible outcome. Add characterization tests for unclear cases before moving declarations or
splitting events. A forbidden or rejected event means no transition and no output; it does not mean
an equal-state transition.

## Implement sentence-readable routes

Keep sealed state and event sets while flattening concrete alternatives. Follow repository naming;
when no stricter grammar exists, use `<Owner>Is<PresentCondition>` states and observed facts such as
`<Owner><Operation>WasRequested` and `<Owner><Operation>DidSucceed`.

Each route must expose the sentence directly:

```text
When concrete current state, on concrete event, transition to literal concrete state
and/or start a named output.
```

Use a literal concrete state constructor/object or `state.copy(...)` with a visible value change.
Do not call a state-returning helper, transition to a local or generic state value, generate routes
with loops, or put `if`, `when`, iteration, early returns, correlation algorithms, or result mapping
inside an `On` body. Helpers may return arguments, commands, plans, outputs, or atomic events, but
never DSL route objects or target states. An accepted output-only route omits `Transition` and
preserves the current state without emitting an equal-state transition.

## Keep topology atomic

Map repository, capability, and platform result unions to outcome-specific events inside the output
helper. Do not carry a result/update union, success flag, retry enum, nullable retry command, or an
equivalent renamed discriminator in a machine event or state. If the discriminator changes legal
future events, create separate explicit states/events.

Use capture-free named top-level or private-object guards only for correlation, stale rejection,
capability, or genuine value policy. Do not use guards to unpack a polymorphic result event that
should be atomic. Use direct event-type cancellation when sufficient; otherwise pass a capture-free
named cancellation policy by function reference.

An empty `state.copy()`, a copy that only assigns fields to their current values, or construction of
an equal state is observable and must never stand in for no route. Keep capability and validation
rejection before both transition and output; simplifying the DSL must not cause an effect to start
for a previously forbidden input.

## Verify both state and effect behavior

Test legal journeys, every atomic output result mapping, both sides of each guard, stale IDs,
cancellation/replacement, explicit retry states, and forbidden pairs. For rejection tests, observe
the raw machine and a capability spy: assert no state transition/emission and zero effect calls.
Controller/ViewModel projection tests remain necessary but cannot replace the raw no-route proof.
