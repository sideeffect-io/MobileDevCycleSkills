package example.data

import example.domain.Profile
import example.domain.ProfileId
import example.domain.ProfileLoadFailure
import example.domain.ProfileLoadResult
import example.http.HttpDataClient
import example.http.HttpResult
import java.util.UUID
import javax.inject.Inject

class RemoteProfileRepository @Inject constructor(
    httpClient: HttpDataClient,
) : ProfileRepository {
    private val remoteSource = ProfileRemoteSource(httpClient)

    override suspend fun load(profileId: ProfileId): ProfileLoadResult =
        when (val result = remoteSource.load(profileId)) {
            RemoteProfileResult.NotFound ->
                ProfileLoadResult.Failure(ProfileLoadFailure.NOT_FOUND)
            RemoteProfileResult.Malformed ->
                ProfileLoadResult.Failure(ProfileLoadFailure.MALFORMED_RESPONSE)
            RemoteProfileResult.Unavailable ->
                ProfileLoadResult.Failure(ProfileLoadFailure.UNAVAILABLE)
            is RemoteProfileResult.Found -> map(result.payload, profileId)
        }

    private fun map(payload: RemoteProfile, requestedId: ProfileId): ProfileLoadResult {
        val remoteId = payload.id.toUuidOrNull()
            ?: return ProfileLoadResult.Failure(ProfileLoadFailure.MALFORMED_RESPONSE)
        return when {
            remoteId != requestedId.value ->
                ProfileLoadResult.Failure(ProfileLoadFailure.IDENTITY_MISMATCH)
            payload.displayName.isBlank() ->
                ProfileLoadResult.Failure(ProfileLoadFailure.MALFORMED_RESPONSE)
            else ->
                ProfileLoadResult.Success(
                    Profile(id = requestedId, displayName = payload.displayName),
                )
        }
    }
}

private class ProfileRemoteSource(
    private val httpClient: HttpDataClient,
) {
    suspend fun load(profileId: ProfileId): RemoteProfileResult =
        when (val response = httpClient.get("/profiles/${profileId.value}")) {
            HttpResult.NotFound -> RemoteProfileResult.NotFound
            HttpResult.Unavailable -> RemoteProfileResult.Unavailable
            is HttpResult.Success -> response.body.toRemoteProfile()
        }
}

private sealed interface RemoteProfileResult {
    data class Found(val payload: RemoteProfile) : RemoteProfileResult

    data object NotFound : RemoteProfileResult

    data object Malformed : RemoteProfileResult

    data object Unavailable : RemoteProfileResult
}

private data class RemoteProfile(
    val id: String,
    val displayName: String,
)

private fun String.toRemoteProfile(): RemoteProfileResult {
    val fields = split('|', limit = 2)
    return if (fields.size == 2) {
        RemoteProfileResult.Found(RemoteProfile(id = fields[0], displayName = fields[1]))
    } else {
        RemoteProfileResult.Malformed
    }
}

private fun String.toUuidOrNull(): UUID? =
    try {
        UUID.fromString(this)
    } catch (_: IllegalArgumentException) {
        null
    }
