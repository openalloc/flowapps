//
//  MRebalanceSale+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MRebalanceSale.Key: Comparable {
    
    public static func < (lhs: MRebalanceSale.Key, rhs: MRebalanceSale.Key) -> Bool {
        if lhs.accountNormID < rhs.accountNormID { return true }
        if lhs.accountNormID > rhs.accountNormID { return false }

        if lhs.securityNormID < rhs.securityNormID { return true }
        if lhs.securityNormID > rhs.securityNormID { return false }
        
        if lhs.lotNormID < rhs.lotNormID { return true }
        if lhs.lotNormID > rhs.lotNormID { return false }

        return false
    }
}
