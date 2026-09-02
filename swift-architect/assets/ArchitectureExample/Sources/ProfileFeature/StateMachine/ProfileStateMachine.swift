import StateMachineCore

public typealias ProfileStateMachine = AsyncStateMachine<ProfileViewState, ProfileEvent>
public typealias ProfileStateMachineFactory = AsyncStateMachineFactory<
  ProfileViewState, ProfileEvent
>

public func makeProfileStateMachine(
  dependencies: ProfileStateMachineDependencies
) -> ProfileStateMachine {
  AsyncStateMachine(initial: ProfileIsAwaitingInput()) {
    When(state: ProfileIsAwaitingInput.self) {
      On(event: ProfileInputWasReceived.self) { _, event in
        Transition(state: ProfileIsIdle(input: event.input))
      }
    }

    When(state: ProfileIsIdle.self) {
      On(event: ProfileInputWasReceived.self) { _, event in
        Transition(state: ProfileIsIdle(input: event.input))
      }

      On(event: ProfileLoadingWasRequested.self) { state, _ in
        let requestID = dependencies.generateID()
        Transition(state: ProfileIsLoading(input: state.input, requestID: requestID))
        Output(
          sideEffect: {
            await dependencies.loadProfile(
              userID: state.input.userID,
              requestID: requestID
            )
          },
          cancellationPolicy: Cancel(predicate: ProfileCancellation.shouldCancelLoad)
        )
      }
    }

    When(state: ProfileIsLoading.self) {
      On(event: ProfileInputWasReceived.self) { _, event in
        Transition(state: ProfileIsIdle(input: event.input))
      }

      On(event: ProfileLoadingWasRequested.self) { state, _ in
        let requestID = dependencies.generateID()
        Transition(state: ProfileIsLoading(input: state.input, requestID: requestID))
        Output(
          sideEffect: {
            await dependencies.loadProfile(
              userID: state.input.userID,
              requestID: requestID
            )
          },
          cancellationPolicy: Cancel(predicate: ProfileCancellation.shouldCancelLoad)
        )
      }

      On(event: ProfileLoadingDidSucceed.self, guard: ProfileGuard.isCurrentSuccess) {
        state, event in
        Transition(
          state: ProfileIsLoaded(
            input: state.input,
            profile: event.profile,
            pendingOutcome: ProfileOutcomeDelivery(
              id: dependencies.generateID(),
              outcome: .profileDidLoad(id: state.input.userID)
            )
          )
        )
      }

      On(event: ProfileLoadingDidFail.self, guard: ProfileGuard.isCurrentFailure) { state, event in
        Transition(state: ProfileIsInFailure(input: state.input, failure: event.failure))
      }
    }

    When(state: ProfileIsLoaded.self) {
      On(event: ProfileInputWasReceived.self) { _, event in
        Transition(state: ProfileIsIdle(input: event.input))
      }

      On(event: ProfileLoadingWasRequested.self) { state, _ in
        let requestID = dependencies.generateID()
        Transition(state: ProfileIsLoading(input: state.input, requestID: requestID))
        Output(
          sideEffect: {
            await dependencies.loadProfile(
              userID: state.input.userID,
              requestID: requestID
            )
          },
          cancellationPolicy: Cancel(predicate: ProfileCancellation.shouldCancelLoad)
        )
      }

      On(event: ProfileOutcomeWasConsumed.self, guard: ProfileGuard.isCurrentOutcome) { state, _ in
        Transition(
          state: ProfileIsLoaded(
            input: state.input,
            profile: state.profile,
            pendingOutcome: nil
          )
        )
      }
    }

    When(state: ProfileIsInFailure.self) {
      On(event: ProfileInputWasReceived.self) { _, event in
        Transition(state: ProfileIsIdle(input: event.input))
      }

      On(event: ProfileRetryWasRequested.self) { state, _ in
        let requestID = dependencies.generateID()
        Transition(state: ProfileIsLoading(input: state.input, requestID: requestID))
        Output(
          sideEffect: {
            await dependencies.loadProfile(
              userID: state.input.userID,
              requestID: requestID
            )
          },
          cancellationPolicy: Cancel(predicate: ProfileCancellation.shouldCancelLoad)
        )
      }
    }
  }
}

enum ProfileGuard {
  static func isCurrentSuccess(
    _ state: ProfileIsLoading,
    _ event: ProfileLoadingDidSucceed
  ) -> Bool {
    state.requestID == event.requestID
  }

  static func isCurrentFailure(
    _ state: ProfileIsLoading,
    _ event: ProfileLoadingDidFail
  ) -> Bool {
    state.requestID == event.requestID
  }

  static func isCurrentOutcome(
    _ state: ProfileIsLoaded,
    _ event: ProfileOutcomeWasConsumed
  ) -> Bool {
    state.pendingOutcome?.id == event.deliveryID
  }
}

enum ProfileCancellation {
  static func shouldCancelLoad(
    _: any State<ProfileViewState>,
    _ event: any Event<ProfileEvent>,
    _: (any State<ProfileViewState>)?
  ) -> Bool {
    event is ProfileInputWasReceived
      || event is ProfileLoadingWasRequested
  }
}
