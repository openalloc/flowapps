//
//  BaseTable.swift
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


open class BaseTable {
    public var context: LowContext?
    public var params: BaseParams // contains ordering of accounts and assetclasses
    public var accountAllocMap: AccountAssetValueMap

    public init(context: LowContext?,
                params: BaseParams,
                accountAllocMap: AccountAssetValueMap)
    {
        self.context = context
        self.params = params
        self.accountAllocMap = accountAllocMap
    }

    open var accounts: [MAccount] {
        guard let ax = context else { return [] }
        return ax.activeAccounts
    }

    open var allocs: [AssetValue] {
        guard let ax = context else { return [] }
        return ax.baseAllocs
    }

    open var rows: [BaseRow] {
        guard let ax = context else { return [] }

        let totalValue = ax.baseAccountPresentValueMap.values.reduce(0) { $0 + $1 }

        return assetKeyTargetPcts.map { assetKey, targetPct in

            let colorCode = ax.colorCodeMap[assetKey] ?? 0

            let allocationItems: [BaseItem] = accountKeyAllocationMaps.map { accountKey, allocMap in

                let allocatedPct = allocMap[assetKey] ?? 0
                let alloc = AssetValue(assetKey, allocatedPct)
                let accountValue = ax.baseAccountPresentValueMap[accountKey] ?? 0
                let allocatedValue = accountValue * allocatedPct

                let holdingsSummaryMap = ax.baseAccountHoldingsSummaryMap[accountKey] ?? [:]
                let holdingsSummary = holdingsSummaryMap[assetKey] ?? HoldingsSummary()

                return BaseItem(accountKey: accountKey,
                                alloc: alloc,
                                holdingsSummary: holdingsSummary,
                                allocatedValue: allocatedValue,
                                colorCode: colorCode)
            }

            let allocatedTotalValue = targetPct * totalValue

            return BaseRow(assetKey: assetKey,
                           targetPct: targetPct,
                           allocatedValue: allocatedTotalValue,
                           cells: allocationItems,
                           colorCode: colorCode)
        }
    }

    open var headerCells: [BaseColumnHeader] {
        guard let ax = context else { return [] }
        let totalValue = ax.baseAccountPresentValueMap.values.reduce(0) { $0 + $1 }
        let orderedAccounts = params.accountKeys.compactMap { ax.strategiedAccountMap[$0] }
        return orderedAccounts.map {
            let accountValue = ax.baseAccountPresentValueMap[$0.primaryKey] ?? 0
            return BaseColumnHeader(account: $0,
                                    accountValue: accountValue,
                                    fractionOfStrategy: accountValue / totalValue)
        }
    }

    private var assetKeyTargetPcts: [(AssetKey, Double)] {
        guard let ax = context else { return [] }
        let assetKeys = params.assetKeys
        let targetPcts = assetKeys.compactMap { ax.baseAllocMap[$0] }
        return Array(zip(assetKeys, targetPcts))
    }

    private var accountKeyAllocationMaps: [(AccountKey, AssetValueMap)] {
        let accountKeys = params.accountKeys
        let maps: [AssetValueMap] = accountKeys.compactMap { accountAllocMap[$0] }
        return Array(zip(accountKeys, maps))
    }
}

extension BaseTable: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(params)
        hasher.combine(accountAllocMap)
    }
}

extension BaseTable: Equatable {
    public static func == (lhs: BaseTable, rhs: BaseTable) -> Bool {
        lhs.params == rhs.params &&
            lhs.accountAllocMap == rhs.accountAllocMap
    }
}
