plugins {
    id("com.android.library")
    id("org.jetbrains.kotlin.plugin.compose")
}

android {
    namespace = "example.profile"
    compileSdk = 37

    defaultConfig {
        minSdk = 24
        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildFeatures { compose = true }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    lint {
        warningsAsErrors = true
        disable += "AndroidGradlePluginVersion"
    }
}

dependencies {
    implementation("io.sideeffect.kotlinstatemachine:statemachine:0.1.0-SNAPSHOT") {
        version { strictly("0.1.0-SNAPSHOT") }
    }
    api(platform("androidx.compose:compose-bom:2026.08.00"))
    api("androidx.compose.ui:ui")
    api("androidx.lifecycle:lifecycle-viewmodel:2.11.0")
    api("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.11.0")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.11.0")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:2.11.0")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:1.11.0")
    androidTestImplementation(platform("androidx.compose:compose-bom:2026.08.00"))
    androidTestImplementation("androidx.compose.ui:ui-test-junit4")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.7.0")
    androidTestImplementation("androidx.test.ext:junit:1.3.0")
    androidTestImplementation("androidx.test:runner:1.7.0")
    debugImplementation("androidx.compose.ui:ui-test-manifest")
}

tasks.withType<Test>().configureEach { useJUnit() }
