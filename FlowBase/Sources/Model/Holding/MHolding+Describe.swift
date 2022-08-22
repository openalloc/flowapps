//
//  MHolding+Describe.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import AllocData


public extension MHolding {
    func describe(_ securityMap: SecurityMap) -> String {
        var buffer = [String]()
        buffer.append(accountID)
        buffer.append(securityID)
        if lotID != "" {
            buffer.append(lotID)
        }
        if let shareCount_ = shareCount {
            buffer.append("\(shareCount_.format3()) shares")
        }
        if let shareBasis_ = shareBasis {
            buffer.append("\(shareBasis_.currency2())/sh")
        }
        if let pv = getPresentValue(securityMap) {
            buffer.append("pv=\(pv.currency0())")
        }
        if let gl = getGainLoss(securityMap) {
            buffer.append("gl=\(gl.currency0())")
        }
        return buffer.joined(separator: " ")
    }

    static func describe(_ holdings: [MHolding], _ securityMap: SecurityMap, prefix: String? = nil, separator: String = ", ") -> String {
        var buffer = [String]()
        holdings.forEach { buffer.append($0.describe(securityMap)) }
        let formattedValuesJoined = buffer.joined(separator: separator)
        if let prefix_ = prefix {
            return "\(prefix_): \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }

    static func describe(_ assetHoldingsMap: AssetHoldingsMap, securityMap: SecurityMap, prefix: String? = nil) -> String {
        let formattedValues: [String] = assetHoldingsMap.sorted(by: { $0.key < $1.key }).reduce(into: []) { array, entry in
            let formattedValue = "\(entry.key): \(describe(entry.value, securityMap))"
            array.append(formattedValue)
        }
        let formattedValuesJoined = formattedValues.joined(separator: ", ")
        if let prefix_ = prefix {
            return "\(prefix_): \(formattedValuesJoined)"
        }
        return formattedValuesJoined
    }
}
