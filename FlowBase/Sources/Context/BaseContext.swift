//
//  BaseContext.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

open class BaseContext {
    public private(set) var model: BaseModel
    public private(set) var updatedAt: Date
    public private(set) var strategyKey: StrategyKey
    public private(set) var timeZone: TimeZone

    public init(_ model: BaseModel, strategyKey: StrategyKey = MStrategy.emptyKey, timestamp: Date = Date(), timeZone: TimeZone) {
        self.model = model
        self.updatedAt = timestamp
        self.strategyKey = strategyKey
        self.timeZone = timeZone
    }

    // MARK: - Entity maps

    public lazy var accountMap: AccountMap = {
        model.makeAccountMap()
    }()

    public lazy var assetMap: AssetMap = {
        model.makeAssetMap()
    }()

    public lazy var securityMap: SecurityMap = {
        model.makeSecurityMap()
    }()

    public lazy var strategyMap: StrategyMap = {
        model.makeStrategyMap()
    }()

    public lazy var trackerMap: TrackerMap = {
        model.makeTrackerMap()
    }()

    public lazy var accountHoldingsMap: AccountHoldingsMap = {
        model.makeAccountHoldingsMap()
    }()
    
    public lazy var snapshotMap: SnapshotMap = {
        model.makeSnapshotMap()
    }()
    
    // MARK: - Relations
    
    public lazy var relatedTree: AssetKeyTree = {
        do {
            return try Relations.getTree(assetMap: assetMap)
        } catch let error as FlowBaseError {
            print(error.description)
        } catch {
            print(error.localizedDescription)
        }
        return AssetKeyTree(value: Relations.rootAssetKey)
    }()

    // MARK: - Strategies
    
    public lazy var strategyKeys: [StrategyKey] = {
        model.strategyKeys
    }()
    
    // used in determining which accounts are active for strategy
    public lazy var strategyAccountKeySetMap: StrategyAccountKeySetMap = {
        accounts.reduce(into: [:]) { map, account in
            let strategyKey = account.strategyKey
            guard strategyKey.isValid else { return }
            map[strategyKey, default: Set()].insert(account.primaryKey)
        }
    }()

    public lazy var strategyAssetValuesMap: StrategyAssetValuesMap = {
        model.allocations.reduce(into: [:]) { map, allocation in
            let av: AssetValue = AssetValue(allocation.assetKey, allocation.targetPct)
            map[allocation.strategyKey, default: []].append(av)
        }
    }()
    
    // MARK: - Accounts
    
    public lazy var accounts: [MAccount] = {
        model.accounts
    }()
    
    public lazy var accountKeys: [MAccount.Key] = {
        accounts.map(\.primaryKey)
    }()
    
    public lazy var strategiedAccounts: [MAccount] = {
        model.strategiedAccounts
    }()
    
    public lazy var strategiedAccountMap: AccountMap = {
        MAccount.makeAllocMap(strategiedAccounts)
    }()
    
    public lazy var accountHoldingsAssetValuesMap: AccountAssetValuesMap = {
        BaseModel.getAccountAssetValuesMap(accountHoldingsMap: accountHoldingsMap, securityMap: securityMap)
    }()
    
    // MARK: - Accounts and account keys

    public lazy var fixedAccounts: [MAccount] = {
        model.accounts.filter { !$0.canTrade }
    }()

    public lazy var fixedAccountsForStrategy: [MAccount] = {
        fixedAccounts.filter { $0.strategyKey == strategyKey }
    }()

    public lazy var fixedAccountKeysForStrategy: [AccountKey] = {
        fixedAccountsForStrategy.map(\.primaryKey)
    }()

    public lazy var variableAccounts: [MAccount] = {
        model.accounts.filter { $0.canTrade }
    }()

    public lazy var variableAccountsForStrategy: [MAccount] = {
        variableAccounts.filter { $0.strategyKey == strategyKey }
    }()

    public lazy var variableAccountKeysForStrategy: [AccountKey] = {
        variableAccountsForStrategy.map(\.primaryKey)
    }()
    
    public lazy var strategyAccountsMap: StrategyAccountsMap = {
        Dictionary(grouping: strategiedAccounts, by: { $0.strategyKey })
    }()
    
    public lazy var strategyVariableAccountsMap: StrategyAccountsMap = {
        Dictionary(grouping: variableAccounts, by: { $0.strategyKey })
    }()
    
    public lazy var strategyFixedAccountsMap: StrategyAccountsMap = {
        Dictionary(grouping: fixedAccounts, by: { $0.strategyKey })
    }()

    // MARK: - Securities

    public lazy var activeTickerKeySet: SecurityKeySet = {
        Set(activeTickerKeys)
    }()

    private lazy var activeSecurities: [MSecurity] = {
        model.securities.filter { activeTickerKeys.contains($0.primaryKey) }
    }()

    public lazy var activeTickerKeys: [SecurityKey] = {
        MSecurity.getTickerKeys(for: accounts, accountHoldingsMap: accountHoldingsMap)
    }()
    
    public lazy var activeTickersMissingAssetClass: SecurityKeySet = {
        activeSecurities.reduce(into: Set<SecurityKey>()) { set, security in
            guard !security.assetKey.isValid else { return }
            set.insert(security.primaryKey)
        }
    }()

    public lazy var activeTickersMissingSharePrice: SecurityKeySet = {
        activeSecurities.reduce(into: Set<SecurityKey>()) { set, security in
            if let sharePrice = security.sharePrice,
               sharePrice > 0 { return }
            set.insert(security.primaryKey)
        }
    }()

    public lazy var activeTickersMissingSomething: SecurityKeySet = {
        activeTickersMissingSharePrice.union(activeTickersMissingAssetClass)
    }()

    // MARK: - Holdings
    
    // NOTE: includes holdings from all accounts, including those not assigned to a strategy
    // NOTE: may include orphans in fixed
    public lazy var rawHoldings: [MHolding] = {
        let holdings = MHolding.getHoldings(for: model.accounts, accountHoldingsMap: accountHoldingsMap).sorted() // by primaryKey
        return holdings
    }()
    
    public lazy var rawHoldingsSummary: HoldingsSummary = {
        HoldingsSummary.getSummary(rawHoldings, securityMap)
    }()
    
    public lazy var rawHoldingsSummaryMap: AssetHoldingsSummaryMap = {
        HoldingsSummary.getAssetSummaryMap(rawHoldings, securityMap)
    }()

    public lazy var rawHoldingsMap: AssetHoldingsMap = {
        let map = MHolding.getAssetHoldingsMap(rawHoldings, securityMap)
        return map
    }()
    
    public lazy var rawAccountHoldingsMap: AccountHoldingsMap = {
        Dictionary(grouping: rawHoldings, by: { $0.accountKey })
    }()

    public lazy var rawAccountAssetHoldingsSummaryMap: AccountAssetHoldingsSummaryMap = {
        HoldingsSummary.getAccountAssetSummaryMap(accountKeys, accountHoldingsMap, securityMap)
    }()

    public lazy var rawAccountAssetHoldingsMap: AccountAssetHoldingsMap = {
        MHolding.getAccountAssetHoldingsMap(accountKeys: accountKeys,
                                            accountHoldingsMap,
                                            securityMap)
    }()
    
    public lazy var rawAssetTickerHoldingsSummaryMap: AssetTickerHoldingsSummaryMap = {
        let map = HoldingsSummary.getAssetTickerSummaryMap(rawHoldingsMap, securityMap)
        return map
    }()
    
    // MARK: - other
    
    public lazy var colorCodeMap: ColorCodeMap = {
        MAsset.getColorCodeMap(model.assets)
    }()

    public lazy var thirtyDaysBack: Date? = {
        getDaysBackMidnight(daysBack: 30, timestamp: updatedAt, timeZone: timeZone)
    }()
}
