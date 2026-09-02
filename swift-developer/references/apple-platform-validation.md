# Apple Platform Validation

<!-- swift-suite:SWIFT-APPLE-PLATFORM-VALIDATION -->

## Route by product, not by file extension

First identify the changed product and execution owner: portable Swift library, iOS feature package,
macOS target, app scene, widget/Live Activity, App Intent, notification/service extension, CarPlay
surface, persistence adapter, or top-level composition. A `.swift` file can require a host process,
entitlement, SDK, Simulator, or device even when its unit tests run on macOS.

Use the repository's documented commands and generated schemes. For a Swift package:

- run `swift test` only when the package genuinely supports the host platform;
- run `xcodebuild -list -json` before selecting a generated package scheme;
- build or test an iOS-only package with its `<Package>-Package`/discovered scheme and an explicit
  Simulator destination;
- use a temporary DerivedData/result-bundle path for isolated evidence;
- record scheme, configuration, SDK, destination, and exit status.

## Risk matrix

| Surface | Minimum executable evidence | Additional proof when behavior is at risk |
| --- | --- | --- |
| Pure/domain library | target build and deterministic owner tests | minimum/current toolchain lanes |
| SwiftUI feature | owning target tests plus iOS compile | Simulator interaction, accessibility, supported locales |
| macOS scene/window/commands | macOS scheme build/tests | launch, menu/window restoration, keyboard and VoiceOver flow |
| Navigation/deep link | route and composition tests | cold/warm launch URL flow and stale/repeated delivery |
| Persistence/migration | model/repository and migration tests | old-store upgrade, interruption, rollback/recovery, device storage |
| Widget/Live Activity/App Intent | owning target/process plus host build when distinct | system invocation, timeline/activity lifecycle, authorization |
| Background/location/CarPlay | target and composition tests | real entitlement/permission lifecycle; device when Simulator differs |
| Performance/memory | defined baseline flow | comparable trace, signpost, memgraph, or metric evidence |

Compilation proves availability and type checking for that destination. It does not prove
permissions, callbacks, restoration, system presentation, extension launch, background execution,
data migration, accessibility, energy, or device-only behavior.

## App Intents and system actions

<!-- swift-suite:SWIFT-SYSTEM-SURFACES -->

Implement actions rather than screens. Keep intent types thin and translate narrow, display-friendly
`AppEntity` values into an existing feature/domain capability; never mirror the persistence graph or
put business policy in the intent. Prefer `AppEnum` for fixed choices and add `EntityQuery` only when
suggestions or disambiguation provide user value.

Choose explicitly whether the action completes in the invoking surface or opens the app. Use one
runtime handoff into the owning scene/workflow and preserve authorization, permissions, cancellation,
finite failures, correlation, idempotency, repeated/delayed invocation, and missing or stale entities.
Do not hide routing in a global side effect.

Expose only high-value actions through `AppShortcutsProvider` or another applicable system surface.
Localize titles, phrases, parameter prompts, result dialogs, and entity display representations in
every supported locale. Validate from the actual system surface as well as building the owning target
and host when distinct; prove the expected inline result or in-app destination and recovery behavior.

## Localization and accessibility

For every changed user-facing surface, inventory the repository's supported locales and resource
owners. Check key parity, syntax, bundle selection, interpolation/plural behavior, accessibility
labels/hints/values/actions, Dynamic Type, focus, light/dark and increased contrast, Differentiate
Without Color, Reduce Motion, VoiceOver, keyboard/pointer behavior, compact/regular layouts, iPad
multitasking/window resizing, and rotation as applicable. Include extensions, App Intents,
notifications, exports, `InfoPlist.strings`, widgets, and Live Activities rather than validating only
the main app bundle.

Use source/resource lint as one gate and live regional locales as another. Record explicit locale
identifiers and destination; system-default testing alone can hide missing bundles.

## Process boundaries, recovery, and privacy

Trace which process owns state and which APIs cross process/scene boundaries. Validate activation,
termination, replacement, duplicate delivery, stale results, backgrounding, and restoration for the
affected surface. For persistence, test both fresh and existing data, partial failure, retry, and
cleanup ownership.

Make `security-privacy` explicitly applicable when the change touches credentials, authentication,
authorization, network trust, URLs/deep links, untrusted input, logs/analytics, user data,
entitlements, Keychain, data protection, privacy manifests, permissions, sharing, or exports. Inspect
repository-specific policy and use a focused security review when risk warrants it. Never place
secrets or personal data in a report, handoff, command line, screenshot, log, or fixture.

## Evidence

For each applicable matrix row, record the exact command or named runtime flow, working directory,
toolchain, scheme/destination, result, and durable evidence path when one exists. Classify missing
device/account/entitlement state as blocked or not run; do not relabel it non-applicable. The
reviewer independently replays the narrowest high-risk proof.
