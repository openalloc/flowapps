//
//  FlowBaseError.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum FlowBaseError: Error, Equatable, CustomStringConvertible {
    case validationFailure(_ msg: String)
    case unrecognizedAssetClass(_ assetID: String)
    case unrecognizedAssetClassForTicker(_ securityID: String, _ assetID: String)
    case unrecognizedStrategy(_ strategyID: String)
    case unrecognizedAccount(_ accountID: String)
    case unrecognizedTicker(_ securityID: String, _ msg: String = "")
    case unrecognizedTracker(_ trackerID: String)
    case unrecognizedSchema(_ schema: String)
    case invalidPrimaryKey(_ msg: String)
    case decodingError(_ msg: String)
    case encodingError(_ msg: String)
    case archiveCreateFailure
    case archiveRestoreFailure
    case invalidPercent(_ val: Double, _ assetID: String?)
    case invalidControlIndex
    case dateCalculationFailure

    public var localizedDescription: String { description }

    public var description: String {
        switch self {
        case let .validationFailure(msg):
            return String("Validation failure: \(msg)")
        case let .unrecognizedAssetClass(assetID):
            return String("Assets does not contain '\(assetID)'.")
        case let .unrecognizedAssetClassForTicker(securityID, assetID):
            return String("Could not find asset class '\(assetID)' for securityID '\(securityID)'.")
        case let .unrecognizedStrategy(strategyID):
            return String("Strategies does not contain '\(strategyID)'.")
        case let .unrecognizedAccount(accountID):
            return String("Accounts does not contain '\(accountID)'.")
        case let .unrecognizedTicker(securityID, msg):
            return String("Securities does not contain '\(securityID)'. \(msg)")
        case let .unrecognizedTracker(trackerID):
            return String("Trackers does not contain '\(trackerID)'.")
        case let .unrecognizedSchema(schema):
            return String("'\(schema)' not a recognized schema.")
        case let .invalidPrimaryKey(msg):
            return String("'\(msg)' not a valid primary key.")
        case let .decodingError(msg):
            return String("Failure to decode. \(msg)")
        case let .encodingError(msg):
            return String("Failure to encode. \(msg)")
        case .archiveCreateFailure:
            return String("Unable to create archive.")
        case .archiveRestoreFailure:
            return String("Unable to restore from archive.")
        case let .invalidPercent(val, assetID):
            return String(format: "Invalid percent %0.1f%% for %@", val * 100.0, assetID ?? "")
        case .invalidControlIndex:
            return String("Invalid priority.")
        case .dateCalculationFailure:
            return String("Failure to calculate date.")
        }
    }
}
