# Android Platform Validation

<!-- kotlin-suite:KOTLIN-ANDROID-PLATFORM-VALIDATION -->

## Route by owning surface

Identify the changed product and execution owner: pure JVM module, Android library, Compose feature,
Activity/navigation graph, service/receiver/provider, worker, widget/tile, database/migration,
dynamic feature, native/JNI boundary, or app composition. A `.kt` file can require an Android SDK,
manifest merge, resource processing, emulator/device, permission, or Play configuration even when
its local unit tests pass.

Use repository tasks and discover variants rather than guessing. Record Gradle task, module,
variant, JDK/AGP/Kotlin/SDK profile, device/API/ABI, exit status, and artifact/result path.

## Risk matrix

| Surface | Minimum executable evidence | Additional proof when behavior is at risk |
| --- | --- | --- |
| pure model/domain | module compile and deterministic local tests | minimum/current JDK/Kotlin lanes |
| Android library | variant compile, lint, owner tests | resource/manifest consumer fixture |
| Compose feature | owner tests plus Android variant compile | emulator interaction, semantics, locales, adaptive sizes |
| navigation/deep link | route/ViewModel/composition tests | cold/warm/deferred link flow and repeated/stale delivery |
| repository/persistence | mapping/source-of-truth/migration tests | old-data upgrade, interruption, offline/retry, process recreation |
| service/worker/receiver/widget | component and app assembly | OS invocation, permission/background limits, reboot/update behavior |
| release/dependency change | release compile/lint/tests | R8 mapping, startup, bundle/APK, dependency verification |
| performance/memory | defined baseline flow | comparable device trace, benchmark, heap, battery or size evidence |

Compilation verifies type/resource/manifest processing for that variant. It does not prove
permissions, callbacks, navigation, process restoration, background limits, migrations,
accessibility, rendering, battery, R8 reflection, or device-only behavior.

## Localization, accessibility, and adaptive behavior

Inventory supported locales and resource owners. Check key/plural parity, formatting, RTL, resource
qualifiers, accessibility semantics/actions/state, font scaling, focus, keyboard/D-pad, touch target,
contrast, reduced motion, TalkBack/Switch Access, and window-size/foldable behavior as applicable.
Include notifications, widgets, shortcuts, tiles, services, and metadata—not only the main Screen.

Use resource/static validation and live locale/device configurations as separate evidence. Record
explicit locales, font scale, layout direction, window size, and device/API.

## Lifecycle, recovery, and security/privacy

Trace configuration change, background/foreground, destination removal, process kill/recreation,
reboot/update, duplicate intent, cancellation, and restoration for the affected owner. For data,
test fresh and existing stores, partial failure, retry/idempotency, transactions, conflicts, and
cleanup.

Make `security-privacy` applicable for authentication/authorization, network trust, deep links or
untrusted intents, exported components, WebView, files/content providers, credentials, personal
data, logs/analytics, permissions, backups, encryption/Keystore, sharing, or supply-chain changes.
Inspect manifest and network/security configuration; never place secrets or personal data in
commands, logs, screenshots, or artifacts.

## Evidence handoff

Record the exact task or flow, working directory, variant, toolchain, device/API, result, and
inspected evidence path in the current report or lifecycle handoff. Missing SDK, device, account,
or permission state is blocked or not run, not non-applicable. The reviewer independently replays
the narrowest high-risk proof.
