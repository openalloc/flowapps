//
//  MTransaction+Action.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData

extension MTransaction.Action {
    
    /// NOTE not using CustomStringConvertible and description, because that screws with encoding.
    public var displayDescription: String {
        switch self {
        case .buysell:
            return "Buy/Sell"
        case .income:
            return "Income"
        case .transfer:
            return "Transfer"
        case .miscflow:
            return "Misc Flow"
        }
    }
}
