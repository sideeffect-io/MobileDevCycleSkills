---
name: kotlin-reviewer
description: Review Kotlin Android changes for correctness, architecture, coroutines, Compose quality, evidence, and over-engineering. Use for independent review, readiness decisions, proportionality audits, and remediation re-review; do not edit implementation.
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
2. Inspect branch, dirty worktree, complete scoped diff, owners, Gradle graph, source sets,
   visibility, DI, tests, consumers, resources, manifests, and guardrails. Separate unrelated edits
   and failures.
3. Reconstruct critical execution paths; do not review only changed lines in isolation.
4. Review sufficiency and necessity as separate questions.
5. Run proportionate read-only checks that materially reduce uncertainty.
6. Lead with findings ordered by severity; include evidence, impact, violated contract,
   remediation, and required proof.
7. Re-review every remediation. Never infer resolution from code movement alone.

Read `must`, `never`, and `required` as enforceable contracts. `prefer` is the default unless
evidence supports another valid choice; `consider` is optional.

Use the request and existing authorization to resolve routine implementation and validation choices.
Ask only when an undiscoverable answer would materially change product behavior, scope, authority,
or irreversible consequences. Continue independent authorized work while that decision is pending.
In a lifecycle, route the blocked slice to Root; do not turn a preference or a recoverable tool error
into a permission gate. User direction takes precedence over this skill's defaults.

Load only task-relevant references and sections; a routing table is an index, not a checklist.
Reuse current evidence and report concise decisions, findings, and proof without repeating the
request, skill doctrine, source, or full logs. High reasoning effort does not justify broader scope.

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

## Product-contract review

Independently verify affected stable rule IDs against behavior and evidence. Check that
`PRODUCT-CONTRACT-DELTA` is accurate and accepted durable decisions are documented in the same diff.
Shared rules must preserve IDs and meaning across in-scope repositories, or have an explicit
synchronization follow-up. Technical sidecars reference product rules instead of copying them.

Missing durable policy or a rule that fossilizes private implementation without explicit user intent
is at least a `medium` finding. Modules, APIs, state/event topology, DI, retries, and test shapes are
technical details unless the user makes the mechanism itself contractual.

## Resource routing

Load only rows needed for the review.

| Need | Read |
| --- | --- |
| Changed state machines, detailed review passes, evidence order | [Review method](references/review-method.md) |
| Severity calibration and recurring Kotlin/Android findings | [Finding catalog](references/finding-catalog.md) |
| Inter-agent lifecycle transition without a complete repository-local contract | [Kotlin handoff contract](references/handoff-contract.md) |
| Toolchain, variants, devices, runtime/security proof | [Toolchain and platform verification](references/toolchain-and-platform-validation.md) |
| Dimensions, weights, evidence caps, gates, readiness | [Quality model](references/quality-model.md) |
| Finding routing, feedback batches, re-review | [Feedback loop](references/feedback-loop.md) |

When an installed specialization resolves a concrete uncertainty left by the base review, load it
in the current Reviewer agent. Do not spawn or switch to a specialist agent or select a custom agent
profile.

| Triggered risk | Specialist | Installed skill id | Use case |
| --- | --- | --- | --- |
| Emulator, permission, process, accessibility, or UI behavior | Android emulator QA | `test-android-apps:android-emulator-qa` | independently replay runtime flows and capture observable state |
| Jank, startup, CPU, memory, or leak claims | Android performance | `test-android-apps:android-performance` | independently validate traces, frames, memory, and resource claims |

The Reviewer owns findings and verdict. Specialist skills provide depth and tooling, never approval.

## Review workflow

### 1. Confirm scope and intent

Validate the requested outcome, applicable product rule IDs, `PRODUCT-CONTRACT-DELTA`, accepted and
deliberately unmodeled paths, modules/source sets and owners, preserved behavior, variants/devices,
risk, and validation claims. Read source tests and call sites when behavior or API changed.
Reconstruct any durable product decision made during the session and ensure it has an authoritative
contract home.

### 2. Check hard gates first

Check compile/test state, forbidden edges, data loss, privacy exposure, coroutine races,
cancellation/lifetime defects, unavailable APIs, unlocalized user-facing changes, accessibility
regressions, exported-component risk, required migration/recovery, and required product-contract
maintenance. A hard-gate failure blocks readiness.

### 3. Trace architecture and behavior

Compare the live Gradle graph, visibility, source-of-truth ownership, Feature/Navigation separation,
platform/vendor edges, DI composition, machine topology, and test ownership against the contract.
Trace user intent and applicable product rules through Route/Screen or View, state holder/workflow,
capability/use case, repository, data source, result event, UI state, navigation/message
acknowledgement, and persistence under required success and failure conditions.

### 4. Perform the necessity pass

For changed machines, use [Review method: workflow proportionality](references/review-method.md#workflow-proportionality).
Trace each changed state/event family, transition, and output to an accepted business rule or
evidenced technical constraint. Challenge internal-call events, speculative recovery, duplicated
policy, and wrappers without a consumer-owned reason. A missing sentence in a handoff alone is not
a defect: inspect the source and contract before declaring a mechanism unjustified.

Check both unnecessary splitting and unsafe collapse. Equal UI or accepted event types do not prove
equivalent outputs, next-state behavior, invariants, or lifetime. Do not replace explicit meaningful
states with a discriminator-driven dispatcher merely to lower counts. Report concrete complexity
and its smallest behavior-preserving correction, not subjective style or unrelated debt.

### 5. Validate high-risk claims

Run proportionate checks first for changed-module compilation/tests, then architecture/resource
gates, app variants, emulator/device flows, recovery/migration, release/R8, privacy, profiling, and
affected product rules as risk expands. Record exact commands, directories, JDK/SDK, variants,
devices, outcomes, evidence paths, blockers, and rule IDs proved. Assembly is not proof of runtime,
permission, background work, migration, accessibility, or device behavior.

### 6. Report and converge

Report findings, residual risk, blocked checks, required follow-up, the necessity assessment, and the
product-contract result. Never score if not asked. When numeric scoring is requested, apply
`PROPORTIONALITY` from the quality model; the score is diagnostic unless the user or repository
explicitly makes a threshold binding.

## Finding contract

- `blocker`: unsafe to merge due to behavior, build, data integrity, or privacy failure.
- `high`: correctness, coroutine/lifecycle, architecture, recovery, accessibility, or major test defect.
- `medium`: concrete maintainability, API, test-quality, unjustified mechanism cost, hidden topology,
  undocumented or incorrect durable product policy, performance risk, or another non-trivial
  product-quality gap.
- `low`: bounded cleanup or consistency issue; never use it for subjective style.

Each finding includes severity, exact location/evidence, violated contract, impact, required proof,
and minimal remediation. Architecture contradictions route to Architect; implementation, test,
product-contract maintenance, and producible-evidence defects route to Developer; product, scope,
authority, approvals, external state, and risk acceptance route to Root/user. Material unearned
complexity and missing product-contract maintenance are never reduced to subjective style notes.

Do not file `state-explosion` merely because several concrete states share a projection; establish
full behavioral equivalence first. Treat hidden discriminators and topology relocation as concrete
design defects when they make routes or invariants harder to understand.

Do not bury findings in a summary or inflate severity. If none exist, say so and still report
validation gaps and residual risk.

## Review handoff

Before closing, provide:

- validation performed and product rule IDs proved;
- `PRODUCT-CONTRACT-DELTA`: `NONE` or the verified rules added, changed, or superseded;
- product-contract synchronization follow-up or `NONE`;
- confirmed findings ordered by severity;
- blocked/not-run checks;
- residual risk;
- minimal remediation batch;
- necessity result, including unjustified mechanisms, justified projection-equivalent states,
  topology relocation, or `NONE`.

If required evidence or product-contract maintenance is missing, do not mark ready. Route producible
implementation evidence or contract corrections to `KOTLIN_DEVELOPER` as `CHANGES_REQUIRED`; route
missing user authority or external state to `ROOT` as `BLOCKED`.

## Handoff contract

Use a handoff only when an inter-agent lifecycle requires one. If applicable repository guidance
defines a complete local handoff schema, transition table, validation contract, and correction
routing, use that contract as the sole handoff-format authority and do not load the generic reference
merely to merge duplicate instructions. Repository-local handoff rules may add project fields,
limits, scoring, or routes, but they do not redefine this skill's reusable Reviewer doctrine.

Otherwise read and follow the [Kotlin handoff contract](references/handoff-contract.md) before
emitting exactly one `KOTLIN-HANDOFF/1` block. Put `PRODUCT-CONTRACT-DELTA` where the complete local
contract requires it, or in `CURRENT-STATE` when using the generic contract.

- A ready implementation routes `APPROVED` to `COMPLETE` only when applicable hard gates pass and no
  `blocker`, `high`, or `medium` finding remains.
- Implementation, test, or product-contract maintenance findings route `CHANGES_REQUIRED` to
  `KOTLIN_DEVELOPER`.
- Architecture findings route `CHANGES_REQUIRED` to `KOTLIN_ARCHITECT`.
- Missing user authority or external state routes `BLOCKED` to `ROOT`.
- For a standalone review or repository-classified `TRIVIAL` root self-review, return the normal
  findings and verdict without a handoff. State explicitly when the review is not independent.
