// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibSauna",
    platforms: [
        .macOS(.v11),
        .watchOS(.v6),
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "SaunaApp",
            targets: ["SaunaApp"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/alexjohnj/Requests.git", .upToNextMinor(from: "0.3.0")),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", .upToNextMinor(from: "0.16.0"))
    ],
    targets: [
        .target(name: "Loadable"),
        .target(
            name: "TCAHelpers",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),

        .target(name: "SaunaKit", dependencies: ["Requests"]),
        .testTarget(name: "SaunaKitTests", dependencies: ["SaunaKit"]),

        .target(
            name: "SaunaApp",
            dependencies: [
                "Loadable",
                "SaunaKit",
                "TCAHelpers",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "SaunaAppTests",
            dependencies: ["SaunaApp"]
        )
    ]
)
