//
//  BasePopulator-extension.swift
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

import FlowBase

extension BasePopulator {
    
    mutating public func populateRandom(_ model: inout BaseModel,
                                        snapshotCount: Int = 12) throws {
        
        // 1. generate accounts
        // 2. generate holdings for each account
        // 3. get first snapshot
        // 4. update security prices, modify holdings, & generate history records
        // 5. get next snapshot
        // 6. goto step 4
        
        var ax = WorthContext(model)
        var capturedAt = Date()
        let firstSnapshot = PendingSnapshot(timestamp: capturedAt,
                                            holdings: model.holdings,
                                            transactions: [],
                                            previousSnapshot: nil,
                                            previousPositions: [],
                                            previousCashflows: [],
                                            userExcludedTxnKeys: [],
                                            accountMap: ax.accountMap,
                                            assetMap: ax.assetMap,
                                            securityMap: ax.securityMap)
        var lastHoldings = model.holdings
        try model.commitPendingSnapshot(firstSnapshot)

        try (1..<snapshotCount).forEach { _ in
            model.holdings = lastHoldings // simulate a user-import
            
            // advance time
            // TODO replace with endOfNextMonth()
            let startNextMonth = Calendar.current.startOfNextMonth(for: capturedAt)
            capturedAt = Calendar.current.endOfMonth(for: startNextMonth)
            
            refreshSecurityPrices(timestamp: capturedAt)
            ax = WorthContext(model)
            
            // update holdings and generate history records
            refreshHoldings(ax, &model, timestamp: capturedAt)
            
            ax = WorthContext(model)
            
            let pendingSnapshot = PendingSnapshot(timestamp: capturedAt,
                                                  holdings: model.holdings,
                                                  transactions: model.transactions,
                                                  previousSnapshot: ax.lastSnapshot,
                                                  previousPositions: ax.lastSnapshotPositions,
                                                  previousCashflows: ax.lastSnapshotCashflows,
                                                  userExcludedTxnKeys: [],
                                                  accountMap: ax.accountMap,
                                                  assetMap: ax.assetMap,
                                                  securityMap: ax.securityMap)
            lastHoldings = model.holdings
            try model.commitPendingSnapshot(pendingSnapshot)
        }
    }
    
    mutating func refreshHoldings(_ ax: WorthContext, _ model: inout BaseModel, timestamp: Date) {
        // vary holding share counts (up or down)
        var holdingKeysToDelete: Set<MHolding.Key> = Set()
        var unallocatedAssetValueMap: [AssetKey: Double] = [:]
        for (n, holding) in model.holdings.enumerated() {
            guard let assetKey = ax.securityMap[holding.securityKey]?.assetKey else { continue }
            
            let begShareCount = holding.shareCount ?? 0
            let endShareCount = BasePopulator.getRandomShares(begShareCount)
            let deltaShareCount = endShareCount - begShareCount
            if deltaShareCount.isEqual(to: 0, accuracy: 0.001) { continue }
            let sharePrice = ax.securityMap[holding.securityKey]?.sharePrice ?? 0
            
            // update holding and create history
            model.holdings[n].shareCount = endShareCount
            
            let action: MTransaction.Action = MTransaction.Action.allCases.randomElement() ?? .buysell
            
            let txn = MTransaction(action: action,
                                   transactedAt: timestamp,
                                   accountID: holding.accountID,
                                   securityID: holding.securityID,
                                   lotID: "",
                                   shareCount: deltaShareCount,
                                   sharePrice: sharePrice)
            model.transactions.append(txn)
            
            if endShareCount == 0 {
                holdingKeysToDelete.insert(holding.primaryKey)
                continue
            }
            
            let deltaValue = deltaShareCount * sharePrice
            unallocatedAssetValueMap[assetKey, default: 0] += deltaValue
        }
        
        model.holdings.removeAll(where: { holdingKeysToDelete.contains($0.primaryKey) })
        
        // distribute any unallocated cash
        for (assetKey, value) in unallocatedAssetValueMap {
            guard value > 0,
                  let security = securityPool.filter({ $0.assetKey == assetKey }).randomElement(),
                  let accountID = model.accounts.randomElement()?.accountID,
                  let sharePrice = security.sharePrice,
                  case let shareCount = value / sharePrice,
                  shareCount > 0
            else { continue }
            let nuHolding = MHolding(accountID: accountID,
                                     securityID: security.securityID,
                                     lotID: "",
                                     shareCount: shareCount,
                                     shareBasis: sharePrice)
            model.holdings.append(nuHolding)
        }
    }
  
    // For baseShares=10, return random value in range 5...15
    static func getRandomShares(_ baseShares: Double, downFactor: Double = -0.5, upFactor: Double = 0.5) -> Double {
        let netDown = abs(baseShares) * downFactor // -5
        let netUp = abs(baseShares) * upFactor // 5
        return baseShares + Double.random(in: netDown ... netUp)
    }
}
