import DomainModel
import Foundation
import Testing

@testable import ProfileNavigation

@Test
func profileRouteCarriesOnlyTheDomainIdentifier() {
  let id = UserID(rawValue: UUID())

  #expect(ProfileRoute.profile(userID: id) == .profile(userID: id))
}
