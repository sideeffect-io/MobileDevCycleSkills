package example.feature.statemachine

import example.domain.ProfileLoadResult
import example.feature.LoadProfile
import example.feature.ProfileInput
import io.sideeffect.kotlinstatemachine.dsl.Cancel
import java.util.UUID

private object ProfilePolicies {
    fun shouldReplaceLoad(
        currentState: ProfileState,
        event: ProfileEvent,
        newState: ProfileState?,
    ): Boolean =
        (event is ProfileInputWasReceived && newState is ProfileIsIdle) ||
            (event is ProfileLoadWasRequested && newState is ProfileIsLoading)
}

internal val replaceableLoad = Cancel<ProfileState, ProfileEvent>(
    predicate = ProfilePolicies::shouldReplaceLoad,
)

internal suspend fun loadEvent(
    loadProfile: LoadProfile,
    input: ProfileInput,
    requestId: UUID,
): ProfileEvent =
    when (val result = loadProfile(input.profileId)) {
        is ProfileLoadResult.Success -> ProfileLoadDidSucceed(requestId, result.profile)
        is ProfileLoadResult.Failure -> ProfileLoadDidFail(requestId, result.reason)
    }
