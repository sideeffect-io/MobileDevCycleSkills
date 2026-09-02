package example.profile

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import io.sideeffect.kotlinstatemachine.SendCompletion
import java.util.UUID
import kotlinx.coroutines.launch
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn

class ProfileViewModel private constructor(
    loadProfile: LoadProfile,
    generateRequestId: () -> UUID,
) : ViewModel() {
    private val machine = makeProfileMachine(viewModelScope, loadProfile, generateRequestId)

    val uiState: StateFlow<ProfileUiState> = machine
        .map { it.superState }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.Eagerly,
            initialValue = machine.initial.superState,
        )

    suspend fun submitInput(input: ProfileInput) {
        machine.sendAndWait(
            event = ProfileInputReceived(input),
            until = SendCompletion.TRANSITION_COMMITTED,
        )
    }

    fun load() = send(ProfileLoadRequested)

    fun retry() = send(ProfileRetryRequested)

    private fun send(event: ProfileEvent) {
        viewModelScope.launch {
            machine.sendSuspending(event)
        }
    }

    class Factory(
        private val loadProfile: LoadProfile,
        private val generateRequestId: () -> UUID = UUID::randomUUID,
    ) : ViewModelProvider.Factory {
        override fun <T : ViewModel> create(modelClass: Class<T>): T {
            require(modelClass.isAssignableFrom(ProfileViewModel::class.java))
            @Suppress("UNCHECKED_CAST")
            return ProfileViewModel(loadProfile, generateRequestId) as T
        }
    }
}
