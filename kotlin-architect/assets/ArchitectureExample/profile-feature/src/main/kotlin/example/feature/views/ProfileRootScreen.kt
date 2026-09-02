package example.feature.views

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.lifecycle.viewmodel.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import example.domain.ProfileLoadFailure
import example.feature.ProfileInput
import example.feature.ProfileUiState
import example.feature.R

@Composable
fun ProfileRoute(
    input: ProfileInput,
    modifier: Modifier = Modifier,
) {
    val viewModel = hiltViewModel<ProfileViewModel, ProfileViewModelAssistedFactory>(
        key = "ProfileViewModel/${input.profileId.value}",
    ) { factory -> factory.create(input) }
    val state by viewModel.uiState.collectAsStateWithLifecycle()

    ProfileScreen(
        state = state,
        onLoad = { viewModel.load() },
        onRetry = { viewModel.retry() },
        modifier = modifier,
    )
}

@Composable
fun ProfileScreen(
    state: ProfileUiState,
    onLoad: () -> Unit,
    onRetry: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Column(
        modifier = modifier
            .fillMaxSize()
            .padding(24.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(16.dp, Alignment.CenterVertically),
    ) {
        when (state) {
            ProfileUiState.AwaitingInput -> Text(stringResource(R.string.profile_preparing))
            is ProfileUiState.Idle -> {
                Text(stringResource(R.string.profile_prompt))
                Button(onClick = onLoad) {
                    Text(stringResource(R.string.profile_load))
                }
            }
            is ProfileUiState.Loading -> {
                CircularProgressIndicator()
                Text(stringResource(R.string.profile_loading))
            }
            is ProfileUiState.Ready -> {
                Text(state.profile.displayName)
                Button(onClick = onLoad) {
                    Text(stringResource(R.string.profile_reload))
                }
            }
            is ProfileUiState.Failed -> {
                Text(stringResource(state.reason.messageResource()))
                Button(onClick = onRetry) {
                    Text(stringResource(R.string.profile_retry))
                }
            }
        }
    }
}

private fun ProfileLoadFailure.messageResource(): Int =
    when (this) {
        ProfileLoadFailure.NOT_FOUND -> R.string.profile_error_not_found
        ProfileLoadFailure.IDENTITY_MISMATCH -> R.string.profile_error_identity
        ProfileLoadFailure.MALFORMED_RESPONSE -> R.string.profile_error_malformed
        ProfileLoadFailure.UNAVAILABLE -> R.string.profile_error_unavailable
    }
