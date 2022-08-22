//
//  BaseModel+Maps.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


public extension BaseModel {

    // MARK: - Keys
    
    var accountKeys: [AccountKey] {
       accounts.map(\.primaryKey)
    }
    
    var securityKeys: [SecurityKey] {
       securities.map(\.primaryKey)
    }

    var strategyKeys: [StrategyKey] {
       strategies.map(\.primaryKey)
    }

    var assetKeys: [AssetKey] {
       assets.map(\.primaryKey)
    }

    var trackerKeys: [TrackerKey] {
       trackers.map(\.primaryKey)
    }
    
    // MARK: - Keyed Maps

    func makeAccountMap() -> AccountMap {
        MAccount.makeAllocMap(accounts)
    }

    func makeSecurityMap() -> SecurityMap {
        MSecurity.makeAllocMap(securities)
    }

    func makeStrategyMap() -> StrategyMap {
        MStrategy.makeAllocMap(strategies)
    }

    func makeAssetMap() -> AssetMap {
        MAsset.makeAllocMap(assets)
    }

    func makeTrackerMap() -> TrackerMap {
        MTracker.makeAllocMap(trackers)
    }
    
    func makeSnapshotMap() -> SnapshotMap {
        MValuationSnapshot.makeAllocMap(valuationSnapshots)
    }
    
    func makeTransactionMap() -> TransactionMap {
        MTransaction.makeAllocMap(transactions)
    }

    // MARK: - Other maps

    var strategiedAccounts: [MAccount] {
        accounts.filter { strategyKeys.contains( $0.strategyKey ) }
    }
    
    func makeAccountHoldingsMap() -> AccountHoldingsMap {
        Dictionary(grouping: holdings, by: { $0.accountKey })
    }
}

public extension BaseModel {
    
    static func getAccountAssetValuesMap(accountHoldingsMap: AccountHoldingsMap, securityMap: SecurityMap) -> AccountAssetValuesMap {
        let accountKeys = accountHoldingsMap.map(\.key)
        let accountHoldingsSummaryMap = HoldingsSummary.getAccountAssetSummaryMap(accountKeys, accountHoldingsMap, securityMap)
        return BaseModel.getAccountAssetValuesMap(accountHoldingsSummaryMap)
    }

    // currently sorted by present value of holdings in each asset class
    static func getAccountAssetValues(_ holdingsSummaryMap: AssetHoldingsSummaryMap) -> [AssetValue] {
        let total = holdingsSummaryMap.map(\.value).reduce(0) { $0 + $1.presentValue }
        guard total > 0 else { return [] }
        return holdingsSummaryMap.sorted(by: { $0.value.presentValue > $1.value.presentValue }).map { assetKey, holdingsSummary in
            AssetValue(assetKey, holdingsSummary.presentValue / total)
        }
    }

    static func getAccountAssetValuesMap(_ accountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap) -> AccountAssetValuesMap { // [AccountKey: [AssetValue]]
        let accountKeys = accountHoldingsSummaryMap.map(\.key)
        let allocArrays = accountKeys.map { getAccountAssetValues(accountHoldingsSummaryMap[$0] ?? [:]) }
        return Dictionary(uniqueKeysWithValues: zip(accountKeys, allocArrays))
    }
}


public extension BaseModel {
    // recent history items, suitable for caching in HighContext
    func getRecentTxns(since: Date) -> [MTransaction] {
        transactions.filter { $0.transactedAt >= since }
    }
}


public extension BaseModel {
    func getActiveAccounts(strategyKey: StrategyKey) -> [MAccount] {
        accounts.filter { $0.strategyKey == strategyKey }
    }

    func getActiveVariableAccounts(strategyKey: StrategyKey) -> [MAccount] {
        getActiveAccounts(strategyKey: strategyKey).filter { $0.canTrade }
    }

    func getActiveFixedAccounts(strategyKey: StrategyKey) -> [MAccount] {
        getActiveAccounts(strategyKey: strategyKey).filter { !$0.canTrade }
    }
}
