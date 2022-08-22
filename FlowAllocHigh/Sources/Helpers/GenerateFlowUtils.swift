//
//  GenerateFlowUtils.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public func generateFlowItems(itemCount: Int) -> [Double] {
    guard itemCount > 1 else { return [] }
    let chunkSize = 1.0 / Double(itemCount - 1)
    let flowItems: [Double] = (0 ... (itemCount - 1)).map { Double($0) * chunkSize }
    let multiplier = 1000.0 // for rounding to three decimal places
    return flowItems.map { ($0 * multiplier).rounded() / multiplier }
}

// generate count items on either side of centroid
public func generateFlowItems(centroid: Double,
                              stride: Double,
                              count: Int) -> [Double]
{
    let acceptableRange = (0.0 ... 1.0)
    guard acceptableRange.contains(centroid),
          stride > 0,
          count > 0
    else { return [] }

    let rawValues: [Double] = (0 ..< count).map { Double($0 + 1) * stride }
    let flowItemsLeft: [Double] = rawValues.map { centroid - $0 }.filter { (0 ..< centroid).contains($0) }.reversed()
    let flowItemsRight: [Double] = rawValues.map { centroid + $0 }.filter { $0 <= 1.0 }
    let multiplier = 1000.0 // for rounding to three decimal places
    return (flowItemsLeft + flowItemsRight).map { ($0 * multiplier).rounded() / multiplier }
}
