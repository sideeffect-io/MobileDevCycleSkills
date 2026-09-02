import DomainModel
import Foundation
import StateMachineCore
import SwiftUI

public struct ProfileRootView: View {
  @Environment(\.profileStateMachineFactory) private var stateMachineFactory

  private let input: ProfileInput
  private let onOutcome: @MainActor @Sendable (ProfileOutcome) -> Void

  public init(
    input: ProfileInput,
    onOutcome: @MainActor @Sendable @escaping (ProfileOutcome) -> Void
  ) {
    self.input = input
    self.onOutcome = onOutcome
  }

  public var body: some View {
    StateMachineView(factory: stateMachineFactory) { machine in
      ProfileContentView(
        state: machine.state,
        load: { machine.send(ProfileLoadingWasRequested()) },
        retry: { machine.send(ProfileRetryWasRequested()) }
      )
      .onChange(of: input, initial: true) { _, input in
        machine.send(ProfileInputWasReceived(input: input))
      }
      .onChange(of: machine.state.pendingOutcome, initial: true) { _, delivery in
        guard let delivery else { return }
        onOutcome(delivery.outcome)
        machine.send(ProfileOutcomeWasConsumed(deliveryID: delivery.id))
      }
    }
  }
}

extension EnvironmentValues {
  public var profileStateMachineFactory: ProfileStateMachineFactory {
    get { self[ProfileStateMachineFactoryKey.self] }
    set { self[ProfileStateMachineFactoryKey.self] = newValue }
  }
}

private struct ProfileStateMachineFactoryKey: EnvironmentKey {
  static let defaultValue = ProfileStateMachineFactory.default(
    initial: ProfileIsAwaitingInput()
  )
}
