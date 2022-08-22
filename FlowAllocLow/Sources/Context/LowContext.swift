//
//  LowContext.swift
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

open class LowContext: BaseContext {

    public override init(_ model: BaseModel, strategyKey: StrategyKey, timestamp: Date = Date(), timeZone: TimeZone = TimeZone.current) {
        super.init(model, strategyKey: strategyKey, timestamp: timestamp, timeZone: timeZone)
    }

    // return true if context is older than model timestamp (requiring a refresh)
    public func isOlderThan(_ modelTimestamp: Date) -> Bool {
        updatedAt < modelTimestamp
    }

    public lazy var activeAccounts: [MAccount] = {
        guard strategyKey.isValid else { return [] }
        return model.accounts.filter { $0.strategyKey == strategyKey }.sorted()
    }()

    public lazy var activeAccountKeys: [AccountKey] = {
        activeAccounts.map(\.primaryKey)
    }()
    
    public lazy var activeAccountKeySet: AccountKeySet = {
        Set(activeAccountKeys)
    }()
    
    public lazy var baseAllocs: [AssetValue] = {
        guard let allocs = strategyAllocsMap[strategyKey] else { return [] }
        return (try? AssetValue.normalize(allocs))?.sorted() ?? []
    }()

    public lazy var strategyAllocationsMap: StrategyAllocationsMap = {
        model.strategyAllocationsMap
    }()

    public lazy var strategyAllocsMap: StrategyAssetValuesMap = {
        model.strategyAllocsMap
    }()

    public lazy var baseAllocAssetKeys: [AssetKey] = {
        baseAllocs.map(\.assetKey)
    }()

    public lazy var baseAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        // NOTE should be baseAccountKeys (rather than netAccountKeys) to include fixed accounts in HighContext
        HoldingsSummary.getAccountAssetSummaryMap(activeAccountKeys, accountHoldingsMap, securityMap)
    }()

    public lazy var baseAccountPresentValueMap: AccountPresentValueMap = {
        // NOTE should be activeAccountKeys (rather than netAccountKeys) to include fixed accounts in HighContext
        let map = MAccount.getAccountPresentValueMap(activeAccountKeys, accountHoldingsMap, securityMap)
        //print(AssetValue.describe(map, prefix: "accountPresentValueMap", style: .currency0))
        return map
    }()

    public lazy var baseAllocMap: AssetValueMap = {
        AssetValue.getAssetValueMap(from: baseAllocs)
    }()

    // MARK: - Overrideable attributes to be used in Allocation

    open var allocatingAccounts: [MAccount] {
        activeAccounts
    }

    open var allocatingAccountKeys: [AccountKey] {
        activeAccountKeys
    }

    open var allocatingAllocs: [AssetValue] {
        baseAllocs
    }

    open var allocatingAllocAssetKeys: [AssetKey] {
        baseAllocs.map(\.assetKey)
    }

    // MARK: - convenience functions

    public func getAccount(_ key: AccountKey?) -> MAccount? {
        guard let key_ = key else { return nil }
        return accountMap[key_]
    }

    public func getAsset(_ key: AssetKey?) -> MAsset? {
        guard let key_ = key else { return nil }
        return assetMap[key_]
    }

    public func getSecurity(_ key: SecurityKey?) -> MSecurity? {
        guard let key_ = key else { return nil }
        return securityMap[key_]
    }

    public func getStrategy(_ key: StrategyKey?) -> MStrategy? {
        guard let key_ = key,
              key_.isValid
        else { return nil }
        return strategyMap[key_]
    }

    public func getTracker(_ key: TrackerKey?) -> MTracker? {
        guard let key_ = key else { return nil }
        return trackerMap[key_]
    }

    // MARK: - Flow Allocation Support

    public lazy var accountCapsMap: AccountCapsMap = {
        model.capsMap
    }()

    public lazy var assetAccountLimitMap: AssetAccountLimitMap = {
        getAssetAccountLimitMap(accountKeys: allocatingAccountKeys,
                                baseAllocs: allocatingAllocs,
                                accountCapacitiesMap: accountCapacitiesMap,
                                accountCapsMap: accountCapsMap)
    }()

    public lazy var accountUserVertLimitMap: AccountUserVertLimitMap = {
        guard let map = try? getAccountUserVertLimitMap(accountKeys: allocatingAccountKeys,
                                                        baseAllocs: allocatingAllocs,
                                                        accountCapacitiesMap: accountCapacitiesMap,
                                                        accountCapsMap: accountCapsMap)
        else { return AccountUserVertLimitMap() }
        return map
    }()

    public lazy var accountUserAssetLimitMap: AccountUserAssetLimitMap = {
        guard let map = try? getAccountUserAssetLimitMap(accountKeys: allocatingAccountKeys,
                                                         baseAllocs: allocatingAllocs,
                                                         accountCapacitiesMap: accountCapacitiesMap,
                                                         accountCapsMap: accountCapsMap)
        else { return AccountUserAssetLimitMap() }
        return map
    }()

    public lazy var accountCapacitiesMap: AccountCapacitiesMap = {
        getCapacitiesMap(allocatingAccountKeys,
                         baseAccountPresentValueMap)
    }()

    // should include both fixed and allocating (aka variable), but not inactive
    public lazy var baseAccountAssetHoldingsMap: AccountAssetHoldingsMap = {
        MHolding.getAccountAssetHoldingsMap(accountKeys: activeAccountKeys,
                                            accountHoldingsMap,
                                            securityMap)
    }()
}
