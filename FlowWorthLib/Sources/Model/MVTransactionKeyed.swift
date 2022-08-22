//
//  MVTransactionKeyed.swift
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

public protocol MVTransactionKeyed {
    var mvTransactionKey: MVTransactionKey { get }
}

public struct MVTransactionKey: Hashable {
    let accountNormID: String
    let assetNormID: String
    let transactedAt: Date
    
    public init(accountID: AccountID,
                assetID: AssetID,
                transactedAt: Date) {
        self.accountNormID = MHolding.normalizeID(accountID)
        self.assetNormID = MHolding.normalizeID(assetID)
        self.transactedAt = transactedAt
    }
}

extension MVTransactionKeyed {
    static func getMVTransactionKeyMap<T: MVTransactionKeyed>(_ elements: [T]) -> [MVTransactionKey: [T]] {
        elements.reduce(into: [:]) { map, element in
            map[ element.mvTransactionKey, default: [] ].append(element)
        }
    }
}
