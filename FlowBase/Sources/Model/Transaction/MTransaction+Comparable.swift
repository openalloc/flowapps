//
//  MTransaction+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

// NOTE this is similar to MValuationCashflow's Comparable
// NOTE it ignores transactionID
extension MTransaction: Comparable {
    public static func < (lhs: MTransaction, rhs: MTransaction) -> Bool {      
        if lhs.transactedAt < rhs.transactedAt { return true }
        if lhs.transactedAt > rhs.transactedAt { return false }

        if lhs.accountKey < rhs.accountKey { return true }
        if lhs.accountKey > rhs.accountKey { return false }

        if lhs.securityKey < rhs.securityKey { return true }
        if lhs.securityKey > rhs.securityKey { return false }

        if lhs.shareCount < rhs.shareCount { return true }
        if lhs.shareCount > rhs.shareCount { return false }

        return false
    }
}
    
extension MTransaction.Key: Comparable {
    
    
    public static func < (lhs: MTransaction.Key, rhs: MTransaction.Key) -> Bool {
        if lhs.transactedAt < rhs.transactedAt { return true }
        if lhs.transactedAt > rhs.transactedAt { return false }

        if lhs.accountNormID < rhs.accountNormID { return true }
        if lhs.accountNormID > rhs.accountNormID { return false }

        if lhs.securityNormID < rhs.securityNormID { return true }
        if lhs.securityNormID > rhs.securityNormID { return false }

        if lhs.shareCount < rhs.shareCount { return true }
        if lhs.shareCount > rhs.shareCount { return false }

//        if lhs.sharePrice < rhs.sharePrice { return true }
//        if lhs.sharePrice > rhs.sharePrice { return false }
        return false
    }

}

extension MTransaction.Action: Comparable {
    public static func < (lhs: MTransaction.Action, rhs: MTransaction.Action) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
}

//extension BaseModel {
//    
//    /// sort using the provided comparator, with option to use the comparator in reverse
//    public mutating func sortBy(_ forward: Bool = true, _ comparator: (MTransaction, MTransaction) -> Bool ) {
//        sortByField(forward, \.transactions, comparator)
//    }
//}
