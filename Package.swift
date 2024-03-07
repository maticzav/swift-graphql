// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "swift-graphql",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        // SwiftGraphQL
        .library(name: "SwiftGraphQL", targets: ["SwiftGraphQL"]),
        .library(name: "SwiftGraphQLClient", targets: ["SwiftGraphQLClient"]),
        // Utilities
        .library(name: "GraphQL", targets: ["GraphQL"]),
        .library(name: "GraphQLWebSocket", targets: ["GraphQLWebSocket"]),
    ],
    dependencies: [
        // .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.5"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    ],
    targets: [
        // Spec
        .target(name: "GraphQL", dependencies: [], path: "Sources/GraphQL"),
        .target(
            name: "GraphQLWebSocket",
            dependencies: [
                "GraphQL",
                .product(name: "Logging", package: "swift-log"),
                "Starscream"
            ],
            path: "Sources/GraphQLWebSocket",
            exclude: ["README.md"]
        ),

        // SwiftGraphQL

        .target(
            name: "SwiftGraphQL",
            dependencies: [
                "GraphQL",
            ],
            path: "Sources/SwiftGraphQL"
        ),
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

        // Tests

        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: [
                "Files",
                "GraphQL",
                "GraphQLWebSocket",
                "SwiftGraphQL",
                "SwiftGraphQLClient",
            ],
            path: "Tests",
            exclude: [
                "SwiftGraphQLTests/Integration/schema.json",
                "SwiftGraphQLTests/Integration/swiftgraphql.yml",
            ]
        )
    ]
)
