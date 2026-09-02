plugins {
    id("com.android.library") version "9.3.0" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.4.10" apply false
}

allprojects {
    providers.gradleProperty("exampleBuildDir").orNull?.let { externalRoot ->
        layout.buildDirectory.set(file("$externalRoot/${project.name}"))
    }
}
