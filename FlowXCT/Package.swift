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
    name: "FlowXCT",
    products: [
        .library(
            name: "FlowXCT",
            targets: ["FlowXCT"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "FlowXCT",
            dependencies: [],
            path: "Sources"
        ),
    ]
)
