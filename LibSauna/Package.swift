// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LibSauna",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "LibSauna",
            targets: ["LibSauna"]),
    ],
    dependencies: [
        .package(url: "https://github.com/alexjohnj/Requests.git", .upToNextMinor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "LibSauna",
            dependencies: ["Requests"]),
        .testTarget(
            name: "LibSaunaTests",
            dependencies: ["LibSauna"]),
    ]
)
