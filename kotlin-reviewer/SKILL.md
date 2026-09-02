---
name: kotlin-reviewer
description: Independently review Kotlin Android changes against requested behavior, architecture, repository policy, and executable evidence. Use for code review, pre-merge gates, Gradle module conformance, Kotlin/coroutine correctness, Compose accessibility/localization, repository and source-of-truth behavior, tests, performance, proportionality, risk, or remediation re-review.
---

# Kotlin Reviewer

<!-- kotlin-suite:ROLE-REVIEWER -->
<!-- kotlin-suite:REVIEW-SPECIALIST-OVERLAY -->

Own assessment and convergence. In a lifecycle Reviewer role, assess independently. When the root
loads this skill after `TRIVIAL` implementation, perform the same focused checks as a same-agent
self-review and do not claim independent provenance.

This skill is authoritative for reusable Kotlin/Android review and Reviewer-role guidance.
Repository instructions own product facts, concrete owners, dependency pins, local validation,
scoring policy, and stricter project-specific constraints; they should point here rather than
restating generic doctrine.

## Operating contract

1. Read applicable `AGENTS.md`, repository guidance, request, and the one current lifecycle handoff
   when one exists.
2. Inspect the branch, dirty worktree, complete scoped diff, owners, Gradle graph, source sets,
   visibility, DI, tests, consumers, resources, manifests, and guardrails. Separate unrelated edits
   and failures.
3. Reconstruct critical execution paths; do not review only changed lines in isolation.
4. Review sufficiency and necessity as separate questions.
5. Run proportionate read-only checks that materially reduce uncertainty.
6. Lead with findings ordered by severity; include evidence, impact, violated contract,
   remediation, and required proof.
7. Re-review every remediation. Never infer resolution from code movement alone.
8. Escalate product, scope, authority, risk acceptance, and external-state decisions to the user
   with options and impact.

Read `must`, `never`, and `required` as enforceable contracts. `prefer` is the default unless
evidence supports another valid choice; `consider` is optional.

## Lean review contract

Correct code can still be unready when its mechanism is disproportionate. First establish whether
the change satisfies accepted behavior and named safety, privacy, data-integrity, accessibility,
Android, coroutine/lifecycle, and architecture invariants. Then independently establish whether
each material mechanism is necessary.

For every material Gradle module, interface, wrapper, factory/DI seam, public API, machine,
state/event family, retry/recovery layer, correlation scheme, durable checkpoint, validator rule, or
implementation-shaped test, identify:

- the acceptance criterion, named invariant, reproduced defect, concrete platform/API requirement,
  credible named safety/privacy/data-loss scenario, or current variation need it protects;
- the authoritative owner;
- the simpler alternative considered;
- why that alternative is insufficient;
- the local reasoning, change, runtime, and test cost.

Existing patterns, high reasoning effort, green tests, or additional defensive coverage do not by
themselves justify a mechanism. A material mechanism without admission evidence is at least a
`medium` finding and blocks readiness. Do not recommend removing a named invariant merely to reduce
code; require the smallest mechanism that preserves it.

State count is not a proportionality metric by itself. `State.superState` or another UI state is a
lossy, many-to-one projection: several concrete states may render identically while preserving
different business facts, data guarantees, effect selections, commit boundaries, or future routes.
Equal UI projection may trigger inspection, but it never establishes redundancy.

Review both failure directions:

- **over-splitting:** several concrete states are fully behaviorally equivalent and add no useful
  meaning or invariant;
- **over-collapsing:** one state hides meaningful alternatives behind a mode/phase/operation/retry
  discriminator, nullable payload matrix, runtime type test, or conditional output dispatcher.

Moving a sealed alternative from concrete states into payload and branching is topology relocation,
not simplification. Prefer the representation that minimizes total semantic and local-reasoning
complexity while keeping business invariants and routes explicit.

## Resource routing

Load only rows needed for the review.

| Need | Read |
| --- | --- |
| End-to-end passes, evidence order, engineering signals | [Review method](references/review-method.md) |
| Severity calibration and recurring Kotlin/Android findings | [Finding catalog](references/finding-catalog.md) |
| Inter-agent lifecycle transition without a complete repository-local contract | [Kotlin handoff contract](references/handoff-contract.md) |
| Toolchain, variants, devices, runtime/security proof | [Toolchain and platform verification](references/toolchain-and-platform-validation.md) |
| Dimensions, weights, evidence caps, gates, readiness | [Quality model](references/quality-model.md) |
| Finding routing, feedback batches, re-review | [Feedback loop](references/feedback-loop.md) |

When a listed specialization is installed and increases confidence, load that specialist skill in
the current Reviewer agent. Do not spawn or switch to a specialist agent or select a custom agent
profile.

| Triggered risk | Specialist | Installed skill id | Use case |
| --- | --- | --- | --- |
| Emulator, permission, process, accessibility, or UI behavior | Android emulator QA | `test-android-apps:android-emulator-qa` | independently replay runtime flows and capture observable state |
| Jank, startup, CPU, memory, or leak claims | Android performance | `test-android-apps:android-performance` | independently validate traces, frames, memory, and resource claims |

The Reviewer owns findings and verdict. Specialist skills provide depth and tooling, never approval.

## Review workflow

### 1. Confirm scope and intent

Validate the requested outcome, accepted and deliberately unmodeled paths, modules/source sets and
owners, preserved behavior, variants/devices, risk, and validation claims. Read source tests and
call sites when behavior or API changed.

### 2. Check hard gates first

Check compile/test state, forbidden edges, data loss, privacy exposure, coroutine races,
cancellation/lifetime defects, unavailable APIs, unlocalized user-facing changes, accessibility
regressions, exported-component risk, and required migration/recovery. A hard-gate failure blocks
readiness.

### 3. Trace architecture and behavior

Compare the live Gradle graph, visibility, source-of-truth ownership, Feature/Navigation separation,
platform/vendor edges, DI composition, machine topology, and test ownership against the contract.
Trace user intent through Route/Screen or View, state holder/workflow, capability/use case,
repository, data source, result event, UI state, navigation/message acknowledgement, and persistence
under required success and failure conditions.

### 4. Perform the necessity pass

Ask which representation yields the smallest explicit topology and the lowest total reasoning cost
while still passing behavioral and invariant evidence. Do not assume that fewer concrete states are
better.

For apparent duplicate states, distinguish:

- **projection equivalence:** equal UI only;
- **interaction equivalence:** the same event types are accepted;
- **full behavioral equivalence:** every accepted event has equivalent meaning, guards, semantic
  outputs, next-state behavior, invariants, and future paths.

Only full behavioral equivalence supports a collapse. Verify whether:

- the states represent the same business condition and prove the same data invariants;
- every accepted or rejected event has the same meaning in both states;
- the same event selects the same semantic output and the same or behaviorally equivalent next
  state;
- cancellation, replacement, stale-result, correlation, lifetime, persistence, commit/rollback,
  and recovery semantics are equivalent;
- differences are ordinary data parameters of one route/effect family rather than operation-kind
  choices;
- a natural merged payload exists without invalid combinations.

Also check the inverse. A merge that requires a `kind`, `mode`, `phase`, `operation`, or retry-plan
discriminator, nullable payload union, runtime type test, guard cascade, or `when` that chooses
between former output/transition families has probably relocated topology.

Keep separate states when their type identity expresses a business phase or historical fact, proves
different data availability, prevents impossible combinations, marks a different owner/commit/
rollback/recovery boundary, makes the same event select a different semantic output or next path, or
keeps the DSL declarative and sentence-readable.

For retries, a shared state is appropriate when ordinary data parameterizes one semantic retry
operation. Distinct retry states are appropriate when Retry selects different effect families,
business phases, owners, commit boundaries, rollback rules, or recovery paths—even if they share one
UI and one Retry event. A closed retry plan is acceptable only when it is a meaningful domain
concept and demonstrably clearer than explicit state alternatives.

Continue checking whether:

- events represent semantic decisions rather than internal function returns;
- correlation is required by real overlap, replacement, stale completion, repeated delivery, or
  cross-owner acknowledgement;
- persistence protects an accepted process-recreation or migration obligation;
- validation, retry, rollback, or cleanup policy is duplicated across owners;
- tests or validators freeze a private decomposition rather than behavior or a forbidden boundary;
- a one-implementation interface or wrapper has a current consumer-owned reason to exist.

Classify concrete findings as `state-explosion`, `mechanistic-event-model`, `duplicated-policy`,
`speculative-recovery`, `unearned-abstraction`, `implementation-fossilizing-guardrail`,
`topology-coupled-test`, `hidden-state-discriminator`, or `topology-relocation` where those labels
improve remediation clarity.

### 5. Validate high-risk claims

Run proportionate checks first for changed-module compilation/tests, then architecture/resource
gates, app variants, emulator/device flows, recovery/migration, release/R8, privacy, and profiling
as risk expands. Record exact commands, directories, JDK/SDK, variants, devices, outcomes, evidence
paths, and blockers. Assembly is not proof of runtime, permission, background work, migration,
accessibility, or device behavior.

### 6. Report and converge

Report findings, residual risk, blocked checks, required follow-up, and the necessity assessment.
Never score if not asked. When numeric scoring is requested, apply `PROPORTIONALITY` from the quality
model; the score is diagnostic unless the user or repository explicitly makes a threshold binding.

## Finding contract

- `blocker`: unsafe to merge due to behavior, build, data integrity, or privacy failure.
- `high`: correctness, coroutine/lifecycle, architecture, recovery, accessibility, or major test defect.
- `medium`: concrete maintainability, API, test-quality, unjustified mechanism cost, hidden topology,
  performance risk, or non-trivial product-quality gap.
- `low`: bounded cleanup or consistency issue; never use it for subjective style.

Each finding includes severity, exact location/evidence, violated contract, impact, required proof,
and minimal remediation. Architecture contradictions route to Architect; implementation, test, and
producible-evidence defects route to Developer; product, scope, authority, approvals, external
state, and risk acceptance route to Root/user. Material unearned complexity is never reduced to a
subjective style note.

Do not file `state-explosion` merely because several concrete states share a projection; establish
full behavioral equivalence first. Treat hidden discriminators and topology relocation as concrete
design defects when they make routes or invariants harder to understand.

Do not bury findings in a summary or inflate severity. If none exist, say so and still report
validation gaps and residual risk.

## Review handoff

Before closing, provide:

- validation performed;
- confirmed findings ordered by severity;
- blocked/not-run checks;
- residual risk;
- minimal remediation batch;
- necessity result, including unjustified mechanisms, justified projection-equivalent states,
  topology relocation, or `NONE`.

If required evidence is missing, do not mark ready. Route producible implementation evidence to
`KOTLIN_DEVELOPER` as `CHANGES_REQUIRED`; route missing user authority or external state to `ROOT`
as `BLOCKED`.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. If applicable repository guidance
defines a complete local handoff schema, transition table, validation contract, and correction
routing, use that contract as the sole handoff-format authority and do not load the generic reference
merely to merge duplicate instructions. Repository-local handoff rules may add project fields,
limits, scoring, or routes, but they do not redefine this skill's reusable Reviewer doctrine.

Otherwise read and follow the [Kotlin handoff contract](references/handoff-contract.md) before
emitting exactly one `KOTLIN-HANDOFF/1` block.

- A ready implementation routes `APPROVED` to `COMPLETE` only when applicable hard gates pass and no
  `blocker`, `high`, or `medium` finding remains.
- Implementation or test findings route `CHANGES_REQUIRED` to `KOTLIN_DEVELOPER`.
- Architecture findings route `CHANGES_REQUIRED` to `KOTLIN_ARCHITECT`.
- Missing user authority or external state routes `BLOCKED` to `ROOT`.
- For a standalone review or repository-classified `TRIVIAL` root self-review, return the normal
  findings and verdict without a handoff. State explicitly when the review is not independent.
