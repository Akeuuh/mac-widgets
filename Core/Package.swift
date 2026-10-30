// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "PRCore", targets: ["PRCore"]),
        .library(name: "GitHubClient", targets: ["GitHubClient"]),
    ],
    targets: [
        .target(name: "PRCore"),
        .target(name: "GitHubClient", dependencies: ["PRCore"]),
        .testTarget(name: "PRCoreTests", dependencies: ["PRCore"], resources: [.copy("Fixtures")]),
    ]
)
