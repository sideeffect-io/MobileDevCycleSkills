# Feedback Loop

<!-- kotlin-suite:REVIEW-ROUTING -->

Route findings deterministically:

- architecture ownership, Gradle direction, source-of-truth, public-seam, and workflow-topology
  contradictions route `CHANGES_REQUIRED` to `KOTLIN_ARCHITECT`;
- implementation, tests, evidence, local Kotlin/coroutine correctness, Compose, and resources route
  to `KOTLIN_DEVELOPER` as `CHANGES_REQUIRED`;
- product behavior, scope, authority, third-party approval, external state, and risk acceptance route
  `BLOCKED` to `ROOT`, which involves the user only when necessary.

Every remediation returns to the Reviewer for focused re-review.

## First review

Group findings into the smallest coherent developer batch:

1. hard-gate and correctness fixes;
2. architecture/source-of-truth/ownership/API corrections;
3. coroutine/lifecycle and workflow edge cases;
4. Compose/accessibility/localization/product quality;
5. tests, guardrails, performance evidence, and bounded cleanup.

For each item, state the required constraints and proof. Avoid prescribing a large implementation
when several valid designs satisfy current architecture decisions. Route a design contradiction to
`kotlin-architect` with exact Gradle/manifest/source evidence.

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
dimensions, evidence, and regression gates unless remediation broadened scope. Do not redo unrelated
expensive validation unless the fix broadened scope. Look for regressions introduced by remediation,
especially visibility, dependency edges, duplicate state/source-of-truth ownership, cancellation,
and test-only code or dependencies in production.

## Reassessment

Reassess only affected findings and residual risk. When numeric scoring was explicitly requested,
change only dimensions for which new evidence exists, then recompute the weighted score. A resolved
finding may remain at the source-evidence cap until the required executable gate runs. Do not
increase a score because the developer explained intent.

Stop the loop when fixed readiness thresholds and hard gates pass, or clearly report the remaining
blocker, authority needed, or external-state dependency. Open blocker, high, and medium findings
block readiness under this handoff framework. Blocker/high findings cannot be accepted; medium/low
acceptance requires a user-routed decision. Do not average away a required finding.
