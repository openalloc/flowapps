//
//  MAccount+Comparable.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MAccount: Comparable {
    public static func < (lhs: MAccount, rhs: MAccount) -> Bool {
        lhs._title < rhs._title ||
            (lhs.title == rhs.title && lhs.accountID < rhs.accountID)
    }

    private var _title: String {
        title ?? ""
    }
}

extension MAccount.Key: Comparable {
    public static func < (lhs: MAccount.Key, rhs: MAccount.Key) -> Bool {
        lhs.accountNormID < rhs.accountNormID
    }
}
