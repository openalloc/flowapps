//
//  AllocatLowError2.swift
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


//TODO combine with AllocLowError1
public enum AllocLowError2: Error, Equatable, CustomStringConvertible {
    case generalFailure(_ msg: String)
    case invalidContext(_ msg: String) // TODO: _ implicit param name
    case invalidConfig(_ msg: String)
    case invalidParams(_ msg: String)
    case invalidShareCount(_ shareCount: Double)
    case invalidSharePrice(_ sharePrice: Double)
    case invalidShareBasis(_ shareBasis: Double)
    case invalidTransactedAt(_ transactedAt: String)
    case missingAssetClassForSecurity(_ securityID: String)
    case unrecognizedAccount(_ accountID: AccountID)
    case unrecognizedSecurity(_ security: MSecurity)
    case encodingError(_ msg: String)
    case decodingError(_ msg: String)
    case decodingKeyError(key: String, classType: String, _ msg: String)
    case importError(_ msg: String)
    case exportError(_ msg: String)
    case rejectedDuplicate(_ msg: String)
    case missingContext(_ msg: String)
    case missingStrategy(_ msg: String)
    case summarizationFailure
    case invalidStorageKey(_ key: String)

    public var localizedDescription: String { description }

    public var description: String {
        switch self {
        case let .generalFailure(msg):
            return String(msg)
        case let .invalidContext(msg):
            return String("Invalid context: \(msg)")
        case let .invalidConfig(msg):
            return String("Invalid config: \(msg)")
        case let .invalidParams(msg):
            return String("Invalid params: \(msg)")

        case let .invalidShareCount(val):
            return String("Invalid share count: \(val.format2()).")
        case let .invalidSharePrice(val):
            return String("Invalid share price: \(val.format2()).")
        case let .invalidShareBasis(val):
            return String("Invalid share price: \(val.format2()).")
        case let .invalidTransactedAt(val):
            return String("Invalid share price: \(val).")

        case let .missingAssetClassForSecurity(securityID):
            return String("Missing asset class for security '\(securityID)'.")
        case let .unrecognizedAccount(accountID):
            return String("Accounts does not contain '\(accountID)'.")
        case let .unrecognizedSecurity(security):
            return String("Securities does not contain '\(security)'.")
        case let .encodingError(msg):
            return String("Failure to encode. \(msg)")
        case let .decodingError(msg):
            return String("Failure to decode. \(msg)")
        case let .decodingKeyError(key, classType, msg):
            return String("Failure to decode '\(key)' in \(classType). \(msg)")
        case let .importError(msg):
            return String("Failure to import. \(msg)")
        case let .exportError(msg):
            return String("Failure to export. \(msg)")
        case let .rejectedDuplicate(msg):
            return String("Rejected duplicate. \(msg)")
        case let .missingContext(msg):
            return String("Missing context. \(msg)")
        case let .missingStrategy(msg):
            return String("Missing strategy. \(msg)")
        case .summarizationFailure:
            return String("Unable to summarize results of allocation.")
        case let .invalidStorageKey(key):
            return String("Invalid storage key '\(key)'.")
        }
    }
}
