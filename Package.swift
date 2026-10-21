// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClaudeKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ClaudeKit",
            targets: ["ClaudeKit"]
        ),
        .executable(
            name: "ClaudeCLI",
            targets: ["ClaudeCLI"]
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(name: "ClaudeCLI"),
        .target(
            name: "ClaudeKit"
        ),
        .target(
            name: "ClaudeCore"
        ),
        .testTarget(
            name: "ClaudeKitTests",
            dependencies: ["ClaudeKit"]
        ),
        .testTarget(
            name: "ClaudeCoreTests",
            dependencies: ["ClaudeCore"]
        ),
    ]
)

for target in package.targets {
    var settings = target.swiftSettings ?? []
    settings.append(contentsOf: [
        .defaultIsolation(MainActor.self),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ])
    target.swiftSettings = settings
}
