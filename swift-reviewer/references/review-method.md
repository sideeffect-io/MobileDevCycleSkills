# Review Method

<!-- swift-suite:REVIEW-INDEPENDENCE -->

## Contents

- Evidence order
- Review passes
- Reporting discipline

## Evidence order

Use evidence in this order: repository/user contract, current architecture decisions, manifests and
resolved dependencies, production source, tests/guardrails, build/test output, and runtime proof. A
comment or self-assessment cannot override compiled behavior. Memory and naming are discovery aids,
not proof.

For `STANDARD` or `COMPLEX` lifecycle approval, use a distinct Reviewer in a clean context with the
live checkout and current handoff. Same-agent review is permitted only when repository policy
classifies the work `TRIVIAL`; disclose that it is self-review rather than independent provenance.
In every case, reconstruct execution paths and inspect or replay the evidence directly.

Inspect the whole scoped diff and the owners it touches. For an API change, inspect consumers. For a
workflow change, trace all states/events/effects. For a dependency change, inspect both manifests and
imports. For a UI change, inspect localized/accessibility resources and the runtime presentation.

## Review passes

### Correctness and safety

Check invariants, invalid input, finite failure mapping, stale results, retries, cancellation,
exactly-once behavior, persistence/migration, restoration, error propagation, optionals, force
unwraps, and availability. Look for races across suspension points and unsound isolation escapes.

### Architecture

Check allowed target edges, exact dependencies/imports, Domain purity, Frameworks and Datasources
ownership, Feature/Navigation separation, app composition, public API minimality, root/runtime
ownership, resources, and target-local tests. If a combined Infrastructure fallback exists, verify
that its cohesive/legacy rationale is explicit and that it preserves the same forbidden edges.
Confirm a compiler boundary exists where the architecture contract claims one.

### Functional design and readability

Check algebraic data modeling, inert values, pure/total decisions, explicit effect capabilities,
and clear use of platform `map`, `compactMap`, `flatMap`, `filter`, `reduce`,
`Dictionary.merge`/`merging`, set operations, and available `AsyncSequence` algorithms. Require
toolchain or explicit-dependency support for asynchronous merge. Also check local reasoning,
cohesive owners, argument complexity, nesting, duplicated policy, names, comments, dead code, and
abstraction cost. A line threshold triggers ownership review; it is not itself a finding without a
concrete mixed responsibility or readability impact. Do not require a pipeline when a direct loop
is clearer or measured performance justifies it.

Perform a mechanism-to-behavior pass for each added target, machine, protocol, wrapper,
factory/environment entry, test product, or guardrail. Identify its protected failure class, simpler
alternative, and concrete API, build, tracing, ownership, or test cost. Do not block a scoped change
for unrelated existing debt or report a count without impact.

When the repository has no stricter policy, inspect functions beyond 15-20 logical lines, 4 or more
independent parameters, 4 levels of nesting, cyclomatic complexity above 10, transformation chains
beyond 5-7 operations, types beyond 250-300 production lines, files beyond 400, protocols beyond 5-7
requirements, and workflows with roughly 10-15 unrelated properties or large transitions. These
are review signals, not scoring shortcuts. Cohesion and correctness beat a number; never split an
irreducible algorithm or cohesive owner mechanically.

### Swift concurrency and lifecycle

Inspect actual language/isolation settings. Check `Sendable`, actor ownership, structured task
lifetime, cancellation, stream buffering/termination, continuation resumption, reentrancy after
`await`, UI isolation, and process/scene/extension behavior. Require an invariant and removal plan
for every unsafe escape.

### SwiftUI and product quality

Check source-of-truth ownership, wrapper choice, root versus child responsibilities, stable identity,
semantic controls, typed navigation/presentation, side effects in `body`, accessibility, Dynamic
Type extremes, focus, VoiceOver, keyboard/pointer input, light/dark and increased contrast,
Differentiate Without Color, Reduce Motion, compact/regular layouts, iPad multitasking/window
resizing, supported locales, package bundles, deterministic previews, and platform availability.
Validate only applicable variants, but require live evidence for high-risk interactions.

### Tests and evidence

Check ownership, behavior coverage, failure/cancellation/stale cases, deterministic inputs,
parallel safety, parameterization, `#require` for dependent prerequisites, `withKnownIssue` for
tracked temporary failures, function-level `@available`, trait/tag test-plan filtering, test doubles
at real seams, integration scope, architecture fixtures, and whether validation claims match logs.
Treat `.serialized` as a justified transition after attempted isolation, not a default fix.
Disabled/flaky tests require an owner, reason, and removal condition and do not count as passing
evidence.

### Performance and resources

Do not infer a performance win from aesthetics. Require a defined flow and comparable measurement
for optimization claims. Inspect obvious main-actor blocking, view invalidation, unbounded streams,
image cost, I/O, task leaks, retain cycles, and resource/bundle ownership. Use profiling/memgraph
evidence when source review cannot prove impact.

Before accepting runtime evidence, confirm that the expected scheme, bundle identifier, and process
reached observable start and end states through the UI/accessibility hierarchy or a screenshot. For
trace-based conclusions, require UUID-matched dSYMs and symbolicated first-party frames from the
measured build. Reject unsymbolicated first-party attribution, incomparable flows/configurations, and
heap reductions that do not remove the claimed retaining path.

## Reporting discipline

Lead with findings, not compliments or a change summary. Cite the narrowest path/line/symbol that
shows the problem and explain downstream impact. Recommend the contract to satisfy, not a large
rewrite unless smaller remediation cannot work. Keep separate:

- verified defect;
- high-confidence source issue;
- unverified risk requiring a test/trace;
- non-blocking preference (usually omit).

After findings, summarize validation, residual risk, and the next feedback batch. Add exact commands,
working directories, destinations, exit codes, and relevant evidence paths in the same report or, if
the lifecycle requires it, in the compact **SWIFT-HANDOFF/1** block.
