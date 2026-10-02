// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "SyncNexus",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "SyncCore", targets: ["SyncCore"]),
        .executable(name: "syncnexus", targets: ["syncnexus"]),
    ],
    targets: [
        .target(name: "SyncCore"),
        .executableTarget(name: "syncnexus", dependencies: ["SyncCore"]),
        .executableTarget(name: "SyncNexusApp", dependencies: ["SyncCore"]),
        .testTarget(name: "SyncCoreTests", dependencies: ["SyncCore"]),
    ]
)
