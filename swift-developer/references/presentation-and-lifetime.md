# Presentation and lifetime

Use this reference when a SwiftUI, UIKit, navigation, sheet, popover, full-screen cover, or hosted
controller does not appear, remain mounted, or dismiss at the expected boundary.

## Ownership

- The owner that initiates a presentation owns its binding or item identity and decides when that
  presentation is dismissed. A child emits a semantic completion or cancellation request; it does not
  mutate an unrelated ancestor's navigation state.
- Keep durable feature facts and transient presentation state distinct. A refreshed projection, loading
  transition, or child success event must not implicitly mean “dismiss the current presentation” unless
  that is the accepted contract.
- Lifecycle callbacks (`onAppear`, `onDisappear`, controller appearance methods) observe mounting. They
  are not authoritative account, identity, persistence, or workflow-commit boundaries.
- Use stable presentation identity. Avoid recreating an item or host solely because a child completed;
  preserve the identity while the current screen remains part of the flow.

## Trace checklist

1. Identify the presentation host and the exact binding/item passed to it.
2. Identify the child completion path and every callback/output it emits.
3. Check whether a parent projection, task, or identity change causes the host to be rebuilt or its
   binding to become `nil`.
4. Distinguish an explicit dismissal request from an incidental view recomputation, data refresh, or
   navigation replacement.
5. Verify the mounted destination/controller after the completion, not only the state-machine event.

## Proof

- Unit or feature tests should assert the semantic completion and the intended presentation command or
  absence of a dismissal command.
- Hosted SwiftUI/UIKit tests or Simulator evidence should assert the mounted destination/controller
  identity when retention or dismissal is user-visible behavior.
- For async presentation, test owner teardown, cancellation, duplicate completion, and stale completion
  only when those paths are part of the boundary contract.
- A green transition test does not prove that a presentation stayed mounted; pair it with mounted
  identity evidence when lifetime is the behavior under test.
