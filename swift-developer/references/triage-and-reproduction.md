# Triage and reproduction

Use this reference for a bounded Swift defect when ownership and the public contract appear settled.
It is a fast path, not permission to skip required runtime, safety, accessibility, or product proof.

## Sequence

1. **State the observable.** Write the exact action, expected result, actual result, environment, and
   one smallest reproducible path. Capture the failing test, screenshot, log excerpt, or hosted-runtime
   observation before editing.
2. **Find the immediate owner.** Follow the action to its view/controller, state owner, effect, and
   consumer. Inspect only the symbols and neighboring tests on that path. Identify which value or
   callback actually controls the observed behavior.
3. **Separate layers.** Mark each fact as local presentation state, feature state, external projection,
   persistence, or platform behavior. Do not redesign a lower layer because a higher layer has not yet
   been traced.
4. **Check lifetime and identity.** For async work, record owner lifetime, cancellation, operation
   identity, and completion delivery. Reject late or stale results only when the boundary requires it.
5. **Patch the owner.** Prefer the smallest local correction that preserves the existing contract and
   dependency direction. Add a new owner, machine, persistence seam, or retry only when the trace proves
   the current owner cannot satisfy the behavior.
6. **Prove and stop.** Run the focused regression proof, then the required consumer/runtime proof. Once
   the failing path is green and no new topology or risk was admitted, stop diagnosis and use the normal
   completion gates.

## Bounded evidence

- Prefer symbol matches, scoped diffs, and bounded logs. Keep complete logs and result bundles as
  artifacts; carry command, result, failure excerpt, and artifact path in the active checkpoint.
- Do not repeat an unchanged command or reread a full file after a truncation. Query the saved artifact
  narrowly.
- If two hypotheses are disproven, write a fresh checkpoint with the observed failure, evidence,
  rejected hypotheses, owner, and next proof. Do not replay the full transcript.

## Escalation triggers

Escalate to architecture only when evidence shows unresolved ownership, dependency direction, source of
truth, workflow topology, persistence/recovery policy, or a real cross-boundary invariant. A defect is
not architectural merely because it crosses a view boundary, uses async code, or needs Simulator proof.
