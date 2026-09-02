// swift-tools-version: 6.0

import Foundation
import PackageDescription

let swiftStateMachine: Package.Dependency
if let localPath = ProcessInfo.processInfo.environment["SWIFT_STATE_MACHINE_PATH"],
  !localPath.isEmpty
{
  swiftStateMachine = .package(name: "SwiftStateMachine", path: localPath)
} else {
  swiftStateMachine = .package(
    url: "https://github.com/sideeffect-io/SwiftStateMachine",
    revision: "c358b986a0d0d783ddc6f7b9f42ebecfec4a9a88"
  )
}

let package = Package(
  name: "ArchitectureExample",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(name: "DomainModel", targets: ["DomainModel"]),
    .library(name: "HTTPFramework", targets: ["HTTPFramework"]),
    .library(name: "ProfileDataSource", targets: ["ProfileDataSource"]),
    .library(name: "ProfileFeature", targets: ["ProfileFeature"]),
    .library(name: "ProfileNavigation", targets: ["ProfileNavigation"]),
    .library(name: "AppComposition", targets: ["AppComposition"]),
  ],
  dependencies: [swiftStateMachine],
  targets: [
    .target(name: "DomainModel"),
    .testTarget(name: "DomainModelTests", dependencies: ["DomainModel"]),
    .target(name: "HTTPFramework"),
    .testTarget(name: "HTTPFrameworkTests", dependencies: ["HTTPFramework"]),
    .target(
      name: "ProfileDataSource",
      dependencies: ["DomainModel", "HTTPFramework"]
    ),
    .testTarget(
      name: "ProfileDataSourceTests",
      dependencies: ["DomainModel", "HTTPFramework", "ProfileDataSource"]
    ),
    .target(
      name: "ProfileFeature",
      dependencies: [
        "DomainModel",
        .product(name: "StateMachineCore", package: "SwiftStateMachine"),
      ],
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "ProfileFeatureTests",
      dependencies: [
        "DomainModel",
        "ProfileFeature",
        .product(name: "StateMachineTest", package: "SwiftStateMachine"),
      ]
    ),
    .target(
      name: "ProfileNavigation",
      dependencies: ["DomainModel", "ProfileFeature"]
    ),
    .testTarget(
      name: "ProfileNavigationTests",
      dependencies: ["DomainModel", "ProfileNavigation"]
    ),
    .target(
      name: "AppComposition",
      dependencies: [
        "DomainModel",
        "HTTPFramework",
        "ProfileDataSource",
        "ProfileFeature",
        "ProfileNavigation",
        .product(name: "StateMachineCore", package: "SwiftStateMachine"),
      ]
    ),
    .testTarget(
      name: "AppCompositionTests",
      dependencies: [
        "AppComposition",
        "DomainModel",
        "HTTPFramework",
        "ProfileFeature",
        .product(name: "StateMachineCore", package: "SwiftStateMachine"),
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
