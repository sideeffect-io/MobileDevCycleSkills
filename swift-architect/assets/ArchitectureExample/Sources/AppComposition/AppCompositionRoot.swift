import DomainModel
import Foundation
import HTTPFramework
import ProfileFeature
import ProfileNavigation
import SwiftUI

public struct AppCompositionRoot: Sendable {
  public let profileStateMachineFactory: ProfileStateMachineFactory

  public init(
    httpClient: HTTPDataClient,
    profileBaseURL: URL
  ) {
    profileStateMachineFactory = Self.makeProfileFactory(
      httpClient: httpClient,
      baseURL: profileBaseURL
    )
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
