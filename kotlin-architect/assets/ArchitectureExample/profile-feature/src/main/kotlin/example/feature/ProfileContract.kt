package example.feature

import example.domain.Profile
import example.domain.ProfileId
import example.domain.ProfileLoadFailure
import example.domain.ProfileLoadResult

data class ProfileInput(val profileId: ProfileId)

sealed interface ProfileUiState {
    data object AwaitingInput : ProfileUiState

    data class Idle(val input: ProfileInput) : ProfileUiState

    data class Loading(val input: ProfileInput) : ProfileUiState

    data class Ready(
        val input: ProfileInput,
        val profile: Profile,
    ) : ProfileUiState

    data class Failed(
        val input: ProfileInput,
        val reason: ProfileLoadFailure,
    ) : ProfileUiState
}

fun interface LoadProfile {
    suspend operator fun invoke(profileId: ProfileId): ProfileLoadResult
}
