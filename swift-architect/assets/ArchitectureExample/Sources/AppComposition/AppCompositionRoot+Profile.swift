import Foundation
import HTTPFramework
import ProfileDataSource
import ProfileFeature
import StateMachineCore

extension AppCompositionRoot {
  static func makeProfileFactory(
    httpClient: HTTPDataClient,
    baseURL: URL
  ) -> ProfileStateMachineFactory {
    ProfileStateMachineFactory(lifecycle: .instance) {
      let profileDataSource = ProfileRemoteDataSource(
        httpClient: httpClient,
        baseURL: baseURL
      )
      let outputs = ProfileOutputs(
        loadProfile: LoadProfileOutput { userID in
          await profileDataSource.load(userID: userID)
        }
      )
      return makeProfileStateMachine(outputs: outputs).disableLog()
    }
  }
}
