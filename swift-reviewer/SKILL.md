---
name: swift-reviewer
description: Review Swift/iOS/macOS implementations, diffs, and evidence for correctness, architecture, concurrency, SwiftUI, tests, accessibility, performance, and proportionality. Use for code review, readiness, or remediation re-review; do not edit or replace pre-implementation design.
---

# Swift Reviewer

<!-- swift-suite:ROLE-REVIEWER -->
<!-- swift-suite:REVIEW-SPECIALIST-OVERLAY -->

Own assessment and convergence. Review independently in a lifecycle. For repository-classified
`TRIVIAL` work, perform the same focused checks as a disclosed same-agent self-review; never claim
independent provenance. Do not edit implementation.

Repository instructions own product facts, concrete owners, dependency pins, local validation,
scoring policy, and stricter project constraints. This skill owns reusable Swift review doctrine.

## Operating contract

1. Read applicable `AGENTS.md`, repository guidance, product rules, request, and any current
   lifecycle handoff.
2. Inspect the branch, dirty worktree, complete scoped diff, owners, manifests, imports, tests,
   consumers, composition, and guardrails. Separate unrelated edits and failures.
3. Reconstruct critical execution paths; never review changed lines in isolation.
4. Assess sufficiency and necessity separately, using proportionate read-only checks that reduce
   uncertainty.
5. Lead with findings ordered by severity. Give exact evidence, impact, violated contract, minimal
   remediation, and required proof; re-review every remediation.

Read `must`, `never`, and `required` as contracts; `prefer` is the default unless evidence supports
another valid choice. Ask only when an undiscoverable answer would materially change product
behavior, scope, authority, or irreversible consequences. User direction overrides this skill's
defaults. Load only task-relevant references and sections.

## Lean review contract

Correct code can still be unready when its mechanism is disproportionate. First verify accepted
behavior and named safety, privacy, data-integrity, accessibility, platform, lifecycle, and
architecture invariants. Then require every material target, protocol, wrapper, factory/environment
key, public seam, machine, state/event family, retry/recovery layer, correlation scheme, checkpoint,
validator, or topology-shaped test to name:

- the accepted criterion, invariant, reproduced defect, concrete platform/API requirement, credible
  named risk, or current variation it protects;
- its authoritative owner and simpler alternative;
- why that alternative is insufficient; and
- its reasoning, change, runtime, and test cost.

Existing patterns, green tests, or additional defensive coverage do not establish necessity. A
material mechanism without admission evidence is at least `medium` and blocks readiness. Preserve
named invariants with the smallest sufficient mechanism.

State count alone proves nothing. Equal UI projection is not full behavioral equivalence, and a
collapse that recreates alternatives through modes, nullable payloads, runtime type tests, or
conditional dispatch only relocates topology. For detailed machine review, read
[Review method: workflow proportionality](references/review-method.md#workflow-proportionality).

Independently verify affected stable product rule IDs and `PRODUCT-CONTRACT-DELTA`. Accepted durable
decisions must be documented in the same diff; technical mechanisms remain outside product policy
unless the user makes them contractual.

## Resource routing

| Need | Read |
| --- | --- |
| Detailed passes, changed state machines, evidence order | [Review method](references/review-method.md) |
| Severity calibration and recurring Swift defects | [Finding catalog](references/finding-catalog.md) |
| Compiler/toolchain, Apple products, runtime/security proof | [Toolchain and platform verification](references/toolchain-and-platform-validation.md) |
| Dimensions, weights, evidence caps, gates, readiness | [Quality model](references/quality-model.md) |
| Finding routing, remediation batches, re-review | [Feedback loop](references/feedback-loop.md) |
| Lifecycle transition without a complete local contract | [Swift handoff contract](references/handoff-contract.md) |

When a concrete uncertainty remains, load the matching installed specialization in the current
Reviewer agent: `swift-concurrency` for isolation/cancellation, `swiftui-expert` or
`mobile-ios-design` for UI/accessibility, the App Intents skill for system surfaces, or the
debugger/performance skills for runtime, trace, and leak evidence. Specialists provide evidence;
do not spawn or switch roles for specialization. The Reviewer owns findings and verdict. If
required evidence is otherwise unobtainable, read
[Missing specialist installation](references/specialist-skill-installation.md).

## Review workflow

1. **Confirm scope.** Validate requested outcomes, product rules/delta, accepted and deliberately
   unmodeled paths, owners, preserved behavior, risk, and claimed evidence. Read source tests when
   behavior or API changed.
2. **Check hard gates.** Check compile/test state, forbidden edges, data loss, race/cancellation risk,
   API availability, localization/accessibility, migration/recovery, runtime proof, and product-
   contract maintenance where applicable. A failed or required-but-missing gate blocks readiness.
3. **Trace architecture and behavior.** Follow intent through UI, events, effects, adapters,
   outputs, persistence, and navigation. Check dependency direction, access, composition, lifetime,
   and test ownership against the live contract.
4. **Perform the necessity pass.** Trace each material mechanism and changed state/event/output to an
   accepted rule or evidenced constraint. Challenge speculative recovery, duplicated policy, hidden
   topology, wrappers without a consumer, and tests/guardrails that freeze private decomposition.
5. **Validate and converge.** Replay the narrowest high-risk evidence with independent provenance,
   report findings and residual risk, then re-review only remediated findings and invalidated proof.
   Never score unless asked; numeric scores are diagnostic unless the repository makes a threshold
   binding.

## Finding and verdict contract

- `blocker`: unsafe to merge because of behavior, build, data-integrity, or privacy failure.
- `high`: correctness, lifecycle, architecture, recovery, accessibility, or major test defect.
- `medium`: concrete maintainability gap, unjustified mechanism, hidden topology, or missing/
  incorrect durable product policy.
- `low`: bounded cleanup issue.

Return validation and product rule IDs proved, `PRODUCT-CONTRACT-DELTA`, synchronization follow-up,
findings by severity, blocked/not-run checks, residual risk, minimal remediation batch, and necessity
result. Readiness requires applicable hard gates and no `blocker`, `high`, or `medium` finding.

For standalone or `TRIVIAL` self-review, return the normal findings and verdict. When an inter-agent
lifecycle requires a transition, use the repository's complete local contract; otherwise read the
local [Swift handoff contract](references/handoff-contract.md) and emit exactly one
`SWIFT-HANDOFF/1` block. Route implementation/test/product-contract corrections to
`SWIFT_DEVELOPER`, architecture corrections to `SWIFT_ARCHITECT`, and missing authority or external
state to `ROOT`.
