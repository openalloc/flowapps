//
//  MStrategy+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


extension MStrategy: Comparable {
    public static func < (lhs: MStrategy, rhs: MStrategy) -> Bool {
        lhs._title < rhs._title ||
            (lhs.title == rhs.title && lhs.strategyID < rhs.strategyID)
    }

    private var _title: String {
        title ?? ""
    }
}

extension MStrategy.Key: Comparable {
    
    public static func < (lhs: MStrategy.Key, rhs: MStrategy.Key) -> Bool {
        if lhs.strategyNormID < rhs.strategyNormID { return true }
        if lhs.strategyNormID > rhs.strategyNormID { return false }
        return false
    }
}
