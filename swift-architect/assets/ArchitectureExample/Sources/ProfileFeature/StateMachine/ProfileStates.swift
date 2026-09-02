import DomainModel
import Foundation
import StateMachineCore

struct ProfileOutcomeDelivery: Equatable, Sendable {
  let id: UUID
  let outcome: ProfileOutcome
}

public struct ProfileViewState: Equatable, Sendable {
  let isAwaitingInput: Bool
  let isLoading: Bool
  let profile: Profile?
  let failure: ProfileLoadFailure?
  let pendingOutcome: ProfileOutcomeDelivery?
}

struct ProfileIsAwaitingInput: Equatable, State {
  var superState: ProfileViewState {
    ProfileViewState(
      isAwaitingInput: true,
      isLoading: false,
      profile: nil,
      failure: nil,
      pendingOutcome: nil
    )
  }
}

struct ProfileIsIdle: Equatable, State {
  let input: ProfileInput

  var superState: ProfileViewState {
    ProfileViewState(
      isAwaitingInput: false,
      isLoading: false,
      profile: nil,
      failure: nil,
      pendingOutcome: nil
    )
  }
}

struct ProfileIsLoading: Equatable, State {
  let input: ProfileInput
  let requestID: UUID

  var superState: ProfileViewState {
    ProfileViewState(
      isAwaitingInput: false,
      isLoading: true,
      profile: nil,
      failure: nil,
      pendingOutcome: nil
    )
  }
}

struct ProfileIsLoaded: Equatable, State {
  let input: ProfileInput
  let profile: Profile
  let pendingOutcome: ProfileOutcomeDelivery?

  var superState: ProfileViewState {
    ProfileViewState(
      isAwaitingInput: false,
      isLoading: false,
      profile: profile,
      failure: nil,
      pendingOutcome: pendingOutcome
    )
  }
}

struct ProfileIsInFailure: Equatable, State {
  let input: ProfileInput
  let failure: ProfileLoadFailure

  var superState: ProfileViewState {
    ProfileViewState(
      isAwaitingInput: false,
      isLoading: false,
      profile: nil,
      failure: failure,
      pendingOutcome: nil
    )
  }
}
