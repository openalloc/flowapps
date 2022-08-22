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
    name: "FlowAllocLow",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "FlowAllocLow", targets: ["FlowAllocLow"]),
    ],
    dependencies: [
        .package(name: "FlowXCT", path: "../FlowXCT"),
        .package(name: "FlowBase", path: "../FlowBase"),
    ],
    targets: [
        .target(
            name: "FlowAllocLow",
            dependencies: [
                "FlowBase",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FlowAllocLowTests",
            dependencies: [
                "FlowAllocLow",
                "FlowBase",
                "FlowXCT",
            ],
            path: "Tests"
        ),
    ]
)
