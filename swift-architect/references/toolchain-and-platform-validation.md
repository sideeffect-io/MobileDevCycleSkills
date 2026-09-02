# Toolchain and Platform Planning

<!-- swift-suite:ARCH-TOOLCHAIN-PLATFORM -->

Use this reference when architecture depends on compiler, SDK, deployment, system-surface semantics,
process, entitlement, or device behavior.

## Establish the environment

Record separately:

1. compiler/toolchain version;
2. Swift language mode, strict-concurrency/default-isolation settings, enabled upcoming or
   experimental features, and imported-module annotations;
3. Swift tools versions from manifests;
4. Xcode and available SDK versions;
5. deployment targets, supported destinations, and minimum/current CI lanes.

Do not infer Apple SDK availability from a Swift.org release or infer target language behavior from
the manifest tools version. Before adopting a newer API or language feature, prove that the selected
compiler parses it, the target enables it, the SDK and OS support it, and every required build lane
can ship it. Record availability guards and migration effects on isolation or behavior.

Useful discovery commands include `xcrun swift --version`, `xcodebuild -version`, `xcodebuild
-showsdks`, `swift package dump-package`, `xcodebuild -list -json`, and target-specific
`xcodebuild -showBuildSettings`. Use repository wrappers when present and never guess generated
package schemes.

## Design system-surface contracts

<!-- swift-suite:ARCH-SYSTEM-SURFACES -->

Start with one to three user-valued actions people need outside the app rather than mirroring screens
or the navigation tree. Define each verb, finite parameters, authorization, observable result, and
failure/cancellation semantics. Keep an `AppEntity` narrower than the persistence model; prefer an
`AppEnum` for fixed choices and add an `EntityQuery` only for genuine suggestion or disambiguation.

Decide whether each action completes in the invoking surface or opens the app. When app execution is
required, define one runtime handoff into the owning scene/workflow, including correlation,
idempotency, repeated or delayed delivery, missing/stale entities, locked or offline state, and
recovery. Assign every executable process its own composition root and minimal dependency graph.

Plan discoverability through concise localized titles, phrases, symbols, and only the shortcuts or
system surfaces with demonstrated user value. Require invocation from the actual system surface;
owning-target/process and host compilation alone do not prove routing, authorization, or result presentation.

## Route validation by product

Identify the execution owner: portable library, iOS/macOS feature, app scene, widget/Live Activity,
App Intent, notification extension, CarPlay, background/location service, persistence adapter, or
composition root. A Swift file may still require a host process, entitlement, SDK, Simulator, or
device.

| Surface | Minimum planned evidence | Behavior-risk evidence |
| --- | --- | --- |
| Pure/domain library | owner tests and target build | minimum/current toolchain lanes |
| SwiftUI feature | owner tests and platform compile | Simulator flow, accessibility, locales |
| Navigation/deep link | route/composition tests | cold/warm URL flow, stale/repeated delivery |
| Persistence/migration | model/repository/migration tests | old-store upgrade, interruption, recovery |
| Extension/system surface | owning target/process and host build when distinct | system invocation and lifecycle |
| Background/location/CarPlay | target and composition tests | entitlement/permission lifecycle; device if needed |
| Performance/resources | defined baseline flow | comparable trace, signpost, memgraph, or metric |

Compilation proves availability and type checking for one destination. It does not prove permission,
callback, restoration, extension launch, migration, accessibility, energy, or device-only behavior.

For runtime and performance proof, define the exact product, scheme/bundle, build configuration,
destination, observable start and end states, metric, and artifact integrity requirements. Trace-based
claims require complete first-party symbolication for the build being measured and comparable runs of
the same focused flow.

Plan localization and accessibility across every affected resource owner and process. Make
security/privacy explicitly applicable for credentials, authorization, untrusted input, network
trust, deep links, logs, user data, entitlements, permissions, sharing, or exports. Never put secrets
or personal data in an artifact, command, screenshot, log, or fixture.

For UI work, select an applicable adaptive matrix: compact/regular layouts, iPhone/iPad and
multitasking/window resizing, rotation, Dynamic Type extremes, light/dark and increased-contrast
appearances, Differentiate Without Color, Reduce Motion, VoiceOver, keyboard/pointer input, and
localization expansion. Do not require irrelevant variants, but name every deferred one.

Classify unavailable devices, accounts, entitlements, or minimum toolchains as blocked/not run—not
non-applicable—and name the proof still required.
