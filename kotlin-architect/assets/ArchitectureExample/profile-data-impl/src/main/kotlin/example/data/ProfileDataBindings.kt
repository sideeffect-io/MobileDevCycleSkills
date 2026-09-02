package example.data

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent

@Module
@InstallIn(SingletonComponent::class)
abstract class ProfileDataBindings {
    @Binds
    abstract fun bindProfileRepository(
        repository: RemoteProfileRepository,
    ): ProfileRepository
}
