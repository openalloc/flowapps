//
//  Sale.swift
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

public struct Sale: Hashable, Identifiable {
    
    public let id = UUID()
    
    public static let epsilon = 0.01 // nearest 'penny'

    // asset class of holdings to liquidate
    public var assetKey: AssetKey

    // the amount we're targeting to liquidate (should be positive)
    public let targetAmount: Double

    // the MHolding(accountID: "", securityID:  s) to liquidate, at least in part
    public var liquidateHoldings: [LiquidateHolding] = []

    public init(assetKey: AssetKey, targetAmount: Double, liquidateHoldings: [LiquidateHolding] = []) {
        self.liquidateHoldings = liquidateHoldings
        self.assetKey = assetKey
        self.targetAmount = targetAmount
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(assetKey)
        hasher.combine(targetAmount)
        hasher.combine(liquidateHoldings)
    }
}

extension Sale: Equatable {
    public static func == (lhs: Sale, rhs: Sale) -> Bool {
        lhs.assetKey == rhs.assetKey &&
            lhs.targetAmount == rhs.targetAmount &&
            lhs.liquidateHoldings == rhs.liquidateHoldings
    }
}

public extension Sale {
    var tickerKeys: [SecurityKey] {
        Set(liquidateHoldings.map(\.holding.securityKey)).sorted()
    }

    var proceeds: Double {
        liquidateHoldings.reduce(0) { $0 + ($1.fractionalValue ?? 0) }
    }

    var netGainLoss: Double {
        liquidateHoldings.reduce(0) { $0 + ($1.fractionalGainLoss ?? 0) }
    }

    // absolute gains (ignoring all losses)
    var absoluteGains: Double {
        liquidateHoldings.reduce(0) { $0 + max(0, $1.fractionalGainLoss ?? 0) }
    }
}

public extension Sale {
    static func getSaleMap(_ rebalanceMap: AssetValueMap,
                           _ assetHoldingsMap: AssetHoldingsMap,
                           _ securityMap: SecurityMap,
                           //_ cashAssetKeySet: AssetKeySet,
                           minimumSaleAmount: Double = 0,
                           minimumPositionValue: Double = 0) -> SaleMap
    {
        let sales = getSales(rebalanceMap,
                             assetHoldingsMap,
                             securityMap,
                             //cashAssetKeySet,
                             minimumSaleAmount: minimumSaleAmount,
                             minimumPositionValue: minimumPositionValue)
        let assetKeys = sales.map(\.assetKey)
        return Dictionary(uniqueKeysWithValues: zip(assetKeys, sales))
    }

    static func getSales(_ rebalanceMap: AssetValueMap, // won't be grouped
                         _ assetHoldingsMap: AssetHoldingsMap, // will be grouped if 'Group Related Assets' is enabled
                         _ securityMap: SecurityMap,
                         minimumSaleAmount: Double = 0,
                         minimumPositionValue: Double = 0) -> [Sale]
    {
        rebalanceMap.sorted(by: { $0.key < $1.key }).compactMap { assetKey, rawAmount in

            // ignore near-zero sales, cash sales, and all purchases
            guard rawAmount.isLess(than: 0, accuracy: epsilon),
                  assetKey != MAsset.cashAssetKey
            else { return nil }

            let amount = -1 * rawAmount // flip the negative sale amount to positive

            guard amount >= minimumSaleAmount else { return nil }

            var remainingToSell = amount

            guard let qualifyingHoldings = assetHoldingsMap[assetKey],
                  qualifyingHoldings.count > 0
            else { return nil }

            let liquidations = LiquidateHolding.getLiquidations(securityMap,
                                                                qualifyingHoldings,
                                                                &remainingToSell,
                                                                minimumPositionValue)

            return .init(assetKey: assetKey,
                         targetAmount: amount,
                         liquidateHoldings: liquidations)
        }
    }
}
