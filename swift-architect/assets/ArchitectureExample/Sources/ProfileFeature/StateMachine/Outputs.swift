import DomainModel
import Foundation
import StateMachineCore

public struct LoadProfileOutput: Sendable {
  private let load: @Sendable (UserID) async -> ProfileLoadResult

  public init(load: @escaping @Sendable (UserID) async -> ProfileLoadResult) {
    self.load = load
  }

  func callAsFunction(
    userID: UserID,
    requestID: UUID
  ) -> @Sendable () async -> (any Event<ProfileEvent>)? {
    { [load] in
      guard !Task.isCancelled else { return nil }

      switch await load(userID) {
      case .success(let profile):
        guard !Task.isCancelled else { return nil }
        return ProfileLoadingDidSucceed(requestID: requestID, profile: profile)
      case .failure(let failure):
        guard !Task.isCancelled else { return nil }
        return ProfileLoadingDidFail(requestID: requestID, failure: failure)
      case .cancelled:
        return nil
      }
    }
  }
}

public struct ProfileOutputs: Sendable {
  let loadProfile: LoadProfileOutput

  public init(loadProfile: LoadProfileOutput) {
    self.loadProfile = loadProfile
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
