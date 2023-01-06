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
        .executable(name: "bbctl", targets: ["bbctl"])
    ],
    targets: [
        .target(
            name: "BBLib",
            dependencies: []
        ),
        .executableTarget(
            name: "bbctl",
            dependencies: ["BBLib"]
        )
    ]
)
