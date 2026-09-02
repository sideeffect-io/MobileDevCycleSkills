package example.feature.views

import androidx.compose.material3.MaterialTheme
import androidx.compose.ui.semantics.ProgressBarRangeInfo
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assertHasClickAction
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.v2.createComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import example.domain.Profile
import example.domain.ProfileId
import example.domain.ProfileLoadFailure
import example.feature.ProfileInput
import example.feature.ProfileUiState
import example.feature.R
import java.util.UUID
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class ProfileRootScreenTest {
    @get:Rule
    val composeRule = createComposeRule()

    private val profileId = ProfileId(
        UUID.fromString("13e87821-0d06-44a2-b15c-64a37f61f5fd"),
    )
    private val input = ProfileInput(profileId)

    @Test
    fun idleRendersLocalizedLoadActionAndEmitsIntent() {
        var loadCount = 0
        composeRule.setContent {
            MaterialTheme {
                ProfileScreen(
                    state = ProfileUiState.Idle(input),
                    onLoad = { loadCount += 1 },
                    onRetry = {},
                )
            }
        }

        composeRule.onNodeWithText(resource(R.string.profile_prompt)).assertIsDisplayed()
        composeRule.onNodeWithText(resource(R.string.profile_load))
            .assertIsDisplayed()
            .assertHasClickAction()
            .performClick()
        composeRule.runOnIdle { assertEquals(1, loadCount) }
    }

    @Test
    fun failureRendersLocalizedRetryActionAndEmitsIntent() {
        var retryCount = 0
        composeRule.setContent {
            MaterialTheme {
                ProfileScreen(
                    state = ProfileUiState.Failed(input, ProfileLoadFailure.UNAVAILABLE),
                    onLoad = {},
                    onRetry = { retryCount += 1 },
                )
            }
        }

        composeRule.onNodeWithText(resource(R.string.profile_error_unavailable)).assertIsDisplayed()
        composeRule.onNodeWithText(resource(R.string.profile_retry))
            .assertIsDisplayed()
            .assertHasClickAction()
            .performClick()
        composeRule.runOnIdle { assertEquals(1, retryCount) }
    }

    @Test
    fun loadingExposesProgressSemantics() {
        composeRule.setContent {
            MaterialTheme {
                ProfileScreen(
                    state = ProfileUiState.Loading(input),
                    onLoad = {},
                    onRetry = {},
                )
            }
        }

        composeRule.onNodeWithText(resource(R.string.profile_loading)).assertIsDisplayed()
        composeRule.onNode(
            SemanticsMatcher.expectValue(
                SemanticsProperties.ProgressBarRangeInfo,
                ProgressBarRangeInfo.Indeterminate,
            ),
        ).assertExists()
    }

    @Test
    fun readyRendersProfileAndReloadAction() {
        val profile = Profile(profileId, "Ada Lovelace")
        var reloadCount = 0
        composeRule.setContent {
            MaterialTheme {
                ProfileScreen(
                    state = ProfileUiState.Ready(input, profile),
                    onLoad = { reloadCount += 1 },
                    onRetry = {},
                )
            }
        }

        composeRule.onNodeWithText(profile.displayName).assertIsDisplayed()
        composeRule.onNodeWithText(resource(R.string.profile_reload))
            .assertIsDisplayed()
            .assertHasClickAction()
            .performClick()
        composeRule.runOnIdle { assertEquals(1, reloadCount) }
    }

    private fun resource(id: Int): String =
        InstrumentationRegistry.getInstrumentation().targetContext.getString(id)
}
