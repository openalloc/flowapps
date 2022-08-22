//
//  AssetValue+Describe.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import FlowBase
import AllocData

public extension AssetValue {
    enum DescribeStyle {
        case percent0
        case percent1
        case percent2
        case currency0
        case currency2
        case format0
        case format1
        case format2
        case format3
        case general
    }

    // single AssetValue struct
    static func describe(_ av: AssetValue, style: DescribeStyle = .general) -> String {
        let formattedValue = format(av.value, style: style)
        return "\(av.assetKey): \(formattedValue)"
    }

    static func format(_ value: Double, style: DescribeStyle = .general) -> String {
        switch style {
        case .percent0:
            return value.percent0()
        case .percent1:
            return value.percent1()
        case .percent2:
            return value.percent2()
        case .currency0:
            return value.currency0()
        case .currency2:
            return value.currency2()
        case .format0:
            return value.format0()
        case .format1, .general:
            return value.format1()
        case .format2:
            return value.format2()
        case .format3:
            return value.format3()
        }
    }

    // array of AssetValue structs
    static func describe(_ assetValues: [AssetValue], prefix: String? = nil, style: DescribeStyle = .general) -> String {
        let formattedValues = assetValues.sorted().map { describe($0, style: style) }
        let formattedValuesJoined = formattedValues.joined(separator: ", ")
        if let prefix_ = prefix {
            let formattedSum = format(sumOf(assetValues), style: style)
            return "\(prefix_) [\(formattedSum)]: \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }

    // dictionary of AssetValue structs, keyed by String
    static func describe(_ assetValueDict: [String: AssetValue], prefix: String? = nil, style: DescribeStyle = .general, separator: String = "; ") -> String {
        let formattedValues: [String] = assetValueDict.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            array.append("\(entry.key): \(AssetValue.describe(entry.value, style: style))")
        }
        let formattedValuesJoined = formattedValues.joined(separator: separator)
        if let prefix_ = prefix {
            let formattedSum = format(sumOf(assetValueDict), style: style)
            return "\(prefix_) [\(formattedSum)]: \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }

    // single AssetValueMap, or [AssetKey: Value]
    static func describe(_ assetValueMap: AssetValueMap, prefix: String? = nil, style: DescribeStyle = .general) -> String {
        let formattedValues: [String] = assetValueMap.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            let av = AssetValue(entry.key, entry.value)
            array.append(AssetValue.describe(av, style: style))
        }
        let formattedValuesJoined = formattedValues.joined(separator: ", ")
        if let prefix_ = prefix {
            let formattedSum = format(sumOf(assetValueMap), style: style)
            return "\(prefix_) [\(formattedSum)]: \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }
}
