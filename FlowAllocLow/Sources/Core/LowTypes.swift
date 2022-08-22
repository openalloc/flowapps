//
//  LowTypes.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import AllocData

import FlowBase


public typealias AccountAmountMap = [AccountKey: Double]
public typealias AccountAssetValueMap = [AccountKey: AssetValueMap]
public typealias AccountCapacitiesMap = [AccountKey: Double]
public typealias AccountCapsMap = [AccountKey: [MCap]]
public typealias AccountPresentValueMap = [AccountKey: Double]
public typealias AccountPurchasesMap = [AccountKey: [Purchase]]
public typealias AccountRebalanceMap = [AccountKey: RebalanceMap]
public typealias AccountSalesMap = [AccountKey: [Sale]]
public typealias AccountUserAssetLimitMap = [AccountKey: UserAssetLimitMap]
public typealias AccountUserVertLimitMap = [AccountKey: UserVertLimitMap]
public typealias AllocationMap = [AssetKey: MAllocation]
public typealias AccountLimitMap = [AccountKey: Double]
public typealias AssetAccountLimitMap = [AssetKey: AccountLimitMap]
public typealias AssetTickerMap = [AssetKey: SecurityKeySet]
public typealias LimitPctMap = [AssetKey: Double]
public typealias PurchaseMap = [AssetKey: Purchase]
public typealias RebalanceMap = [AssetKey: Double]
public typealias SaleMap = [AssetKey: Sale]
public typealias SecurityAssetMap = [SecurityKey: AssetKey]
public typealias StrategyAllocationsMap = [StrategyKey: [MAllocation]]
public typealias StrategyAssetValuesMap = [StrategyKey: [AssetValue]]
public typealias UserAssetLimitMap = [AssetKey: Double]
public typealias UserVertLimitMap = [AssetKey: Double]
