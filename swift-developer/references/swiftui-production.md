# SwiftUI Production

<!-- swift-suite:SWIFT-PRESENTATION -->

## Ownership before wrappers

Choose the source of truth first:

| Ownership | Default tool |
| --- | --- |
| Local transient value state | `@State` |
| Child edits parent-owned value | `@Binding` |
| View owns an `@Observable` reference | `@State` |
| Child uses an injected observable reference | explicit stored property / `@Bindable` when bindings are needed |
| Shared service or configuration | typed `@Environment` |
| Legacy deployment/model | `@StateObject` owner and `@ObservedObject` consumer |

Follow the current architecture decision or lifecycle handoff when a feature root owns
`StateMachineView`. Child views receive a
small equatable projection and semantic callbacks; they do not store the machine, call repositories,
route, export, or adapt SDKs.

## View composition

Keep `body` declarative, stable, and free of side effects or expensive derived work. Extract a
dedicated subview when a section has independent meaning, state, branching, reuse, or a useful
preview. Prefer explicit inputs over passing an entire parent model. Small computed view helpers are
fine; do not hide a whole screen behind them.

Prefer semantic system containers and controls: `NavigationStack`, `NavigationSplitView`, `List`,
`Form`, `Table`, `Button`, `Toggle`, `Menu`, `Label`, and `ContentUnavailableView`. Use typed routes,
tabs, and item-driven presentations. Avoid multiple booleans for mutually exclusive destinations,
gesture-only buttons, broad `AnyView`, unstable `ForEach` identity, and heavy work in `body`.

Put lifecycle-triggered intent in `.task`, `.task(id:)`, `onChange`, or the feature-root activation
contract as appropriate. Those closures may initiate the explicit workflow; they must not contain
hidden business logic or direct I/O.

## Accessibility and localization

Use semantic controls first; preserve Dynamic Type extremes, meaningful labels/values/hints, focus
order, hit targets, light and dark appearances, increased contrast, Differentiate Without Color,
reduced motion, keyboard/pointer navigation, VoiceOver, and macOS accessibility. Test important flows
with accessibility settings, not only labels in source.

Every changed user-facing string must use the repository localization path and be updated in every
supported locale. Include accessibility text, notifications, widgets/Live Activities, App Intents,
menus/commands, exports/PDFs, metadata, and Info.plist strings. Package resources use
`Bundle.module`; do not assume the app main bundle finds them.

Use locale-aware `FormatStyle` and injected locale/calendar/time-zone for testable formatting. Do
not display raw errors or debug descriptions.

## iOS and macOS

Use availability checks and fallbacks for APIs newer than the deployment target. On iOS, validate
compact/regular layouts, iPhone/iPad, multitasking or window resizing, rotation, and keyboard/pointer
input when applicable. Respect macOS window/scene commands, Settings, menu bars, tables,
keyboard/mouse interactions, and AppKit interoperation rather than applying iPhone layout
assumptions. Isolate UIKit/AppKit representables and coordinators as presentation adapters with
explicit ownership and cleanup.

## Previews and UI validation

Provide deterministic, backend-free previews for primary, empty, loading, failure, accessibility,
localization, color-scheme, content-size, and size-class states when valuable. Build previews or their
package target. Then validate the real flow on a Simulator/device for state identity, navigation,
sheets, deep links, focus, adaptive layout, restoration, and platform-specific behavior that source
inspection cannot prove.

Treat SwiftUI performance advice as a hypothesis until profiling or a clear invalidation/identity
defect supports it. Narrow observation, stabilize identity, move work out of hot paths, downsample
images, and compare the same flow before and after.
