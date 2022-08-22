//
//  MSecurity+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MSecurity: Comparable {
    public static func < (lhs: MSecurity, rhs: MSecurity) -> Bool {
        lhs.securityID < rhs.securityID
    }
}

extension MSecurity.Key: Comparable {
    
    public static func < (lhs: MSecurity.Key, rhs: MSecurity.Key) -> Bool {
        if lhs.securityNormID < rhs.securityNormID { return true }
        if lhs.securityNormID > rhs.securityNormID { return false }
        return false
    }
}
