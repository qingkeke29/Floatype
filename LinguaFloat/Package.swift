// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LinguaFloat",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "LinguaFloat", targets: ["LinguaFloat"]),
        .library(name: "LinguaFloatCore", targets: ["LinguaFloatCore"])
    ],
    targets: [
        .target(
            name: "LinguaFloatCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "LinguaFloat",
            dependencies: ["LinguaFloatCore"]
        ),
        .testTarget(
            name: "LinguaFloatTests",
            dependencies: ["LinguaFloatCore"]
        )
    ],
    swiftLanguageModes: [.v5]
)
