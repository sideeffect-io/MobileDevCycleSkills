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
  ) async -> (any Event<ProfileEvent>)? {
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

public struct ProfileStateMachineDependencies: Sendable {
  let loadProfile: LoadProfileOutput
  let generateID: @Sendable () -> UUID

  public init(
    loadProfile: LoadProfileOutput,
    generateID: @escaping @Sendable () -> UUID
  ) {
    self.loadProfile = loadProfile
    self.generateID = generateID
  }
}
