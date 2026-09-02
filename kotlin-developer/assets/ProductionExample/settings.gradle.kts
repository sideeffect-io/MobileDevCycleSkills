pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "KotlinProductionExample"
include(":profile-feature")
project(":profile-feature").projectDir = file("profile")

val stateMachineCheckout = providers.gradleProperty("kotlinStateMachineCheckout").get()
includeBuild(stateMachineCheckout) {
    dependencySubstitution {
        substitute(module("io.sideeffect.kotlinstatemachine:statemachine")).using(project(":"))
    }
}
