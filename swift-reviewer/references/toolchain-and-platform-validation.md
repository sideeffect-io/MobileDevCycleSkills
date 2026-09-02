# Toolchain and Platform Verification

<!-- swift-suite:REVIEW-TOOLCHAIN-PLATFORM -->

Use this reference when a claim depends on Swift/Xcode currency, Apple SDK availability, process
boundaries, entitlements, migration, runtime behavior, or a device-only surface.

## Reconstruct the environment

Record compiler/toolchain, target language and strict-concurrency/default-isolation settings, enabled
upcoming or experimental features, imported-module annotations, manifest tools versions, Xcode/SDKs,
deployment targets, destinations, and minimum/current CI lanes.
Useful discovery commands include `xcrun swift --version`, `xcodebuild -version`, `xcodebuild
-showsdks`, `swift package dump-package`, `xcodebuild -list -json`, and target-specific
`xcodebuild -showBuildSettings`.

Do not infer target behavior from “Swift 6,” infer SDK availability from Swift.org releases, guess a
generated package scheme, or treat a current-toolchain pass as minimum-toolchain evidence. Verify
post-6.0 syntax, isolation behavior, SDK/OS availability, build flags, and supported CI lanes
separately.

## Route proof by execution owner

| Surface | Minimum independent proof | Additional high-risk proof |
| --- | --- | --- |
| Pure/domain library | owner tests and target build | minimum/current toolchain lanes |
| SwiftUI feature | owner tests and platform compile | interaction, accessibility, locales |
| Navigation/deep link | route/composition tests | cold/warm URL, stale/repeated delivery |
| Persistence/migration | repository/migration tests | old data, interruption, retry/recovery |
| Widget/Live Activity/App Intent/extension | owning target/process and host build when distinct | system invocation and lifecycle |
| Background/location/CarPlay | target and composition tests | entitlement/permission flow; device if needed |
| Performance/resources | defined baseline flow | comparable trace, metric, signpost, or memgraph |

Compilation proves availability and type checking for one destination. It does not prove permission,
callbacks, restoration, system presentation, extension launch, background execution, migration,
accessibility, energy, or device behavior.

## Verify App Intents and system actions

<!-- swift-suite:REVIEW-SYSTEM-SURFACES -->

Check that the change exposes user-valued actions rather than screens or the navigation/persistence
graph. Require narrow `AppEntity` values, `AppEnum` for fixed choices when appropriate, and an
`EntityQuery` only when suggestions or disambiguation are useful. Intent types remain thin and call an
owned feature/domain capability instead of embedding business policy or concrete data access.

Verify the declared inline-versus-open-app behavior and one runtime handoff into the owning
scene/workflow. Trace authorization, permissions, correlation, idempotency, repeated or delayed
invocation, missing/stale entities, cancellation, finite failures, and recovery. Inspect localized
titles, phrases, prompts, dialogs, and display representations, then invoke the action from the actual
system surface; owning-target/process and host builds alone are insufficient.

Inventory all affected locales, resource bundles, accessibility semantics, Dynamic Type/focus,
light/dark and increased contrast, Differentiate Without Color, Reduce Motion, VoiceOver,
keyboard/pointer input, compact/regular layouts, iPad multitasking/window resizing, extension
surfaces, App Intents, notifications, exports, widgets, and Live Activities. Source lint and live
locale behavior are separate evidence.

Make `security-privacy` applicable for credentials, authentication/authorization, network trust,
untrusted URLs/input, logs/analytics, user data, entitlements, Keychain/data protection, permissions,
sharing, or exports. Never put secrets or personal data in review evidence.

Record exact commands, working directories, schemes, bundle identifiers/processes, destinations,
observable start/end states, results, and stable artifacts. Trace-based claims require UUID-matched
symbols and complete first-party symbolication for the measured build. Unavailable
devices/accounts/entitlements/toolchains are blocked or not run, never silently non-applicable.
