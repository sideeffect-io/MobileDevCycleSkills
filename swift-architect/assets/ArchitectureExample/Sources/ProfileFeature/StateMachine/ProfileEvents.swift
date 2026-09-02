import DomainModel
import Foundation
import StateMachineCore

public enum ProfileEvent: Equatable, Sendable {}

struct ProfileInputWasReceived: Equatable, Event {
  typealias SuperEvent = ProfileEvent
  let input: ProfileInput
}

struct ProfileLoadingWasRequested: Equatable, Event {
  typealias SuperEvent = ProfileEvent
}

struct ProfileRetryWasRequested: Equatable, Event {
  typealias SuperEvent = ProfileEvent
}

struct ProfileLoadingDidSucceed: Equatable, Event {
  typealias SuperEvent = ProfileEvent
  let requestID: UUID
  let profile: Profile
}

struct ProfileLoadingDidFail: Equatable, Event {
  typealias SuperEvent = ProfileEvent
  let requestID: UUID
  let failure: ProfileLoadFailure
}

struct ProfileOutcomeWasConsumed: Equatable, Event {
  typealias SuperEvent = ProfileEvent
  let deliveryID: UUID
}
