# Kotlin Android Toolchain Currency

<!-- kotlin-suite:KOTLIN-TOOLCHAIN-CURRENCY -->

## Build a complete profile

Do not use “latest Kotlin” or “modern Android” as an environment description. Record independently:

1. Kotlin compiler/language/API versions and compiler options.
2. Android Gradle Plugin and Gradle wrapper versions.
3. JDK toolchain plus Java/Kotlin JVM bytecode targets.
4. compile SDK, target SDK, min SDK, build tools/NDK when applicable.
5. Compose compiler/runtime/BOM and relevant AndroidX versions.
6. Build variants, convention plugins, KSP/KAPT/codegen versions, dependency repositories, locks,
   verification metadata, and minimum/current CI lanes.

Also record whether the module is Android, pure JVM, or KMP. A library's JVM bytecode target and
Kotlin metadata version are separate compatibility constraints.

## Resolve truth from the build

Inspect `settings.gradle(.kts)`, root/module build files, `gradle-wrapper.properties`, version
catalogs, convention plugins, dependency reports, locks, and CI setup. Use repository wrappers and
toolchain managers rather than the shell's incidental Java/Kotlin installation.

Useful commands (adapt module/variant names):

```shell
./gradlew --version
./gradlew projects
./gradlew buildEnvironment
./gradlew :app:dependencies
./gradlew :app:dependencyInsight --dependency <name> --configuration <configuration>
./gradlew :app:tasks
```

Record `java -version`, Android SDK path/API availability, connected devices, and Android Studio
version only when they influence the proof. Do not print secrets from environment or Gradle
properties.

## Adopt versions deliberately

Before using a newer language/library/API, prove the selected compiler parses it, the target enables
it, every supported CI/release lane has the toolchain, and Android API availability is guarded down
to min SDK. Align Java and Kotlin JVM targets; do not upgrade them merely to silence one fixture.

AGP 9 introduced built-in Kotlin enabled by default, replacing the `org.jetbrains.kotlin.android`
plugin for Android modules. Inspect the project's actual AGP and migration state before adding or
removing plugins; KMP modules use distinct plugins and constraints. Recheck the official
[built-in Kotlin migration guide](https://developer.android.com/build/migrate-to-built-in-kotlin)
when this boundary matters.

KSP, Compose compiler, Hilt, serialization, Room, and other code generators have compatibility
matrices. Resolve their selected versions and generated source tasks instead of guessing. Do not use
`-Xskip-metadata-version-check` to hide a consumer/library mismatch.

## Compatibility result

Report one of:

- **current and minimum verified**: both required toolchain/API lanes passed;
- **current verified, minimum blocked**: name the missing JDK/SDK/runner/device;
- **source compatible only**: no executable compatibility proof;
- **migration required**: name the first incompatible setting/API and owner.

A debug assembly is not release/R8, unit-test, device, or minimum-SDK proof.
