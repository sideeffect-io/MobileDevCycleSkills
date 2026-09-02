# Toolchain and Platform Verification

<!-- kotlin-suite:REVIEW-TOOLCHAIN-PLATFORM -->

Use this reference when a claim depends on Kotlin/AGP/Gradle/SDK currency, variant behavior,
component/process boundaries, permissions, background execution, migration, release shrinking, or a
device-only surface.

## Reconstruct the environment

Record Kotlin compiler/language/API settings, AGP and Gradle wrapper, JDK/JVM targets, metadata and
code-generator compatibility, compile/target/min SDK, Compose/AndroidX versions, variants,
repositories/locks, and minimum/current CI lanes. Useful discovery commands include `./gradlew
--version`, `projects`, `buildEnvironment`, module `dependencies`/`dependencyInsight`,
variant-specific task lists, `java -version`, and `adb devices -l`.

Do not infer Android API availability from “modern Kotlin,” assume plugin compatibility from AGP,
hide metadata mismatch with skip flags, or treat a current-toolchain pass as minimum-toolchain
evidence. Verify syntax, compiler options, generated sources, JVM targets, SDK guards, min-SDK
behavior, and supported CI lanes separately.

## Route proof by execution owner

| Surface | Minimum independent proof | Additional high-risk proof |
| --- | --- | --- |
| Pure JVM/domain library | owner tests and module build | minimum/current JDK/Kotlin lanes |
| Android/Compose feature | owner tests and variant compile | interaction, accessibility, locales |
| Navigation/deep link | route/composition tests | cold/warm intent, stale/repeated delivery |
| Repository/persistence/migration | integration/migration tests | old data, interruption, retry/recovery |
| Worker/service/receiver/widget | component and app build | OS invocation, constraints, process lifecycle |
| Permission/background/vendor surface | composition tests | permission/background/device flow |
| Performance/resources | defined baseline flow | comparable Macrobenchmark, Perfetto, heap, or metric |

Assembly proves compilation and packaging for one variant. It does not prove permission, callbacks,
process recreation, system invocation, background scheduling, migration, accessibility, battery,
release/R8 behavior, or device behavior.

Inventory affected locales, resource configurations, accessibility semantics, font scaling/focus,
adaptive layouts, exported components, workers/services/receivers, notifications, widgets, deep
links, and backups. Source/resource lint and live behavior are separate evidence.

Make `security-privacy` applicable for credentials, authentication/authorization, network trust,
untrusted intents/URLs/input, exported components, logs/analytics, user data, permissions, backups,
sharing, or vendor SDKs. Never put secrets or personal data in review evidence.

Record exact commands, working directories, JDK/SDK, variants, devices, results, and stable
artifacts. Unavailable devices, accounts, services, SDKs, permissions, or toolchains are blocked or
not run, never silently non-applicable.
