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
    name: "FlowUI",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "FlowUI",
            targets: ["FlowUI"]),
    ],
    dependencies: [
        .package(name: "FlowBase", path: "../FlowBase"),
        .package(name: "FlowViz", path: "../FlowViz"),
        .package(url: "https://github.com/openalloc/SwiftDetailer", from: "0.5.0"),
        .package(url: "https://github.com/openalloc/SwiftDetailerMenu", from: "0.5.0"),
        .package(url: "https://github.com/openalloc/SwiftTabler", from: "0.5.0"),
        .package(url: "https://github.com/openalloc/SwiftSideways", from: "0.5.0"),
        .package(url: "https://github.com/openalloc/SwiftCompactor", from: "1.0.0"),
        .package(url: "https://github.com/reedes/KeyWindow", from: "0.0.4"),
        .package(url: "https://github.com/reedes/ZIPFoundation", from: "0.9.0"),
    ],
    targets: [
        .target(
            name: "FlowUI",
            dependencies: [
                "FlowBase",
                "FlowViz",
                "ZIPFoundation",
                .product(name: "Detailer", package: "SwiftDetailer"),
                .product(name: "DetailerMenu", package: "SwiftDetailerMenu"),
                .product(name: "Tabler", package: "SwiftTabler"),
                .product(name: "Sideways", package: "SwiftSideways"),
                .product(name: "Compactor", package: "SwiftCompactor"),
                .product(name: "KeyWindow", package: "KeyWindow"),
            ],
            path: "Sources"
        )
    ]
)
