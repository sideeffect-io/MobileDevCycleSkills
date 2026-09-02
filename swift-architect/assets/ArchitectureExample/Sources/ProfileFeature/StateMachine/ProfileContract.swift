import DomainModel

public enum ProfileInput: Equatable, Sendable {
  case user(id: UserID)

  var userID: UserID {
    switch self {
    case .user(let id): id
    }
  }
}

public enum ProfileOutcome: Equatable, Sendable {
  case profileDidLoad(id: UserID)
}
