// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "RawTerm",
    products: [
        .library(name: "RawTerm", targets: ["RawTerm"]),
    ],
    targets: [
        .target(name: "RawTerm"),
        .testTarget(name: "RawTermTests", dependencies: ["RawTerm"]),
    ]
)