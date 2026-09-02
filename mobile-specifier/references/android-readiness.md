# Android readiness

Use this reference only for native Android requests. These are applicability signals, not a
mandatory questionnaire. Prefer behavior already established by the live repository.

## Journey and presentation

Inspect the affected Activity, Compose Route/Screen or View surface, Navigation destination, and
current behavior owner. When the request changes the journey, establish applicable launch,
destination, up/back, predictive-back, dismiss, cancel, deep-link, duplicate-tap, and repeat-entry
outcomes.

Ask only when the repository leaves materially different user outcomes plausible. Do not ask the
user to choose NavController structure, ViewModels, StateFlow, state machines, Hilt, or Gradle
ownership.

## Lifecycle, windows, and recovery

For work that can outlive the visible surface, distinguish the intended user outcome after
configuration change, window-size change, backgrounding, task removal, process death, or reopening.
Resolve whether work continues, pauses, cancels, checkpoints, retries, or needs explicit restart
only when the feature depends on that policy.

Do not make routine Compose recomposition a specification question. Coroutine scopes, SavedState,
services, WorkManager, and restoration mechanics belong downstream.

## Permissions and privacy

For location, camera, microphone, media, Bluetooth, notifications, contacts, or other protected
access, establish applicable user-visible behavior for:

- the explicit action and rationale that precede the prompt;
- denial, permanent denial, restriction, approximate access, or partial media access;
- a Settings route, manual alternative, or degraded feature path; and
- collection, retention, disclosure, deletion, and sensitive content shown outside the app.

Use binding repository policy when present. Do not ask the user to choose manifest permissions,
permission-launcher APIs, service types, or SDK wrappers.

## Data and destructive behavior

For persistence, offline work, synchronization, sharing, account identity, import/export,
migration, or deletion, resolve applicable user outcomes for pending changes, retry, conflicts,
account switching, process recovery, confirmation, reversibility, and data retention.

Room, DataStore, Firebase, files, repositories, workers, and migration mechanics remain downstream
unless their choice exposes an unsettled product behavior.

## Android system surfaces

For App Links, intents, notification actions, foreground services, widgets, shortcuts, workers,
Android Auto, or other system-created components, establish the semantic action and observable
outcome for cold process delivery, signed-out state, unavailable destinations, duplicate/replayed
intents, dismissal, and privacy on shared surfaces when applicable.

Do not ask the user to select PendingIntent flags, component classes, WorkManager policy, service
implementation, or intent-parsing architecture.

## Accessibility, localization, and adaptation

Use repository policy for supported locales, TalkBack, Switch Access, keyboard/D-pad navigation,
font scale, animation scale, contrast, touch targets, IME, dark/light themes, orientation, tablets,
foldables, and window classes. Ask only when a product choice remains—for example, whether a large
window gains a simultaneous detail pane—not for established quality obligations.

Visual parity with iOS means equivalent hierarchy, semantics, and outcomes implemented with native
Material/Android behavior, not copied Apple layout or assets.
