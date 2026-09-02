# Toolchain and Platform Planning

<!-- kotlin-suite:ARCH-TOOLCHAIN-PLATFORM -->

Use this reference when architecture depends on Kotlin/Gradle/SDK compatibility, build variants,
process or component boundaries, permissions, background execution, migration, or device behavior.

## Establish the environment

Record separately:

1. Kotlin compiler, language/API versions, and compiler options;
2. AGP and Gradle wrapper versions;
3. JDK toolchain, Java/Kotlin JVM targets, and Kotlin metadata compatibility;
4. compile/target/min SDK, build tools/NDK when applicable, and available SDKs;
5. Compose compiler/runtime/BOM, AndroidX, code generators, variants, and minimum/current CI lanes.

Do not infer Android API availability from a Kotlin release, infer target behavior from an AGP
version alone, or assume plugin compatibility. Before adopting a newer language, plugin, library,
or platform API, prove that the selected compiler parses it, the module enables it, code generation
and metadata are compatible, min-SDK behavior is guarded, and every required lane can ship it.

Useful discovery commands include `./gradlew --version`, `./gradlew projects`,
`./gradlew buildEnvironment`, module `dependencies`/`dependencyInsight`, variant-specific task
listing, `java -version`, and `adb devices -l`. Use repository wrappers and convention plugins as
truth. Never print secrets from Gradle properties or the environment.

## Route validation by execution owner

Identify the owner: pure JVM/domain library, Android library, Compose feature, navigation/deep link,
repository/persistence adapter, application, worker/service, notification/widget, dynamic feature,
or platform/vendor integration.

| Surface | Minimum planned evidence | Behavior-risk evidence |
| --- | --- | --- |
| Pure JVM/domain library | owner tests and module build | minimum/current JDK/Kotlin lanes |
| Android/Compose feature | owner tests and variant compile | emulator/device flow, accessibility, locales |
| Navigation/deep link | route/composition tests | cold/warm intent, stale/repeated delivery |
| Repository/persistence/migration | unit/integration/migration tests | old-data upgrade, interruption, recovery |
| Worker/service/receiver/widget | component and app build | OS invocation, constraints, process lifecycle |
| Permission/background/vendor surface | composition tests | permission/background/device lifecycle |
| Performance/resources | defined baseline flow | comparable Macrobenchmark, Perfetto, heap, or metric |

Assembly proves compilation and packaging for one variant. It does not prove permission, callbacks,
process recreation, background scheduling, migration, accessibility, battery, R8/release behavior,
or device-only behavior.

Plan localization, accessibility, and adaptive behavior across every affected resource owner and
component. Make security/privacy explicitly applicable for credentials, exported components,
authorization, untrusted intents/URLs/input, network trust, logs, user data, permissions, sharing,
or backups. Never put secrets or personal data in artifacts, commands, screenshots, logs, or
fixtures.

Classify unavailable devices, accounts, SDKs, permissions, services, or minimum toolchains as
blocked/not run—not non-applicable—and name the proof still required.
