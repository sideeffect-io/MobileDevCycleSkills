# Debugging and Performance

<!-- kotlin-suite:KOTLIN-DEBUGGING-PERFORMANCE -->

## Diagnose before patching

1. Record symptom, variant/build type, device/emulator/API, inputs, and reproduction.
2. Minimize the path and identify last known good behavior when available.
3. Gather the narrowest evidence: compiler/Gradle error, failing test, structured log, stack trace,
   crash/ANR, UI hierarchy, network/database artifact, trace, or heap dump.
4. Form one falsifiable hypothesis and choose an observation that distinguishes it.
5. Fix the root cause at its owner, then rerun the same reproduction and regression tests.

Separate build/configuration failures, behavior defects, coroutine races, resource leaks, and
performance regressions. They require different evidence.

## Logs and debugger

Use Logcat tags/categories and structured privacy-safe values. Do not log credentials, tokens,
personal data, raw payloads, or localized copy as internal state. Remove temporary logging unless it
has durable operational value.

Use Android Studio debugger, coroutine dump/debug probes when permitted, breakpoints, thread/heap
inspection, Layout Inspector, database/network inspectors, tombstones, and Play/Crash artifacts to
prove control flow and ownership. Timing-sensitive changes under a debugger require stronger
concurrency evidence.

## Performance method

1. Define a user-visible flow and metric.
2. Capture a comparable baseline, preferably release-like on representative hardware.
3. Locate inclusive first-party cost with Macrobenchmark, Baseline Profile tools, Perfetto/system
   trace, Compose tracing, CPU profiler, memory profiler, or allocation/heap evidence.
4. Make one targeted change.
5. Repeat the same flow and report delta/caveats.
6. Add a stable regression metric/test when valuable.

Inspect startup, frames/jank, ANRs, recomposition, CPU, memory, GC, allocations/leaks, disk/network
I/O, battery, wakeups, background work, APK/App Bundle size, and R8 behavior according to the
symptom. Emulator measurements help iteration but are not physical-device performance proof.

## Resource lifetime and reporting

For a leak, state intended lifetime and prove the retaining path using a heap dump/trace or isolated
reproduction. Also inspect coroutines, Flows, callbacks, observers, receivers, cursors, files,
bitmaps, WebViews, and Compose references for cleanup.

Report exact flow, variant/device/toolchain, artifacts, before/after metrics, symbols/hotspots,
remaining uncertainty, and validation. Distinguish verified, source-only, and inferred claims.
