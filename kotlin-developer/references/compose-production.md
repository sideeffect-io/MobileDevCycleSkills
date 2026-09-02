# Jetpack Compose Production

<!-- kotlin-suite:KOTLIN-PRESENTATION -->

## Ownership before state APIs

Choose the source of truth first:

| Ownership | Default tool |
| --- | --- |
| local transient UI element | `remember` |
| saveable UI element input | `rememberSaveable` when Bundle-safe |
| state shared by composables | hoist to the lowest common owner |
| screen business state | destination/screen `ViewModel` exposing immutable `StateFlow` |
| persistent application data | repository source of truth |

Do not hoist every UI element into a ViewModel. Conversely, do not keep business state in
composition-local `mutableStateOf`. One authoritative owner updates state in response to events.

## Route and Screen

Use a stateful `<Feature>Route` to obtain the ViewModel, collect with
`collectAsStateWithLifecycle()`, translate platform/navigation callbacks, and call a stateless
`<Feature>Screen`. The Screen receives immutable state and semantic callbacks. Do not pass a
ViewModel, repository, state-machine runtime, `NavController`, coroutine scope, or Hilt component
through the tree.

Keep composable bodies declarative and free of direct I/O, data-layer calls, and expensive policy.
Use `LaunchedEffect`, `DisposableEffect`, `SideEffect`, or `produceState` only for lifecycle-bound
presentation effects with correct keys and cleanup. Starting feature work should send an explicit
intent/event; it should not hide policy in an effect block.

## UDF, identity, and navigation

State flows down and events flow up. Prefer semantic callbacks (`onRetry`, `onTripSelected`) over a
generic mutation closure. Use stable keys for lazy content and immutable/stable inputs where the
real contract supports them; do not add stability annotations to conceal mutable behavior.

Navigation caused directly by a UI action can call the navigation callback. When navigation or a
message depends on business validation, model readiness/message as durable UI state and acknowledge
consumption after the UI acts. Avoid lossy one-shot Channels/SharedFlows by default.

Use typed routes when supported by the selected Navigation version. Keep route parsing and parent
coordination outside child Screens.

## Accessibility, localization, and adaptive UI

Prefer semantic Material controls over click gestures. Preserve content descriptions where needed,
role/state/value semantics, heading/live-region behavior, focus order, keyboard/D-pad input, touch
targets, contrast, font scaling, reduced motion, and TalkBack/Switch Access flows.

Every user-facing string, plural, accessibility label, notification, widget, shortcut, tile, and
metadata value follows repository resources and all supported locales. Do not display exception
messages. Use locale-aware formatters and test RTL when a supported locale requires it.

Build adaptive layouts for window size classes, orientation, foldables, tablets, ChromeOS, and
multi-window as the product supports. Do not encode phone-only width assumptions.

## Previews, tests, and performance

Keep previews deterministic, backend-free, and independent of Hilt/ViewModels. Cover primary,
loading, empty, failure, large-font, dark, and locale states when valuable. Test stateless Screens
with semantic nodes/actions; add screenshot tests only where visual regression value justifies them.

Treat recomposition/performance advice as a hypothesis. Use Layout Inspector, compiler reports,
Compose tracing, Macrobenchmark, or system traces to prove a problem. Stabilize identity, narrow
observed state, move work out of composition, and compare the same flow before/after.
