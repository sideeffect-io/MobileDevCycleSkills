# Swift Toolchain Currency

<!-- swift-suite:SWIFT-TOOLCHAIN-CURRENCY -->

## Build a five-part profile

Do not use “Swift 6” as a complete environment description. Record these independently:

1. **Compiler/toolchain** from `xcrun swift --version` or the repository-selected Swift toolchain.
2. **Language mode** from `swiftLanguageModes`, `SWIFT_VERSION`, and strict-concurrency settings.
3. **Swift tools version** from the first line of each `Package.swift`; this controls manifest API,
   not the language mode of every target.
4. **Xcode and SDKs** from `xcodebuild -version`, `xcodebuild -showsdks`, and target build settings.
5. **Deployment targets** and supported destinations from manifests, project settings, and CI.

Also record repository mode: pinned Xcode/Swift version, minimum supported toolchain, current CI
toolchain, and whether a beta or custom Swift.org toolchain is explicitly allowed.

Swift.org releases and Apple's shipping Xcode toolchain can be on different minor versions. For
example, Swift.org announced Swift 6.3 after Apple documented Swift 6.2 in Xcode 26. Never infer
Xcode/API availability from the upstream version or vice versa. Recheck the official
[Swift releases](https://www.swift.org/blog/),
[Swift 6.2 release](https://www.swift.org/blog/swift-6.2-released/),
[Swift 6.3 release](https://www.swift.org/blog/swift-6.3-released/), and
[Xcode release notes](https://developer.apple.com/documentation/xcode-release-notes) when currency
matters.

## Adopt features deliberately

Before using a post-6.0 feature, answer:

| Question | Evidence |
| --- | --- |
| Does the selected compiler parse it? | exact compiler version and a focused compile |
| Is it active in this target? | language mode, upcoming/experimental flags, build settings |
| Does it change isolation or behavior? | migration diagnostics plus behavior/concurrency tests |
| Does it require a newer SDK or OS? | SDK declaration, availability guard, deployment matrix |
| Does every supported CI/release environment have it? | minimum and current toolchain jobs |

Swift 6.2's approachable-concurrency options include default actor isolation, caller-isolated
nonisolated async behavior, and explicit `@concurrent`; strict memory safety is opt-in. These can
change semantics and diagnostics, so adopt them per target with migration evidence rather than as
decorative settings. Low-level types such as `Span`/`InlineArray`, new Swift Testing capabilities,
and Swift 6.3 additions should be used only when the product and selected toolchains benefit.

Do not upgrade a manifest, language mode, package pin, SDK, or deployment target merely to make a
fixture look current. State the compatibility reason, migrate one target class at a time, and keep
minimum-toolchain evidence separate from current-toolchain evidence.

## Discovery commands

Use repository wrappers when present. Otherwise start with:

```bash
xcrun swift --version
xcodebuild -version
xcodebuild -showsdks
swift package dump-package
xcodebuild -list -json
```

For Xcode-owned targets, inspect the exact scheme/configuration with `xcodebuild
-showBuildSettings`. Discover generated package schemes; do not guess their names. Record the
selected destination and `DEVELOPER_DIR`/toolchain override when non-default.

When the repository supports a separate minimum-toolchain lane, run it with the documented
`DEVELOPER_DIR` or toolchain selection. Do not point minimum and current lanes at the same Xcode and
describe them as independent.

## Compatibility result

Report one of:

- **current and minimum verified**: both required toolchain lanes passed;
- **current verified, minimum blocked**: name the unavailable toolchain/runner;
- **source compatible only**: no executable compatibility evidence;
- **migration required**: identify the first incompatible setting/API and its owning target.

A current-toolchain build is not proof of the declared minimum, and a host `swift test` is not proof
that an iOS-only package compiles or runs with its Apple SDK resources.
