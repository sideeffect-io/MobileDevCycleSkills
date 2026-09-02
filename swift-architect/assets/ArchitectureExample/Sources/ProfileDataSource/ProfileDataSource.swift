import DomainModel
import Foundation
import HTTPFramework

public struct ProfileRemoteDataSource: Sendable {
  private let httpClient: HTTPDataClient
  private let baseURL: URL

  public init(httpClient: HTTPDataClient, baseURL: URL) {
    self.httpClient = httpClient
    self.baseURL = baseURL
  }

  public func load(userID: UserID) async -> ProfileLoadResult {
    let url =
      baseURL
      .appendingPathComponent("profiles")
      .appendingPathComponent(userID.rawValue.uuidString)
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    do {
      let data = try await httpClient.data(for: request)
      try Task.checkCancellation()
      let profileDTO = try JSONDecoder().decode(ProfileDTO.self, from: data)
      try Task.checkCancellation()
      guard profileDTO.id == userID.rawValue else {
        return .failure(.identityMismatch)
      }
      return .success(profileDTO.domainValue())
    } catch is CancellationError {
      return .cancelled
    } catch is DecodingError {
      return .failure(.malformedPayload)
    } catch {
      let foundationError = error as NSError
      if foundationError.domain == NSURLErrorDomain,
        foundationError.code == NSURLErrorCancelled
      {
        return .cancelled
      }
      guard !Task.isCancelled else { return .cancelled }
      return .failure(.unavailable)
    }
  }
}

private struct ProfileDTO: Decodable {
  let id: UUID
  let displayName: String

  func domainValue() -> Profile {
    Profile(id: UserID(rawValue: id), displayName: displayName)
  }
}
