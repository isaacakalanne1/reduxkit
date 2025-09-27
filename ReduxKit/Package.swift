// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ReduxKit",
    platforms: [
        .iOS("17.4")
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ReduxKit",
            targets: ["ReduxKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/combine-schedulers", "0.9.0"..<"1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ReduxKit",
            dependencies: [
                .product(name: "CombineSchedulers", package: "combine-schedulers")
            ]
        ),
        .testTarget(
            name: "ReduxKitTests",
            dependencies: ["ReduxKit"]
        ),
    ]
)
