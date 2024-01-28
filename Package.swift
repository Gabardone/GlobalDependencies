// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "GlobalDependencies",
    platforms: [
        // Currently only limited by tooling & Swift support.
        .iOS(.v13),
        .macCatalyst(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .visionOS(.v1),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "GlobalDependencies",
            targets: ["GlobalDependencies"]
        )
    ],
    dependencies: [
        // Depend on the Swift 5.9 release of SwiftSyntax for macro implementation.
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
        // Depend on the swift documentation plugin to produce web-ready docs.
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        .macro(
            name: "GlobalDependenciesMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "GlobalDependencies",
            dependencies: ["GlobalDependenciesMacros"]
        ),
        .testTarget(
            name: "GlobalDependenciesTests",
            dependencies: [
                "GlobalDependencies",
                "GlobalDependenciesMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax")
            ]
        )
    ]
)
