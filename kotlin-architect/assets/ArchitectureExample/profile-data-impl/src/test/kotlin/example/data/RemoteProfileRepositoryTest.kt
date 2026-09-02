package example.data

import example.domain.ProfileId
import example.domain.ProfileLoadFailure
import example.domain.ProfileLoadResult
import example.http.HttpDataClient
import example.http.HttpResult
import java.util.UUID
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Test

class RemoteProfileRepositoryTest {
    private val profileId = ProfileId(UUID.fromString("13e87821-0d06-44a2-b15c-64a37f61f5fd"))

    @Test
    fun mapsTransportPayloadIntoDomainModel() = runTest {
        val repository = RemoteProfileRepository(
            HttpDataClient { HttpResult.Success("${profileId.value}|Ada Lovelace") },
        )

        val result = repository.load(profileId)

        assertEquals(
            ProfileLoadResult.Success(
                example.domain.Profile(profileId, "Ada Lovelace"),
            ),
            result,
        )
    }

    @Test
    fun rejectsPayloadForAnotherIdentity() = runTest {
        val repository = RemoteProfileRepository(
            HttpDataClient {
                HttpResult.Success("00000000-0000-0000-0000-000000000000|Ada")
            },
        )

        assertEquals(
            ProfileLoadResult.Failure(ProfileLoadFailure.IDENTITY_MISMATCH),
            repository.load(profileId),
        )
    }

    @Test
    fun mapsFiniteTransportAndPayloadFailures() = runTest {
        assertEquals(
            ProfileLoadResult.Failure(ProfileLoadFailure.NOT_FOUND),
            RemoteProfileRepository(HttpDataClient { HttpResult.NotFound }).load(profileId),
        )
        assertEquals(
            ProfileLoadResult.Failure(ProfileLoadFailure.UNAVAILABLE),
            RemoteProfileRepository(HttpDataClient { HttpResult.Unavailable }).load(profileId),
        )
        assertEquals(
            ProfileLoadResult.Failure(ProfileLoadFailure.MALFORMED_RESPONSE),
            RemoteProfileRepository(HttpDataClient { HttpResult.Success("invalid") }).load(profileId),
        )
    }

    @Test
    fun rethrowsCancellation() {
        assertThrows(CancellationException::class.java) {
            runTest {
                RemoteProfileRepository(HttpDataClient { throw CancellationException() })
                    .load(profileId)
            }
        }
    }
}
