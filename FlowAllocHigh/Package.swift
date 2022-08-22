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
    name: "FlowAllocHigh",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(name: "FlowAllocHigh", targets: ["FlowAllocHigh"]),
    ],
    dependencies: [
        .package(name: "FlowXCT", path: "../FlowXCT"),
        .package(name: "FlowAllocLow", path: "../FlowAllocLow"),
        .package(url: "https://github.com/reedes/SwiftPriorityQueue", from: "1.3.5"),
    ],
    targets: [
        .target(
            name: "FlowAllocHigh",
            dependencies: [
                "FlowAllocLow",
                "SwiftPriorityQueue",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FlowAllocHighTests",
            dependencies: [
                "FlowAllocHigh",
                "FlowAllocLow",
                "FlowXCT",
            ],
            path: "Tests"
        ),
    ]
)
