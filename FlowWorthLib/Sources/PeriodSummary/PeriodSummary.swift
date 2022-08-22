//
//  PeriodSummary.swift
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
import ModifiedDietz

public final class PeriodSummary {
    
    public typealias MD = ModifiedDietz<Double>
    
    let period: DateInterval
    let begPositions: [MValuationPosition]
    let endPositions: [MValuationPosition]
    let cashflows: [MValuationCashflow]
    let accountMap: AccountMap
    
    public init(period: DateInterval,
                begPositions: [MValuationPosition],
                endPositions: [MValuationPosition],
                cashflows: [MValuationCashflow],
                accountMap: AccountMap = [:]) {
        self.period = period
        self.begPositions = begPositions
        self.endPositions = endPositions
        self.cashflows = cashflows
        self.accountMap = accountMap
    }
    
    // MARK: - Market value totals
    
    public lazy var begMarketValue: Double = {
        begPositions.reduce(0) { $0 + $1.marketValue }
    }()
    
    public lazy var endMarketValue: Double = {
        endPositions.reduce(0) { $0 + $1.marketValue }
    }()
    
    public lazy var deltaMarketValue: Double = {
        endMarketValue - begMarketValue
    }()
    
    // % change in market value for the period
    public lazy var singlePeriodReturn: Double? = {
        guard begMarketValue > 0 else { return nil }
        return deltaMarketValue / begMarketValue
    }()
    
    public lazy var annualizedPeriodReturn: Double? = {
        guard let _singlePeriodReturn = singlePeriodReturn else { return nil }
        return _singlePeriodReturn / yearsInPeriod
    }()
    
    public lazy var daysInPeriod: Double = {
        period.duration / 24 / 60 / 60
    }()
    
    public lazy var yearsInPeriod: Double = {
        daysInPeriod / 365.25
    }()
    
    public lazy var marketValueDeltaPerDay: Double = {
        guard daysInPeriod > 0 else { return 0 }
        return deltaMarketValue / daysInPeriod
    }()
    
    public lazy var marketValueDeltaPerYear: Double = {
        marketValueDeltaPerDay * 365.25
    }()
    
    // MARK: - Total Basis
    
    public lazy var begTotalBasis: Double = {
        begPositions.reduce(0) { $0 + $1.totalBasis }
    }()
    
    public lazy var endTotalBasis: Double = {
        endPositions.reduce(0) { $0 + $1.totalBasis }
    }()
    
    public lazy var deltaTotalBasis: Double = {
        endTotalBasis - begTotalBasis
    }()
    
    // % change in basis for the period
    public lazy var singlePeriodBasisReturn: Double? = {
        guard begTotalBasis > 0 else { return nil }
        return deltaTotalBasis / begTotalBasis
    }()
    
    // MARK: - Market Value (AccountValueMap)
    
    public lazy var begAccountMV: AccountValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            map[position.accountKey, default: 0] += position.marketValue
        }
    }()
    
    public lazy var endAccountMV: AccountValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            map[position.accountKey, default: 0] += position.marketValue
        }
    }()
    
    public lazy var begAccountTB: AccountValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            map[position.accountKey, default: 0] += position.totalBasis
        }
    }()
    
    public lazy var endAccountTB: AccountValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            map[position.accountKey, default: 0] += position.totalBasis
        }
    }()
    
    public lazy var accountKeySet: Set<AccountKey> = {
        Set(begAccountMV.keys).union(endAccountMV.keys)
    }()
    
    // MARK: - Market Value (AccountAssetValueMap)
    
    public lazy var begAccountAssetMV: AccountAssetValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            map[position.accountAssetKey] = position.marketValue
        }
    }()
    
    public lazy var endAccountAssetMV: AccountAssetValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            map[position.accountAssetKey] = position.marketValue
        }
    }()
    
    // MARK: - Market Value (AssetValueMap)
    
    public lazy var begAssetMV: AssetValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            map[position.assetKey, default: 0] += position.marketValue
        }
    }()
    
    public lazy var endAssetMV: AssetValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            map[position.assetKey, default: 0] += position.marketValue
        }
    }()
    
    public lazy var begAssetTB: AssetValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            map[position.assetKey, default: 0] += position.totalBasis
        }
    }()
    
    public lazy var endAssetTB: AssetValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            map[position.assetKey, default: 0] += position.totalBasis
        }
    }()
    
    public lazy var assetKeySet: Set<AssetKey> = {
        Set(begAssetMV.keys).union(endAssetMV.keys)
    }()
    
    // MARK: - Market Value (StrategyValueMap)
    
    public lazy var begStrategyMV: StrategyValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            guard let strategyKey = accountMap[position.accountKey]?.strategyKey else { return }
            map[strategyKey, default: 0] += position.marketValue
        }
    }()
    
    public lazy var endStrategyMV: StrategyValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            guard let strategyKey = accountMap[position.accountKey]?.strategyKey else { return }
            map[strategyKey, default: 0] += position.marketValue
        }
    }()
    
    public lazy var begStrategyTB: StrategyValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            guard let strategyKey = accountMap[position.accountKey]?.strategyKey else { return }
            map[strategyKey, default: 0] += position.totalBasis
        }
    }()
    
    public lazy var endStrategyTB: StrategyValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            guard let strategyKey = accountMap[position.accountKey]?.strategyKey else { return }
            map[strategyKey, default: 0] += position.totalBasis
        }
    }()
    
    public lazy var strategyKeySet: Set<StrategyKey> = {
        Set(begStrategyMV.keys).union(endStrategyMV.keys)
    }()
    
    // MARK: - Market Value (StrategyAssetValueMap)
    
    public lazy var begStrategyAssetMV: StrategyAssetValueMap = {
        begPositions.reduce(into: [:]) { map, position in
            guard let strategyAssetKey = position.getStrategyAssetKey(accountMap: accountMap) else { return }
            map[strategyAssetKey] = position.marketValue
        }
    }()
    
    public lazy var endStrategyAssetMV: StrategyAssetValueMap = {
        endPositions.reduce(into: [:]) { map, position in
            guard let strategyAssetKey = position.getStrategyAssetKey(accountMap: accountMap) else { return }
            map[strategyAssetKey] = position.marketValue
        }
    }()
    
    // MARK: - Delta (period change)
    
    public lazy var deltaMV: AccountAssetValueMap = {
        endAccountAssetMV.subtract(begAccountAssetMV)
    }()
    
    public lazy var deltaAssetMV: AssetValueMap = {
        deltaMV.reduce(into: [:]) { map, entry in
            map[entry.key.assetKey, default: 0] += entry.value
        }
    }()
    
    public lazy var deltaAccountMV: AccountValueMap = {
        deltaMV.reduce(into: [:]) { map, entry in
            map[entry.key.accountKey, default: 0] += entry.value
        }
    }()
    
    // MARK: - Dietz (period performance)
    
    public lazy var dietz: MD? = {
        MD(period, dietzMV, dietzCF)
    }()
    
    public lazy var assetDietz: [AssetKey: MD] = {
        assetKeySet.reduce(into: [:]) { map, assetKey in
            guard let mv = dietzAssetMV[assetKey],
                  let cf = dietzAssetCF[assetKey],
                  let md = MD(period, mv, cf)
            else { return }
            map[assetKey] = md
        }
    }()
    
    public lazy var accountDietz: [AccountKey: MD] = {
        accountKeySet.reduce(into: [:]) { map, accountKey in
            guard let mv = dietzAccountMV[accountKey],
                  let cf = dietzAccountCF[accountKey] else { return }
            map[accountKey] = MD(period, mv, cf)
        }
    }()
    
    public lazy var strategyDietz: [StrategyKey: MD] = {
        strategyKeySet.reduce(into: [:]) { map, strategyKey in
            guard let mv = dietzStrategyMV[strategyKey],
                  let cf = dietzStrategyCF[strategyKey] else { return }
            map[strategyKey] = MD(period, mv, cf)
        }
    }()
    
    // MARK: - Dietz Maps (total, and by account and asset class)
    
    internal lazy var dietzMV: MD.MarketValueDelta = {
        MD.MarketValueDelta(start: begMarketValue, end: endMarketValue)
    }()
    
    internal lazy var dietzCF: MD.CashflowMap = {
        cashflows.reduce(into: [:]) { map, cashflow in
            map[cashflow.transactedAt, default: 0] += cashflow.amount
        }
    }()
    
    internal lazy var dietzAccountMV: [AccountKey: MD.MarketValueDelta] = {
        accountKeySet.reduce(into: [:]) { map, accountKey in
            let beg = begAccountMV[accountKey] ?? 0
            let end = endAccountMV[accountKey] ?? 0
            map[accountKey] = MD.MarketValueDelta(start: beg, end: end)
        }
    }()
    
    internal lazy var dietzAccountCF: [AccountKey: MD.CashflowMap] = {
        cashflows.reduce(into: [:]) { map, cashflow in
            let accountKey = cashflow.accountKey
            var cfMap: MD.CashflowMap = map[accountKey, default: [:]]
            cfMap[cashflow.transactedAt, default: 0] += cashflow.amount
            map[accountKey] = cfMap
        }
    }()
    
    internal lazy var dietzAssetMV: [AssetKey: MD.MarketValueDelta] = {
        assetKeySet.reduce(into: [:]) { map, assetKey in
            let beg = begAssetMV[assetKey] ?? 0
            let end = endAssetMV[assetKey] ?? 0
            map[assetKey] = MD.MarketValueDelta(start: beg, end: end)
        }
    }()
    
    internal lazy var dietzAssetCF: [AssetKey: MD.CashflowMap] = {
        cashflows.reduce(into: [:]) { map, cashflow in
            let assetKey = cashflow.assetKey
            var cfMap: MD.CashflowMap = map[assetKey, default: [:]]
            cfMap[cashflow.transactedAt, default: 0] += cashflow.amount
            map[assetKey] = cfMap
        }
    }()
    
    internal lazy var dietzStrategyMV: [StrategyKey: MD.MarketValueDelta] = {
        strategyKeySet.reduce(into: [:]) { map, strategyKey in
            let beg = begStrategyMV[strategyKey] ?? 0
            let end = endStrategyMV[strategyKey] ?? 0
            map[strategyKey] = MD.MarketValueDelta(start: beg, end: end)
        }
    }()
    
    internal lazy var dietzStrategyCF: [StrategyKey: MD.CashflowMap] = {
        cashflows.reduce(into: [:]) { map, cashflow in
            let accountKey = cashflow.accountKey
            guard let strategyKey = accountMap[accountKey]?.strategyKey else { return }
            var cfMap: MD.CashflowMap = map[strategyKey, default: [:]]
            cfMap[cashflow.transactedAt, default: 0] += cashflow.amount
            map[strategyKey] = cfMap
        }
    }()
}
