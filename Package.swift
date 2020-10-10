// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGraphQL",
    products: [
        .library(
            name: "SwiftGraphQL",
            targets: ["SwiftGraphQL"]),
        .library(
            name: "SwiftGraphQLCodegen",
            targets: ["SwiftGraphQLCodegen"]),
    ],
    dependencies: [
        .package(
            name: "GraphQL",
            url: "https://github.com/GraphQLSwift/GraphQL.git",
            .upToNextMajor(from: "1.1.7")),
    ],
    targets: [
        .target(
            name: "SwiftGraphQL",
            dependencies: []),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: ["GraphQL"]),
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: ["SwiftGraphQL"]),
    ]
)
