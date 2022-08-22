//
//  MAccount.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

import FlowAllocLow
import FlowBase


public extension MAccount {
    static func getHoldingsPresentValue(_ accountKey: AccountKey, _ accountPresentValueMap: AccountPresentValueMap) -> Double {
        accountPresentValueMap[accountKey] ?? 0
    }

    static func getPresentValue(_ accountKeys: [AccountKey], _ accountPresentValueMap: AccountPresentValueMap) -> Double {
        accountKeys.reduce(0) { $0 + getHoldingsPresentValue($1, accountPresentValueMap) }
    }
}
