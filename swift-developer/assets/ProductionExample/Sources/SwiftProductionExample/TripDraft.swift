import Foundation

public struct TripDraft: Equatable, Sendable {
  public let distanceText: String
  public let note: String

  public init(distanceText: String, note: String) {
    self.distanceText = distanceText
    self.note = note
  }
}

public struct ValidatedTrip: Equatable, Sendable {
  public let distanceKilometers: Decimal
  public let note: String
}

public enum TripValidationFailure: Error, Equatable, Sendable {
  case distanceIsMissing
  case distanceIsInvalid
  case distanceMustBePositive
}

public enum TripDraftValidator {
  public static func validate(
    _ draft: TripDraft,
    locale: Locale
  ) -> Result<ValidatedTrip, TripValidationFailure> {
    let distanceText = draft.distanceText.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !distanceText.isEmpty else { return .failure(.distanceIsMissing) }
    guard let distance = parseDistance(distanceText, locale: locale) else {
      return .failure(.distanceIsInvalid)
    }
    guard distance > .zero else { return .failure(.distanceMustBePositive) }

    return .success(
      ValidatedTrip(
        distanceKilometers: distance,
        note: draft.note.trimmingCharacters(in: .whitespacesAndNewlines)
      )
    )
  }

  private static func parseDistance(_ text: String, locale: Locale) -> Decimal? {
    let formatter = NumberFormatter()
    formatter.locale = locale
    formatter.numberStyle = .decimal
    formatter.isLenient = false
    formatter.generatesDecimalNumbers = true
    return formatter.number(from: text)?.decimalValue
  }
}
