//
//  HighContext.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import SimpleTree
import AllocData

import FlowAllocLow
import FlowBase


public class HighContext: LowContext {
    public private(set) var settings: ModelSettings
    
    public init(_ model: BaseModel,
                _ settings: ModelSettings,
                strategyKey: StrategyKey,
                timestamp: Date = Date(),
                timeZone: TimeZone = TimeZone.current)
    {
        self.settings = settings
        
        super.init(model, strategyKey: strategyKey, timestamp: timestamp, timeZone: timeZone)
    }
    
    // MARK: - Overrides
    
    override public var allocatingAccounts: [MAccount] {
        variableAccountsForStrategy
    }
    
    override public var allocatingAccountKeys: [AccountKey] {
        variableAccountsForStrategy.map(\.primaryKey)
    }
    
    override public var allocatingAllocAssetKeys: [AssetKey] {
        variableAllocs.map(\.assetKey)
    }
    
    override public var allocatingAllocs: [AssetValue] {
        variableAllocs
    }
    
    // MARK: - Advanced Features
    
    public lazy var isRollupAssets: Bool = {
        settings.rollupAssets
    }()
    
    public lazy var isGroupRelatedHoldings: Bool = {
        settings.groupRelatedHoldings
    }()
    
    public lazy var isReduceRebalance: Bool = {
        settings.reduceRebalance
    }()
    
    // MARK: - Asset Keys  [AssetKey] and Set<AssetKey>
    
    private lazy var activeHoldingAssetKeys: [AssetKey] = {
        let keys = rawHoldingsMap.map(\.key).sorted()
        //print("activeHoldingAssetKeys: \(keys)")
        return keys
    }()
    
    private lazy var activeHoldingAssetKeySet: AssetKeySet = {
        Set(rawHoldingsMap.map(\.key))
    }()
    
    private lazy var rawFixedAssetKeys: [AssetKey] = {
        MHolding.getAssetKeys(rawFixedHoldings, securityMap: securityMap)
    }()
    
    private lazy var rawVariableAssetKeys: [AssetKey] = {
        MHolding.getAssetKeys(rawVariableHoldings, securityMap: securityMap)
    }()
    
    public lazy var netAllocAssetKeys: [AssetKey] = {
        netAllocs.map(\.assetKey)
    }()
    
    private lazy var netAllocAssetKeySet: AssetKeySet = {
        let keys = AssetKeySet(netAllocMap.keys)
        //print("netAllocAssetKeySet: \(keys.sorted())")
        return keys
    }()
    
    // MARK: - AssetValue
    
    private lazy var fixedAllocs: [AssetValue] = {
        let allocs = AssetValue.getAssetValues(from: fixedAllocMap)
        //print(AssetValue.describe(allocs, prefix: "fixedAllocs", style: .percent1))
        return allocs
    }()
    
    private lazy var variableAllocs: [AssetValue] = {
        AssetValue.getAssetValues(from: variableAllocMap)
    }()
    
    private lazy var netAllocs: [AssetValue] = {
        AssetValue.getAssetValues(from: netAllocMap, orderBy: baseAllocAssetKeys)
    }()
    
    // MARK: - Holdings  [MHolding]
    
    private lazy var rawVariableHoldings: [MHolding] = {
        MHolding.getHoldings(for: variableAccountsForStrategy, accountHoldingsMap: accountHoldingsMap)
    }()
    
    private lazy var acceptedVariableHoldings: [MHolding] = {
        acceptedVariableHoldingsMap.flatMap(\.value).sorted()
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    private lazy var mergedVariableHoldings: [MHolding] = {
        mergedVariableHoldingsMap.flatMap(\.value).sorted()
    }()
    
    // NOTE may include orphans
    private lazy var acceptedHoldings: [MHolding] = {
        acceptedVariableHoldings + acceptedFixedHoldings
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    private lazy var mergedHoldings: [MHolding] = {
        mergedVariableHoldings + mergedFixedHoldings
    }()
    
    private lazy var rawFixedHoldings: [MHolding] = {
        // note that not all fixed holdings will make it into the allocation (some may be orphaned)
        let holdings = MHolding.getHoldings(for: fixedAccountsForStrategy, accountHoldingsMap: accountHoldingsMap)
        //print(MHolding.describe(holdings, securityMap, prefix: "rawFixedHoldings"))
        return holdings
    }()
    
    // NOTE excludes holdings that don't map to allocation's asset classes
    private lazy var acceptedFixedHoldings: [MHolding] = {
        acceptedFixedHoldingsMap.flatMap(\.value).sorted()
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    private lazy var mergedFixedHoldings: [MHolding] = {
        mergedFixedHoldingsMap.flatMap(\.value).sorted()
    }()
    
    // MARK: - Asset Holdings Map  [AssetKey: [MHolding]]
    
    private lazy var rawFixedHoldingsMap: AssetHoldingsMap = {
        MHolding.getAssetHoldingsMap(rawFixedHoldings, securityMap)
    }()
    
    // NOTE may include orphans!! TODO
    private lazy var acceptedFixedHoldingsMap: AssetHoldingsMap = {
        netFixedHoldingsMapPair.accepted
    }()
    
    private lazy var rejectedFixedHoldingsMap: AssetHoldingsMap = {
        netFixedHoldingsMapPair.rejected
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    private lazy var mergedFixedHoldingsMap: AssetHoldingsMap = {
        acceptedFixedHoldingsMap.merging(rejectedFixedHoldingsMap, uniquingKeysWith: { _, _ in [] })
    }()
    
    // identify the fixed holdings applicable to our target allocation
    private lazy var netFixedHoldingsMapPair: DistillationResult = {
        guard isGroupRelatedHoldings else { return (rawFixedHoldingsMap, AssetHoldingsMap()) }
        return Relations.getDistilledMap(rawFixedHoldings,
                                         topRankedTargetMap: topRankedTargetMap,
                                         securityMap: securityMap)
    }()
    
    private lazy var rawVariableHoldingsMap: AssetHoldingsMap = {
        MHolding.getAssetHoldingsMap(rawVariableHoldings, securityMap)
    }()
    
    private lazy var acceptedVariableHoldingsMap: AssetHoldingsMap = {
        netVariableHoldingsMapPair.accepted
    }()
    
    private lazy var rejectedVariableHoldingsMap: AssetHoldingsMap = {
        netVariableHoldingsMapPair.rejected
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    private lazy var mergedVariableHoldingsMap: AssetHoldingsMap = {
        acceptedVariableHoldingsMap.merging(rejectedVariableHoldingsMap, uniquingKeysWith: { _, _ in [] })
    }()
    
    // identify the variable holdings applicable to our target allocation
    private lazy var netVariableHoldingsMapPair: DistillationResult = {
        guard isGroupRelatedHoldings else { return (rawVariableHoldingsMap, AssetHoldingsMap()) }
        return Relations.getDistilledMap(rawVariableHoldings,
                                         topRankedTargetMap: topRankedTargetMap,
                                         securityMap: securityMap)
    }()
    
    // MARK: - HoldingsSummary
    
    // may contain orphans!
    private lazy var acceptedFixedHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(acceptedFixedHoldings, securityMap)
    }()
    
    public lazy var mergedFixedHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(mergedFixedHoldings, securityMap)
    }()
    
    private lazy var acceptedVariableHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(acceptedVariableHoldings, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedVariableHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(mergedVariableHoldings, securityMap)
    }()
    
    // NOTE: may include orphans!
    private lazy var acceptedHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(acceptedHoldings, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(mergedHoldings, securityMap)
    }()
    
    // MARK: - AssetTickerHoldingsSummaryMap [AssetKey: [SecurityKey: HoldingsSummary]]
    
    // NOTE may contain orphans!
    public lazy var rawFixedAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        HoldingsSummary.getAssetTickerSummaryMap(rawFixedHoldingsMap, securityMap)
    }()
    
    public lazy var rawVariableAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        HoldingsSummary.getAssetTickerSummaryMap(rawVariableHoldingsMap, securityMap)
    }()
    
    // NOTE may contain orphans!
    private lazy var acceptedFixedAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        HoldingsSummary.getAssetTickerSummaryMap(acceptedFixedHoldingsMap, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedFixedAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        HoldingsSummary.getAssetTickerSummaryMap(mergedFixedHoldingsMap, securityMap)
    }()
    
    private lazy var acceptedVariableAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        HoldingsSummary.getAssetTickerSummaryMap(acceptedVariableHoldingsMap, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedVariableAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        HoldingsSummary.getAssetTickerSummaryMap(mergedVariableHoldingsMap, securityMap)
    }()
    
    // MARK: - AssetHoldingsSummaryMap  [AssetKey: HoldingsSummary]
    
    public lazy var rawFixedSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetHoldingsSummaryMap(rawFixedHoldingsMap, securityMap)
    }()
    
    public lazy var rawVariableSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetHoldingsSummaryMap(rawVariableHoldingsMap, securityMap)
    }()
    
    // NOTE may contain orphans!
    public lazy var acceptedFixedSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetHoldingsSummaryMap(acceptedFixedHoldingsMap, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedFixedSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetHoldingsSummaryMap(mergedFixedHoldingsMap, securityMap)
    }()
    
    public lazy var acceptedVariableSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetHoldingsSummaryMap(acceptedVariableHoldingsMap, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedVariableSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetHoldingsSummaryMap(mergedVariableHoldingsMap, securityMap)
    }()
    
    // MARK: - AccountAssetHoldingsSummaryMap  [AccountKey: [AssetKey: HoldingsSummary]]
    
    public lazy var rawFixedAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(rawFixedHoldingsMap, securityMap)
    }()
    
    public lazy var rawVariableAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(rawVariableHoldingsMap, securityMap)
    }()
    
    public lazy var acceptedFixedAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(acceptedFixedHoldingsMap, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedFixedAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(mergedFixedHoldingsMap, securityMap)
    }()
    
    public lazy var acceptedVariableAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(acceptedVariableHoldingsMap, securityMap)
    }()
    
    private lazy var rejectedVariableAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(rejectedVariableHoldingsMap, securityMap)
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedVariableAccountHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetHoldingsSummaryMap(mergedVariableHoldingsMap, securityMap)
    }()
    
    // MARK: - Relations
    
    /// map each 'held' asset key to its top-ranked 'target' asset key
    // NOTE used in getDistilledMap
    public lazy var topRankedTargetMap: ClosestTargetMap = {
        let map = Relations.getTopRankedTargetMap(rankedTargetsMap: rawRankedTargetsMap)
        //print(Relations.describe(map, assetMap: assetMap, prefix: "topRankedTargetMap"))
        return map
    }()
    
    /// map the held asset keys (value) to their top-ranked target asset key (key)
    // NOTE used to show asset groupings in various tables
    public lazy var topRankedHoldingAssetKeysMap: DeepRelationsMap = {
        let map = Relations.getTopRankedHeldMap(topRankedTargetMap: topRankedTargetMap)
        //print(Relations.describe(map, assetMap: assetMap, prefix: "topRankedHeldMap"))
        return map
    }()
    
    /// map each 'held' asset key to a ranked list of 'target' asset keys
    // NOTE: used in reduce/consolidate rebalance
    public lazy var rawRankedTargetsMap: DeepRelationsMap = {
        let map = Relations.getRawRankedTargetsMap(heldAssetKeySet: activeHoldingAssetKeySet,
                                                   targetAssetKeySet: netAllocAssetKeySet,
                                                   relatedTree: relatedTree)
        //print(Relations.describe(map, assetMap: assetMap, prefix: "rawRankedTargetsMap"))
        return map
    }()
    
    /// map each 'target' asset key to sorted list of 'held' asset keys
    private lazy var rawRelatedHoldingAssetKeysMap: DeepRelationsMap = {
        let map = Relations.getRawRelatedHeldMap(heldAssetKeySet: activeHoldingAssetKeySet,
                                                 targetAssetKeySet: netAllocAssetKeySet,
                                                 relatedTree: relatedTree)
        //print(Relations.describe(map, assetMap: assetMap, prefix: "rawRelatedHeldMap"))
        return map
    }()
    
    // MARK: - AccountAssetHoldingsMaps
    
    // NOTE may include orphans
    public lazy var acceptedAccountAssetHoldingsMap: AccountAssetHoldingsMap = {
        guard isGroupRelatedHoldings else { return baseAccountAssetHoldingsMap }
        return accountAssetHoldingsMapPair.reduce(into: [:]) { map, entry in
            let (accountKey, distillationResult) = entry
            map[accountKey] = distillationResult.accepted
        }
    }()
    
    private lazy var rejectedAccountAssetHoldingsMap: AccountAssetHoldingsMap = {
        guard isGroupRelatedHoldings else { return [:] }
        return accountAssetHoldingsMapPair.reduce(into: [:]) { map, entry in
            let (accountKey, distillationResult) = entry
            map[accountKey] = distillationResult.rejected
        }
    }()
    
    // combines the distilled (accepted) asset classes with the rejected randos
    public lazy var mergedAccountAssetHoldingsMap: AccountAssetHoldingsMap = {
        guard isGroupRelatedHoldings else { return baseAccountAssetHoldingsMap }
        return accountAssetHoldingsMapPair.reduce(into: [:]) { map, entry in
            let (accountKey, distillationResult) = entry
            map[accountKey] = distillationResult.accepted.merging(distillationResult.rejected, uniquingKeysWith: { _, _ in [] })
        }
    }()
    
    private lazy var accountAssetHoldingsMapPair: [AccountKey: DistillationResult] = {
        precondition(isGroupRelatedHoldings)
        return activeAccountKeys.reduce(into: [:]) { map, accountKey in
            guard let rawHoldings = accountHoldingsMap[accountKey]
            else { return }
            map[accountKey] = Relations.getDistilledMap(rawHoldings,
                                                        topRankedTargetMap: topRankedTargetMap,
                                                        securityMap: securityMap)
        }
    }()
    
    // MARK: - Rollup
    
    private lazy var rollupMap: RollupMap? = {
        netAllocMapPair.rollupMap
    }()
    
    // if enabled, roll up the slices (eliminating those with <10% allocation that can be folded into others)
    private lazy var netAllocMapPair: RollupResult = {
        if isRollupAssets {
            do {
                return try rollup(relatedTree, self.baseAllocMap, threshold: rollupThreshold)
            } catch let error as FlowBaseError {
                print(error.description)
            } catch {
                print(error.localizedDescription)
            }
        }
        return (self.baseAllocMap, nil)
    }()
    
    private lazy var rollupThreshold: Double = {
        let rawVal = settings.rollupThreshold
        let netVal = (0 ... 20).contains(rawVal) ? rawVal : ModelSettings.defaultRollupThreshold
        return Double(netVal) / 100.0
    }()
    
    // MARK: - Asset Value Map   [AssetKey: Double]
    
    public lazy var fixedAllocMap: AssetValueMap = {
        let map = AssetValue.getNormalizedAssetValueMap(from: netFixedAssetAmountMap)
        //print(AssetValue.describe(map, prefix: "fixedAllocMap", style: .percent1))
        return map
    }()
    
    public lazy var variableAllocMap: AssetValueMap = {
        AssetValue.getNormalizedAssetValueMap(from: netVariableAssetAmountMap)
    }()
    
    public lazy var netAllocMap: AssetValueMap = {
        netAllocMapPair.netAllocMap
    }()
    
    // MARK: - Account Asset Amount Map    [AccountKey: [AssetKey: Double]]
    
    // NOTE adjusted for orphans
    public lazy var fixedAllocatedMap: AccountAssetAmountMap = {
        //print(AssetValue.describe(fixedMapPair.allocated, prefix: "fixedAllocatedMap", style: .currency0))
        fixedMapPair.allocated
    }()
    
    public lazy var fixedOrphanedMap: AccountAssetAmountMap = {
        //print(AssetValue.describe(fixedMapPair.orphans, prefix: "fixedOrphanedMap", style: .currency0))
        fixedMapPair.orphans
    }()
    
    private lazy var fixedMapPair: FixedAllocationMapPair = {
        allocateFixed(accounts: fixedAccountsForStrategy,
                      fixedNetContribMap: netFixedAssetAmountMap,
                      accountHoldingsSummaryMap: baseAccountHoldingsSummaryMap,
                      topRankedTargetMap: topRankedTargetMap)
    }()
    
    // MARK: - Account Amount Map       [AccountKey: Double]
    
    // NOTE adjusted for orphans
    public lazy var accountAllocatingValueMap: AccountAmountMap = {
        var map = AccountAmountMap()
        map.merge(rawVariableAccountAmountMap, uniquingKeysWith: { old, _ in old })
        map.merge(fixedAccountAllocatingValueMap, uniquingKeysWith: { old, _ in old })
        return map
    }()
    
    private lazy var rawVariableAccountAmountMap: AccountAmountMap = {
        rawVariableAccountHoldingsMap.reduce(into: [:]) { map, entry in
            let (accountKey, holdings) = entry
            map[accountKey] = holdings.reduce(0) { $0 + ($1.getPresentValue(securityMap) ?? 0) }
        }
    }()
    
    // NOTE adjusted for orphans
    private lazy var fixedAccountAllocatingValueMap: AccountAmountMap = {
        fixedAllocatedMap.reduce(into: [:]) { map, entry in
            let (accountKey, assetAmountMap) = entry
            map[accountKey] = AssetValue.sumOf(assetAmountMap)
        }
    }()
    
    // MARK: - Asset Amount Map   [AssetKey: Double]
    
    // available fixed holding amounts, by asset class (e.g., Cash at $200K)
    // NOTE will EXCLUDE those holdings that have no relation to the current allocation (e.g., IntlBond)
    // NOTE may not account for partial orphan!
    private lazy var netFixedValueMap: AssetValueMap = {
        let map = MHolding.getPresentValueMap(holdingsMap: acceptedFixedHoldingsMap, securityMap: securityMap)
        //print(AssetValue.describe(map, prefix: "fixedValueMap", style: .currency0))
        return map
    }()
    
    public lazy var netFixedAssetAmountMap: AssetValueMap = {
        let map = getFixedContribMap(combinedContribMap: netAssetAmountMap,
                                     fixedValueMap: netFixedValueMap)
        //print(AssetValue.describe(map, prefix: "fixedContribMap", style: .currency0))
        return map
    }()
    
    public lazy var netVariableAssetAmountMap: AssetValueMap = {
        let map = AssetValue.difference(netAssetAmountMap, netFixedAssetAmountMap)
        //print(AssetValue.describe(map, prefix: "variableContribMap", style: .currency0))
        return map
    }()
    
    // available variable holding amounts, by asset class (e.g., Cash at $200K)
    private lazy var netVariableValueMap: AssetValueMap = {
        MHolding.getPresentValueMap(holdingsMap: acceptedVariableHoldingsMap, securityMap: securityMap)
    }()
    
    private lazy var netAssetAmountMap: AssetValueMap = {
        let map = AssetValue.distribute(value: netTotal, allocationMap: netAllocMap)
        //print(AssetValue.describe(map, prefix: "netAssetAmountMap", style: .currency0))
        return map
    }()
    
    // MARK: - AccountAssetValueMap  [AccountKey: [AssetKey: Double]]
    
    // from amount to percent
    public lazy var fixedAccountAllocationMap: AccountAssetValueMap = {
        let map = AssetValue.getAccountAssetValueMap(fixedAllocatedMap)
        //print(AssetValue.describe(map, prefix: "fixedAccountAllocationMap", style: .percent1))
        return map
    }()
    
    // MARK: - Totals   Double
    
    // NOTE properly excludes orphans
    public lazy var netCombinedTotal: Double = {
        // should be same as AssetValue.sumOf(accountAllocatingValueMap)
        netVariableTotal + netFixedTotal
    }()
    
    public lazy var netFixedTotal: Double = {
        AssetValue.sumOf(netFixedAssetAmountMap)
    }()
    
    public lazy var netVariableTotal: Double = {
        // cash and holdings in variable accounts ($696K)
        let val = MAccount.getPresentValue(variableAccountKeysForStrategy, baseAccountPresentValueMap)
        //print("netVariableTotal: \(val.currency0())")
        return val
    }()
    
    // NOTE may include orphans!
    private lazy var netTotal: Double = {
        getNetCombinedTotal(fixedValueMap: netFixedValueMap,
                            variableContribTotal: netVariableTotal,
                            netAllocMap: netAllocMap)
    }()
    
    // NOTE misleading! Actual combined contribution may be less, as fixed may be restricted as to what it can contribute.
    // NOTE may include orphans!
    private lazy var netAssetTotal: Double = {
        AssetValue.sumOf(netAssetAmountMap)
    }()
    
    // MARK: - AccountHoldingsMap  [AccountKey: [MHolding]]
    
    private lazy var rawVariableAccountHoldingsMap: AccountHoldingsMap = {
        Dictionary(grouping: rawVariableHoldings, by: { $0.accountKey })
    }()
    
    // NOTE: may include orphans!
    private lazy var netAccountHoldingsMap: AccountHoldingsMap = {
        Dictionary(grouping: acceptedHoldings, by: { $0.accountKey })
    }()
    
    private lazy var netVariableAccountHoldingsMap: AccountHoldingsMap = {
        Dictionary(grouping: acceptedVariableHoldings, by: { $0.accountKey })
    }()
    
    // MARK: - Transaction Maps
    
    public lazy var assetBuyTxnsMap: AssetTxnsMap = {
        MTransaction.getAssetTxnsMap(recentBuyTxns, securityMap)
    }()
    
    public lazy var assetSellTxnsMap: AssetTxnsMap = {
        MTransaction.getAssetTxnsMap(recentSellTxns, securityMap)
    }()
    
    public lazy var recentPurchasesMap: RecentPurchasesMap = {
        MTransaction.getRecentPurchasesMap(recentBuyTxns: recentBuyTxns)
    }()
    
    // NOTE: not considering whether account is taxable or not, as it may not be known
    public lazy var assetRecentNetGainsMap: AssetTickerAmountMap = {
        MTransaction.getAssetNetRealizedGainMap(assetSellTxnsMap: assetSellTxnsMap,
                                                accountMap: strategiedAccountMap)
    }()
    
    // NOTE: not considering whether account is taxable or not, as it may not be known
    public lazy var assetRecentPurchaseMap: AssetTickerAmountMap = {
        MTransaction.getAssetRecentPurchaseMap(assetBuyTxnsMap: assetBuyTxnsMap)
    }()
    
    // MARK: - Various maps
    
    public lazy var trackerSecuritiesMap: TrackerSecuritiesMap = {
        model.trackerSecuritiesMap
    }()
    
    // MARK: - Transactions

    public lazy var missingRealizedGainsTxns: [MTransaction] = {
        recentSellTxns.filter {
            $0.needsRealizedGain(thirtyDaysBack, securityMap, strategiedAccountMap)
        }
    }()
    
    public lazy var recentSellTxns: [MTransaction] = {
        recentTxns.filter { $0.isSell }
    }()

    public lazy var recentBuyTxns: [MTransaction] = {
        recentTxns.filter { $0.isBuy }
    }()
    
    internal lazy var recentTxns: [MTransaction] = {
        guard let since = thirtyDaysBack else { return [] }
        return model.getRecentTxns(since: since)
    }()
}
