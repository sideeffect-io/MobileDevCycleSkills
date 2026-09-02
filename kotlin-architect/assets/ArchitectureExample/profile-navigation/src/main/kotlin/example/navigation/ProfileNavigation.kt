package example.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import example.domain.ProfileId
import example.feature.ProfileInput
import example.feature.views.ProfileRoute

data class ProfileDestination(val profileId: ProfileId)

@Composable
fun ProfileFlow(
    destination: ProfileDestination,
    modifier: Modifier = Modifier,
) {
    ProfileRoute(
        input = ProfileInput(destination.profileId),
        modifier = modifier,
    )
}
