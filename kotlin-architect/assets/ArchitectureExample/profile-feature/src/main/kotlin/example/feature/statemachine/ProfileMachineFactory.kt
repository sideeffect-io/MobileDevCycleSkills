package example.feature.statemachine

import example.feature.LoadProfile
import example.feature.ProfileInput
import java.util.UUID
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope

class ProfileRequestIds @Inject constructor() {
    fun next(): UUID = UUID.randomUUID()
}

class ProfileMachineFactory @Inject constructor(
    private val loadProfile: LoadProfile,
    private val requestIds: ProfileRequestIds,
) {
    internal fun create(
        scope: CoroutineScope,
        input: ProfileInput,
    ) = makeProfileMachine(scope, loadProfile, requestIds::next).also { machine ->
        check(machine.send(ProfileInputWasReceived(input)))
    }
}
