import Foundation
import Testing

@testable import HTTPFramework

@Test
func clientDelegatesToTheInjectedTransport() async throws {
  let url = URL(string: "https://example.invalid/profile")!
  let expectedData = Data("profile".utf8)
  let client = HTTPDataClient { request in
    #expect(request.url == url)
    return expectedData
  }

  let data = try await client.data(for: URLRequest(url: url))

  #expect(data == expectedData)
}
