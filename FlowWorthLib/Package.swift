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
    name: "FlowWorthLib",
    platforms: [.macOS(.v12), .iOS(.v15)],
    products: [
        .library(
            name: "FlowWorthLib",
            targets: ["FlowWorthLib"]
        ),
    ],
    dependencies: [
        .package(name: "FlowXCT", path: "../FlowXCT"),
        .package(name: "FlowBase", path: "../FlowBase"),
        .package(name: "FlowStats", path: "../FlowStats"),
        .package(url: "https://github.com/openalloc/SwiftSeriesResampler", from: "1.0.0"),
        .package(url: "https://github.com/openalloc/SwiftNiceScale", from: "1.0.0"),
        .package(url: "https://github.com/openalloc/SwiftRegressor", from: "1.0.0"),
        .package(url: "https://github.com/openalloc/SwiftModifiedDietz.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "FlowWorthLib",
            dependencies: [
                "FlowBase",
                "FlowStats",
                .product(name: "SeriesResampler", package: "SwiftSeriesResampler"),
                .product(name: "NiceScale", package: "SwiftNiceScale"),
                .product(name: "Regressor", package: "SwiftRegressor"),
                .product(name: "ModifiedDietz", package: "SwiftModifiedDietz"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "FlowWorthLibTests",
            dependencies: [
                "FlowWorthLib",
                "FlowXCT",
            ],
            path: "Tests"
        ),
    ]
)
