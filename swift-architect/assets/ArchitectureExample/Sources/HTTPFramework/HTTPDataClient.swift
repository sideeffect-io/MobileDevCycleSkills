import Foundation

public enum HTTPDataClientFailure: Error, Equatable, Sendable {
  case invalidResponse(statusCode: Int?)
}

public struct HTTPDataClient: Sendable {
  private let fetchData: @Sendable (URLRequest) async throws -> Data

  public init(fetchData: @escaping @Sendable (URLRequest) async throws -> Data) {
    self.fetchData = fetchData
  }

  public func data(for request: URLRequest) async throws -> Data {
    try await fetchData(request)
  }

  public static func urlSession(_ session: URLSession = .shared) -> Self {
    Self { request in
      let (data, response) = try await session.data(for: request)
      guard
        let response = response as? HTTPURLResponse,
        (200..<300).contains(response.statusCode)
      else {
        throw HTTPDataClientFailure.invalidResponse(
          statusCode: (response as? HTTPURLResponse)?.statusCode
        )
      }
      return data
    }
  }
}
