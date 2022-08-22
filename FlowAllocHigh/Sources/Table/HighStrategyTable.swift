//
//  HighStrategyTable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase


public struct HighStrategyTable {
    public var rows: [HighRow]
    public var headerCells: [BaseColumnHeader] // TODO: rename to items
    public var fixedHeaderCells: [BaseColumnHeader] // TODO: rename to items

    internal init(rows: [HighRow] = [],
                  headerCells: [BaseColumnHeader] = [],
                  fixedHeaderCells: [BaseColumnHeader] = [])
    {
        self.rows = rows
        self.headerCells = headerCells
        self.fixedHeaderCells = fixedHeaderCells
    }

    public static func create(context: HighContext? = nil,
                              params: BaseParams = BaseParams(),
                              accountAllocMap: AccountAssetValueMap = AccountAssetValueMap()) -> HighStrategyTable
    {
        //print("HighTable.create accountKeys=\(params.accountKeys)")

        guard let ax = context else { return HighStrategyTable() }

        let variableKeys = params.accountKeys // not ax.variableAccountKeys
        let headerCells = getHeaderCells(ax, variableKeys)
        let fixedHeaderCells = getHeaderCells(ax, params.fixedAccountKeys)

        let rows = HighStrategyTable.getRows(ax, params, accountAllocMap)

        return HighStrategyTable(rows: rows,
                                  headerCells: headerCells,
                                  fixedHeaderCells: fixedHeaderCells)
    }

    private static func getRows(_ ax: HighContext,
                                _ params: BaseParams,
                                _ accountAllocMap: AccountAssetValueMap) -> [HighRow]
    {
        // ordered by params, which may not have all the assetKeys needed
        // (the getAllocs function will append them to the end)
        let netAllocs = AssetValue.getAssetValues(from: ax.netAllocMap, orderBy: params.assetKeys)

        return netAllocs.map { netAlloc in

            let assetKey = netAlloc.assetKey
            let colorCode = ax.colorCodeMap[assetKey] ?? 0

            let variableMaps = getAccountMaps(params.accountKeys, accountAllocMap)
            let variableItems: [BaseItem] = variableMaps.map { accountKey, allocMap in
                HighStrategyTable.getCell(ax, assetKey, colorCode, accountKey, allocMap)
            }
            let variableTargetPct = ax.variableAllocMap[assetKey] ?? 0.0
            let variableValue = ax.netVariableAssetAmountMap[assetKey] ?? 0.0 // netAlloc.targetPct * totalValue

            let fixedMaps = getAccountMaps(params.fixedAccountKeys, ax.fixedAccountAllocationMap)
            let fixedItems: [HighFixedItem] = fixedMaps.map { accountKey, allocMap in
                HighStrategyTable.getFixedCell(ax, assetKey, colorCode, accountKey, allocMap)
            }

            return HighRow(assetKey: assetKey,
                            targetPct: variableTargetPct,
                            allocatedValue: variableValue,
                            cells: variableItems,
                            colorCode: colorCode,
                            netAlloc: netAlloc,
                            fixedCells: fixedItems)
        }
    }

    private static func getHeaderCells(_ ax: HighContext,
                                       _ accountKeys: [AccountKey]) -> [BaseColumnHeader]
    {
        let totalValue = ax.netCombinedTotal
        // //print("\(#function) \(totalValue.format0())")
        return accountKeys.compactMap {
            guard let account = ax.strategiedAccountMap[$0]
            else { return nil }
            let amount: Double = ax.accountAllocatingValueMap[$0] ?? 0 // okay if account isn't allocating (show it regardless)
            // //print("\(#function) \($0) \(amount.format0())")
            return BaseColumnHeader(account: account,
                                    accountValue: amount,
                                    fractionOfStrategy: amount / totalValue)
        }
    }

    private static func getAccountMaps(_ accountKeys: [AccountKey],
                                       _ accountAllocMap: AccountAssetValueMap) -> [(AccountKey, AssetValueMap)]
    {
        let maps: [AssetValueMap] = accountKeys.compactMap { accountAllocMap[$0] }
        return Array(zip(accountKeys, maps))
    }

    private static func getCell(_ ax: HighContext,
                                _ assetKey: AssetKey,
                                _ colorCode: Int,
                                _ accountKey: AccountKey,
                                _ allocMap: AssetValueMap) -> BaseItem
    {
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

    private static func getFixedCell(_ ax: HighContext,
                                     _ assetKey: AssetKey,
                                     _ colorCode: Int,
                                     _ accountKey: AccountKey,
                                     _ allocMap: AssetValueMap) -> HighFixedItem
    {
        // //print("\(#function) \(assetKey)")
        let orphanedValue = ax.fixedOrphanedMap[accountKey]?[assetKey] ?? 0
        let allocatedValue = ax.fixedAllocatedMap[accountKey]?[assetKey] ?? 0

        let allocatedPct = allocMap[assetKey] ?? 0
        // let accountValue = ax.accountPresentValueMap[accountKey] ?? 0
        // let allocatedValue = accountValue * allocatedPct
        let alloc = AssetValue(assetKey, allocatedPct)

        let holdingsSummaryMap = ax.baseAccountHoldingsSummaryMap[accountKey] ?? [:]
        let holdingsSummary = holdingsSummaryMap[assetKey] ?? HoldingsSummary()

        return HighFixedItem(accountKey: accountKey,
                              alloc: alloc,
                              holdingsSummary: holdingsSummary,
                              allocatedValue: allocatedValue,
                              colorCode: colorCode,
                              orphanedValue: orphanedValue)
    }
}
