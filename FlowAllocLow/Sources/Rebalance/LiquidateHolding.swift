//
//  LiquidateHolding.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowBase


// representing all (fraction=1) or part of a holding (fraction<1) to liquidate
public struct LiquidateHolding: Hashable, Encodable {
    public let holding: MHolding
    public let presentValue: Double
    public let fraction: Double

    public init(_ holding: MHolding, presentValue: Double, fraction: Double = 1.0) {
        self.holding = holding
        self.presentValue = presentValue
        self.fraction = fraction
    }

    public var securityKey: SecurityKey {
        holding.securityKey
    }

    public var absoluteShareCount: Double {
        holding.shareCount ?? 0.0
    }

    public var fractionalShareCount: Double {
        absoluteShareCount * fraction
    }

    public var fractionalValue: Double? {
        presentValue * fraction
    }

    public var sharePrice: Double {
        presentValue / absoluteShareCount
    }

    public var fractionalGainLoss: Double? {
        guard let shareBasis_ = holding.shareBasis else { return nil }
        return (presentValue - (absoluteShareCount * shareBasis_)) * fraction
    }
}

extension LiquidateHolding: Comparable {
    public static func < (lhs: LiquidateHolding, rhs: LiquidateHolding) -> Bool {
        (lhs.fractionalValue ?? 0) < (rhs.fractionalValue ?? 0)
    }
}

extension LiquidateHolding: Equatable {
    public static func == (lhs: LiquidateHolding, rhs: LiquidateHolding) -> Bool {
        lhs.holding == rhs.holding &&
            lhs.fraction == rhs.fraction
    }
}

extension LiquidateHolding {
    public func getTicker(_ securityMap: SecurityMap) -> SecurityID? {
        guard securityKey.isValid else { return nil }
        return securityMap[securityKey]?.securityID
    }

    // NOTE that holdings SHOULD have been sorted in getAssetHoldingsMap by gainLoss (asc)
    // to avoid having to re-sort here.
    static func getLiquidations(_ securityMap: SecurityMap,
                                _ holdings: [MHolding],
                                _ remainingToSell: inout Double,
                                _ minimumPositionValue: Double = 0) -> [LiquidateHolding]
    {
        holdings.compactMap { holding in

            guard remainingToSell > 0,
                  let pv = holding.getPresentValue(securityMap),
                  pv > 0
            else { return nil }

            var amountToSell = min(pv, remainingToSell)

            let remainingPositionValue = pv - amountToSell

            // avoid leaving tiny positions behind
            if remainingPositionValue.isLessThanOrEqual(to: minimumPositionValue, accuracy: epsilon) {
                amountToSell = pv
            }

            remainingToSell -= min(remainingToSell, amountToSell)

            let fractionToSell = amountToSell / pv // 1.0 is selling all of holding

            return .init(holding, presentValue: pv, fraction: fractionToSell)
        }
    }
}
