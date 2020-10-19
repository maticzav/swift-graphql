// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGraphQL",
    products: [
        .library(
            name: "SwiftGraphQL",
            targets: ["SwiftGraphQL", "SwiftGraphQLCodegen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "SwiftGraphQL",
            dependencies: []),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: []),
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: ["SwiftGraphQL"]),
        .testTarget(
            name: "SwiftGraphQLCodegenTests",
            dependencies: ["Files", "SwiftGraphQLCodegen"]),
    ]
)
