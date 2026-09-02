# iOS readiness

Use this reference only for native iOS requests. These are applicability signals, not a checklist
to recite or a reason to question behavior already established by the repository.

## Journey and presentation

Inspect the affected SwiftUI/UIKit entry point and current navigation or presentation owner. When
the request changes the journey, establish what the user observes for push, sheet, full-screen,
tab, deep-link, back, swipe-to-dismiss, cancel, and repeat-entry behavior that actually applies.

Ask only when multiple materially different outcomes remain. Existing app navigation conventions
can supply the default. Do not ask the user to choose NavigationStack structure, coordinators,
state-machine states, factories, or package ownership.

## Lifecycle and recovery

For work that can outlive the visible screen, determine the approved behavior when the scene moves
to the background, the task is cancelled, the process terminates, or the user returns later.
Distinguish continuation, pausing, cancellation, checkpoint recovery, and explicit restart only
when the feature needs that distinction.

Do not turn ordinary synchronous screen interactions into lifecycle questions. Actor isolation,
task ownership, cancellation implementation, and state restoration mechanics belong downstream.

## Permissions and privacy

For capabilities involving location, camera, microphone, photos, Bluetooth, notifications,
tracking, contacts, or other protected data, establish the user-visible policy when applicable:

- which explicit user action triggers the request;
- useful behavior before authorization and after denial, restriction, or limited access;
- whether Settings guidance or a manual alternative is offered;
- whether approximate or reduced access changes the outcome; and
- what data is collected, retained, displayed, shared, or deleted.

Use existing privacy policy and least-privilege behavior when the repository makes them binding.
Do not ask the user for Info.plist keys or framework APIs.

## Data and destructive behavior

When persistence, sync, sharing, account identity, import/export, or deletion changes, resolve the
observable offline behavior, source of truth, conflict outcome, account-switch effect, recovery,
confirmation, reversibility, and migration expectation only where the request makes them relevant.

Repository data contracts may settle these behaviors. Core Data, CloudKit, Firestore, Keychain,
file formats, repository protocols, and migration implementation are downstream decisions unless
the user-visible policy remains ambiguous.

## Apple system surfaces

For notifications, widgets, Live Activities, App Intents, Universal Links, CarPlay, extensions, or
other system-created entry points, establish the semantic action and outcome when the app is cold,
locked, signed out, unavailable, or already handling the same request. Ask about replay, duplicate
delivery, privacy on shared surfaces, and destination failure only when those outcomes are not
already specified by the app.

Do not ask the user to choose ActivityKit, WidgetKit, AppIntents, scene-delegate, or handoff-store
mechanics.

## Accessibility, localization, and adaptation

Use repository policy for supported locales, VoiceOver, Dynamic Type, Reduce Motion, contrast,
touch targets, orientation, iPad, and size-class behavior. Ask only when the product decision itself
is unclear—for example, whether an animation conveys required meaning or an iPad journey should
differ—not for mandatory quality already established by repository guidance.

Visual parity with Android means equivalent hierarchy, semantics, and outcomes expressed through
native iOS behavior, not copied Android layout or assets.
