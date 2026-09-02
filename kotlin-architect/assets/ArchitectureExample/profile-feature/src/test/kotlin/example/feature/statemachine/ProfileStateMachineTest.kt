package example.feature.statemachine

import example.domain.Profile
import example.domain.ProfileId
import example.domain.ProfileLoadFailure
import example.domain.ProfileLoadResult
import example.feature.LoadProfile
import example.feature.ProfileInput
import java.util.UUID
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class ProfileStateMachineTest {
    private val profileId = ProfileId(UUID.fromString("13e87821-0d06-44a2-b15c-64a37f61f5fd"))
    private val input = ProfileInput(profileId)
    private val profile = Profile(profileId, "Ada Lovelace")

    @Test
    fun loadIntentRunsCapabilityAndPublishesReadyState() = runTest {
        val requestId = UUID.fromString("f66cba8f-4f29-43f0-81a9-e65788688b49")
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile { ProfileLoadResult.Success(profile) },
            generateRequestId = { requestId },
        )

        machine.sendAndWait(ProfileInputWasReceived(input))
        machine.sendAndWait(ProfileLoadWasRequested)
        advanceUntilIdle()

        assertEquals(ProfileIsReady(input, profile), machine.lastKnownState)
        machine.finishAndWait()
    }

    @Test
    fun repeatedEquivalentInputEmitsNothingAndDoesNotRunCapability() = runTest {
        var capabilityInvocations = 0
        val observedStates = mutableListOf<ProfileState>()
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile {
                capabilityInvocations += 1
                ProfileLoadResult.Success(profile)
            },
            generateRequestId = UUID::randomUUID,
        )
        val collection = backgroundScope.launch {
            machine.collect { observedStates += it }
        }
        runCurrent()

        machine.sendAndWait(ProfileInputWasReceived(input))
        machine.sendAndWait(ProfileLoadWasRequested)
        advanceUntilIdle()
        runCurrent()
        val emissionCountBeforeRejectedInput = observedStates.size
        val capabilityInvocationsBeforeRejectedInput = capabilityInvocations

        machine.sendAndWait(ProfileInputWasReceived(input))
        runCurrent()

        assertEquals(ProfileIsReady(input, profile), machine.lastKnownState)
        assertEquals(emissionCountBeforeRejectedInput, observedStates.size)
        assertEquals(capabilityInvocationsBeforeRejectedInput, capabilityInvocations)
        collection.cancel()
        machine.finishAndWait()
    }

    @Test
    fun retryMapsFailureBackThroughTheCapability() = runTest {
        var invocation = 0
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile {
                invocation += 1
                if (invocation == 1) {
                    ProfileLoadResult.Failure(ProfileLoadFailure.UNAVAILABLE)
                } else {
                    ProfileLoadResult.Success(profile)
                }
            },
            generateRequestId = UUID::randomUUID,
        )

        machine.sendAndWait(ProfileInputWasReceived(input))
        machine.sendAndWait(ProfileLoadWasRequested)
        advanceUntilIdle()
        assertEquals(ProfileIsFailed(input, ProfileLoadFailure.UNAVAILABLE), machine.lastKnownState)

        machine.sendAndWait(ProfileRetryWasRequested)
        advanceUntilIdle()
        assertEquals(ProfileIsReady(input, profile), machine.lastKnownState)
        machine.finishAndWait()
    }

    @Test
    fun staleCompletionEmitsNothingAndDoesNotRunCapabilityAgain() = runTest {
        val result = CompletableDeferred<ProfileLoadResult>()
        val activeRequestId = UUID.fromString("f66cba8f-4f29-43f0-81a9-e65788688b49")
        val staleRequestId = UUID.fromString("4b1e574d-e9d8-4a66-8af8-1ff16728379e")
        var capabilityInvocations = 0
        val observedStates = mutableListOf<ProfileState>()
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile {
                capabilityInvocations += 1
                result.await()
            },
            generateRequestId = { activeRequestId },
        )
        val collection = backgroundScope.launch {
            machine.collect { observedStates += it }
        }
        runCurrent()

        machine.sendAndWait(ProfileInputWasReceived(input))
        machine.sendSuspending(ProfileLoadWasRequested)
        runCurrent()
        val emissionCountBeforeStaleResult = observedStates.size
        val capabilityInvocationsBeforeStaleResult = capabilityInvocations
        machine.sendAndWait(ProfileLoadDidSucceed(staleRequestId, profile))
        runCurrent()

        assertEquals(ProfileIsLoading(input, activeRequestId), machine.lastKnownState)
        assertEquals(emissionCountBeforeStaleResult, observedStates.size)
        assertEquals(capabilityInvocationsBeforeStaleResult, capabilityInvocations)

        collection.cancel()
        machine.finishAndWait()
    }

    @Test
    fun newerLoadCancelsAndReplacesOlderOutput() = runTest {
        val firstStarted = CompletableDeferred<Unit>()
        val firstCancelled = CompletableDeferred<Unit>()
        var invocation = 0
        val requestIds = ArrayDeque(
            listOf(
                UUID.fromString("f66cba8f-4f29-43f0-81a9-e65788688b49"),
                UUID.fromString("4b1e574d-e9d8-4a66-8af8-1ff16728379e"),
            ),
        )
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile {
                invocation += 1
                if (invocation == 1) {
                    try {
                        firstStarted.complete(Unit)
                        awaitCancellation()
                    } finally {
                        firstCancelled.complete(Unit)
                    }
                } else {
                    ProfileLoadResult.Success(profile)
                }
            },
            generateRequestId = requestIds::removeFirst,
        )

        machine.sendAndWait(ProfileInputWasReceived(input))
        machine.sendSuspending(ProfileLoadWasRequested)
        runCurrent()
        assertTrue(firstStarted.isCompleted)

        machine.sendAndWait(ProfileLoadWasRequested)
        advanceUntilIdle()

        assertTrue(firstCancelled.isCompleted)
        assertEquals(ProfileIsReady(input, profile), machine.lastKnownState)
        machine.finishAndWait()
    }
}
