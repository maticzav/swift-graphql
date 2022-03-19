// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-graphql",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        /* SwiftGraphQL */
        .library(
            name: "SwiftGraphQL",
            targets: ["SwiftGraphQL"]
        ),
        .library(
            name: "SwiftGraphQLClient",
            targets: ["SwiftGraphQLClient"]
        ),
        .library(
            name: "SwiftGraphQLCodegen",
            targets: ["SwiftGraphQLCodegen"]
        ),
        .library(
            name: "SwiftGraphQLUI",
            targets: ["SwiftGraphQLUI"]
        ),
        /* CLI */
        .executable(
            name: "swift-graphql",
            targets: ["SwiftGraphQLCLI"]
        ),
        /* Utilities */
        .library(
            name: "GraphQL",
            targets: ["GraphQL"]
        ),
        .library(
            name: "GraphQLAST",
            targets: ["GraphQLAST"]
        ),
        .library(
            name: "GraphQLWebSocket",
            targets: ["GraphQLWebSocket"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
        .package(url: "https://github.com/apple/swift-format", from: "0.50600.0")
    ],
    targets: [
        /* SwiftGraphQL */
        .target(
            name: "SwiftGraphQL",
            dependencies: ["GraphQL"],
            path: "Sources/SwiftGraphQL"
        ),
        .target(
            name: "SwiftGraphQLClient",
            dependencies: [
                "GraphQL",
                "GraphQLWebSocket",
                "SwiftGraphQL",
            ],
            path: "Sources/SwiftGraphQLClient"
        ),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: [
                .product(name: "SwiftFormat", package: "swift-format"),
                .product(name: "SwiftFormatConfiguration", package: "swift-format"),
                "GraphQLAST"
            ],
            path: "Sources/SwiftGraphQLCodegen"
        ),
        .target(
            name: "SwiftGraphQLUI",
            dependencies: [
                "GraphQL",
                "SwiftGraphQL",
                "SwiftGraphQLClient"
            ],
            path: "Sources/SwiftGraphQLUI"
        ),
        .executableTarget(
            name: "SwiftGraphQLCLI",
            dependencies: [
                "SwiftGraphQLCodegen",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Yams",
                "Files",
            ],
            path: "Sources/SwiftGraphQLCLI"
        ),
        /* Utilities */
        .target(
            name: "GraphQL",
            dependencies: [],
            path: "Sources/GraphQL"
        ),
        .target(
            name: "GraphQLAST",
            dependencies: [],
            path: "Sources/GraphQLAST"
        ),
        .target(
            name: "GraphQLWebSocket",
            dependencies: ["GraphQL"],
            path: "Sources/GraphQLWebSocket"
        ),
        /* Tests */
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: ["SwiftGraphQL"]
        ),
        .testTarget(
            name: "SwiftGraphQLClientTests",
            dependencies: ["SwiftGraphQLClient"]
        ),
        .testTarget(
            name: "SwiftGraphQLCodegenTests",
            dependencies: [
                "Files",
                "SwiftGraphQLCodegen",
                "SwiftGraphQL"
            ]
        ),
        .testTarget(
            name: "GraphQLASTTests",
            dependencies: ["GraphQLAST"]
        ),
    ]
)
