// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-graphql",
    products: [
        .library(
            name: "SwiftGraphQL",
            targets: ["SwiftGraphQL"]
        ),
        .library(
            name: "SwiftGraphQLCodegen",
            targets: ["SwiftGraphQLCodegen"]
        ),
        .executable(
            name: "SwiftGraphQLCLI",
            targets: ["SwiftGraphQLCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.41.2"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.3.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
    ],
    targets: [
        .target(
            name: "SwiftGraphQL",
            dependencies: [],
            path: "Sources/SwiftGraphQL"
        ),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: ["SwiftFormat"],
            path: "Sources/SwiftGraphQLCodegen"
        ),
        .target(
            name: "SwiftGraphQLCLI",
            dependencies: [
                "SwiftGraphQLCodegen",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Yams",
            ],
            path: "Sources/SwiftGraphQLCLI"
        ),
        /* Tests */
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: ["SwiftGraphQL"]
        ),
        .testTarget(
            name: "SwiftGraphQLCodegenTests",
            dependencies: ["Files", "SwiftGraphQLCodegen"]
        ),
    ]
)
