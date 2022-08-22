//
//  MHolding+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MHolding: Comparable {
    public static func < (lhs: MHolding, rhs: MHolding) -> Bool {
        if lhs.primaryKey < rhs.primaryKey { return true }
        if lhs.primaryKey > rhs.primaryKey { return false }
        
        if let la = lhs.acquiredAt, let ra = rhs.acquiredAt {
            if la < ra { return true }
            if la > ra { return false }
        }
        
        if let ls = lhs.shareCount, let rs = rhs.shareCount {
            if ls < rs { return true }
            if ls > rs { return false }
        }

        return false
    }
}

extension MHolding.Key: Comparable {
    
    public static func < (lhs: MHolding.Key, rhs: MHolding.Key) -> Bool {
        if lhs.accountNormID < rhs.accountNormID { return true }
        if lhs.accountNormID > rhs.accountNormID { return false }

        if lhs.securityNormID < rhs.securityNormID { return true }
        if lhs.securityNormID > rhs.securityNormID { return false }
        
        if lhs.lotNormID < rhs.lotNormID { return true }
        if lhs.lotNormID > rhs.lotNormID { return false }

        return false
    }

}
