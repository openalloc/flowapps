//
//  Reducer+Describe.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowAllocLow
import FlowBase

public extension ReducerPair {
    static func describe(_ av: ReducerPair) -> String {
        return "\(av.left):\(av.right)"
    }

    // [ReducerPair: Double]
    static func describe(_ reducerMap: ReducerMap, prefix: String? = nil) -> String {
        let formattedValues: [String] = reducerMap.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            let formattedValue = "\(describe(entry.key)): \(entry.value.currency0())"
            array.append(formattedValue)
        }
        let formattedValuesJoined = formattedValues.joined(separator: ", ")
        if let prefix_ = prefix {
            return "\(prefix_): \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }

    // [String: [ReducerPair: Double]]
    static func describe(_ reducerMapDict: [String: ReducerMap], prefix: String? = nil, separator: String = "; ") -> String {
        let formattedValues: [String] = reducerMapDict.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            array.append("\(entry.key): \(describe(entry.value))")
        }
        let formattedValuesJoined = formattedValues.joined(separator: separator)
        if let prefix_ = prefix {
            return "\(prefix_): \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }
}
