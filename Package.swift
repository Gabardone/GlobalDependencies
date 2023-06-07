// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GlobalDependencies",
    platforms: [ // We require Combine for some of the dependency micropackages so that limits what we support.
        .iOS(.v11),
        .macCatalyst(.v13),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GlobalDependencies",
            targets: ["GlobalDependencies"]
        )
    ],
    dependencies: [
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "GlobalDependencies",
            dependencies: []
        ),
        .testTarget(
            name: "GlobalDependenciesTests",
            dependencies: ["GlobalDependencies"]
        )
    ]
)
