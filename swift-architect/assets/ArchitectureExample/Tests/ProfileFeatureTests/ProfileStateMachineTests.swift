import DomainModel
import Foundation
import StateMachineTest
import Testing
import XCTest

@testable import ProfileFeature

@Test
func profileLoadJourneyProducesASemanticOutcome() async {
  let userID = UserID(rawValue: UUID())
  let generatedID = UUID()
  let profile = Profile(id: userID, displayName: "Taylor")
  let machine = makeProfileStateMachine(
    dependencies: ProfileStateMachineDependencies(
      loadProfile: LoadProfileOutput { _ in .success(profile) },
      generateID: { generatedID }
    )
  )

  await StateMachineTest.XCTAssert(
    asyncStateMachine: machine,
    timeout: .milliseconds(500)
  ) { assertions in
    await assertions.assert(state: ProfileIsAwaitingInput())
    assertions.send(event: ProfileInputWasReceived(input: .user(id: userID)))
    await assertions.assert(state: ProfileIsIdle(input: .user(id: userID)))
    assertions.send(event: ProfileLoadingWasRequested())
    await assertions.assert(
      state: ProfileIsLoading(input: .user(id: userID), requestID: generatedID)
    )
    await assertions.assert(
      state: ProfileIsLoaded(
        input: .user(id: userID),
        profile: profile,
        pendingOutcome: ProfileOutcomeDelivery(
          id: generatedID,
          outcome: .profileDidLoad(id: userID)
        )
      )
    )
  }
}

@Test
func staleSuccessCannotReplaceTheCurrentRequest() async {
  let userID = UserID(rawValue: UUID())
  let currentRequestID = UUID()
  let staleEvent = ProfileLoadingDidSucceed(
    requestID: UUID(),
    profile: Profile(id: userID, displayName: "Stale")
  )
  let machine = makeProfileStateMachine(
    dependencies: ProfileStateMachineDependencies(
      loadProfile: LoadProfileOutput { _ in .cancelled },
      generateID: UUID.init
    )
  )

  await StateMachineTest.XCTAssertNoTransition(
    asyncStateMachine: machine,
    when: ProfileIsLoading(input: .user(id: userID), requestID: currentRequestID),
    on: staleEvent
  )
}

@Test
func profileLoadFailureEntersAFiniteFailureState() async {
  let userID = UserID(rawValue: UUID())
  let requestID = UUID()
  let machine = makeProfileStateMachine(
    dependencies: ProfileStateMachineDependencies(
      loadProfile: LoadProfileOutput { _ in .failure(.unavailable) },
      generateID: { requestID }
    )
  )

  await StateMachineTest.XCTAssert(
    asyncStateMachine: machine,
    timeout: .milliseconds(500)
  ) { assertions in
    await assertions.assert(state: ProfileIsAwaitingInput())
    assertions.send(event: ProfileInputWasReceived(input: .user(id: userID)))
    await assertions.assert(state: ProfileIsIdle(input: .user(id: userID)))
    assertions.send(event: ProfileLoadingWasRequested())
    await assertions.assert(
      state: ProfileIsLoading(input: .user(id: userID), requestID: requestID)
    )
    await assertions.assert(
      state: ProfileIsInFailure(input: .user(id: userID), failure: .unavailable)
    )
  }
}

@Test
func consumingTheCurrentOutcomeClearsItsDelivery() async {
  let userID = UserID(rawValue: UUID())
  let deliveryID = UUID()
  let profile = Profile(id: userID, displayName: "Taylor")
  let loaded = ProfileIsLoaded(
    input: .user(id: userID),
    profile: profile,
    pendingOutcome: ProfileOutcomeDelivery(
      id: deliveryID,
      outcome: .profileDidLoad(id: userID)
    )
  )
  let machine = makeProfileStateMachine(
    dependencies: ProfileStateMachineDependencies(
      loadProfile: LoadProfileOutput { _ in .cancelled },
      generateID: UUID.init
    )
  )

  await StateMachineTest.XCTAssertTransition(
    asyncStateMachine: machine,
    when: loaded,
    on: ProfileOutcomeWasConsumed(deliveryID: deliveryID),
    transitionsTo: ProfileIsLoaded(
      input: .user(id: userID),
      profile: profile,
      pendingOutcome: nil
    )
  )
}

@Test
func retryDoesNotCancelAnInFlightLoadWithoutAReplacementTransition() {
  let userID = UserID(rawValue: UUID())
  let state = ProfileIsLoading(input: .user(id: userID), requestID: UUID())

  let shouldCancel = ProfileCancellation.shouldCancelLoad(
    state,
    ProfileRetryWasRequested(),
    nil
  )

  #expect(!shouldCancel)
}
