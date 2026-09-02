package example.profile

import io.sideeffect.kotlinstatemachine.StateMachineFlow
import io.sideeffect.kotlinstatemachine.dsl.Cancel
import io.sideeffect.kotlinstatemachine.dsl.State
import java.util.UUID
import kotlinx.coroutines.CoroutineScope

internal sealed class ProfileState : State<ProfileUiState>

internal data object ProfileAwaitingInput : ProfileState() {
    override val superState = ProfileUiState.AwaitingInput
}

internal data class ProfileIdle(val input: ProfileInput) : ProfileState() {
    override val superState = ProfileUiState.Idle(input)
}

internal data class ProfileLoading(
    val input: ProfileInput,
    val requestId: UUID,
) : ProfileState() {
    override val superState = ProfileUiState.Loading(input)
}

internal data class ProfileReady(
    val input: ProfileInput,
    val profile: Profile,
) : ProfileState() {
    override val superState = ProfileUiState.Ready(input, profile)
}

internal data class ProfileFailed(
    val input: ProfileInput,
    val reason: ProfileLoadFailure,
) : ProfileState() {
    override val superState = ProfileUiState.Failed(input, reason)
}

internal sealed interface ProfileEvent

internal data class ProfileInputReceived(val input: ProfileInput) : ProfileEvent

internal data object ProfileLoadRequested : ProfileEvent

internal data object ProfileRetryRequested : ProfileEvent

internal data class ProfileLoadSucceeded(
    val requestId: UUID,
    val profile: Profile,
) : ProfileEvent

internal data class ProfileLoadFailed(
    val requestId: UUID,
    val reason: ProfileLoadFailure,
) : ProfileEvent

internal fun makeProfileMachine(
    scope: CoroutineScope,
    loadProfile: LoadProfile,
    generateRequestId: () -> UUID,
): StateMachineFlow<ProfileState, ProfileEvent> =
    StateMachineFlow(initial = ProfileAwaitingInput, scope = scope) {
        When(state = ProfileAwaitingInput::class) {
            On(event = ProfileInputReceived::class) { _, event ->
                Transition(ProfileIdle(event.input))
            }
        }

        When(
            states = {
                +ProfileIdle::class
                +ProfileLoading::class
                +ProfileReady::class
                +ProfileFailed::class
            },
        ) {
            On(
                event = ProfileInputReceived::class,
                guard = { state, event -> state.boundInput != event.input },
            ) { _, event ->
                Transition(ProfileIdle(event.input))
            }
        }

        When(state = ProfileIdle::class) {
            On(event = ProfileLoadRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
        }

        When(state = ProfileLoading::class) {
            On(event = ProfileLoadRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
            On(
                event = ProfileLoadSucceeded::class,
                guard = { state, event -> state.requestId == event.requestId },
            ) { state, event ->
                Transition(ProfileReady(state.input, event.profile))
            }
            On(
                event = ProfileLoadFailed::class,
                guard = { state, event -> state.requestId == event.requestId },
            ) { state, event ->
                Transition(ProfileFailed(state.input, event.reason))
            }
        }

        When(state = ProfileReady::class) {
            On(event = ProfileLoadRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
        }

        When(state = ProfileFailed::class) {
            On(event = ProfileRetryRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
        }
    }

private val replaceableLoad = Cancel<ProfileState, ProfileEvent> { _, event, newState ->
    (event is ProfileInputReceived && newState is ProfileIdle) ||
        (event is ProfileLoadRequested && newState is ProfileLoading)
}

private val ProfileState.boundInput: ProfileInput?
    get() = when (this) {
        ProfileAwaitingInput -> null
        is ProfileIdle -> input
        is ProfileLoading -> input
        is ProfileReady -> input
        is ProfileFailed -> input
    }

private suspend fun loadEvent(
    loadProfile: LoadProfile,
    input: ProfileInput,
    requestId: UUID,
): ProfileEvent =
    when (val result = loadProfile(input.profileId)) {
        is ProfileLoadResult.Success -> ProfileLoadSucceeded(requestId, result.profile)
        is ProfileLoadResult.Failure -> ProfileLoadFailed(requestId, result.reason)
    }
