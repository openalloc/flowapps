//
//  MValuationPosition+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MValuationPosition: Comparable {
    public static func < (lhs: MValuationPosition, rhs: MValuationPosition) -> Bool {
        if lhs.primaryKey < rhs.primaryKey { return true }
        if lhs.primaryKey > rhs.primaryKey { return false }
        
        if lhs.marketValue < rhs.marketValue { return true }
        if lhs.marketValue > rhs.marketValue { return false }

        return false
    }
}

extension MValuationPosition.Key: Comparable {
    
    public static func < (lhs: MValuationPosition.Key, rhs: MValuationPosition.Key) -> Bool {
        if lhs.snapshotNormID < rhs.snapshotNormID { return true }
        if lhs.snapshotNormID > rhs.snapshotNormID { return false }

        if lhs.accountNormID < rhs.accountNormID { return true }
        if lhs.accountNormID > rhs.accountNormID { return false }

        if lhs.assetNormID < rhs.assetNormID { return true }
        if lhs.assetNormID > rhs.assetNormID { return false }

        return false
    }

}
