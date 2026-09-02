# Review Method

<!-- kotlin-suite:REVIEW-INDEPENDENCE -->

## Contents

- Evidence order
- Review passes
- Reporting discipline

## Evidence order

Use evidence in this order: repository/user contract, current architecture decisions, Gradle and
resolved dependencies, production source, tests/guardrails, build/test output, and runtime proof.
Comments and self-assessment cannot override compiled behavior. Memory and naming are discovery
aids, not proof.

For `STANDARD` or `COMPLEX` lifecycle approval, use a distinct Reviewer in a clean context with the
live checkout and current handoff. Same-agent review is permitted only when repository policy
classifies work `TRIVIAL`; disclose that it is self-review rather than independent provenance. In
every case, reconstruct execution paths and inspect or replay evidence directly.

Inspect the whole scoped diff and the owners it touches. For an API change, inspect consumers. For
a workflow change, trace all states/events/effects. For a dependency change, inspect Gradle
declarations, resolved graph, plugins, repositories, locks, and imports. For a UI change, inspect
localized/accessibility resources and runtime presentation.

## Review passes

### Correctness and safety

Check invariants, null/error handling, invalid input, finite failure mapping, stale results, retries,
cancellation, exactly-once behavior, source-of-truth, transactions/migrations, restoration, API
availability, exported components, and security/privacy. Look for mutable assumptions across
suspension points and unowned concurrent work.

### Architecture

Check allowed Gradle edges, direct dependencies, `api`/`implementation`, source-set and Kotlin
visibility, Domain purity, Frameworks/Datasources ownership, feature/Navigation separation,
app/component composition, public API minimality, repository/source-of-truth ownership, resources,
and test source sets. Confirm a compiler boundary exists where the architecture contract claims
one.

### Functional design and readability

Check sealed algebraic modeling, immutable inert values, pure total decisions, explicit effect
capabilities, and clear standard collection/Flow operations. Review local reasoning, argument and
dependency complexity, nesting, duplicated policy, names, comments, dead code, and abstraction
cost. A line threshold triggers ownership review; it is not itself a finding without concrete mixed
responsibility or readability impact. Do not require a chain when a direct loop is clearer or
measured performance justifies it.

For every state-machine route, read the concrete `When` state, `On` event, literal `Transition`
target when present, and named output when present as one sentence. Accept an output-only route as
state-preserving without a transition. Reject target-state helpers, generic/local targets, empty or
equal-value copies used as no-ops, loop-generated routes, and control flow or algorithms in `On`
bodies. Confirm outputs translate result unions into atomic events, retry legality is explicit state
topology, and guards/cancellation policies are capture-free named function references used only for
correlation, stale rejection, capability, or genuine value policy.

Compare the pre/post accepted-route matrix during a topology refactor. For every forbidden pair and
rejected guard side, require raw-machine proof of no state transition/emission and a capability spy
proving no output ran. An unchanged UI projection or an equal-state transition is insufficient
because it can conceal observable machine work.

Perform a mechanism-to-behavior pass for each added module, machine, interface, wrapper,
factory/composition entry, test task, or guardrail. Identify its protected failure class, simpler
alternative, and concrete API, build, tracing, ownership, or test cost. Do not block a scoped
change for unrelated debt or report a count without impact.

When the repository has no stricter policy, inspect functions beyond 15-20 logical lines, 4 or more
independent parameters, 4 levels of nesting, cyclomatic complexity above 10, transformation chains
beyond 5-7 operations, types beyond 250-300 production lines, files beyond 400, interfaces beyond
5-7 members, and workflows with roughly 10-15 unrelated properties or large transitions. These
are review signals, not scoring shortcuts. Cohesion and correctness beat a number; never split an
irreducible algorithm or cohesive owner mechanically.

### Coroutines, Flow, and lifecycle

Inspect actual Kotlin/compiler/coroutines settings. Check scopes, Jobs, dispatchers, structured
concurrency, cancellation propagation, supervision, Flow cold/hot semantics, sharing/replay/buffer/
termination, callback cleanup, stale-result guards, ViewModel and composition lifetime, background
work, configuration change, destination removal, and process recreation. Require deterministic
tests for timing-sensitive behavior.

### Compose and product quality

Check source-of-truth ownership, Route/Screen split, state hoisting, stable identity, effect keys,
typed Navigation, message durability, semantic controls, accessibility, font scaling, focus and
keyboard/D-pad input, TalkBack, light/dark and increased contrast, animation scale/Reduce Motion,
supported locales, adaptive layouts and window classes, deterministic previews, min-SDK
availability, and live interaction proof where risk requires it.

### Tests and evidence

Check ownership, behavior/failure/cancellation/stale/recovery coverage, one coroutine test
scheduler, virtual time or explicit gates, parallel-safe resources, appropriate JVM/Robolectric/
instrumented split, test doubles at real seams, architecture fixtures, and whether validation
claims match inspected outputs. Disabled or flaky tests need an owner, reason, and removal condition
and do not count as passing evidence.

### Performance and resources

Do not infer a performance win from aesthetics. Require a defined flow and comparable measurement
for optimization claims. Inspect main-thread blocking, unbounded coroutines/buffers, duplicate Flow
collection, recomposition/identity churn, bitmap and I/O cost, coroutine/listener leaks, APK/R8
impact, and resource ownership. Use Perfetto, Simpleperf, frame, memory, heap, or allocation
evidence when source review cannot prove impact.

Before accepting runtime evidence, confirm that the expected application ID, variant, process, and
destination reached observable start and end states through the UI hierarchy, screenshot, or
equivalent inspected output. For trace-based conclusions, require attributable first-party frames
from the measured build and comparable flows/configurations. Reject unsymbolized first-party
attribution and heap reductions that do not remove the claimed retaining path.

## Reporting discipline

Lead with findings, not compliments or a change summary. Cite the narrowest path/line/symbol that
shows the problem and explain downstream impact. Recommend the contract to satisfy, not a large
rewrite unless smaller remediation cannot work. Keep separate:

- verified defect;
- high-confidence source issue;
- unverified risk requiring a test or trace;
- non-blocking preference (usually omit).

After findings, summarize validation, residual risk, and the next feedback batch. Add exact
commands, working directories, variants, devices, exit codes, and inspected evidence paths in the
same report or, when the lifecycle requires it, in the compact `KOTLIN-HANDOFF/1` block. Add a
numeric score only when the user explicitly requests one.
