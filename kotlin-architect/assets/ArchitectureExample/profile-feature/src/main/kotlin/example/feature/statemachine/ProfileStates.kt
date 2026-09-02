package example.feature.statemachine

import example.domain.Profile
import example.domain.ProfileLoadFailure
import example.feature.ProfileInput
import example.feature.ProfileUiState
import io.sideeffect.kotlinstatemachine.dsl.State
import java.util.UUID

internal sealed class ProfileState : State<ProfileUiState>

internal data object ProfileIsAwaitingInput : ProfileState() {
    override val superState = ProfileUiState.AwaitingInput
}

internal data class ProfileIsIdle(val input: ProfileInput) : ProfileState() {
    override val superState = ProfileUiState.Idle(input)
}

internal data class ProfileIsLoading(
    val input: ProfileInput,
    val requestId: UUID,
) : ProfileState() {
    override val superState = ProfileUiState.Loading(input)
}

internal data class ProfileIsReady(
    val input: ProfileInput,
    val profile: Profile,
) : ProfileState() {
    override val superState = ProfileUiState.Ready(input, profile)
}

internal data class ProfileIsFailed(
    val input: ProfileInput,
    val reason: ProfileLoadFailure,
) : ProfileState() {
    override val superState = ProfileUiState.Failed(input, reason)
}
