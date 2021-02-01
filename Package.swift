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
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.41.2"),
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
