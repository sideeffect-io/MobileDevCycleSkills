import DomainModel
import Foundation
import HTTPFramework
import ProfileDataSource
import ProfileFeature
import ProfileNavigation
import StateMachineCore
import SwiftUI

public struct AppCompositionRoot: Sendable {
  public let profileStateMachineFactory: ProfileStateMachineFactory

  public init(
    httpClient: HTTPDataClient,
    profileBaseURL: URL
  ) {
    let profileDataSource = ProfileRemoteDataSource(
      httpClient: httpClient,
      baseURL: profileBaseURL
    )
    let outputs = ProfileOutputs(
      loadProfile: LoadProfileOutput { userID in
        await profileDataSource.load(userID: userID)
      }
    )
    profileStateMachineFactory = ProfileStateMachineFactory(lifecycle: .instance) {
      makeProfileStateMachine(outputs: outputs)
    }
  }
}

public struct AppShell: View {
  private let compositionRoot: AppCompositionRoot
  private let userID: UserID
  private let onProfileOutcome: @MainActor @Sendable (ProfileOutcome) -> Void

  public init(
    compositionRoot: AppCompositionRoot,
    userID: UserID,
    onProfileOutcome: @MainActor @Sendable @escaping (ProfileOutcome) -> Void
  ) {
    self.compositionRoot = compositionRoot
    self.userID = userID
    self.onProfileOutcome = onProfileOutcome
  }

  public var body: some View {
    ProfileFlowView(
      route: .profile(userID: userID),
      onOutcome: onProfileOutcome
    )
    .environment(
      \.profileStateMachineFactory,
      compositionRoot.profileStateMachineFactory
    )
  }
}
