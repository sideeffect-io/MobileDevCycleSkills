# Feedback Loop

<!-- swift-suite:REVIEW-ROUTING -->

Route findings deterministically:

- architecture ownership, dependency direction, public-seam, and workflow-topology contradictions
  route `CHANGES_REQUIRED` to `SWIFT_ARCHITECT`;
- implementation, tests, evidence, local Swift correctness, concurrency, UI, and resources route to
  `SWIFT_DEVELOPER` as `CHANGES_REQUIRED`;
- product behavior, scope, authority, third-party approval, and risk acceptance route `BLOCKED` to
  `ROOT`, which involves the user only when necessary.

Every remediation returns to the Reviewer for focused re-review.

## First review

Group findings into the smallest coherent developer batch:

1. hard-gate and correctness fixes;
2. architecture/ownership/API corrections;
3. concurrency/lifecycle and workflow edge cases;
4. UI/accessibility/localization/product quality;
5. tests, guardrails, performance evidence, and bounded cleanup.

For each item, state the required constraints and proof. Avoid prescribing a large implementation
when several valid designs satisfy the current architecture decisions. Route a design contradiction
to `swift-architect` with the exact manifest/source evidence.

## Developer response contract

For lifecycle work, the next current handoff summarizes:

- findings addressed;
- files and behavior changed;
- tests and gates rerun with exact results;
- any declined medium/low finding with rationale and explicit user decision;
- any architecture decision that had to be revised.

For a `TRIVIAL` root self-review, report the same information directly without a handoff.

Do not accept “fixed” without evidence tied to the finding.

## Re-review

For every previous finding, assign one status:

- `resolved`: remediation and required regression evidence pass;
- `open`: defect or proof gap remains;
- `accepted risk`: the user explicitly accepts a documented medium/low impact and follow-up;
- `not_reproducible`: reviewer reran the original evidence and explains why it no longer holds.

Review changed lines plus their affected execution/ownership path. Re-review only affected findings,
dimensions, evidence, and regression gates unless the remediation broadened scope.
Do not redo unrelated expensive validation unless the fix broadened scope.
Look for regressions introduced by the remediation, especially visibility, dependency edges,
duplicate ownership, cancellation, and test-only code in production.

## Reassessment

Reassess only the affected findings and residual risk. When numeric scoring was explicitly requested,
change only dimensions for which new evidence exists, then recompute the weighted score. A resolved
finding may leave its dimension at the source-evidence cap until the required executable gate runs.
Do not increase a score because the developer explained intent.

Stop the loop when the fixed readiness thresholds and hard gates pass, or clearly report the
remaining blocker, authority needed, or external-state dependency. Open blocker, high, and medium
findings block readiness under this handoff framework. Blocker/high findings cannot be accepted;
medium/low acceptance requires a user-routed decision. Do not average away a required finding.
