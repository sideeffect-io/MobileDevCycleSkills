package example.app

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import example.data.ProfileRepository
import example.feature.LoadProfile
import example.http.HttpDataClient
import example.http.HttpResult
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object ProfileIntegrationBindings {
    @Provides
    @Singleton
    fun provideHttpDataClient(): HttpDataClient =
        HttpDataClient { HttpResult.NotFound }

    @Provides
    fun provideLoadProfile(repository: ProfileRepository): LoadProfile =
        LoadProfile(repository::load)
}
