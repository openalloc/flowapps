//
//  HighTypes.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import SimpleTree

import FlowAllocLow
import FlowBase
import AllocData


public typealias AccountAssetAmountMap = [AccountKey: AssetValueMap]
public typealias AccountAssetHoldingsMap = [AccountKey: AssetHoldingsMap]
public typealias AccountReducerMap = [AccountKey: ReducerMap]
public typealias AccountRollupAmountMap = [AccountKey: RollupAmountMap]
public typealias AccountRollupMap = [AccountKey: RollupMap] // when consolidating rebalances
public typealias AccountTickerHoldingsSummaryMap = [AccountKey: TickerHoldingsSummaryMap]
public typealias AccountTickerMap = [AccountKey: AssetTickerMap]
public typealias AssetTxnsMap = [AssetKey: [MTransaction]]
public typealias AssetSalesMap = [AssetKey: [Sale]]
public typealias AssetTickerAmountMap = [AssetKey: TickerAmountMap]
public typealias ClosestTargetMap = [AssetKey: AssetKey]
public typealias DeepRelationsMap = [AssetKey: [AssetKey]]
public typealias DistillationResult = (accepted: AssetHoldingsMap, rejected: AssetHoldingsMap)
public typealias RollupResult = (netAllocMap: AssetValueMap, rollupMap: RollupMap?)
public typealias RecentPurchasesMap = [SecurityKey: [PurchaseInfo]]
public typealias ReducerMap = [ReducerPair: Double]
public typealias RollupAmountMap = [AssetKey: AssetValueMap] // used for consolidating rebalance
public typealias RollupMap = [AssetKey: [AssetKey]] // parent: children
public typealias HighResultOrderFn = (HighResult, HighResult) -> Bool
public typealias HighResultQueue = DistinctLimitedPriorityQueue<HighResult>
public typealias TickerAmountMap = AllocKeyValueMap<MSecurity>
public typealias TrackerSecuritiesMap = [TrackerKey: [MSecurity]]
public typealias AssetGroupMap = [AssetKey: [AssetKey]] // parent: children
