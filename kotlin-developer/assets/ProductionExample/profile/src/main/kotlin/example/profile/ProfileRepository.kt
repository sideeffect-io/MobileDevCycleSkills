package example.profile

import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.ensureActive

interface ProfileRepository {
    suspend fun load(profileId: ProfileId): ProfileLoadResult
}

fun interface LoadProfile {
    suspend operator fun invoke(profileId: ProfileId): ProfileLoadResult
}

class LoadProfileFromRepository(
    private val repository: ProfileRepository,
) : LoadProfile {
    override suspend fun invoke(profileId: ProfileId): ProfileLoadResult = repository.load(profileId)
}

class InMemoryProfileRepository(
    profiles: Collection<Profile>,
) : ProfileRepository {
    private val profilesById = profiles.associateBy(Profile::id)

    override suspend fun load(profileId: ProfileId): ProfileLoadResult {
        currentCoroutineContext().ensureActive()
        return profilesById[profileId]
            ?.let(ProfileLoadResult::Success)
            ?: ProfileLoadResult.Failure(ProfileLoadFailure.NOT_FOUND)
    }
}
