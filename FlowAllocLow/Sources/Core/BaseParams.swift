//
//  BaseParams.swift
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

public struct BaseParams: Hashable, Codable, CustomStringConvertible {
    public var accountKeys: [AccountKey]
    public var assetKeys: [AssetKey]
    public var flowMode: Double
    public var isStrict: Bool
    public var fixedAccountKeys: [AccountKey]

    public init(accountKeys: [AccountKey] = [],
                assetKeys: [AssetKey] = [],
                flowMode: Double = 0.0,
                isStrict: Bool = false,
                fixedAccountKeys: [AccountKey] = [])
    {
        self.accountKeys = accountKeys
        self.assetKeys = assetKeys
        self.flowMode = flowMode
        self.isStrict = isStrict
        self.fixedAccountKeys = fixedAccountKeys
    }

    private enum CodingKeys: String, CodingKey, CaseIterable {
        case accountKeys
        case assetKeys
        case flowMode
        case isStrict
        case fixedAccountKeys
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        accountKeys = try c.decode([MAccount.Key].self, forKey: .accountKeys)
        assetKeys = try c.decode([MAsset.Key].self, forKey: .assetKeys)
        flowMode = try c.decode(Double.self, forKey: .flowMode)
        isStrict = try c.decode(Bool.self, forKey: .isStrict)
        fixedAccountKeys = try c.decode([MAccount.Key].self, forKey: .fixedAccountKeys)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(accountKeys, forKey: .accountKeys)
        try c.encode(assetKeys, forKey: .assetKeys)
        try c.encode(flowMode, forKey: .flowMode)
        try c.encode(isStrict, forKey: .isStrict)
        try c.encode(fixedAccountKeys, forKey: .fixedAccountKeys)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(accountKeys)
        hasher.combine(assetKeys)
        hasher.combine(flowMode)
        hasher.combine(isStrict)
        hasher.combine(fixedAccountKeys)
    }

    public func validate(epsilon: Double = 0.0001) throws {
        guard accountKeys.count > 0 else { throw AllocLowError2.invalidParams("missing accounts") }
        guard assetKeys.count > 0 else { throw AllocLowError2.invalidParams("missing allocation") }
        guard (0.0 ... 1.0).contains(flowMode) else { throw AllocLowError2.invalidParams("flowMode must be in range 0...1 [\(description)]") }
    }

    public var description: String {
        ["accountKeys: \(accountKeys))",
         "assetKeys: \(assetKeys))"].joined(separator: "; ")
    }

    // update with new indexes, trying to preserve order where possible
    mutating public func update(nuAccountKeys: [AccountKey],
                                nuAssetKeys: [AssetKey],
                                nuFixedAccountKeys: [AccountKey])
    {
        if Set(nuAccountKeys) != Set(accountKeys) {
            //print("flowParams: updating \(nuAccountKeys)")
            accountKeys = nuAccountKeys
        }

        if Set(nuAssetKeys) != Set(assetKeys) {
            //print("flowParams: updating \(nuAssetKeys)")
            assetKeys = nuAssetKeys
        }

        if Set(nuFixedAccountKeys) != Set(fixedAccountKeys) {
            //print("surgeParams: updating \(nuFixedAccountKeys)")
            fixedAccountKeys = nuFixedAccountKeys
        }
    }
}

extension BaseParams: Equatable {
    public static func == (lhs: BaseParams, rhs: BaseParams) -> Bool {
        lhs.accountKeys == rhs.accountKeys &&
            lhs.assetKeys == rhs.assetKeys &&
            lhs.flowMode == rhs.flowMode &&
            lhs.isStrict == rhs.isStrict &&
            lhs.fixedAccountKeys == rhs.fixedAccountKeys
    }
}

extension BaseParams: Comparable {
    public static func < (lhs: BaseParams, rhs: BaseParams) -> Bool {
        lhs.flowMode < rhs.flowMode
    }
}
