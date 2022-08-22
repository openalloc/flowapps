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
    name: "FlowStats",
    products: [
        .library(name: "FlowStats", targets: ["FlowStats"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FlowStats",
            dependencies: [
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "Algorithms", package: "swift-algorithms"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FlowStatsTests",
            dependencies: ["FlowStats"],
            path: "Tests"
        ),
    ]
)
