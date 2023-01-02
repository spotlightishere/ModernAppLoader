// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "BBLib",
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
    ]
)
