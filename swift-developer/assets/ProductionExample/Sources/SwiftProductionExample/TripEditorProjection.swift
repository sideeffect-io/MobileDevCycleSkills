import Foundation

public struct TripEditorViewState: Equatable, Sendable {
  public let distanceText: String
  public let note: String
  public let failure: TripValidationFailure?
  public let canSave: Bool

  public init(
    distanceText: String,
    note: String,
    failure: TripValidationFailure?,
    canSave: Bool
  ) {
    self.distanceText = distanceText
    self.note = note
    self.failure = failure
    self.canSave = canSave
  }
}

public enum TripValidationVisibility: Equatable, Sendable {
  case hidden
  case visible
}

public enum TripEditorProjection {
  public static func project(
    draft: TripDraft,
    locale: Locale,
    validationVisibility: TripValidationVisibility
  ) -> TripEditorViewState {
    switch TripDraftValidator.validate(draft, locale: locale) {
    case .success:
      return TripEditorViewState(
        distanceText: draft.distanceText,
        note: draft.note,
        failure: nil,
        canSave: true
      )
    case .failure(let failure):
      return TripEditorViewState(
        distanceText: draft.distanceText,
        note: draft.note,
        failure: validationVisibility.presentedFailure(failure),
        canSave: false
      )
    }
  }
}

extension TripValidationVisibility {
  fileprivate func presentedFailure(_ failure: TripValidationFailure) -> TripValidationFailure? {
    switch self {
    case .hidden: nil
    case .visible: failure
    }
  }
}
