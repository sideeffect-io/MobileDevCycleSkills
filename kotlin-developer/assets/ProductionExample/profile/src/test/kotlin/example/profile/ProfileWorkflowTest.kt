package example.profile

import java.util.UUID
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.awaitCancellation
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.runCurrent
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class ProfileWorkflowTest {
    private val profileId = ProfileId(UUID.fromString("13e87821-0d06-44a2-b15c-64a37f61f5fd"))
    private val input = ProfileInput(profileId)
    private val profile = Profile(profileId, "Ada Lovelace")

    @Test
    fun explicitLoadIntentRunsCapability() = runTest {
        val requestId = UUID.fromString("f66cba8f-4f29-43f0-81a9-e65788688b49")
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile { ProfileLoadResult.Success(profile) },
            generateRequestId = { requestId },
        )

        machine.sendAndWait(ProfileInputReceived(input))
        machine.sendAndWait(ProfileLoadRequested)
        advanceUntilIdle()

        assertEquals(ProfileReady(input, profile), machine.lastKnownState)
        machine.finishAndWait()
    }

    @Test
    fun repeatedEquivalentInputKeepsReadyState() = runTest {
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile { ProfileLoadResult.Success(profile) },
            generateRequestId = UUID::randomUUID,
        )

        machine.sendAndWait(ProfileInputReceived(input))
        machine.sendAndWait(ProfileLoadRequested)
        advanceUntilIdle()
        machine.sendAndWait(ProfileInputReceived(input))

        assertEquals(ProfileReady(input, profile), machine.lastKnownState)
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

        machine.sendAndWait(ProfileInputReceived(input))
        machine.sendAndWait(ProfileLoadRequested)
        advanceUntilIdle()
        assertEquals(ProfileFailed(input, ProfileLoadFailure.UNAVAILABLE), machine.lastKnownState)

        machine.sendAndWait(ProfileRetryRequested)
        advanceUntilIdle()
        assertEquals(ProfileReady(input, profile), machine.lastKnownState)
        machine.finishAndWait()
    }

    @Test
    fun staleCompletionCannotOverwriteActiveRequest() = runTest {
        val result = CompletableDeferred<ProfileLoadResult>()
        val activeRequestId = UUID.fromString("f66cba8f-4f29-43f0-81a9-e65788688b49")
        val staleRequestId = UUID.fromString("4b1e574d-e9d8-4a66-8af8-1ff16728379e")
        val machine = makeProfileMachine(
            scope = backgroundScope,
            loadProfile = LoadProfile { result.await() },
            generateRequestId = { activeRequestId },
        )

        machine.sendAndWait(ProfileInputReceived(input))
        machine.sendSuspending(ProfileLoadRequested)
        runCurrent()
        machine.sendAndWait(ProfileLoadSucceeded(staleRequestId, profile))

        assertEquals(ProfileLoading(input, activeRequestId), machine.lastKnownState)

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

        machine.sendAndWait(ProfileInputReceived(input))
        machine.sendSuspending(ProfileLoadRequested)
        runCurrent()
        assertTrue(firstStarted.isCompleted)

        machine.sendAndWait(ProfileLoadRequested)
        advanceUntilIdle()

        assertTrue(firstCancelled.isCompleted)
        assertEquals(ProfileReady(input, profile), machine.lastKnownState)
        machine.finishAndWait()
    }
}
