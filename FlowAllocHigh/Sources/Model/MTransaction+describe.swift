//
//  MTransaction+describe.swift
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

public extension MTransaction {
    static func describe(_ strArray: [String]) -> String {
        switch strArray.count {
        case 0:
            return "[]"
        case 1:
            return strArray[0]
        default:
            return "[\(strArray.joined(separator: ", "))]"
        }
    }
}
