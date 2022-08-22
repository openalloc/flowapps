//
//  FINschema+tableNames.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public extension AllocSchema {
    var camelCasePluralName: String {
        switch self {
        case .allocStrategy:
            return "strategies"
        case .allocAllocation:
            return "allocations"
        case .allocAsset:
            return "assets"
        case .allocHolding:
            return "holdings"
        case .allocAccount:
            return "accounts"
        case .allocSecurity:
            return "securities"
        case .allocTransaction:
            return "transactions"
        case .allocCap:
            return "caps"
        case .allocTracker:
            return "trackers"
        case .allocRebalanceSale:
            return "rebalanceSales"
        case .allocRebalancePurchase:
            return "rebalancePurchases"
        case .allocRebalanceAllocation:
            return "rebalanceAllocations"
        case .allocValuationSnapshot:
            return "valuationSnapshots"
        case .allocValuationPosition:
            return "valuationPositions"
        case .allocValuationCashflow:
            return "valuationCashflows"
        case .allocMetaSource:
            return "metadata"
//        default:
//            return ""
        }
    }

    static func getFromCamelCasePlural(maybeCamelCasePluralName: String) -> AllocSchema? {
        for schema in AllocSchema.allCases {
            if maybeCamelCasePluralName == schema.camelCasePluralName {
                return schema
            }
        }
        return nil
    }
}
