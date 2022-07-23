// swift-tools-version:5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-graphql",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // SwiftGraphQL
        .library(name: "SwiftGraphQL", targets: ["SwiftGraphQL"]),
        .library(name: "SwiftGraphQLClient", targets: ["SwiftGraphQLClient"]),
        .library(name: "SwiftGraphQLCodegen", targets: ["SwiftGraphQLCodegen"]),
        // CLI
        .executable( name: "swift-graphql", targets: ["SwiftGraphQLCLI"]),
        // Utilities
        .library(name: "GraphQL", targets: ["GraphQL"]),
        .library(name: "GraphQLAST", targets: ["GraphQLAST"]),
        .library(name: "GraphQLWebSocket", targets: ["GraphQLWebSocket"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-format", from: "0.50600.1"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.0"),
        .package(url: "https://github.com/dominicegginton/Spinner", from: "1.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
    ],
    targets: [
        // Utility Targets
        .target(name: "GraphQL", dependencies: [], path: "Sources/GraphQL"),
        .target(name: "GraphQLAST", dependencies: [], path: "Sources/GraphQLAST"),
        .target(
            name: "GraphQLWebSocket",
            dependencies: [
                "GraphQL",
                .product(name: "Logging", package: "swift-log"),
                "Starscream"
            ],
            path: "Sources/GraphQLWebSocket",
            exclude: [
                "README.md"
            ]
        ),
        // SwiftGraphQL
        .target(name: "SwiftGraphQL", dependencies: ["GraphQL"], path: "Sources/SwiftGraphQL"),
        .target(
            name: "SwiftGraphQLClient",
            dependencies: [
                "GraphQL",
                "GraphQLWebSocket",
                .product(name: "Logging", package: "swift-log"),
                "SwiftGraphQL",
            ],
            path: "Sources/SwiftGraphQLClient"
        ),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: [
                .product(name: "SwiftFormat", package: "swift-format"),
                .product(name: "SwiftFormatConfiguration", package: "swift-format"),
                .byName(name: "GraphQLAST"),
                .byName(name: "SwiftGraphQL"),
            ],
            path: "Sources/SwiftGraphQLCodegen"
        ),
        .executableTarget(
            name: "SwiftGraphQLCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SwiftGraphQLCodegen",
                "Yams",
                "Files",
                "Spinner"
            ],
            path: "Sources/SwiftGraphQLCLI"
        ),
        // Tests
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: [
                "Files",
                "GraphQL",
                "GraphQLAST",
                "SwiftGraphQLCodegen",
                "SwiftGraphQL",
                "SwiftGraphQLClient"
            ],
            path: "Tests",
            exclude: [
                "SwiftGraphQLCodegenTests/Integration/schema.json",
                "SwiftGraphQLCodegenTests/Integration/swiftgraphql.yml",
            ]
        )
    ]
)
