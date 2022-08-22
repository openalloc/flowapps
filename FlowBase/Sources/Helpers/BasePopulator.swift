//
//  BaseModel+Populate.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import Algorithms
import AllocData

public struct BasePopulator {
    
    public var assetMap: AssetMap
    public var securityMap: SecurityMap
    public var assetPool: [MAsset]
    public var securityPool: [MSecurity]
    public var includeLiabilities: Bool
    
    public init(_ model: inout BaseModel,
                assetCount: Int = 10,
                tickerCount: Int = 10,
                strategyCount: Int = 2,
                accountsPerStrategy: Int = 4,
                baseSharePrice: Double = 100.0,
                includeLiabilities: Bool = false,
                timestamp: Date = Date()) {
        self.includeLiabilities = includeLiabilities
        assetMap = model.makeAssetMap()
        securityMap = model.makeSecurityMap()
        
        assetPool = BasePopulator.getAssetPool(model, assetCount: assetCount, assetMap: assetMap)
        
        let assetKeyPool = Set(assetPool.map(\.primaryKey))
        securityPool = BasePopulator.getSecurityPool(model, tickerCount, assetKeyPool, assetMap, baseSharePrice, timestamp)
        model.securities = securityPool
        
        model.strategies = BasePopulator.strategyPool.randomSample(count: strategyCount)
        let strategyKeys = model.strategies.map(\.primaryKey)
        model.allocations = BasePopulator.allocationPool.filter { strategyKeys.contains($0.strategyKey) }
        
        model.accounts = BasePopulator.populateGetAccounts(model, accountsPerStrategy: accountsPerStrategy)

        model.holdings = BasePopulator.getHoldings(model, randomSecurity, includeLiabilities)
    }

    public var assetKeyPool: Set<AssetKey> {
        Set(assetPool.map(\.primaryKey))
    }
    
    public func randomAsset() -> MAsset {
        let assetKey = assetKeyPool.randomElement()!
        return assetMap[assetKey]!
    }
    
    public func randomSecurity() -> MSecurity {
        securityPool.randomElement()!
    }

    public static func populateGetAccounts(_ model: BaseModel, accountsPerStrategy: Int) -> [MAccount] {
        let accountRange = 0 ..< (model.strategies.count * accountsPerStrategy)
        return accountRange.map {
            let strategyIndex = $0 % model.strategies.count
            let isFirst = Int($0 / (model.strategies.count + 1)) == 0
            let isTaxable = isFirst || Bool.random() // at least one taxable account
            let canTrade = isFirst || $0 % 2 == 1 // at least one tradable account
            let accountID = String($0 + 1000)
            let strategy = model.strategies[strategyIndex]
            return MAccount(accountID: accountID,
                            title: "Account\($0)",
                            isTaxable: isTaxable,
                            canTrade: canTrade,
                            strategyID: strategy.strategyID)
        }
    }
    
    public static func getHoldings(_ model: BaseModel,
                                   _ randomSecurity: () -> MSecurity,
                                   _ includeLiabilities: Bool) -> [MHolding] {
        let holdingArrays: [[MHolding]] = model.accounts.map { account in
            let holdingRange = 1 ... Int.random(in: 3 ... 10)
            let holdings: [MHolding] = holdingRange.compactMap { _ in
                
                let security = randomSecurity()
                let securityID = security.securityID
                let shareCount = includeLiabilities ? Double.random(in: -500 ... 500) : Double.random(in: 1 ... 1000)
                let shareBasis = security.isCashAsset ? 1.0 : getNetSharePrice(security.sharePrice!)
                
                return MHolding(accountID: account.accountID,
                                securityID: securityID,
                                lotID: "",
                                shareCount: shareCount,
                                shareBasis: shareBasis)
            }
            return holdings
        }
        return holdingArrays.flatMap { $0 }
    }
    
    // assets of all the allocations, plus a few randos
    public static func getAssetPool(_ model: BaseModel, assetCount: Int = 10, assetMap: AssetMap) -> [MAsset] {
        var assetKeyPool = Set(model.allocations.map(\.assetKey))
        assetKeyPool.insert(MAsset.cashAssetKey)
        (0 ... assetCount).forEach { _ in
            guard let assetKey = model.assets.randomElement()?.primaryKey else { return }
            assetKeyPool.insert(assetKey)
        }
        return assetKeyPool.compactMap { assetMap[$0] }
    }
    
    public static func getSecurityPool(_ model: BaseModel,
                                       _ tickerCount: Int,
                                       _ assetKeyPool: Set<AssetKey>,
                                       _ _assetMap: AssetMap,
                                       _ baseSharePrice: Double,
                                       _ timestamp: Date = Date()) -> [MSecurity] {
        var pool = [MSecurity]()
        (0 ..< tickerCount).forEach { _ in
            let ticker = randomTicker(model)
            let assetKey = assetKeyPool.randomElement()!
            let asset = _assetMap[assetKey]!
            let assetID = asset.assetID
            let sharePrice = asset.isCash ? 1.0 : getNetSharePrice(baseSharePrice)
            let security = MSecurity(securityID: ticker,
                                     assetID: assetID,
                                     sharePrice: sharePrice,
                                     updatedAt: timestamp)
            pool.append( security)
        }
        return pool
    }
    
    mutating public func refreshSecurityPrices(timestamp: Date = Date()) {
        for n in 0..<(securityPool.count - 1) {
            guard !securityPool[n].isCashAsset else { continue }
            securityPool[n].sharePrice = BasePopulator.getNetSharePrice(securityPool[n].sharePrice ?? 0)
            securityPool[n].updatedAt = timestamp
        }
    }
    
    static let alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
    static func randomTicker(_ model: BaseModel) -> String {
        let count = Bool.random() ? 3 : 4
        let word = alpha.randomSample(count: count).map { String($0) }.joined()
        return badTickers.contains(word) ? randomTicker(model) : word
    }
    
    public static func getNetSharePrice(_ basePrice: Double) -> Double {
        let foo = basePrice / 2
        guard foo > 1 else { return foo }
        return max(1, basePrice + (Double.random(in: 1 ... foo) - foo / 2))
    }
    
    public static let strategyPool: [MStrategy] = [
        MStrategy(strategyID: "60/40", title: "60/40"),
        MStrategy(strategyID: "Coffee", title: "Shultheis' Coffeehouse"),
        MStrategy(strategyID: "Butterfly", title: "Portfolio Charts' Golden Butterfly"),
        MStrategy(strategyID: "Swenson", title: "Swenson's Portfolio"),
        MStrategy(strategyID: "Pinwheel", title: "Portfolio Charts' Pinwheel Portfolio"),
    ]
    
    public static let allocationPool: [MAllocation] = [
        MAllocation(strategyID: "60/40", assetID: "LC", targetPct: 0.6),
        MAllocation(strategyID: "60/40", assetID: "Bond", targetPct: 0.4),
        MAllocation(strategyID: "Coffee", assetID: "Bond", targetPct: 0.4),
        MAllocation(strategyID: "Coffee", assetID: "Intl", targetPct: 0.1),
        MAllocation(strategyID: "Coffee", assetID: "LC", targetPct: 0.1),
        MAllocation(strategyID: "Coffee", assetID: "LCVal", targetPct: 0.1),
        MAllocation(strategyID: "Coffee", assetID: "SC", targetPct: 0.1),
        MAllocation(strategyID: "Coffee", assetID: "SCVal", targetPct: 0.1),
        MAllocation(strategyID: "Coffee", assetID: "RE", targetPct: 0.1),
        MAllocation(strategyID: "Butterfly", assetID: "Gold", targetPct: 0.2),
        MAllocation(strategyID: "Butterfly", assetID: "SCVal", targetPct: 0.2),
        MAllocation(strategyID: "Butterfly", assetID: "STGov", targetPct: 0.2),
        MAllocation(strategyID: "Butterfly", assetID: "LC", targetPct: 0.2),
        MAllocation(strategyID: "Butterfly", assetID: "LTGov", targetPct: 0.2),
        MAllocation(strategyID: "Swenson", assetID: "Total", targetPct: 0.3),
        MAllocation(strategyID: "Swenson", assetID: "Intl", targetPct: 0.15),
        MAllocation(strategyID: "Swenson", assetID: "EM", targetPct: 0.05),
        MAllocation(strategyID: "Swenson", assetID: "ITGov", targetPct: 0.3),
        MAllocation(strategyID: "Swenson", assetID: "RE", targetPct: 0.2),
        MAllocation(strategyID: "Pinwheel", assetID: "Total", targetPct: 0.15),
        MAllocation(strategyID: "Pinwheel", assetID: "SCVal", targetPct: 0.1),
        MAllocation(strategyID: "Pinwheel", assetID: "Intl", targetPct: 0.15),
        MAllocation(strategyID: "Pinwheel", assetID: "EM", targetPct: 0.1),
        MAllocation(strategyID: "Pinwheel", assetID: "ITGov", targetPct: 0.15),
        MAllocation(strategyID: "Pinwheel", assetID: "Cash", targetPct: 0.1),
        MAllocation(strategyID: "Pinwheel", assetID: "RE", targetPct: 0.15),
        MAllocation(strategyID: "Pinwheel", assetID: "Gold", targetPct: 0.1),
    ]
}
