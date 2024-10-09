// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MPRIS",
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "MPRIS",
      targets: ["MPRIS"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    .package(url: "https://github.com/suransea/dbus-swift", from: "0.0.5"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "MPRIS",
      dependencies: [
        .product(name: "DBus", package: "dbus-swift")
      ]
    ),
    .testTarget(
      name: "MPRISTests",
      dependencies: ["MPRIS"]
    ),
  ]
)
