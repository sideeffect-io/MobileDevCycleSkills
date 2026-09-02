# Debugging and Performance

<!-- swift-suite:SWIFT-DEBUGGING-PERFORMANCE -->

## Diagnose before patching

1. Record the exact symptom, environment, build configuration, device/Simulator, inputs, and
   reproduction steps.
2. Minimize the failing path and identify the last known good behavior when available.
3. Gather the narrowest evidence: compiler diagnostic, failing test, structured log, stack trace,
   crash report, UI hierarchy, network/persistence artifact, trace, or memgraph.
4. Form one falsifiable hypothesis and choose an observation that distinguishes it.
5. Patch the root cause at its owner, then rerun the same reproduction and regression tests.

Do not implement every plausible fix at once. Separate build errors, behavior defects, races,
resource leaks, and performance regressions; they require different evidence.

## Logs and debugger

Use unified logging categories and privacy annotations for production diagnostics. Do not log
secrets, tokens, personal data, raw payloads, or localized user copy as debug state. Add temporary
logging narrowly and remove it unless it provides durable operational value.

Use LLDB breakpoints, exception breakpoints, thread/task backtraces, and state inspection to prove
control flow and ownership. A breakpoint changing timing is a warning that concurrency evidence is
incomplete.

## Runtime evidence integrity

Resolve the expected scheme, bundle identifier, and process before launch. After launch, prove the
observable start and end states through the accessibility/UI hierarchy or a screenshot, with logs
tied to the same flow when relevant. A successful build, launch command, or loaded mirror page alone
is not proof that the intended app and state were reached.

For trace-based conclusions, require first-party frames to be symbolicated with UUID-matched dSYMs
from the measured build. Reject an unsymbolicated first-party trace rather than guessing from address
or framework buckets. Preserve the fresh source/processed artifacts required to reproduce the report,
and record the exact run count, configuration, destination, and symbol coverage.

## Performance method

Treat performance as a measurement loop:

1. define one user-visible flow and metric;
2. capture a comparable baseline, preferably Release on a representative physical device;
3. locate inclusive first-party cost with Instruments/signposts/traces;
4. make one targeted change;
5. capture the same flow with the same build class, configuration, destination, and start/stop points,
   then report the delta and caveats;
6. add a performance regression test or metric when stable and valuable.

Inspect launch, hangs/hitches, view invalidation, CPU, memory, allocations/leaks, disk I/O, network,
energy, and background work according to the symptom. Simulator measurements are useful for
iteration but are not device performance proof.

## Memory and resource lifetime

For a suspected leak, identify the intended lifetime and prove the retaining path with a memgraph,
trace tree, or isolated reproduction. A smaller heap alone is not proof. Recapture the same flow
after the patch and show the specific type/path disappeared. Also inspect tasks, continuations,
notifications, delegates, timers, streams, file handles, and observation tokens for explicit
termination.

## Reporting

Distinguish `verified`, `source-only`, and `inferred`. Include the exact flow, artifacts, build,
environment, run count, before/after metrics, symbol coverage/hotspots, remaining uncertainty, and
validation results.
If evidence is insufficient, request or capture the next narrow artifact rather than asserting a
root cause.
