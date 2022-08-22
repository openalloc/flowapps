//
//  MAsset+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MAsset: Comparable {
    public static func < (lhs: MAsset, rhs: MAsset) -> Bool {
        lhs._title < rhs._title ||
            (lhs.title == rhs.title && lhs.assetID < rhs.assetID)
    }

    private var _title: String {
        title ?? ""
    }
}

extension MAsset.Key: Comparable {
    
    public static func < (lhs: MAsset.Key, rhs: MAsset.Key) -> Bool {
        if lhs.assetNormID < rhs.assetNormID { return true }
        if lhs.assetNormID > rhs.assetNormID { return false }
        return false
    }

}
