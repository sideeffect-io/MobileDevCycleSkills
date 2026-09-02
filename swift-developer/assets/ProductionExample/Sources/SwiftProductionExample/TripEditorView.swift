import Foundation
import SwiftUI

public struct TripEditorView: View {
  private let state: TripEditorViewState
  private let distanceChanged: @MainActor @Sendable (String) -> Void
  private let noteChanged: @MainActor @Sendable (String) -> Void
  private let saveRequested: @MainActor @Sendable () -> Void

  public init(
    state: TripEditorViewState,
    distanceChanged: @MainActor @Sendable @escaping (String) -> Void,
    noteChanged: @MainActor @Sendable @escaping (String) -> Void,
    saveRequested: @MainActor @Sendable @escaping () -> Void
  ) {
    self.state = state
    self.distanceChanged = distanceChanged
    self.noteChanged = noteChanged
    self.saveRequested = saveRequested
  }

  public var body: some View {
    Form {
      TextField(
        TripEditorCopy.distance,
        text: Binding(get: { state.distanceText }, set: { distanceChanged($0) })
      )
      .accessibilityIdentifier("trip.distance")

      TextField(
        TripEditorCopy.note,
        text: Binding(get: { state.note }, set: { noteChanged($0) }),
        axis: .vertical
      )

      if let failure = state.failure {
        Text(TripEditorCopy.message(for: failure))
          .foregroundStyle(.secondary)
          .accessibilityIdentifier("trip.validation")
      }

      Button(TripEditorCopy.save, action: saveRequested)
        .disabled(!state.canSave)
    }
  }
}

private enum TripEditorCopy {
  static let distance = String(localized: "trip.distance", bundle: .module)
  static let note = String(localized: "trip.note", bundle: .module)
  static let save = String(localized: "trip.save", bundle: .module)

  static func message(for failure: TripValidationFailure) -> String {
    switch failure {
    case .distanceIsMissing:
      String(localized: "trip.error.missing", bundle: .module)
    case .distanceIsInvalid:
      String(localized: "trip.error.invalid", bundle: .module)
    case .distanceMustBePositive:
      String(localized: "trip.error.positive", bundle: .module)
    }
  }
}
