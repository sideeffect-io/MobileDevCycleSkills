package example.feature.statemachine

import example.domain.Profile
import example.domain.ProfileLoadFailure
import example.feature.ProfileInput
import java.util.UUID

internal sealed interface ProfileEvent

internal data class ProfileInputWasReceived(val input: ProfileInput) : ProfileEvent

internal data object ProfileLoadWasRequested : ProfileEvent

internal data object ProfileRetryWasRequested : ProfileEvent

internal data class ProfileLoadDidSucceed(
    val requestId: UUID,
    val profile: Profile,
) : ProfileEvent

internal data class ProfileLoadDidFail(
    val requestId: UUID,
    val reason: ProfileLoadFailure,
) : ProfileEvent
