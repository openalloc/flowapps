//
//  WorthError.swift
//
// Copyright 2021, 2022  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public enum WorthError: Error, Equatable, CustomStringConvertible {
    case missingTxns(_ dict: AccountAssetValueMap)
    case missingSnapshot(_ msg: String)
    case transactionOutOfRange(_ msg: String)
    case invalidPositionOrder(_ msg: String)
    case invalidSecurity(_ securityID: String)
    case invalidAssetClass(_ securityID: String)
    case invalidShareBasis(_ securityID: String)
    case invalidShareCount(_ securityID: String)
    case invalidAccount(_ msg: String)
    case invalidPosition(_ msg: String)
    case invalidTransaction(_ msg: String)
    case cannotCreateSnapshot(_ msg: String)
    case reconcileFailure(_ msg: String)

    static let df = ISO8601DateFormatter()
    
    public var localizedDescription: String { description }

    public var description: String {
        switch self {
        case let .missingTxns(dict):
            return String("Missing transaction(s). Net market values do not reconcile: \(dict)")
        case let .missingSnapshot(msg):
            return String("Missing snapshot. \(msg)")
        case let .transactionOutOfRange(msg):
            return String("Transaction dates must fall within the position range. \(msg)")
        case let .invalidPositionOrder(msg):
            return String("Invalid position order. \(msg)")
        case let .invalidSecurity(securityID):
            return String("Invalid security: \(securityID)")
        case let .invalidAssetClass(securityID):
            return String("Invalid asset class for security: \(securityID)")
        case let .invalidShareBasis(securityID):
            return String("Invalid share basis for holding: \(securityID)")
        case let .invalidShareCount(securityID):
            return String("Invalid share count for holding: \(securityID)")
        case let .invalidAccount(msg):
            return String("Invalid account: \(msg)")
        case let .invalidPosition(msg):
            return String("Invalid position: \(msg)")
        case let .invalidTransaction(msg):
            return String("Invalid transaction: \(msg)")
        case let .cannotCreateSnapshot(msg):
            return String("Cannot create snapshot: \(msg)")
        case let .reconcileFailure(msg):
            return String("Reconcile failure: \(msg)")
        }
    }
}
