//
//  BaseColumnHeader.swift
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

open class BaseColumnHeader: Identifiable, Hashable {
    public var id: Int { hashValue }
    public var account: MAccount
    public var accountValue: Double
    public var fractionOfStrategy: Double

    public init(account: MAccount, accountValue: Double, fractionOfStrategy: Double) {
        self.account = account
        self.accountValue = accountValue
        self.fractionOfStrategy = fractionOfStrategy
    }

    open func hash(into hasher: inout Hasher) {
        hasher.combine(account)
        hasher.combine(accountValue)
        hasher.combine(fractionOfStrategy)
    }
}

extension BaseColumnHeader: Equatable {
    public static func == (lhs: BaseColumnHeader, rhs: BaseColumnHeader) -> Bool {
        lhs.account == rhs.account
    }
}
