//
//  HighResult+Describe.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase

extension HighResult: CustomStringConvertible {
    public var description: String {
        "ng=\(taxableGainsDollars) ag=\(absTaxableGainsDollars) v=\(volumeDollars) w=\(washAmountDollars) fm=\(flowModeInt) tc=\(transactionCount)"
    }
}

extension HighResult: CustomDebugStringConvertible {
    public var debugDescription: String {
        var buffer = [String]()
        buffer.append("FlowMode: \(flowMode.format3())")
        //buffer.append("AccountKeys: \(accountKeys.joined(separator: ", "))")
        //buffer.append("AssetKeys: \(assetKeys.joined(separator: ", "))")
        buffer.append("Taxable Gains: \(netTaxGains.currency0())")
        buffer.append("Volume: \(saleVolume.currency0())")
        //buffer.append("AccountAllocMap: \(AssetValue.describe(accountAllocMap, style: .percent1, separator: "\n\t"))")
        //buffer.append("AccountRebalanceMap: \(AssetValue.describe(accountRebalanceMap, style: .currency0, separator: "\n\t"))")
        //buffer.append("AccountReducerMap: \(ReducerPair.describe(accountReducerMap, separator: "\n\t"))")
        return buffer.joined(separator: "\n")
    }
}
