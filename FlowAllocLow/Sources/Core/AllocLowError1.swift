//
//  AllocLowError1.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

//TODO combine with AllocLowError2
public enum AllocLowError1: Error, Equatable, CustomStringConvertible {
    case invalidFlowValues(_ msg: String)
    case unableToGetMidpoint
    case invalidLimits
    case unexpectedResult(_ msg: String)
    case userLimitExceededUnderStrict
    case missingVertLimit
    case missingAssetLimit

    public var localizedDescription: String { description }

    public var description: String {
        switch self {
        case let .invalidFlowValues(msg):
            return String("Invalid flow values: \(msg)")
        case let .unexpectedResult(msg):
            return String("Unexpected result: \(msg)")
        case .unableToGetMidpoint:
            return String("Unable to calculate midpoint.")
        case .invalidLimits:
            return String("Must allow non-zero allocation in account.")
        default:
            return String("Other error.")
        }
    }
}
