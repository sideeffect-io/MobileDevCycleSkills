# State-machine interleavings

Load this reference only when accepted behavior includes retry, replaceable or long-lived work,
authoritative observation, identity admission, correlation, cancellation, or stale-result risk.
These mechanisms need evidence; this guide never admits them by itself.

## Pre-review interleaving matrix

For an async workflow whose legality depends on identity, admission, or an operation token, settle
only the applicable risks before implementation/review handoff:

1. Keep observed, staged, and admitted identity distinct when they mean different facts. Only
   accepted semantic success changes admission; cancellation restores the previous admission, and
   loading or unavailable observation never relaxes the fence.
2. When the machine decides whether a durable/external mutation is still legal, the output first
   emits a correlated result. The machine admits that result and only then selects the correlated
   apply output; do not mutate durably before admission.
3. An operation suspended across authoritative observation either rebases same-identity snapshots
   for success, failure, and cancellation, or is cancelled when identity is replaced.
4. Every operation-specific state rejects a mismatched completion. Prove both no transition and no
   effect for the rejected event.
5. Test cancellation/stale fencing with a deliberately non-cooperative dependency. Use repeated
   deterministic scheduling only to amplify a real race, never instead of an explicit gate.

## Retry and correlation

A shared retry state is appropriate when ordinary payload data parameterizes the same semantic
retry output without branching over operation kinds. Keep states distinct when Retry selects
different effect families, business phases, commit boundaries, owners, rollback rules, or recovery
paths, even when UI and Retry input are equal.

A closed retry-plan value is acceptable only when it is already a meaningful domain concept and
improves local reasoning. A switch with one case per former retry state usually relocates topology.
Boolean retry flags, nullable command bags, and open executable command containers remain forbidden.

Carry a request, generation, or observation ID only when work can overlap or be replaced, stale
completion can arrive, equal outcomes can repeat, or another owner requires acknowledgement. A
proved actor-serialized or single-flight workflow does not need per-phase correlation for symmetry.

## Cancellation and observation

Define cancellation for every long-lived or replaceable output. Cancellation is cooperative;
cancelling old work does not define the replacement route. Test both. Use lifecycle restart only
for resilient subscriptions or polling with explicit policy; ordinary loads use explicit retry when
retry is accepted behavior.

Authoritative observations normally live for the owning machine lifetime, not view visibility. Use
suitable buffering and test termination, replacement, and stale delivery only where those risks are
real. Never create competing iterators over one unicast machine.
