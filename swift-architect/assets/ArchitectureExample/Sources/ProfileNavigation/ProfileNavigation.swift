import DomainModel
import ProfileFeature
import SwiftUI

public enum ProfileRoute: Hashable, Sendable {
  case profile(userID: UserID)
}

public struct ProfileFlowView: View {
  private let route: ProfileRoute
  private let onOutcome: @MainActor @Sendable (ProfileOutcome) -> Void

  public init(
    route: ProfileRoute,
    onOutcome: @MainActor @Sendable @escaping (ProfileOutcome) -> Void
  ) {
    self.route = route
    self.onOutcome = onOutcome
  }

  public var body: some View {
    switch route {
    case .profile(let userID):
      ProfileRootView(input: .user(id: userID), onOutcome: onOutcome)
    }
  }
}
