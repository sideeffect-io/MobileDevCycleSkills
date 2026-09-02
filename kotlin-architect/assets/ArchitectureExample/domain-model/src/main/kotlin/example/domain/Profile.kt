package example.domain

import java.util.UUID

// kotlin-suite-example: profile-load/v1
@JvmInline
value class ProfileId(val value: UUID)

data class Profile(
    val id: ProfileId,
    val displayName: String,
)

enum class ProfileLoadFailure {
    NOT_FOUND,
    IDENTITY_MISMATCH,
    MALFORMED_RESPONSE,
    UNAVAILABLE,
}

sealed interface ProfileLoadResult {
    data class Success(val profile: Profile) : ProfileLoadResult

    data class Failure(val reason: ProfileLoadFailure) : ProfileLoadResult
}
