import Foundation
import Testing

@testable import SwiftProductionExample

struct ValidationCase: Sendable {
  let distanceText: String
  let expected: Result<ValidatedTrip, TripValidationFailure>
}

struct LocalizedDistanceCase: Sendable {
  let localeIdentifier: String
  let distanceText: String
  let expectedDistance: Decimal
}

struct WrongSeparatorCase: Sendable {
  let localeIdentifier: String
  let distanceText: String
}

@Test(
  arguments: [
    ValidationCase(distanceText: "", expected: .failure(.distanceIsMissing)),
    ValidationCase(distanceText: "abc", expected: .failure(.distanceIsInvalid)),
    ValidationCase(distanceText: "0", expected: .failure(.distanceMustBePositive)),
    ValidationCase(
      distanceText: "12.5",
      expected: .success(ValidatedTrip(distanceKilometers: 12.5, note: "practice"))
    ),
  ]
)
func validatesTripDistance(testCase: ValidationCase) {
  let result = TripDraftValidator.validate(
    TripDraft(distanceText: testCase.distanceText, note: " practice "),
    locale: Locale(identifier: "en_US_POSIX")
  )

  #expect(result == testCase.expected)
}

@Test
func projectionKeepsValidationHiddenUntilRequested() {
  let state = TripEditorProjection.project(
    draft: TripDraft(distanceText: "", note: ""),
    locale: Locale(identifier: "en_US_POSIX"),
    validationVisibility: .hidden
  )

  #expect(!state.canSave)
  #expect(state.failure == nil)
}

@Test
func projectionPresentsValidationWhenRequested() {
  let state = TripEditorProjection.project(
    draft: TripDraft(distanceText: "", note: ""),
    locale: Locale(identifier: "en_US_POSIX"),
    validationVisibility: .visible
  )

  #expect(!state.canSave)
  #expect(state.failure == .distanceIsMissing)
}

@Test(
  arguments: [
    LocalizedDistanceCase(
      localeIdentifier: "en_US_POSIX",
      distanceText: "12.5",
      expectedDistance: 12.5
    ),
    LocalizedDistanceCase(
      localeIdentifier: "fr_FR",
      distanceText: "12,5",
      expectedDistance: 12.5
    ),
    LocalizedDistanceCase(
      localeIdentifier: "de_DE",
      distanceText: "12,5",
      expectedDistance: 12.5
    ),
    LocalizedDistanceCase(
      localeIdentifier: "es_ES",
      distanceText: "12,5",
      expectedDistance: 12.5
    ),
  ]
)
func parsesTheCompleteLocalizedDistance(testCase: LocalizedDistanceCase) {
  let result = TripDraftValidator.validate(
    TripDraft(distanceText: testCase.distanceText, note: "practice"),
    locale: Locale(identifier: testCase.localeIdentifier)
  )

  #expect(
    result
      == .success(
        ValidatedTrip(distanceKilometers: testCase.expectedDistance, note: "practice")
      )
  )
}

@Test(
  arguments: ["en_US_POSIX", "fr_FR", "de_DE", "es_ES"],
  ["12abc", "12.5abc", "12,5abc"]
)
func rejectsLocalizedDistanceWithATrailingSuffix(
  localeIdentifier: String,
  distanceText: String
) {
  let result = TripDraftValidator.validate(
    TripDraft(distanceText: distanceText, note: "practice"),
    locale: Locale(identifier: localeIdentifier)
  )

  #expect(result == .failure(.distanceIsInvalid))
}

@Test(
  arguments: [
    WrongSeparatorCase(localeIdentifier: "en_US_POSIX", distanceText: "12,5"),
    WrongSeparatorCase(localeIdentifier: "fr_FR", distanceText: "12.5"),
    WrongSeparatorCase(localeIdentifier: "de_DE", distanceText: "12.5"),
    WrongSeparatorCase(localeIdentifier: "es_ES", distanceText: "12.5"),
  ]
)
func rejectsTheWrongLocalizedDecimalSeparator(testCase: WrongSeparatorCase) {
  let result = TripDraftValidator.validate(
    TripDraft(distanceText: testCase.distanceText, note: "practice"),
    locale: Locale(identifier: testCase.localeIdentifier)
  )

  #expect(result == .failure(.distanceIsInvalid))
}
