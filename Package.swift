// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Acceleratus",
    platforms: [
        .iOS(.v10), .macOS(.v11)
    ],
    products: [
        .library(
            name: "Acceleratus",
            targets: ["Acceleratus"]
        ),
        .library(
            name: "AcceleratusExtensions",
            targets: ["AcceleratusExtensions"]
        ),
        .library(
            name: "AcceleratusMutex",
            targets: ["AcceleratusMutex"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AcceleratusMutex",
            exclude: ["include"] // will be fixed with PR-2814
        ),
        .target(
            name: "AcceleratusExtensions"
        ),
        .target(
            name: "Acceleratus",
            dependencies: ["AcceleratusMutex"]
        ),
        .testTarget(
            name: "AcceleratusTests",
            dependencies: ["Acceleratus"]
        ),
    ],
    cxxLanguageStandard: .cxx17
)
