package example.feature.views

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.assisted.Assisted
import dagger.assisted.AssistedFactory
import dagger.assisted.AssistedInject
import dagger.hilt.android.lifecycle.HiltViewModel
import example.feature.ProfileInput
import example.feature.ProfileUiState
import example.feature.statemachine.ProfileEvent
import example.feature.statemachine.ProfileLoadWasRequested
import example.feature.statemachine.ProfileMachineFactory
import example.feature.statemachine.ProfileRetryWasRequested
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

@HiltViewModel(assistedFactory = ProfileViewModelAssistedFactory::class)
class ProfileViewModel @AssistedInject constructor(
    @Assisted input: ProfileInput,
    machineFactory: ProfileMachineFactory,
) : ViewModel() {
    private val machine = machineFactory.create(viewModelScope, input)

    val uiState: StateFlow<ProfileUiState> = machine
        .map { it.superState }
        .stateIn(
            scope = viewModelScope,
            started = SharingStarted.Eagerly,
            initialValue = machine.initial.superState,
        )

    fun load() = send(ProfileLoadWasRequested)

    fun retry() = send(ProfileRetryWasRequested)

    private fun send(event: ProfileEvent) {
        viewModelScope.launch {
            machine.sendSuspending(event)
        }
    }

    override fun onCleared() {
        machine.finish()
    }
}

@AssistedFactory
interface ProfileViewModelAssistedFactory {
    fun create(input: ProfileInput): ProfileViewModel
}
