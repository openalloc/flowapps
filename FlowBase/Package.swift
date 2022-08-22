// swift-tools-version:5.5
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import PackageDescription

let package = Package(
    name: "FlowBase",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "FlowBase", targets: ["FlowBase"]),
    ],
    dependencies: [
        .package(url: "https://github.com/openalloc/FINporter.git", from: "1.1.0"),
        .package(url: "https://github.com/openalloc/FINporterAllocSmart.git", from: "0.9.0"),
        .package(url: "https://github.com/openalloc/FINporterFido.git", from: "0.9.0"),
        .package(url: "https://github.com/openalloc/FINporterChuck.git", from: "0.9.0"),
        .package(url: "https://github.com/openalloc/FINporterTabular.git", from: "0.9.0"),
        .package(url: "https://github.com/openalloc/AllocData", from: "1.1.0"),
        .package(url: "https://github.com/openalloc/SwiftSimpleTree", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FlowBase",
            dependencies: [
                "FINporter",
                "FINporterAllocSmart",
                "FINporterFido",
                "FINporterChuck",
                "FINporterTabular",
                .product(name: "SimpleTree", package: "SwiftSimpleTree"),
                .product(name: "AllocData", package: "AllocData"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FlowBaseTests",
            dependencies: [
                "FlowBase",
            ],
            path: "Tests"
        ),
    ]
)
