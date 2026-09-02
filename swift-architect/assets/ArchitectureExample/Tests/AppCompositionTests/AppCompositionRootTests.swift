import DomainModel
import Foundation
import HTTPFramework
import StateMachineCore
import Testing

@testable import AppComposition
@testable import ProfileFeature

@Test
func compositionBuildsTheFeatureFactoryFromFrameworksAndDatasources() {
  let httpClient = HTTPDataClient { _ in Data() }
  let compositionRoot = AppCompositionRoot(
    httpClient: httpClient,
    profileBaseURL: URL(string: "https://example.invalid")!,
    generateID: UUID.init
  )

  _ = compositionRoot.profileStateMachineFactory
}

@Test
func compositionWiresTheTransportIntoTheFeatureOutput() async {
  let userID = UserID(rawValue: UUID())
  let payload = Data(
    #"{"id":"\#(userID.rawValue.uuidString)","displayName":"Taylor"}"#.utf8
  )
  let requests = RequestRecorder()
  let httpClient = HTTPDataClient { request in
    await requests.record(request)
    return payload
  }
  let compositionRoot = AppCompositionRoot(
    httpClient: httpClient,
    profileBaseURL: URL(string: "https://example.invalid")!,
    generateID: UUID.init
  )
  let machine = await UIStateMachine(
    asyncStateMachineFactory: compositionRoot.profileStateMachineFactory
  )

  await machine.sendAndWait(ProfileInputWasReceived(input: .user(id: userID)))
  await machine.sendAndWait(ProfileLoadingWasRequested())
  let requestCount = await requests.count

  #expect(requestCount == 1)
}

private actor RequestRecorder {
  private(set) var count = 0

  func record(_: URLRequest) {
    count += 1
  }
}
