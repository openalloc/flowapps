//
//  BaseModel+Export.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import FINporter


public extension BaseModel {
    func exportHordes(schema: AllocSchema,
                      format: AllocFormat) throws -> Data?
    {
        switch schema {
        case .allocAsset:
            return try exportData(assets, format: format)
        case .allocAccount:
            return try exportData(accounts, format: format)
        case .allocStrategy:
            return try exportData(strategies, format: format)
        case .allocSecurity:
            return try exportData(securities, format: format)
        case .allocAllocation:
            return try exportData(allocations, format: format)
        case .allocHolding:
            return try exportData(holdings, format: format)
        case .allocCap:
            return try exportData(caps, format: format)
        case .allocTracker:
            return try exportData(trackers, format: format)
        case .allocTransaction:
            return try exportData(transactions, format: format)
        case .allocValuationSnapshot:
            return try exportData(valuationSnapshots, format: format)
        case .allocValuationPosition:
            return try exportData(valuationPositions, format: format)
        case .allocValuationCashflow:
            return try exportData(valuationCashflows, format: format)
        default:
            return nil // excluding the rebalance schema
        }
    }
}
