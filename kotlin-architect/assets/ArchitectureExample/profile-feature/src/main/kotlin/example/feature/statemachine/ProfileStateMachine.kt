package example.feature.statemachine

import example.feature.LoadProfile
import io.sideeffect.kotlinstatemachine.StateMachineFlow
import java.util.UUID
import kotlinx.coroutines.CoroutineScope

internal fun makeProfileMachine(
    scope: CoroutineScope,
    loadProfile: LoadProfile,
    generateRequestId: () -> UUID,
): StateMachineFlow<ProfileState, ProfileEvent> =
    StateMachineFlow(initial = ProfileIsAwaitingInput, scope = scope) {
        When(state = ProfileIsAwaitingInput::class) {
            On(event = ProfileInputWasReceived::class) { _, event ->
                Transition(ProfileIsIdle(event.input))
            }
        }

        When(state = ProfileIsIdle::class) {
            On(
                event = ProfileInputWasReceived::class,
                guard = ProfileGuards::idleInputChanged,
            ) { _, event ->
                Transition(ProfileIsIdle(event.input))
            }
            On(event = ProfileLoadWasRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileIsLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
        }

        When(state = ProfileIsLoading::class) {
            On(
                event = ProfileInputWasReceived::class,
                guard = ProfileGuards::loadingInputChanged,
            ) { _, event ->
                Transition(ProfileIsIdle(event.input))
            }
            On(event = ProfileLoadWasRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileIsLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
            On(
                event = ProfileLoadDidSucceed::class,
                guard = ProfileGuards::successfulRequestMatches,
            ) { state, event ->
                Transition(ProfileIsReady(state.input, event.profile))
            }
            On(
                event = ProfileLoadDidFail::class,
                guard = ProfileGuards::failedRequestMatches,
            ) { state, event ->
                Transition(ProfileIsFailed(state.input, event.reason))
            }
        }

        When(state = ProfileIsReady::class) {
            On(
                event = ProfileInputWasReceived::class,
                guard = ProfileGuards::readyInputChanged,
            ) { _, event ->
                Transition(ProfileIsIdle(event.input))
            }
            On(event = ProfileLoadWasRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileIsLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
        }

        When(state = ProfileIsFailed::class) {
            On(
                event = ProfileInputWasReceived::class,
                guard = ProfileGuards::failedInputChanged,
            ) { _, event ->
                Transition(ProfileIsIdle(event.input))
            }
            On(event = ProfileRetryWasRequested::class) { state, _ ->
                val requestId = generateRequestId()
                Transition(ProfileIsLoading(state.input, requestId))
                Output(
                    sideEffect = { loadEvent(loadProfile, state.input, requestId) },
                    lifecycle = replaceableLoad,
                )
            }
        }
    }

private object ProfileGuards {
    fun idleInputChanged(state: ProfileIsIdle, event: ProfileInputWasReceived): Boolean =
        state.input != event.input

    fun loadingInputChanged(state: ProfileIsLoading, event: ProfileInputWasReceived): Boolean =
        state.input != event.input

    fun readyInputChanged(state: ProfileIsReady, event: ProfileInputWasReceived): Boolean =
        state.input != event.input

    fun failedInputChanged(state: ProfileIsFailed, event: ProfileInputWasReceived): Boolean =
        state.input != event.input

    fun successfulRequestMatches(
        state: ProfileIsLoading,
        event: ProfileLoadDidSucceed,
    ): Boolean = state.requestId == event.requestId

    fun failedRequestMatches(
        state: ProfileIsLoading,
        event: ProfileLoadDidFail,
    ): Boolean = state.requestId == event.requestId
}
