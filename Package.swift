// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "swift-graphql",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
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
        // .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-format", "508.0.0"..<"510.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/dominicegginton/Spinner", from: "2.0.0"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
    ],
    targets: [
        // Spec
        .target(name: "GraphQL", dependencies: [], path: "Sources/GraphQL"),
        .target(name: "GraphQLAST", dependencies: [], path: "Sources/GraphQLAST"),
        .target(
            name: "GraphQLWebSocket",
            dependencies: [
                "GraphQL",
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/GraphQLWebSocket",
            exclude: ["README.md"]
        ),
        
        // SwiftGraphQL
        
        .target(
            name: "SwiftGraphQL",
            dependencies: ["GraphQL", "SwiftGraphQLUtils"],
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
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: [
                "GraphQLAST",
                .product(name: "SwiftFormat", package: "swift-format"),
                .product(name: "SwiftFormatConfiguration", package: "swift-format"),
                "SwiftGraphQLUtils"
            ],
            path: "Sources/SwiftGraphQLCodegen"
        ),
        .target(name: "SwiftGraphQLUtils", dependencies: [], path: "Sources/SwiftGraphQLUtils"),
        
        // Executables
        
        .executableTarget(
            name: "SwiftGraphQLCLI",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "Files",
                "Spinner",
                "SwiftGraphQLCodegen",
                "Yams",
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
                "GraphQLWebSocket",
                "SwiftGraphQLCodegen",
                "SwiftGraphQL",
                "SwiftGraphQLClient",
                "SwiftGraphQLUtils",
            ],
            path: "Tests",
            exclude: [
                "SwiftGraphQLCodegenTests/Integration/schema.json",
                "SwiftGraphQLCodegenTests/Integration/swiftgraphql.yml",
            ]
        )
    ]
)
