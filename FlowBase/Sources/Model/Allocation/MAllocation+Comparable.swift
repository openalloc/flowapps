//
//  MAllocation+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MAllocation.Key: Comparable {
    public static func < (lhs: MAllocation.Key, rhs: MAllocation.Key) -> Bool {
        if lhs.strategyNormID < rhs.strategyNormID { return true }
        if lhs.strategyNormID > rhs.strategyNormID { return false }

        if lhs.assetNormID < rhs.assetNormID { return true }
        if lhs.assetNormID > rhs.assetNormID { return false }
        
        return false
    }
}
