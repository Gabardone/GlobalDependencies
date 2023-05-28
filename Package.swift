// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MiniDePin",
    platforms: [ // We require Combine for some of the dependency micropackages so that limits what we support.
        .iOS(.v14),
        .macCatalyst(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MiniDePin",
            targets: ["MiniDePin"]
        ),
        .library(
            name: "LocationDependency",
            targets: ["LocationDependency"]
        ),
        .library(
            name: "LocationDependencyTesting",
            targets: ["LocationDependencyTesting"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/Gabardone/SwiftUX", revision: "b5f0e82ba23a2815d3fba6097348d57d107aac12")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MiniDePin",
            dependencies: []
        ),
        .testTarget(
            name: "MiniDePinTests",
            dependencies: ["MiniDePin"]
        ),
        .target(
            name: "LocationDependency",
            dependencies: ["MiniDePin", "SwiftUX"]
        ),
        .target(
            name: "LocationDependencyTesting",
            dependencies: ["LocationDependency", "MiniDePin", "SwiftUX"]
        )
    ]
)
