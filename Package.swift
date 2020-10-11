// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftGraphQL",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        .library(
            name: "SwiftGraphQL",
            targets: ["SwiftGraphQL", "SwiftGraphQLCodegen"]),
        
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-format.git",
            .upToNextMajor(from: "0.50300.0")),
    ],
    targets: [
        .target(
            name: "SwiftGraphQL",
            dependencies: []),
        .target(
            name: "SwiftGraphQLCodegen",
            dependencies: ["swift-format"]),
        .testTarget(
            name: "SwiftGraphQLTests",
            dependencies: ["SwiftGraphQL", "SwiftGraphQLCodegen"]),
    ]
)
