import DomainModel
import Foundation
import HTTPFramework
import Testing

@testable import ProfileDataSource

@Test
func dataSourceMapsTheFrameworkPayloadToADomainEntity() async {
  let userID = UserID(rawValue: UUID())
  let payload = Data(
    #"{"id":"\#(userID.rawValue.uuidString)","displayName":"Taylor"}"#.utf8
  )
  let client = HTTPDataClient { request in
    #expect(request.url?.path.hasSuffix(userID.rawValue.uuidString) == true)
    return payload
  }
  let dataSource = ProfileRemoteDataSource(
    httpClient: client,
    baseURL: URL(string: "https://example.invalid")!
  )

  let result = await dataSource.load(userID: userID)

  #expect(result == .success(Profile(id: userID, displayName: "Taylor")))
}

@Test
func dataSourceMapsMalformedPayloadToAFiniteFailure() async {
  let client = HTTPDataClient { _ in Data("not-json".utf8) }
  let dataSource = ProfileRemoteDataSource(
    httpClient: client,
    baseURL: URL(string: "https://example.invalid")!
  )

  let result = await dataSource.load(userID: UserID(rawValue: UUID()))

  #expect(result == .failure(.malformedPayload))
}

@Test
func dataSourceRejectsAProfileWithAnotherIdentity() async {
  let requestedUserID = UserID(rawValue: UUID())
  let returnedUserID = UserID(rawValue: UUID())
  let payload = Data(
    #"{"id":"\#(returnedUserID.rawValue.uuidString)","displayName":"Taylor"}"#.utf8
  )
  let client = HTTPDataClient { _ in payload }
  let dataSource = ProfileRemoteDataSource(
    httpClient: client,
    baseURL: URL(string: "https://example.invalid")!
  )

  let result = await dataSource.load(userID: requestedUserID)

  #expect(result == .failure(.identityMismatch))
}

@Test
func dataSourcePreservesTransportCancellation() async {
  let client = HTTPDataClient { _ in throw URLError(.cancelled) }
  let dataSource = ProfileRemoteDataSource(
    httpClient: client,
    baseURL: URL(string: "https://example.invalid")!
  )

  let result = await dataSource.load(userID: UserID(rawValue: UUID()))

  #expect(result == .cancelled)
}

@Test
func dataSourcePreservesBridgedTransportCancellation() async {
  let client = HTTPDataClient { _ in
    throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled)
  }
  let dataSource = ProfileRemoteDataSource(
    httpClient: client,
    baseURL: URL(string: "https://example.invalid")!
  )

  let result = await dataSource.load(userID: UserID(rawValue: UUID()))

  #expect(result == .cancelled)
}
