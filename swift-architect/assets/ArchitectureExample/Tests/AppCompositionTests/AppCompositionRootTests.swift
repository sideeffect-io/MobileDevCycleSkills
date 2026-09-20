import DomainModel
import Foundation
import HTTPFramework
import StateMachineCore
import Testing

@testable import AppComposition
@testable import ProfileFeature

@Test
func compositionFactoryBuildsIndependentMachinesWithoutStartingFeatureWork() async {
  let requests = RequestRecorder()
  let httpClient = HTTPDataClient { request in
    await requests.record(request)
    return Data()
  }
  let compositionRoot = AppCompositionRoot(
    httpClient: httpClient,
    profileBaseURL: URL(string: "https://example.invalid")!
  )
  let first = await UIStateMachine(
    asyncStateMachineFactory: compositionRoot.profileStateMachineFactory
  )
  let second = await UIStateMachine(
    asyncStateMachineFactory: compositionRoot.profileStateMachineFactory
  )

  #expect(first !== second)
  #expect(await requests.count == 0)
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
    profileBaseURL: URL(string: "https://example.invalid")!
  )
  let machine = await UIStateMachine(
    asyncStateMachineFactory: compositionRoot.profileStateMachineFactory
  )

  await machine.sendAndWait(ProfileInputWasReceived(input: .user(id: userID)))
  await machine.sendAndWait(ProfileLoadingWasRequested(requestID: UUID()))
  let requestCount = await requests.count

  #expect(requestCount == 1)
}

private actor RequestRecorder {
  private(set) var count = 0

  func record(_: URLRequest) {
    count += 1
  }
}
