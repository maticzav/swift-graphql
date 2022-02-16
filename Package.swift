// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-graphql",
    platforms: [
//        .iOS(.v13),
        .macOS(.v10_15),
//        .tvOS(.v13),
//        .watchOS(.v6)
    ],
    products: [
        /* SwiftGraphQL */
        .library(
            name: "SwiftGraphQL",
            targets: ["SwiftGraphQL"]
        ),
        .library(
            name: "SwiftGraphQLCodegen",
            targets: ["SwiftGraphQLCodegen"]
        ),
        .executable(
            name: "swift-graphql",
            targets: ["SwiftGraphQLCLI"]
        ),
        /* Utilities */
        .library(
            name: "GraphQLAST",
            targets: ["GraphQLAST"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.4"),
        .package(url: "https://github.com/apple/swift-format", from: "0.50500.0")
    ],
    targets: [
        /* SwiftGraphQL */
        .target(
            name: "SwiftGraphQL",
            dependencies: [],
            path: "Sources/SwiftGraphQL"
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
            name: "GraphQLAST",
            dependencies: [],
            path: "Sources/GraphQLAST"
        ),
        /* Tests */
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: ["SwiftGraphQL"]
        ),
        .testTarget(
            name: "SwiftGraphQLCodegenTests",
            dependencies: [
                .product(name: "SwiftFormat", package: "swift-format"),
                "Files",
                "SwiftGraphQLCodegen",
                "GraphQLAST"
            ]
        ),
        .testTarget(
            name: "GraphQLASTTests",
            dependencies: ["GraphQLAST"]
        ),
    ]
)
