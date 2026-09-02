plugins {
    id("com.android.library")
    id("com.google.dagger.hilt.android")
    id("com.google.devtools.ksp")
}

android {
    namespace = "example.app"
    compileSdk = 37

    defaultConfig { minSdk = 24 }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    lint {
        warningsAsErrors = true
        disable += "AndroidGradlePluginVersion"
    }
}

dependencies {
    implementation(project(":http-framework"))
    implementation(project(":profile-feature"))
    api(project(":profile-navigation"))
    implementation(project(":profile-data-api"))
    implementation(project(":profile-data-impl"))
    implementation("com.google.dagger:hilt-android:2.60.1")
    ksp("com.google.dagger:hilt-compiler:2.60.1")
}
