package example.data

import example.domain.ProfileId
import example.domain.ProfileLoadResult

interface ProfileRepository {
    suspend fun load(profileId: ProfileId): ProfileLoadResult
}
