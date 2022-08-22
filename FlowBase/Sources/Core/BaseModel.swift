//
//  BaseModel.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

public struct BaseModel: Identifiable, Codable {
    
    public var id: UUID
    public var updatedAt: Date

    public var accounts: [MAccount]
    public var allocations: [MAllocation]
    public var strategies: [MStrategy]
    public var assets: [MAsset]
    public var securities: [MSecurity]
    public var holdings: [MHolding]
    public var trackers: [MTracker]
    public var caps: [MCap]
    public var transactions: [MTransaction]
    public var valuationSnapshots: [MValuationSnapshot]
    public var valuationPositions: [MValuationPosition]
    public var valuationCashflows: [MValuationCashflow]

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case updatedAt
        case accounts
        case allocations
        case strategies
        case assets
        case securities
        case holdings
        case trackers
        case caps
        case transactions
        case valuationSnapshots
        case valuationPositions
        case valuationCashflows
    }

    public init(id: UUID = UUID(),
                updatedAt: Date? = nil,
                accounts: [MAccount] = [],
                allocations: [MAllocation] = [],
                strategies: [MStrategy] = [],
                assets: [MAsset] = [],
                securities: [MSecurity] = [],
                holdings: [MHolding] = [],
                trackers: [MTracker] = [],
                caps: [MCap] = [],
                transactions: [MTransaction] = [],
                valuationSnapshots: [MValuationSnapshot] = [],
                valuationPositions: [MValuationPosition] = [],
                valuationCashflows: [MValuationCashflow] = [])
    {
        self.id = id
        self.updatedAt = updatedAt ?? Date()

        self.accounts = accounts
        self.allocations = allocations
        self.strategies = strategies
        self.assets = assets
        self.securities = securities
        self.holdings = holdings
        self.trackers = trackers
        self.caps = caps
        self.transactions = transactions
        self.valuationSnapshots = valuationSnapshots
        self.valuationPositions = valuationPositions
        self.valuationCashflows = valuationCashflows
    }
}

// NOTE intentionally excluding updatedAt from equatable for now
extension BaseModel: Equatable {
    public static func == (lhs: BaseModel, rhs: BaseModel) -> Bool {
        lhs.id == rhs.id
    }
}
