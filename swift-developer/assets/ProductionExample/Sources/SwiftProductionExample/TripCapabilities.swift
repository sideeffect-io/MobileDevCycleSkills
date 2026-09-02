import Foundation

public struct TripID: Hashable, Sendable {
  public let rawValue: UUID

  public init(rawValue: UUID) {
    self.rawValue = rawValue
  }
}

public enum SaveTripResult: Equatable, Sendable {
  case success(TripID)
  case unavailable
  case cancelled
}

public struct SaveTrip: Sendable {
  private let save: @Sendable (ValidatedTrip) async -> SaveTripResult

  public init(save: @escaping @Sendable (ValidatedTrip) async -> SaveTripResult) {
    self.save = save
  }

  public func callAsFunction(_ trip: ValidatedTrip) async -> SaveTripResult {
    guard !Task.isCancelled else { return .cancelled }
    return await save(trip)
  }
}

public actor InMemoryTripStore {
  private let generateID: @Sendable () -> TripID
  private var trips: [TripID: ValidatedTrip] = [:]

  public init(generateID: @escaping @Sendable () -> TripID) {
    self.generateID = generateID
  }

  public func makeSaveTrip() -> SaveTrip {
    SaveTrip { trip in
      await self.save(trip)
    }
  }

  public func count() -> Int {
    trips.count
  }

  private func save(_ trip: ValidatedTrip) -> SaveTripResult {
    guard !Task.isCancelled else { return .cancelled }
    let id = generateID()
    trips[id] = trip
    return .success(id)
  }
}
