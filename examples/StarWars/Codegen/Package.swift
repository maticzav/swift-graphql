// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    dependencies: [
        .package(name: "swift-graphql", path: "../../.."),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: [
                .product(name: "SwiftGraphQLCodegen", package: "swift-graphql"),
                "Files"
            ]
        ),
    ]
)
