// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.


import PackageDescription

let package = Package(
    name: "Leopard",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Leopard",
            targets: ["Leopard"]),
    ],
    dependencies: [
        .package(url: "https://github.com/OpenKitten/Lynx.git", .exact("1.0.0-beta1")),
        .package(url: "https://github.com/OpenKitten/Schrodinger.git", .exact("2.0.0-beta1")),
        .package(url: "https://github.com/OpenKitten/Ocelot.git", .revision("1.0.0-beta1")),
        .package(url: "https://github.com/OpenKitten/Cheetah.git", from: "2.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Leopard",
            dependencies: ["Lynx", "Schrodinger", "Cheetah"]),
        .testTarget(
            name: "LeopardTests",
            dependencies: ["Leopard", "Lynx", "Schrodinger"]),
    ]
)
