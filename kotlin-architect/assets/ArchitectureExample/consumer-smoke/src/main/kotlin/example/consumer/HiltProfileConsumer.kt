package example.consumer

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import example.domain.ProfileId
import example.navigation.ProfileDestination
import example.navigation.ProfileFlow
import java.util.UUID

@Composable
internal fun ConsumerProfile(
    rawProfileId: UUID,
    modifier: Modifier = Modifier,
) {
    ProfileFlow(
        destination = ProfileDestination(ProfileId(rawProfileId)),
        modifier = modifier,
    )
}
