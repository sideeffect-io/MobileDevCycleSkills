package example.profile

import java.util.UUID
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class ProfileRepositoryTest {
    private val profileId = ProfileId(UUID.fromString("13e87821-0d06-44a2-b15c-64a37f61f5fd"))
    private val profile = Profile(profileId, "Ada Lovelace")

    @Test
    fun returnsOwnedDomainValue() = runTest {
        val repository = InMemoryProfileRepository(listOf(profile))

        assertEquals(ProfileLoadResult.Success(profile), repository.load(profileId))
    }

    @Test
    fun representsMissingProfileAsFiniteFailure() = runTest {
        val repository = InMemoryProfileRepository(emptyList())

        assertEquals(
            ProfileLoadResult.Failure(ProfileLoadFailure.NOT_FOUND),
            repository.load(profileId),
        )
    }
}
