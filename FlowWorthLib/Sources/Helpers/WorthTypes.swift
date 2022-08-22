//
//  WorthTypes.swift
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

public typealias AccountAssetPositionsMap = [AccountAssetKey : [MValuationPosition]]
public typealias AccountAssetCashflowsMap = [AccountAssetKey : [MValuationCashflow]]
public typealias AccountAssetValueMap = [AccountAssetKey: Double]
public typealias AccountCashflowsMap = [AccountKey: [MValuationCashflow]]
public typealias AccountFilteredMap = [AccountKey: Bool]
public typealias AccountHistoryMap = [AccountKey: [MTransaction]]
public typealias AccountHoldingsMap = [AccountKey: [MHolding]]
public typealias AccountKeyFilter = (AccountKey) -> Bool
public typealias AccountPositionsMap = [AccountKey: [MValuationPosition]]
public typealias AccountValuesMap = AllocKeyValuesMap<MAccount>
public typealias AssetCashflowsMap = [AssetKey: [MValuationCashflow]]
public typealias AssetHoldingsMap = [AssetKey: [MHolding]]
public typealias AssetKeyFilter = (AssetKey) -> Bool
public typealias AssetPositionKeyFilter = (MValuationPosition) -> AssetKey
public typealias AssetPositionsMap = [AssetKey: [MValuationPosition]]
public typealias AssetValuesMap = AllocKeyValuesMap<MAsset>
public typealias CashflowKey = MValuationCashflow.Key
public typealias CashflowMap = [CashflowKey: MValuationCashflow]
public typealias DateIntervalSnapshotKeyMap = [DateInterval: SnapshotKey]
public typealias ExtentTuple = (negative: Double, positive: Double)
public typealias HPositionHoldingMap = [HPositionKey: MHolding]   // merged holdings
public typealias HPositionHoldingsMap = [HPositionKey: [MHolding]]
public typealias HPositionTxnsMap = [HPositionKey: [MTransaction]]
public typealias HPositionValueMap = [HPositionKey: Double]
public typealias PositionFilter = (MValuationPosition) -> Bool
public typealias PositionKeyFilter<T: AllocKeyed> = (MValuationPosition) -> T.Key
public typealias PositionsMap<T: AllocKeyed> = [T.Key: [MValuationPosition]]
public typealias SnapshotCashflowsMap = [SnapshotKey: [MValuationCashflow]]
public typealias SnapshotDateIntervalMap = [SnapshotKey: DateInterval]
public typealias SnapshotKeyDateIntervalTuple = (snapshotKey: SnapshotKey, dateInterval: DateInterval)
public typealias SnapshotPositionsMap = [SnapshotKey: [MValuationPosition]]
public typealias SnapshotValueMap = AllocKeyValueMap<MValuationSnapshot>
public typealias StrategyAssetValueMap = [StrategyAssetKey: Double]
public typealias StrategyCashflowsMap = [StrategyKey: [MValuationCashflow]]
public typealias StrategyKeyFilter = (StrategyKey) -> Bool
public typealias StrategyPositionsMap = [StrategyKey: [MValuationPosition]]
public typealias StrategyValuesMap = AllocKeyValuesMap<MStrategy>
public typealias TransactionKeySet = Set<TransactionKey>
public typealias ValuationTransactionFilter = (MTransaction) -> Bool


