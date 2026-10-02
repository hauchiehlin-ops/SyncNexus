// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SyncNexus",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SyncCore", targets: ["SyncCore"]),
        .executable(name: "syncnexus", targets: ["syncnexus"]),
    ],
    targets: [
        .target(
            name: "SyncCore",
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "syncnexus",
            dependencies: ["SyncCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .executableTarget(
            name: "SyncNexusApp",
            dependencies: ["SyncCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
        .testTarget(
            name: "SyncCoreTests",
            dependencies: ["SyncCore"],
            swiftSettings: [.swiftLanguageMode(.v5)]
        ),
    ]
)
