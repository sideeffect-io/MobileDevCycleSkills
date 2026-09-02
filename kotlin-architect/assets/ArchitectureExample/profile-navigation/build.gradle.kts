plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "example.navigation"
    compileSdk = 37

    defaultConfig { minSdk = 24 }

    buildFeatures { compose = true }

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
    api(project(":domain-model"))
    implementation(project(":profile-feature"))
    api(platform("androidx.compose:compose-bom:2026.08.00"))
    api("androidx.compose.ui:ui")
}
