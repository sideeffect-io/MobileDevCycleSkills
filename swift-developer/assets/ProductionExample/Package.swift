// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ProductionExample",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(name: "SwiftProductionExample", targets: ["SwiftProductionExample"])
  ],
  targets: [
    .target(
      name: "SwiftProductionExample",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "SwiftProductionExampleTests",
      dependencies: ["SwiftProductionExample"]
    ),
  ],
  swiftLanguageModes: [.v6]
)
