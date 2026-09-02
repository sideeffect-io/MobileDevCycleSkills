import Foundation
import Testing

@testable import SwiftProductionExample

@Test
func saveCapabilityUsesTheActorOwnedStore() async throws {
  let expectedID = TripID(rawValue: UUID())
  let store = InMemoryTripStore(generateID: { expectedID })
  let saveTrip = await store.makeSaveTrip()
  let trip = try TripDraftValidator.validate(
    TripDraft(distanceText: "8", note: "Town"),
    locale: Locale(identifier: "en_US_POSIX")
  ).get()

  let result = await saveTrip(trip)
  let count = await store.count()

  #expect(result == .success(expectedID))
  #expect(count == 1)
}

@Test
func saveCapabilityPreservesCancellationBeforeMutation() async throws {
  let store = InMemoryTripStore(
    generateID: { TripID(rawValue: UUID()) }
  )
  let saveTrip = await store.makeSaveTrip()
  let trip = try TripDraftValidator.validate(
    TripDraft(distanceText: "8", note: "Town"),
    locale: Locale(identifier: "en_US_POSIX")
  ).get()

  let result = await Task {
    withUnsafeCurrentTask { task in task?.cancel() }
    return await saveTrip(trip)
  }.value
  let count = await store.count()

  #expect(result == .cancelled)
  #expect(count == 0)
}
