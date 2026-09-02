import Foundation
import Testing

@testable import DomainModel

@Test
func profilePreservesItsIdentity() {
  let id = UserID(rawValue: UUID())
  let profile = Profile(id: id, displayName: "Taylor")

  #expect(profile.id == id)
}
