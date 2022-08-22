//
//  BaseDataTypes.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData
import SimpleTree

public struct ColumnInfo {
    public var columnName: String
    public var isRequired: Bool

    public init(columnName: String, isRequired: Bool) {
        self.columnName = columnName
        self.isRequired = isRequired
    }
}

public typealias AllocKeyValueMap<T: AllocKeyed> = [T.Key: Double]
public typealias AllocKeyValuesMap<T: AllocKeyed> = [T.Key: [Double]]
public typealias AllocKeyMap<T: AllocKeyed> = [T.Key: T]

public typealias AccountAssetHoldingsMap = [AccountKey: AssetHoldingsMap]
public typealias AccountAssetHoldingsSummaryMap = [AccountKey: AssetHoldingsSummaryMap]
public typealias AccountAssetValuesMap = [AccountKey: [AssetValue]]
public typealias AccountHoldingsMap = [AccountKey: [MHolding]]
public typealias AccountHoldingsSummaryMap = [AccountKey: HoldingsSummary]
public typealias AccountID = String // aka 'account number'
public typealias AccountKey = MAccount.Key
public typealias AccountKeySet = Set<AccountKey>
public typealias AccountMap = AllocKeyMap<MAccount>
public typealias AccountValueMap = AllocKeyValueMap<MAccount>
public typealias AssetHoldingsMap = [AssetKey: [MHolding]]
public typealias AssetHoldingsSummaryMap = [AssetKey: HoldingsSummary]
public typealias AssetID = String // aka 'asset class'
public typealias AssetKey = MAsset.Key
public typealias AssetKeySet = Set<AssetKey>
public typealias AssetKeyTree = SimpleTree<AssetKey>
public typealias AssetMap = AllocKeyMap<MAsset>
public typealias AssetTickerHoldingsSummaryMap = [AssetKey: TickerHoldingsSummaryMap]
public typealias AssetValueMap = AllocKeyValueMap<MAsset>
public typealias LotID = String
public typealias SecurityID = String // aka 'ticker'
public typealias SecurityKey = MSecurity.Key
public typealias SecurityKeySet = Set<SecurityKey>
public typealias SecurityMap = AllocKeyMap<MSecurity>
public typealias SnapshotID = String // UUIDstring
public typealias SnapshotKey = MValuationSnapshot.Key
public typealias SnapshotMap = AllocKeyMap<MValuationSnapshot>
public typealias StrategyAccountKeySetMap = [StrategyKey: Set<AccountKey>]
public typealias StrategyAccountsMap = [StrategyKey: [MAccount]]
public typealias StrategyAssetValuesMap = [StrategyKey: [AssetValue]]
public typealias StrategyID = String
public typealias StrategyKey = MStrategy.Key
public typealias StrategyMap = AllocKeyMap<MStrategy>
public typealias StrategyValueMap = AllocKeyValueMap<MStrategy>
public typealias TickerHoldingsSummaryMap = [SecurityKey: HoldingsSummary]
public typealias TickerShareMap = AllocKeyValueMap<MSecurity>
public typealias TrackerAltMap = [TrackerKey: MTracker]
public typealias TrackerID = String
public typealias TrackerKey = MTracker.Key
public typealias TrackerMap = AllocKeyMap<MTracker>
public typealias TransactionKey = MTransaction.Key
public typealias TransactionMap = AllocKeyMap<MTransaction>

