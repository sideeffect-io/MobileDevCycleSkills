import Foundation

public struct UserID: Hashable, Sendable {
  public let rawValue: UUID

  public init(rawValue: UUID) {
    self.rawValue = rawValue
  }
}

public struct Profile: Equatable, Sendable {
  public let id: UserID
  public let displayName: String

  public init(id: UserID, displayName: String) {
    self.id = id
    self.displayName = displayName
  }
}

public enum ProfileLoadFailure: Equatable, Sendable {
  case identityMismatch
  case malformedPayload
  case unavailable
}

public enum ProfileLoadResult: Equatable, Sendable {
  case success(Profile)
  case failure(ProfileLoadFailure)
  case cancelled
}
