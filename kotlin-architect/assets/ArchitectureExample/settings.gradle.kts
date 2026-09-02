pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "KotlinArchitectureExample"

include(
    ":app-composition",
    ":consumer-smoke",
    ":domain-model",
    ":http-framework",
    ":profile-data-api",
    ":profile-data-impl",
    ":profile-feature",
    ":profile-navigation",
)

val stateMachineCheckout = providers.gradleProperty("kotlinStateMachineCheckout").get()
includeBuild(stateMachineCheckout) {
    dependencySubstitution {
        substitute(module("io.sideeffect.kotlinstatemachine:statemachine")).using(project(":"))
    }
}
