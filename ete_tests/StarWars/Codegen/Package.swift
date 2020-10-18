// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Codegen",
    dependencies: [
        .package(name: "SwiftGraphQL", path: "../../../"),
        .package(url: "https://github.com/JohnSundell/Files", from: "4.0.0")
    ],
    targets: [
        .target(
            name: "Codegen",
            dependencies: ["SwiftGraphQL", "Files"]),
    ]
)
