//
//  Purchase.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import AllocData


public struct Purchase: Hashable, Identifiable {
    public let id = UUID()
    
    // asset class of new holding to purchase
    public var assetKey: AssetKey

    // amount to purchase/liquidate, in currency
    public let amount: Double

    public init(assetKey: AssetKey, amount: Double) {
        self.assetKey = assetKey
        self.amount = amount
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(assetKey)
        hasher.combine(amount)
        // super.hash(into: &hasher)
    }

    public static func getPurchaseMap(rebalanceMap: RebalanceMap) -> PurchaseMap
    {
        let purchases = getPurchases(rebalanceMap: rebalanceMap)
        let assetKeys = purchases.map(\.assetKey)
        return Dictionary(uniqueKeysWithValues: zip(assetKeys, purchases))
    }

    public static func getPurchases(rebalanceMap: RebalanceMap) -> [Purchase] {
        let epsilon = 0.01 // nearest 'penny'

        let acquisitions: [Purchase] = rebalanceMap.sorted(by: { $0.key < $1.key }).compactMap { assetKey, amount in

            // ignore near-zero purchases, cash purchases, and all sales
            guard amount.isGreater(than: 0, accuracy: epsilon),
                  assetKey != MAsset.cashAssetKey
            else { return nil }

            return Purchase(assetKey: assetKey,
                            amount: amount)
        }

        // order by amount desc
        return acquisitions.sorted(by: { $0.amount > $1.amount })
    }
}

extension Purchase: Equatable {
    public static func == (lhs: Purchase, rhs: Purchase) -> Bool {
        lhs.assetKey == rhs.assetKey &&
            lhs.amount == rhs.amount
    }
}
