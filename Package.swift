// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "ModernAppLoader",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "BBLib",
            targets: ["BBLib"]
        ),
    ],
    targets: [
        .target(
            name: "BBLib",
            dependencies: []
        ),
        .testTarget(
            name: "BBLibTests",
            dependencies: ["BBLib"]
        ),
        .executableTarget(
            name: "bbctl",
            dependencies: ["BBLib"]
        ),
    ]
)
