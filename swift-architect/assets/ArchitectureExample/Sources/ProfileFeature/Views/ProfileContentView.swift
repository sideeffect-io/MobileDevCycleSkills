import Foundation
import SwiftUI

struct ProfileContentView: View {
  let state: ProfileViewState
  let load: () -> Void
  let retry: () -> Void

  var body: some View {
    VStack(spacing: 16) {
      if state.isLoading {
        ProgressView(ProfileCopy.loading)
      } else if let profile = state.profile {
        Text(profile.displayName).font(.headline)
      } else if state.failure != nil {
        ContentUnavailableView {
          Label(ProfileCopy.failure, systemImage: "person.crop.circle.badge.exclamationmark")
        } actions: {
          Button(ProfileCopy.retry, action: retry)
        }
      } else if !state.isAwaitingInput {
        Button(ProfileCopy.load, action: load)
      }
    }
    .padding()
  }
}

private enum ProfileCopy {
  static let failure = String(localized: "profile.failure", bundle: .module)
  static let load = String(localized: "profile.load", bundle: .module)
  static let loading = String(localized: "profile.loading", bundle: .module)
  static let retry = String(localized: "profile.retry", bundle: .module)
}
